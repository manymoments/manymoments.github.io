---
title: Commit-Notify - Synchronous Consensus under Omission Faults
date: 2020-09-05 03:10:00 -07:00
published: false
tags:
- dist101
- SMR
author: Kartik Nayak, Ittai Abraham
---

We continue our series of posts on [State Machine Replication](https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/) (SMR). In this post, we move from consensus under [crash failures](https://decentralizedthoughts.github.io/2019-11-01-primary-backup/) to consensus under [omission failures](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/). We still keep the [synchrony](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) assumption.

Let's begin with a quick overview of what we covered in previous posts:

1. [Upper bound](https://decentralizedthoughts.github.io/2019-11-01-primary-backup/): We can tolerate up to $n-1$ crash failures.

2. [Lower bound](https://decentralizedthoughts.github.io/2019-11-02-primary-backup-for-2-servers-and-omission-failures-is-impossible/): The best we can hope for is to tolerate less than $n/2$ omission failures.






### Recap: Primary-Backup for $n$ Replicas Under Crash Faults

In the crash model, the primary behaves as an ideal state machine until it crashes. If it does crash, the backup takes over the execution to continue serving the clients. To provide the clients with an interface of a single non-faulty server, the primary sends client commands to all backups before updating the state machine and responding to the client. The backups passively replicate all the commands sent by the primary. In case the primary fails, which is detected by the absence of a "heartbeat", the next designated backup replica $j$ invokes a ("view change", $j$) to all replicas along with the last command sent by the primary in view $j-1$. It then becomes the primary.

For completeness, we repeat the primary-backup pseudocode below for $n$ replicas with identifiers ${0,1,2,\\dots,n-1}$.

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

## The two choices for safety

There are two different ways to solve this problem:
1. The *lock-commit* (asynchrony) approach: **before** you commit to $x$, make sure that at least $n-f$ non-faulty replicas received a lock on $x$. Since any later view change will hear from $n-f$ parties, then quorum intersection will guarantee to hear from at least one party locked on $x$. We will cover the lock-commit approach in the next post - it is the core idea behind [Paxos]()!

2. The *commit-notify* (synchrony) approach: **after** you commit to $x$, send to all a notify of $x$. Make sure the view change waits sufficient time for the notify echo to arrive. Since any later view change will hear from $n-f$ parties, then quorum intersection will be guaranteed to hear from at least one party that heard the notify of $x$.


A clear advantage of the commit-notify approach is that the commit happens one round earlier!
Note that the second path also comes with several disadvantages:
1. Safety depends on synchrony. This is similar to [Dolev-Strong]().
2. Safety is only guaranteed for non-faulty replicas: A replica may commit and then crash before any notify message is sent.



## commit-notify in the steady state:

We  detail the steady-state protocol tolerating omission failures under a fixed primary; we later discuss the view-change protocol.

    // Replica j

    state = init // the state of the state machine
    log = []     // the log of committed commands
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

We make an important observation wrt the steady state protocol: *If a non-faulty replica commits a cmd at seq-no at time $t$, then any non-faulty replicas that has not quit the current view will commit within time $t+\Delta$.* This is simply because it will receive the forwarded proposal by time $t+\Delta$.

The commit-notify aspect will be clearer after we explain the view-change protocol.



## commit-notify, changing view with synchrony:



**View-change protocol:**

The key challenge is the following: what if a non-faulty replica decides and adds a command to its log, and immediately after that the new primary sends a different command for the same seq-no. The notify-forward message will arrive too late!

The solution is to make sure that the new primary starts the new view at least $\Delta$ time after any replica decides and adds a command to its log. By that time all replicas will have received the forwarded notify message and will also add this command to their log.


There is a small twist: the observation above implies that to maintain safety, a replica must wait for $2\Delta$ before starting a new view (we will explain why 2 below). Let's describe the view-change protocol:

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

1. *If a non-faulty replica quits view (or enters the next view) at time $t$, all non-faulty replicas quit view (or enter the next view) by time $< t+\Delta$.* This is simply because of forwarding of the f+1 "no heartbeat" messages, which arrive within $\Delta$ time. 

2. **Commit-Notify Lemma**: *If a non-faulty replica $r$ commits a cmd at seq-no at time $t$, then for all non-faulty replicas $r'$, either they will have committed cmd at seq-no before entering the next view or (highest-cmd, highest-seq-no) = (cmd, seq-no).* If $r'$ does not quit view by time $t+\Delta$, then it will commit cmd (follows from the previous observation). For the other part, observe that $r'$ could not have quit view before time $t-\Delta$, otherwise replica $r$ would then have quit view before time $t$ and not committed cmd. Thus, $r'$ has quit view at time $> t-\Delta$ and entered the next view at time $> t+\Delta$. This time is sufficient for $r'$ to receive the notification from $r$. Moreover, since we assume that the client sends the next command after the previous one has been committed, any honest replica will not have committed a command with a higher sequence number in this view. Thus, $r'$ will have (highest-cmd, highest-seq-no) = (cmd, seq-no) before entering the next view.

3. Talk about status ensuring the next leader will pick the last command again!
