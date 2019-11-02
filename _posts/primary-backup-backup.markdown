---
title: Primary-Backup Backup State Machine Replication
date: 2019-11-01 03:10:00 -07:00
published: false
tags:
- dist101
- SMR
author: Ittai Abraham
---

We continue our series of posts on [State Machine Replication](https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/) (SMR). In this post we discuss the most simple form of SMR: Primary-Backup for crash failures. We will assume [synchronous](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) communication; in particular, we assume [lock-step synchrony](https://groups.csail.mit.edu/tds/papers/Lynch/jacm88.pdf). For simplicity, we will consider the case with two replicas, out of which one can crash.

### The Primary-Backup Protocol

The goal is to give the clients exactly the same experience as if they are interacting with an ideal state machine as described below. 

```
Ideal State Machine

state = init
log = []
while true:
   on receiving cmd from a client:
      log.append(cmd)
      state, output = apply(cmd, state)
      send output to the client
```

The above state machine can be implemented in practice with a simple primary-backup paradigm. 

**Primary.** The ```primary``` behaves like exactly like an ideal state machine until it crashes. However, if it does crash, it needs the backup to takeover the execution and continue serving the client. 

```
Primary

state = init
log = []
while true:
   on receiving cmd from a client library:
     send cmd to the backup
     log.append(cmd)
     state, output = apply(cmd, state)
     send output to the client library
   if no client message for some predetermined time t: 
     send "heartbeat" to backup
```

The code for the primary is exactly the same as that of an ideal state machine except for two changes. First, it needs to maintain an invariant to update the backup, i.e., *it sends the command to the backup before responding back to the client*. Since we make a synchrony assumption, the message is bound to reach the backup within a known bounded delay $\Delta$. Second, the backup may not be able to differentiate between a crashed primary and absence of client commands. In either case, the backup receives no information. Hence, the primary sends an occasional heartbeat to indicate that it has not crashed.

**Backup.** The ```backup``` passively replicates as long as it either hears client commands or heartbeats. If it receives neither, then  it invokes a *view change* by sending ("view change", 1) to the client. Once a view-change has occured, it is also responsible for responding back to the client. 

```
Backup

state = init
log = []
view = 0
while true:
   on receiving cmd from the primary or a client library:
      log.append(cmd)
      state, output = apply(cmd, state)
   if view == 1:
      send output to the client library
   on missing "heartbeat" from primary in the last t time units:
      view = 1
      send ("view change", 1) to all client libraries
```

In the ideal world, the client needs to interact with only a single state machine. With the primary-backup paradigm, it needs to be aware of their existence and send messages accordingly. Thus, we augment the client with a *client library*. The ```client library``` acts as the required relay between the client in the ideal world and the real world protocol. It implements a mechanism to switch from primary to backup:

```
client library 

view = 0
replica = [primary, backup]
while true:
   on receiving <cmd> from client
      send <cmd> to replica[view]
   on receiving <output> from a replica
      send <output> to client
   on receiving <"view change" 1> from backup
      view = 1
```

Due to the invariant maintained by the primary, a client knows that the response it got from a primary must have been sent to the backup. If the backup crashes then the primary will continue to serve the clients. If the primary is faulty and crashes then the backup is guaranteed to have seen any command whose output was returned to the client.

**A couple of remarks on the setting.**
1. We have assumed that all client messages arrive at the primary/backup and vice-versa. In practice, if these messages do not arrive, i.e., if we have [omission failures](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/), then not all client messages may be executed. On the other hand, sending duplicate messages can cause the same command to be executed twice. This can be fixed by maintaining a unique identifier for every command sent to the state machine and using retries.

2. In the above description, we assume that there will be at most 1 crash in the lifetime of the execution. In practice, one may need to either introduce a recovery mechanism, or use more backups, to tolerate more faults.

### Generalized Primary-Backup

When there are $n>2$ replicas the new primary must do some more work to continue to maintain the invariant: **send the command to all the backups before responding back to the client**. 

Each ```replica j``` maintains a *resend* variable that stores the last command it received from the primary. If $j$ becomes the new primary it resends the last command to all replicas when it does a view change. Assume $n$ replicas with identifiers $\{0,1,2,\dots,n-1\}$.



```
replica j

state = init
log = []
resend = []
view = 0
in step r:
   // as a Backup
   on receiving <cmd> from replica[view]:
      log.append(cmd)
      state, output = apply(cmd, state)
      resend = cmd        
   // as a Primary
   on receiving <cmd> from a client library (and view == j):
      send <cmd> to all replicas
      log.append(cmd)
      state, output = apply(cmd, state)
      send <output> to the client library
   // View change
   on missing <"heartbeat"> from replica[view]
      view = view + 1
      if view == j
         send <"view change" j> to all client libraries
         send <resend> to all replicas (in order)
   // Heartbeat from primary
   no more client messages and view == j
      send <"heartbeat"> to all replicas (in order)
```

Note that clients need a mechanism to discover who is the current primary. For example, they can send a query to all replicas to learn what is the current view number.

