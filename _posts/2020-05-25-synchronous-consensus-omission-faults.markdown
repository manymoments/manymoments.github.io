---
title: Synchronous Consensus under Omission Faults
date: 2020-05-25 03:10:00 -07:00
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

We first go over the upper bound for crash failures. Then see what goes wrong when the failures are omission and how we can fix the protocol.

### Primary-Backup for $n$ Replicas Under Crash Faults

Recall that in the crash model, the primary behaves exactly like an ideal state machine until it crashes. If it does crash, the backup takes over the execution to continue serving the clients. To provide the clients with an interface of a single non-faulty server, the primary sends client commands to all backups before updating the state machine and responding to the client. The backups passively replicate all the commands sent by the primary. In case the primary fails, which is detected by the absence of a "heartbeat", the next designated backup replica $j$ invokes a ("view change", $j$) to all replicas along with the last command sent by the primary in view $j-1$. It then becomes the primary.

For completeness, we repeat the primary-backup pseudocode below. Assume $n$ replicas with identifiers ${0,1,2,\\dots,n-1}$.

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

Can we use the above protocol under omission failures? No! Here is where the protocol fails:

1. In the above protocol, the primary sends the command `cmd` to all backup replicas and then immediately executes the state machine (executing `apply(cmd, state)`) and responds to the client library. Under omission failures, it may so happen that the primary is faulty and no replica has received `cmd`. If all the messages of the primary are blocked subsequently, then there will not be any backup replicating the command sent by it.

2. When a backup needs to invoke a view-change to become the new primary, it may not know the last command that was executed. Simply maintaining a "lock" variable consisting of the last command does not suffice since the last few commands may not have been received by a backup replica.

To deal with the first problem, how can a primary know if its message was sent to a sufficient number of replicas? By waiting to hear an acknowledgment! But even if the primary is non-faulty and sends a message to all replicas, how many acknowledgments can it wait for without losing liveness? Clearly, it cannot wait for more than $n-f$! Hence, in our protocol, the primary waits for a majority of acknowledgments.

Here's how we deal with the second problem. When the faulty primary hears from a majority of replicas, it can so happen that for a given command cmd1, its request is only sent to one non-faulty replica, say replica $r_1$, and all other faulty replicas. For the next command cmd2, its request arrives at a different non-faulty replica, say replica $r_2$, and all other faulty replicas. Since replica $r_2$ does not know of the existence of cmd1, to ensure that all non-faulty replicas have an identical log, we need to be careful about how replica $r_2$ responds to the primary. Observe that this concern arises only when we want to achieve consensus on multiple commands, and not for consensus on a single command. Our solution addresses this concern by keeping all non-faulty replicas in sync: if a non-faulty replica receives a message from the leader, it forwards this message to all other replicas. This ensures that, even if the primary is faulty, if its message reaches some non-faulty replica, then all non-faulty replicas know about it. Thus, we still have the invariant that there is at most one outstanding command stored in the "lock" variable.

## Primary-Backup for $n$ Replicas Under Omission Faults

