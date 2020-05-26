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

### Generalized Primary-Backup

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
   if no client message for some predetermined time t: 
      send "heartbeat" to all replicas (in order)
```

Can we use the above protocol under omission failures? No! Here is where the protocol fails:
1. In the above protocol, the primary sends the command cmd to all backup replicas and then immediately executes the state machine (executing apply(cmd, state)) and responds to the client library. Under omission failures, it may so happen that the primary is faulty and no replica has received the cmd. If all the messages of the primary are blocked subsequently, then there will not be any backup replicating the command sent by it.

2. When a backup needs to invoke a view-change to become the new primary, it may not know the last command that was executed. Simply maintaining a "resend" variable consisting of the last command does not suffice since the last few commands may not have been received by the backup.

To make such a protocol work, we need to ensure the following:
- The primary commits only after ensuring that subsequent primaries can recover this value.
- When a view-change is invoked, the new primary should *safely* be able to adopt a value.
- The steady-state and view-change process should be *live*, i.e., the protocol should not be stuck.

**Attempt 1.** The key property that synchrony under crash failures provided was guaranteed delivery within a bounded time. We will attempt to replicate this under omission faults by having a backup replica acknowledge a message received from the primary -- this ensures that the primary learns of the receipt of the message. Thus, under a modified protocol, the primary will send cmd "request" received from the client to all backup replicas. The primary then waits for an acknowledgment "ack" from all $n$ replicas. Once it receives these acknowledgments, it executes the cmd and responds to the client. It also informs all backup replicas about the receipt of $n$ acknowledgments. The backup replicas execute the cmd only on the receipt of all acknowledgments (and not when it receives a "request").

The modified protocol is simple: it tries to emulate synchrony under crash faults using acknowledgments. This way, an omission faulty primary ensures that its commits will be adopted by subsquent primaries, who can safely use this value in subsequent views. However, a careful reader may have observed that this protocol works *only when no replica is omission faulty*. In other words, despite using $n$ backups, it cannot tolerate even a single omission (or crash) fault, which is perhaps worse than using a single state machine. If any backup is omission faulty, then the primary will never receive all $n$ acknowledgments, ultimately preventing progress (in all views).

**A protocol secure under synchrony and a minority omission faultsh.** The approach to fix the above concern is to follow the basic idea in Attempt 1. However, there is a key modification: instead of waiting for acknowledgments from all $n$ replicas, the primary waits for only $> n/2$ acknowledgments. In terms of fault tolerance, it tolerates $< n/2$ omission faults. The fault tolerance is optimal for omission failures (see this [post](https://decentralizedthoughts.github.io/2019-11-02-primary-backup-for-2-servers-and-omission-failures-is-impossible/)). 

We now explain the steady-state protocol under a fixed primary; we will later discuss the view-change process.

```
// Replica j

state = init
log = []
cur = none
view = 0
acks = []

while true:
   // as a Backup
   on receiving ("request", cmd) from replica[view]:
      send ("ack", cmd) to replica[view]
      resend = cmd
      
   on receiving ("acks", cmd) from replica[view]:
      log.append(cmd) // CHECK IF THIS IS CALLED MULTIPLE TIMES FOR A COMMAND
      state, output = apply(cmd, state)
      
   // as a Primary
   on receiving cmd from a client library (and view == j):
      if cur == none:
         send ("request", cmd) to all replicas
         cur = cmd // ASSUME CMDS ARE UNIQUE
      
   on receiving ("ack", cmd) from a backup replica r:
      if cur == cmd:
         acks[cmd] = acks[cmd] + 1 // TODO(ASSUMES RECEIVES A MESSAGE ONLY ONCE)
         if acks[cmd] > n/2 and cmd not in log:
            send ("acks", cmd) to all replicas
            log.append(cmd)
            state, output = apply(cmd, state)
            send output to the client library
            cur = none
    
   // Heartbeat from primary
   if no client message for some predetermined time t: 
      send "heartbeat" to all replicas (in order)
```

In the steady state protocol, a primary receives commands from the client. The primary sends the command to every replica through ("request", cmd) message. A backup replica, on receiving a ("request", cmd) from the current primary, sends an ("ack", cmd) message back to the primary. If the primary receives ()

// ALL of them are in the same view
// Can ignore messages from other view primaries.

EXPLAIN PROTOCOL UNDER GOOD PRIMARY

EXPLAIN WHEN VIEW-CHANGE CAN HAPPEN

PROVIDE CODE FOR VIEW-CHANGE

EXPLAIN HOW A BACKUP TAKES OVER (IN PAXOS AND RAFT)
