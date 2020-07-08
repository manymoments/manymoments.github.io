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

In a subsequent post in the series, we will extend this to consider asynchronous communication ([partial synchrony](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/)); this protocol will form the key underpinning for the celebrated [Paxos](https://lamport.azurewebsites.net/pubs/paxos-simple.pdf) protocol.

Let's begin with a quick overview of previous posts:
1. [Upper bound](https://decentralizedthoughts.github.io/2019-11-01-primary-backup/): We can tolerate up to $n-1$ crash failures.

2. [Lower bound](https://decentralizedthoughts.github.io/2019-11-02-primary-backup-for-2-servers-and-omission-failures-is-impossible/): The best can can hope for is to tolerate less than $n/2$ omission failures.

We first go over the upper bound for crash failures. Then see what goes wrong when the failures are omission and how we can fix the protocol.

### Primary-Backup for $n$ Replicas

Recall that in the crash model, the primary behaves exactly like an ideal state machine until it crashes. If it does crash, the backup takes over the execution to continue serving the clients. To provide the clients with an interface of a single non-faulty server, the primary sends client commands to all backups before updating the state machine and responding to the client. The backups passively replicate all the commands sent by the primary. In case the primary fails, which is detected by the absence of a "heartbeat", the next designated backup replica $j$ invokes a ("view change", $j$) to all replicas along with the last command sent by the primary in view $j-1$. It then becomes the primary.

For completeness, we repeat the primary-backup pseudocode below. Assume $n$ replicas with identifiers $\{0,1,2,\dots,n-1\}$.

```
// Replica j

state = init
log = []
resend = []
view = 0
while true:

   // as a Primary
   on receiving cmd from a client library (and view == j):
      send cmd to all replicas
      log.append(cmd)
      state, output = apply(cmd, state)
      send output to the client library
      
   // as a Backup
   on receiving cmd from replica[view]:
      log.append(cmd)
      state, output = apply(cmd, state)
      resend = cmd

   // Heartbeat from primary
   if no client message for some predetermined time t (and view == j):
      send ("heartbeat", j) to all replicas (in order)

   // View change
   on missing "heartbeat" from replica[view] in the last t + $\Delta$ time units:
      view = view + 1
      if view == j
         send ("view change", j) to all client libraries
         send resend to all replicas (in order)
```

Can we use the above protocol under omission failures? No! Here is where the protocol fails:
1. In the above protocol, the primary sends the command `cmd` to all backup replicas and then immediately executes the state machine (executing `apply(cmd, state)`) and responds to the client library. Under omission failures, it may so happen that the primary is faulty and no replica has received `cmd`. If all the messages of the primary are blocked subsequently, then there will not be any backup replicating the command sent by it.

2. When a backup needs to invoke a view-change to become the new primary, it may not know the last command that was executed. Simply maintaining a "resend" variable consisting of the last command does not suffice since the last few commands may not have been received by the backup.

To make such a protocol work, we need to ensure the following:
- [ ] *Safe commit*: The primary commits only after ensuring that subsequent primaries can learn that the commit occurred.
- [ ] *Safe view change*: When a view-change is invoked, the new primary must be able to adopt a value, if it was previously committed.
- [ ] *Live steady state*: The steady-state process should not get stuck.
- [ ] *Live view change*: The view-change process should not get stuck.


The key problem we have to deal with is a faulty primary  that is not aware that it is omission faulty. So how can a primary know if its message was sent? By waiting to hear an acknowledgment. But even if the primary is honest and sends a message to all replicas, how many acknowledgments can it wait for without losing liveness? Clearly, it cannot wait for more than $n-f$!

**Steady-state protocol.** We now explain the steady-state protocol tolerating omission failures under a fixed primary; we will later discuss the view-change process.


ITTAI: THINGS TO CHECK::
1. that commands are on the right view
2. do we need log.append or log[sqn] and then we should explain this


```
// Replica j

state = init
log = []
cur = none
view = 0
acks = []
lock = none
seq-no = 0

while true:
   // as a Primary
   on receiving cmd from a client library (and view == j):
      if cur == none: // if not currently processing a cmd 
         send ("propose", cmd, seq-no) to all replicas
         cur = cmd

   on receiving ("vote", cmd, seq-no') from a backup replica r:
      if seq-no == seq-no':
         acks[seq-no] = acks[seq-no] + 1
         if acks[seq-no] > n/2:
            send ("notify", cmd) to all replicas
            log.append(cmd)
            state, output = apply(cmd, state)
            send output to the client library
            cur = none
            seq-no = seq-no + 1
  
   // as a Backup
   on receiving ("propose", cmd, seq-no') from replica[view]:
      if seq-no' == seq-no:
         send ("vote", cmd, seq-no) to replica[view]
         lock = cmd

   on receiving ("notify", cmd, seq-no') from any replica:
      if seq-no' == seq-no:
         log.append(cmd)
         state, output = apply(cmd, state)
         seq-no = seq-no + 1
         send ("notify", cmd, seq-no) to all replicas

   // Heartbeat from primary
   if no client message for some predetermined time t (and view == j):
      send ("heartbeat", j) to all replicas (in order)
```

In the steady state protocol, a primary receives commands from the client. The primary sends the command to every replica through ("request", cmd, seq-no) message. The sequence number seq-no keeps track of the ordering of messages. A backup replica, on receiving a ("request", cmd, seq-no) from the current primary, sends an ("ack", cmd, seq-no) message back to the primary. If the primary receives acknowledgments from a majority of replicas, the primary can add the command to the log, execute it, and send an output to the client. It also sends these acknowledgments to the backup replicas who can then add it to their logs and execute it. The primary then waits to receive the next command from the client. If it does not receive a command for a predetermined amount of time, then it sends a ("heartbeat", j) message to all replicas.

The key observation here is the following: *the primary commits only after ensuring that $f+1$ replicas store the acknowledged value in a lock variable. This observation is key to obtaining safety*.

We now describe the view-change protocol:
```
   // View change
   on missing "heartbeat" from replica[view] in the last t + $\Delta$ time units:
      send ("no heartbeat", view) to replica[view + 1]

   // new primary
   on receiving ("no heartbeat", view) from f+1 replicas (and view == j-1):
      send ("view-change", view) to all replicas
      send ("view-change", view) to all client libraries
      view = view + 1

   // as a backup
   on receiving ("view-change", view) from replica[view+1]: // KARTIK: SHOULD WE ACCEPT MESSAGES FROM LEADERS FROM view+c? what if there were consecutive bad leaders who failed to notify me?
      send ("status", view, lock, seq-no) to replica[view+1]
      stop participating in this view, set view = view+1
      transition to steady state
   
   // new primary: proposes the highest-view-lock
   on receiving ("status", view, lock, seq-no) from f+1 replicas (and view == j):
      highest-view-lock = the lock from the highest view among the f+1 locks received
      send ("propose", highest-view-lock, seq-no) to all replicas (in order)
      cur = highest-view-lock
      transition to steady state
```

The view-change protocol works as follows. If a replica does not receive a heartbeat from the primary for a sufficient amount of time, it stops participating in the view and sends a "no heartbeat" message to the primary of the next view. If the new primary collects f+1 such messages

// if one honest sends, all honest send?

Let us try to understand how we performed in achieving the challenges described earlier:

- [x] The primary commits only after ensuring that subsequent primaries can recover the value: the $f+1$ replicas store the acknowledged value in a lock variable. This ensures that whenever a view-change happens, at least that can be sent to a subsequent primary in case of a view change
- [ ] When a view-change is invoked, the new primary should *safely* be able to adopt a value that may have been committed: not described yet.
- [x] The steady-state process should be *live*: when the primary is not faulty, it will be in sync with all other non-faulty replicas just like in the primary-backup protocol for crash failures. Hence, it will keep making progress. If the primary is faulty, we are not guaranteed to make progress; we will rely on the view-change mechanism then.
- [ ] The view-change process should be *live*: not described yet.

We now describe the view-change protocol to satisfy the other two constraints.

```
   // View change
   on missing "heartbeat" from replica[view] in the last t + $\Delta$ time units:
      send ("no heartbeat", view, resend, seq-no) to all replicas
      stop participating in this view

   on receiving ("no heartbeat", view, resend, seq-no) from f+1 replicas or ("view-change", view, resend, seq-no) from a replica:
      send ("view-change", view, resend, seq-no) to all replicas
      view = view + 1
      if view == j
         send ("view change", j - 1) to all client libraries
         send ("request", resend, seq-no) to all replicas (in order)
      transition to steady state
```


Some observations are in order:
- For simplicity, we assume that the commands sent are unique.
- The replicas accept client commands one at a time -- if the current primary is currently working on consensus for a command, it will not accept the next command until the current command has been committed.
- Due to synchrony and predetermined time-outs t, all of the replicas stay in the same view at the same time -- as soon as a replica receives a view-change message, it sends this message to everyone. So within \Delta time all replicas will be within the same view.


// Can ignore messages from other view primaries.

* talk about quadratic notify, vs other ways
