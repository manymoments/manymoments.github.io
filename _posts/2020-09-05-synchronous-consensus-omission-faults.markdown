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
    acks = []
    seq-no = 0

    while true:
       // as a primary receiving from client
       on receiving cmd from a client library:
          if acks[seq-no] == 0 // seq-no is available
             send ("propose", cmd, seq-no) to all replicas
             acks[seq-no] = acks[seq-no] + 1

       // as a backup replica
       on receiving ("propose", cmd, seq-no') from any replica:
          if seq-no' == seq-no: // if the replica is at the same sequence number
             send ("propose", cmd, seq-no) to all replicas
             // commit
             log.append(cmd)
             state, output = apply(cmd, state)
             send output to the client library
             // notify
             send ("notify", cmd, seq-no) to all replicas
             seq-no = seq-no + 1
       
       on receiving ("notify", cmd, seq-no) from any replica:
          // store the highest seq-no and cmd
          if seq-no > highest-seq-no:
             highest-cmd, highest-seq-no = cmd, seq-no

       // Heartbeat from primary
       if no client message for some predetermined time t (and view == j):
          send ("heartbeat", j) to all replicas (in order)

In the steady state protocol, the primary receives commands from the client. It sends the command to every replica through ("propose", cmd, seq-no) message. The sequence number seq-no keeps track of the ordering of messages. It also marks itself as processing the current command.

A backup replica, on receiving a ("propose", cmd, seq-no) from the current primary, ....

It also *notifies* the backup replicas about the commit, who can then add the command to their logs and execute it. To keep all backup replicas in sync, backups also *forward* the notify message.



The primary then waits to receive the next command from the client. If it does not receive a command for a predetermined amount of time, then it sends a ("heartbeat", j) message to all replicas.





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





The view-change protocol works as follows. If a replica does not receive a heartbeat from the primary for a sufficient amount of time, it sends a "no heartbeat" message to the primary of the next view. The new primary, on receiving "no heartbeat" messages from a majority of replicas, initiates a view change by sending a "view-change" message. It stops participating in this view.

On receiving a "view-change" message, every replica first forwards the view-change message to every other replica. In order to stay in sync with other non-faulty replicas who may not have received a view-change message at the same time and may be making progress, it waits for some time (turns out $2\\Delta$ time suffices)

//ITTAI UPDATE THIS

to update its locks or notifications. It then stops participating in the view, and sends its status consisting of the highest seq-no and an outstanding command (lock), if there is one, to the next leader. It then transitions to the steady state.

The next primary, on obtaining the status message from a majority of replicas (including itself), picks the lock corresponding to the highest sequence number. Recall that there can be at most one outstanding command at any time, and this command, if it exists, is the lock corresponding to the highest seq-no. Thus, the next primary proposes this command, if it exists, to all replicas and then transitions to the steady state.

Let us review some important aspects of this protocol:

* **Safety:** ...

* **Liveness:** KARTIK: IS THERE A LIVENESS CONCERN WITH AN OMISSION FAULT GOING ONE AHEAD OF ALL HONEST REPLICAS? e.g., ALL HONEST REPLICAS ARE LOCKED AT SEQ-NO 10. The faulty primary notifies a faulty replica of a commit and this message is received by the next leader in the status message. The next leader assumes that this command has been committed and does not re-propose.

* By design, the protocol described above processes one command at a time. This restriction ensures that there is at most one outstanding command in a view, simplifying the view-change process. In practical settings, this is too restrictive. In later posts, to lift this restriction, we will either extend our locks to lock on multiple values and handle them in our view-change, or we will hash-chain commands.

* In the protocol, the replicas do not process commands in parallel (or out-of-order) either. Due to the synchrony assumption, non-faulty replicas are not affected by this constraint. However, the protocol does not attempt to keep the omission faulty replicas synchronized. Such a synchronization needs to be performed separately. We will relax this constraint and deal with this concern in a later post when we describe a protocol in the asynchronous setting.
