---
title: Synchronous Consensus Omission Faults
published: false
author:
- Kartik Nayak
- Ittai Abraham
Field name: 
---

We continue our series of posts on [State Machine Replication](https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/) (SMR). In this post, we move from consensus under [crash failures](https://decentralizedthoughts.github.io/2019-11-01-primary-backup/) to consensus under [omission failures](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/). We still keep the [synchrony](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) assumption.

Let's begin with a quick overview of what we covered in previous posts:

1. [Upper bound](https://decentralizedthoughts.github.io/2019-11-01-primary-backup/): We can tolerate up to $n-1$ *crash* failures.

2. [Lower bound](https://decentralizedthoughts.github.io/2019-11-02-primary-backup-for-2-servers-and-omission-failures-is-impossible/): The best we can hope for is to tolerate less than $n/2$ *omission* failures.






### Recap: Primary-Backup for $n$ Replicas Under Crash Faults

In the crash model, the primary behaves as an ideal state machine until it crashes. If it does crash, the backup takes over the execution to continue serving the clients. To provide the clients with an interface of a single non-faulty server, the primary sends client commands to all backups before updating the state machine and responding to the client. The backups passively replicate all the commands sent by the primary. In case the primary fails, which is detected by the absence of a "heartbeat", the next designated backup replica $j$ invokes a ("view change", $j$) to all replicas along with the last command sent by the primary in view $j-1$. It then becomes the primary.

For completeness, we repeat the primary-backup pseudocode below for $n$ replicas with identifiers ${0,1,2,\dots,n-1}$.

    // Replica j

    state = init
    log = []
    view = 0
    while true:

       // as a primary
       on receiving cmd from a client library (and view == j):
          send cmd to all replicas
          log.append(cmd)
          state, output = apply(cmd, state)
          send output to the client library

       // as a backup
       on receiving cmd from replica[view]:
          log.append(cmd)
          state, output = apply(cmd, state)

       // heartbeat from primary
       if no client message for some predetermined time t (and view == j):
          send ("heartbeat", j) to all replicas (in order)

       // view change
       on missing "heartbeat" or cmd from replica[view] in the last t + $\Delta$ time units:
          view = view + 1
          if view == j // I am the leader
             send ("view change", j) to all client libraries
             send resend to all replicas (in order)

Can we use the above protocol under omission failures? ... unfortunately not! This is due to a big difference between crash and omission failures. With crash failures you know who is faulty: if a message does not arrive you know the sender has crashed. With omission failures, you don't know if a missed message is due to a faulty  sender or faulty receiver. So a replica may be faulty without knowing its faulty.

With  omission failures, a faulty primary may omit messages to the replicas, then send a message to the client, then crash. So a client receives 'cmd', but there is no backup replicating the command. So how can you commit safely?

##  Two choices for safety: lock-commit vs commit-notify

There are two different ways to solve this problem:
1. The *lock-commit* (asynchrony) approach: **before** you *commit* to $x$, make sure that at least $n-f$ non-faulty replicas received a *lock* on $x$. Since any later view change will hear from $n-f$ parties, then quorum intersection will guarantee to hear from at least one party locked on $x$. We will cover the lock-commit approach in the next post - it is the core idea behind [Paxos](https://lamport.azurewebsites.net/pubs/lamport-paxos.pdf)!

2. The *commit-notify* (synchrony) approach: **after** you *commit* to $x$, send to all a *notify* of $x$. In addition, make sure the view change waits sufficient time for the notify to arrive. Since any later view change will hear from $n-f$ parties, then quorum intersection will guaranteed to hear from at least one party that heard the notify of $x$.


A clear advantage of the commit-notify approach is that the commit happens one round earlier!
Note that commit-notify also comes with several disadvantages:
1. Safety depends on synchrony. This is similar to [Dolev-Strong](https://decentralizedthoughts.github.io/2019-12-22-dolev-strong/).
2. Safety is only guaranteed for non-faulty replicas: A replica may commit and then crash before any notify message is sent.

**Simplifying assumption: single shot.** To simplify the presentation we will focus on just *one* decision, not a sequence of decisions. [In the next post](...) we will show how to extend this to multi-shot agreement.


## Commit-notify: in the steady state

We  detail the steady-state protocol tolerating omission failures under a fixed primary; we later discuss the view-change protocol.

    // Replica j

    state = init // the state of the state machine
    log = []     // a log (of size 1) of committed commands
    view = 0     // view number that indicates the current Primary
    active == true // is the replica active in this view
    my-cmd == empty // command from client

    while true:
       // as a primary receiving from client
       on receiving cmd from a client library:
          if a "notify" message has not been sent in this view:
            send ("notify", cmd, view) to all replicas

       // as a primary or backup replica
       on receiving cmd from a client library and my-cmd is not empty: or
       on receiving ("notify", cmd, view) from any replica:
        if a "notify" message has not been sent in this view:
          send ("notify", cmd, view) to all replicas
          my-cmd :=  cmd

          if active == true and log[0] is empty: // if the replica did not decide yet
             // commit
             log[0] := cmd
             state, output = apply(cmd, state)
             send output to the client library
             // notify


In the steady state protocol, the primary receives commands from the client. It sends the command to every replica through ("notify", cmd, view) message. On receiving a ("notify", cmd, view) message, a replica does the following: (1) it updates its my-cmd variable; (2) if it did not send notify this view, then sends notify ; (3) if its active in the view, it commits my-cmd.

The commit-notify step ensures that if $r$ commits, all non-faulty replicas are notified within $\Delta$ time:
**Claim 1:** *If a non-faulty replica commits a cmd at time $t$, then any non-faulty replicas that is active in the current view by time $t+\Delta$ will commit within time $t+\Delta$.*

*Proof:* This is simply because it will receive the forwarded notify by time $t+\Delta$.

Now we need to detail the mechanism for changing views


## commit-notify: changing view with synchrony

       // blame the current leader
       on missing a notify from replica[view] in the last t + $\Delta$ time units:
          send ("blame", view) to all replicas

       // as a primary or backup
       on receiving ("blame", view) from f+1 replicas for the current view:
          // make other replicas quit view and wait to be notified of their commits
          send ("quit view", view) messages to all replicas
          active := false
          wait $2\Delta$ time
          // switch to new view and send status to new leader
          view := view + 1
          active := true
          send ("status", my-cmd, view) to replica[view]
          send ("primary change", view-1) to all client libraries
          // backups transition to steady state

       // new primary
       on receiving ("status", cmd, view) from f+1 distinct replicas and j== view:
          pick the (highest-cmd, highest-view) pair with the highest view
          send ("notify", highest-cmd, view) to all replicas (in order)



The view-change protocol works as follows. If a replica does not receive a notify from the primary for a sufficient amount of time, it sends a "blame" message to all replicas. Any replica, on receiving "blame" messages from $f+1$ distinct replicas will quit view and forward this message to all other replicas. After quitting the view, the replicas wait for some time ($2\Delta$ time) to receive any notifications from the commit of a non-faulty replica (we will explain the magic $2\Delta$ number soon). After that, it enters the new view, notifies the new primary of its (highest-cmd, highest-view) through a status message,
notifies client libraries of the primary change and
then transitions to the steady state. The new primary, on receiving a status from $f+1$ distinct replicas, picks a cmd with the highest-view and proposes it to all replicas. It then transitions to the steady state.

we begian by observing that view changing of non-faulty replicas are at most $\Delta$ apart:

**Cliam 2:** *If a non-faulty replica quits view (or enters the next view) at time $t$, all non-faulty replicas quit view (or enter the next view) by time $< t+\Delta$.*

*Proof:* This is simply because of forwarding of the "quit view" message, which arrive within $\Delta$ time.

We are now ready for the key safety claim:

**Commit-Notify Safety:** *If a non-faulty replica $r$ commits cmd in view $v$, then for any non-faulty replicas $r'$, for any view $v'>v$ we have that its $(highest-cmd, highest-view)$ is such that $highest-cmd==cmd$ and $highest-view \geq v$M.*

*Proof:* Since $r$ is non-faulty if will sends a notify to all replicas. If $r'$ is active or passive in view $v$, then it will send a notify and update its (highest-cmd, highest-view). Why $2\Delta$: note that $r'$ must leave the view at most $\Delta$ time before $r$ commits (because otherwise $r$ would have become inactive) - but since $r'$ waits $2\Delta$ then it must hear $r$ notify before moving to view $v+1$.

We have shown that all non-faulty parties entering view $v+1$ have desired property. We can now continue by induction on the views: since the primary must wait for $n-f$ responses, then it must hear from at least one non-faulty party and since it chooses the highest view, it must choose the value cmd.


# POST TWO: Multi-Shot Commit-Notify




    // Replica j

    state = init // the state of the state machine
    log = []     // a log (of size 1) of committed commands
    view = 0     // view number that indicates the current Primary
    seq-no = 0
    highest-seq-no = 0
    highest-cmd = null

    while true:
       // as a primary receiving from client
       on receiving cmd from a client library:
          send ("propose", cmd, seq-no) to all replicas

       // as a primary or backup replica
       on receiving ("propose", cmd, seq-no') from any replica:
          if seq-no' == seq-no: // if the replica is at the same sequence number
             send ("propose", cmd, seq-no) to all replicas (if it has not been sent earlier)
             // commit
             log.append(cmd)
             state, output = apply(cmd, state)
             send output to the client library
             // notify
             send ("notify", cmd, seq-no) to all replicas
             seq-no = seq-no + 1

       // as a primary or backup replica
       on receiving ("notify", cmd, seq-no) from any replica:
          // store the highest seq-no and cmd
          if seq-no > highest-seq-no:
             highest-cmd, highest-seq-no = cmd, seq-no

       // Heartbeat from primary
       if no client message for some predetermined time t (and view == j):
          send ("heartbeat", j) to all replicas (in order)

In the steady state protocol, the primary receives commands from the client. It sends the command to every replica through ("propose", cmd, seq-no) message. The sequence number seq-no keeps track of the ordering of messages. On receiving a ("propose", cmd, seq-no') message, a replica does the following. It checks if the cmd is at the next sequence number that it expects a command from. This ensures that it does not process the same cmd/seq-no multiple times. If it is the expected seq-no, it (i) forwards the proposal to all replicas and then (ii) performs the commit-notify step. If the backup replica $r$ is non-faulty, proposal forwarding ensures that all honest replicas receive the proposal, *even if* the primary is omission faulty. The commit-notify step ensures that if $r$ commits, all non-faulty replicas are notified within $\Delta$ time. On receiving a ("notify", cmd, seq-no) message, every replica maintains the (cmd, seq-no) pair for the highest-seq-no ever received. The primary then waits to receive the next command from the client. If it does not receive a command for a predetermined amount of time, then it sends a ("heartbeat", j) message to all replicas.

We make a couple of important observation wrt the steady state protocol:

**Claim 1:** *If a non-faulty replica commits a cmd at seq-no at time $t$, then any non-faulty replicas that has not quit the current view by time $t+\Delta$ will commit within time $t+\Delta$.*

*Proof:* This is simply because it will receive the forwarded proposal by time $t+\Delta$.

**Claim 2:** *If an non-fauly replica $r'$ commits a cmd at seq-no, but some non-faulty replica $r$ does not commit it at time $t$, then a new client command for seq-no + 1 will not be committed by any non-faulty replica by time $t+\Delta$ in the same view.*

*Proof:* We will consider two cases depending on whether replica $r$ has quit view before time $t$. Suppose it has not. Then, due to the previous observation, any non-faulty $r'$ must have committed after $t-\Delta$. Due to our assumption, the client sends the next command $\geq 2\Delta$ time after receiving $f+1$ commits from the replicas. Among these $f+1$ commits, at least one of them belongs to a non-faulty replica. The client receives $f+1$ commit notifications after $t-\Delta$. Consequently, it does not send the next command before time $t+\Delta$. On the other hand, if replica $r$ has quit view before time $t$, then all non-faulty replicas will learn about the view change by $t+\Delta$ and they will not vote for a new command sent by the client in the same view.

The commit-notify aspect will be clearer after we explain the view-change protocol.



## commit-notify: changing view with synchrony

       // blame the current leader
       on missing "heartbeat" or a proposal from replica[view] in the last t + $\Delta$ time units:
          send ("no heartbeat", view) to all replicas

       // as a primary or backup
       on receiving ("no heartbeat", view) from f+1 replicas for the current view:
          // make other replicas quit view and wait to be notified of their commits
          forward the f+1 ("no heartbeat", view) messages to all replicas
          stop participating in this view except for acting on notify message received for $2\Delta$ time
          // switch to new view and send status to new leader
          view = view + 1
          send ("status", view, highest-cmd, highest-seq-no) to replica[view]
          send ("view-change", view-1) to all client libraries
          // backups transition to steady state

       // new primary
       on receiving ("status", view', highest-cmd, highest-seq-no) from f+1 distinct replicas:
          pick the (highest-cmd, highest-seq-no) pair with the highest seq-no
          send ("propose", highest-cmd, highest-seq-no) to all replicas (in order)
          transition to steady state





The view-change protocol works as follows. If a replica does not receive a heartbeat from the primary for a sufficient amount of time, it sends a "no heartbeat" message to all replicas. Any replica, on receiving "no heartbeat" messages from $f+1$ distinct replicas will quit view and forward this message to all other replicas. After quitting the view, the replicas wait for some time ($2\Delta$ time) to receive any notifications from the commit of a non-faulty replica (we will explain the magic $2\Delta$ number soon). After that, it enters the new view, notifies the new primary of its (highest-cmd, highest-seq-no) through a status message, notifies client libraries of the view-change and then transitions to the steady state. The new primary, on receiving a status from $f+1$ distinct replicas, picks a cmd with the highest-seq-no and proposes it to all replicas. It then transitions to the steady state.

We make a few important observations here:

**Cliam 3:** *If a non-faulty replica quits view (or enters the next view) at time $t$, all non-faulty replicas quit view (or enter the next view) by time $< t+\Delta$.*

*Proof:* This is simply because of forwarding of the f+1 "no heartbeat" messages, which arrive within $\Delta$ time.

**Commit-Notify Lemma:** *If a non-faulty replica $r$ commits a cmd at seq-no at time $t$, then for all non-faulty replicas $r'$, either they will have committed cmd at seq-no before entering the next view or (highest-cmd, highest-seq-no) = (cmd, seq-no).*

*Proof:* If $r'$ does not quit view by time $t+\Delta$, then it will commit cmd (follows from the previous observation). For the other part, observe that $r'$ could not have quit view before time $t-\Delta$, otherwise replica $r$ would then have quit view before time $t$ and not committed cmd. Thus, $r'$ has quit view at time $> t-\Delta$ and entered the next view at time $> t+\Delta$. This time is sufficient for $r'$ to receive the notification from $r$. Moreover, due to the second observation in the steady state, any non-faulty replica will not have committed a command with a higher sequence number in this view. Thus, $r'$ will have (highest-cmd, highest-seq-no) = (cmd, seq-no) before entering the next view.

**Claim 4:** *If a non-faulty replica commits cmd at sequence number seq-no, then a primary in the subsequent view cannot propose $cmd' \neq cmd$ at seq-no.*

*Proof:* Based on the previous observation, all non-faulty replicas will have been notified of cmd at seq-no. Moreover, due to the second observation in the steady state, the client would not have sent a command for a higher sequence number. Thus, all non-faulty replicas will send the same (highest-cmd, highest-seq-no) pairs whereas faulty replicas cannot send a higher pair. Since, the new primary waits for f+1 distinct status messages, at least one of them will be from a non-faulty replica.
