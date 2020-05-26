---
title: Synchronous Consensus under Omission Faults
date: 2020-05-25 03:10:00 -07:00
published: false
tags:
- dist101
- SMR
author: Kartik Nayak, Ittai Abraham
---

We continue our series of posts on [State Machine Replication](https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/) (SMR). In this post, we extend our post on [Primary-Backup for crash failures](https://decentralizedthoughts.github.io/2019-11-01-primary-backup/) to consider [omission](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) failures while still making the synchrony assumption. Recall that we can think of an In a subsequent post, we will extend the idea to consider asynchronous communication; this protocol will form the key underpinning for the celebrated [Paxos](https://lamport.azurewebsites.net/pubs/paxos-simple.pdf) protocol.

To explain the idea, we start with the generalized Primary-Backup SMR with crash failures under synchrony (discussed in this [post](https://decentralizedthoughts.github.io/2019-11-01-primary-backup/)). We will then discuss what goes wrong under omission faults and how to fix it.

### Primary-Backup for $n$ Replicas

Recall that in a generalized primary-backup system, the primary behaves exactly like an ideal state machine until it crashes. If it does crash, the backup takes over the execution to continue serving the client. To provide the client with an interface of a single non-faulty server, the primary sends client commands to all backups before updating the state machine and responding to the client. The backups passively replicate all the commands sent by the primary. In case the primary fails, which is detected by the absence of a "heartbeat", the next designated backup replica j invokes a ("view change", $j$) to all replicas along with the last command sent by the primary in view $j-1$. It then becomes the primary.

For completeness, we have repeated the generalized primary-backup pseudocode below. Assume $n$ replicas with identifiers $\{0,1,2,\dots,n-1\}$.

```
// Replica j

state = init
log = []
resend = []
view = 0
while true:
   // as a Backup
   on receiving cmd from replica[view]:
      log.append(cmd)
      state, output = apply(cmd, state)
      resend = cmd
      
   // as a Primary
   on receiving cmd from a client library (and view == j):
      send cmd to all replicas
      log.append(cmd)
      state, output = apply(cmd, state)
      send output to the client library
      
   // View change
   on missing "heartbeat" from replica[view] in the last t + $\Delta$ time units:
      view = view + 1
      if view == j
         send ("view change", j) to all client libraries
         send resend to all replicas (in order)
         
   // Heartbeat from primary
   if no client message for some predetermined time t (and view == j):
      send ("heartbeat", j) to all replicas (in order)
```

Can we use the above protocol under omission failures? No! Here is where the protocol fails:
1. In the above protocol, the primary sends the command cmd to all backup replicas and then immediately executes the state machine (executing apply(cmd, state)) and responds to the client library. Under omission failures, it may so happen that the primary is faulty and no replica has received the cmd. If all the messages of the primary are blocked subsequently, then there will not be any backup replicating the command sent by it.

2. When a backup needs to invoke a view-change to become the new primary, it may not know the last command that was executed. Simply maintaining a "resend" variable consisting of the last command does not suffice since the last few commands may not have been received by the backup.

To make such a protocol work, we need to ensure the following:
- [ ] The primary commits only after ensuring that subsequent primaries can recover the value.
- [ ] When a view-change is invoked, the new primary should *safely* be able to adopt a value that may have been committed.
- [ ] The steady-state process should be *live*.
- [ ] The view-change process should be *live*.

**Attempt 1.** The key property that synchrony under crash failures provided was guaranteed delivery within a bounded time. We will attempt to replicate this under omission faults by having a backup replica acknowledge a message received from the primary -- this ensures that the primary learns of the receipt of the message. Thus, under a modified protocol, the primary will send cmd "request" received from the client to all backup replicas. The primary then waits for an acknowledgment "ack" from all $n$ replicas. Once it receives these acknowledgments, it executes the cmd and responds to the client. It also informs all backup replicas about the receipt of $n$ acknowledgments. The backup replicas execute the cmd only on the receipt of all acknowledgments (and not when it receives a "request").

The modified protocol is simple: it tries to emulate synchrony under crash faults using acknowledgments. This way, an omission faulty primary ensures that its commits will be adopted by subsquent primaries, who can safely use this value in subsequent views. However, a careful reader may have observed that this protocol works *only when no replica is omission faulty*. In other words, despite using $n$ backups, it cannot tolerate even a single omission (or crash) fault, which is perhaps worse than using a single state machine. If any backup is omission faulty, then the primary will never receive all $n$ acknowledgments, ultimately preventing progress (in all views).

**A protocol secure under synchrony and a minority omission faults.** The approach to fix the above concern is to follow the basic idea in Attempt 1. However, there is a key modification: instead of waiting for acknowledgments from all $n$ replicas, the primary waits for only $> n/2$ acknowledgments. In terms of fault tolerance, it tolerates $< n/2$ omission faults. The fault tolerance is optimal for omission failures (see this [post](https://decentralizedthoughts.github.io/2019-11-02-primary-backup-for-2-servers-and-omission-failures-is-impossible/)). 

We now explain the steady-state protocol under a fixed primary; we will later discuss the view-change process.

```
// Replica j

state = init
log = []
cur = none
view = 0
acks = []
resend = none
seq-no = 0

while true:
   // as a Backup
   on receiving ("request", cmd, seq-no') from replica[view]:
      if seq-no' == seq-no:
         send ("ack", cmd, seq-no) to replica[view]
         resend = cmd
      
   on receiving ("acks", cmd, seq-no') from any replica:
      if seq-no' == seq-no:
         log[seq-no] = cmd
         state, output = apply(cmd, state)
         seq-no = seq-no + 1
         send ("acks", cmd, seq-no) to all replicas
      
   // as a Primary
   on receiving cmd from a client library (and view == j):
      if cur == none:
         send ("request", cmd, seq-no) to all replicas
         cur = cmd
      
   on receiving ("ack", cmd, seq-no) from a backup replica r:
      if cur == cmd:
         acks[seq-no] = acks[seq-no] + 1
         if acks[cmd] > n/2:
            send ("acks", cmd) to all replicas
            log[seq-no] = cmd
            state, output = apply(cmd, state)
            send output to the client library
            cur = none
            seq-no = seq-no + 1
    
   // Heartbeat from primary
   if no client message for some predetermined time t (and view == j):
      send ("heartbeat", j) to all replicas (in order)
```

In the steady state protocol, a primary receives commands from the client. The primary sends the command to every replica through ("request", cmd, seq-no) message. The sequence number seq-no keeps track of the ordering of messages. A backup replica, on receiving a ("request", cmd, seq-no) from the current primary, sends an ("ack", cmd, seq-no) message back to the primary. If the primary receives acknowledgments from a majority of replicas, the primary can add the command to the log, execute it, and send an output to the client. It also sends these acknowledgments to the backup replicas who can then add it to their logs and execute it. The primary then waits to receive the next command from the client. If it does not receive a command for a predetermined amount of time, then it sends a ("heartbeat", j) message to all replicas.

Let us try to understand how we performed in achieving the challenges described earlier:

- [x] The primary commits only after ensuring that subsequent primaries can recover the value: the $f+1$ replicas store the acknowledged value in a resend list that can be sent to a subsequent primary in case of a view change
- [ ] When a view-change is invoked, the new primary should *safely* be able to adopt a value that may have been committed: not described yet.
- [x] The steady-state process should be *live*.
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