**Steady-state protocol.** We now explain the steady-state protocol tolerating omission failures under a fixed primary; we will later discuss the view-change process.

    // Replica j
    
    state = init // the state of the state machine
    log = []     // the log of committed commands
    view = 0     // view number that indicates the current Primary
    acks = []
    seq-no = 0
    
    while true:
       // as a primary
       on receiving cmd from a client library (and view == j):
          send ("propose", cmd, seq-no) to all replicas
    
       on receiving ("vote", cmd, seq-no') from a backup replica r:
          if seq-no == seq-no':
             acks[seq-no] = acks[seq-no] + 1
             if acks[seq-no] > n/2:
                log.append(cmd)
                state, output = apply(cmd, state)
                send output to the client library
                send ("notify", cmd, seq-no) to all replicas
                seq-no = seq-no + 1
      
       // as a backup
       on receiving ("propose", cmd, seq-no') from replica[view] or ("propose-forward", cmd, seq-no') from some replica:
          if seq-no' == seq-no: // if the replica is at the same sequence number and has not already voted for this command
             send ("vote", cmd, seq-no) to replica[view]
             send ("propose-forward", cmd, seq-no) to all replicas // forward the command to all replicas
    
       on receiving ("notify", cmd, seq-no') or ("notify-forward", cmd, seq-no') from any replica:
          if seq-no' == seq-no:
             log.append(cmd)
             state, output = apply(cmd, state)
             send ("notify-forward", cmd, seq-no) to all replicas
             seq-no = seq-no + 1
    
       // Heartbeat from primary
       if no client message for some predetermined time t (and view == j):
          send ("heartbeat", j) to all replicas (in order)

In the steady state protocol, the primary receives commands from the client. If the primary is not currently processing a command, it sends the command to every replica through ("propose", cmd, seq-no) message. The sequence number seq-no keeps track of the ordering of messages. It also marks itself as processing the current command.

A backup replica, on receiving a ("propose", cmd, seq-no) from the current primary, or a forwarded proposal, if it has not already voted for this seq-no, sends a ("vote", cmd, seq-no) message back to the primary. To keep all backup replicas in sync, it forwards the leader proposal to all other replicas. 

If the primary receives votes from a majority of replicas, the primary can add the command to the log, execute it, and send an output to the client. It also notifies the backup replicas about the commit, who can then add the command to their logs and execute it. To keep all backup replicas in sync, backups also forward the notify message. 

The primary then waits to receive the next command from the client. If it does not receive a command for a predetermined amount of time, then it sends a ("heartbeat", j) message to all replicas.

The key observation here is the following: if a non0fualty replica commits and the new primary starts the new view after $\Delta$ time, then by that time all replicas will have received the forwarded notify message.

**View-change protocol:** The observation above simple that to maintain safety, a replica should wait for $2\Delta$ before starting a new view.
We now describe the view-change protocol:

       // blame the current leader
       on missing "heartbeat" or a proposal from replica[view] in the last t + $\Delta$ time units:
          send ("no heartbeat", view) to replica[view + 1]
    
       // new primary
       on receiving ("no heartbeat", view) from f+1 replicas (and view == j-1):
          send ("view-change", view) to all replicas
          send ("view-change", view) to all client libraries
          stop participating in this view; set view = view + 1
    
       // as a backup
       on receiving ("view-change", view') from replica[view'+1] or ("view-change-forward", view') from any replica (and view' >= view):
          send ("view-change-forward", view') to all replicas
          stop participating in this view
          wait for $2\Delta$ time units to hear about any notifications   
          send ("status", view', lock, seq-no) to replica[view'+1]
          set view = view' + 1, transition to steady state
       
       // new primary: proposes the highest-view-lock
       on receiving ("status", view', lock, seq-no) from f+1 distinct replicas (and view' == j):
          highest-lock, seq-no = pick the (lock, seq-no) pair with the highest seq-no
          if highest-lock != none:
            send ("propose", highest-lock, seq-no) to all replicas (in order)
            lock = highest-lock
          transition to steady state

The view-change protocol works as follows. If a replica does not receive a heartbeat from the primary for a sufficient amount of time, it sends a "no heartbeat" message to the primary of the next view. The new primary, on receiving "no heartbeat" messages from a majority of replicas, initiates a view change by sending a "view-change" message. It stops participating in this view.

On receiving a "view-change" message, every replica first forwards the view-change message to every other replica. In order to stay in sync with other non-faulty replicas who may not have received a view-change message at the same time and may be making progress, it waits for some time (turns out $2\\Delta$ time suffices) to update its locks or notifications. It then stops participating in the view, and sends its status consisting of the highest seq-no and an outstanding command (lock), if there is one, to the next leader. It then transitions to the steady state.

The next primary, on obtaining the status message from a majority of replicas (including itself), picks the lock corresponding to the highest sequence number. Recall that there can be at most one outstanding command at any time, and this command, if it exists, is the lock corresponding to the highest seq-no. Thus, the next primary proposes this command, if it exists, to all replicas and then transitions to the steady state.

Let us review some important aspects of this protocol:

* **Safety:** If a primary commits a value, a majority of the replicas will lock on this value. In fact, in our protocol, since non-faulty replicas are always in sync, all non-faulty replicas lock on this value before they end their view. Since the primary in the next view receives a status from a majority of replicas, if the command is not executed in the previous view, the new primary will obtain this lock. Observe that a lock at a higher sequence number does not exist. This is because replicas only process commands one at a time, and none of the non-faulty replicas will vote for a subsequent command until the locked command is executed.

* **Liveness:** KARTIK: IS THERE A LIVENESS CONCERN WITH AN OMISSION FAULT GOING ONE AHEAD OF ALL HONEST REPLICAS? e.g., ALL HONEST REPLICAS ARE LOCKED AT SEQ-NO 10. The faulty primary notifies a faulty replica of a commit and this message is received by the next leader in the status message. The next leader assumes that this command has been committed and does not re-propose.

* By design, the protocol described above processes one command at a time. This restriction ensures that there is at most one outstanding command in a view, simplifying the view-change process. In practical settings, this is too restrictive. In later posts, to lift this restriction, we will either extend our locks to lock on multiple values and handle them in our view-change, or we will hash-chain commands.

* In the protocol, the replicas do not process commands in parallel (or out-of-order) either. Due to the synchrony assumption, non-faulty replicas are not affected by this constraint. However, the protocol does not attempt to keep the omission faulty replicas synchronized. Such a synchronization needs to be performed separately. We will relax this constraint and deal with this concern in a later post when we describe a protocol in the asynchronous setting.
