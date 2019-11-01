---
title: Primary-Backup State Machine Replication
date: 2019-11-01 03:10:00 -07:00
published: false
tags:
- dist101
- SMR
author: Ittai Abraham
---

We continue our series of posts on [State Machine Replication](https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/) (SMR). In this post we discuss what is perhaps the most simple form of SMR: Primary-Backup.

### The Setting
There are two replicas: one called *Primary* and the other called *Backup*. We assume the adversary has the power to [crash](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) at most one replica. In this sense we are in the special case of $n=2,f=1$ of the [dishonest majority](https://decentralizedthoughts.github.io/2019-06-17-the-threshold-adversary/) setting ($n>f$) threshold adversary.

We assume [synchrony](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) and for simplicity in this post we assume [lock-step synchrony](https://groups.csail.mit.edu/tds/papers/Lynch/jacm88.pdf).

There is also a set of clients and the adversary can cause any clients to have [omission failures](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/).

### The Goal

The goal is to give the clients exactly the same experience as if they are interacting with an ideal state machine (a trusted third party that never fails). Here is a simplified *ideal state machine*:

```
state = init
log = []
in step r:
   on receiving <cmd> from a client:
      log.append(cmd)
      state, output = apply(cmd, state)
      send <output> to the client
```


To simply the presentation we will assume that each client command has a unique identifier and that the output returned by the state machine contains this identifier.

### Primary-Backup protocol


The client library does two things: a simply mechanism to switch from the primary to the backup and a simple mechanism to avoid sending an output twice:
```
**client library**
view = 0
replica = [primary, backup]
seen = []
in step r:
   on receiving <view change 1> from backup
      view =1
   on receiving <cmd> from client
      send <cmd> to replica[view]
   on receiving <output> from a replica
      if seen does not contain output
         send <output> to client
      seen.add(output)

```

The primary simply sends the command to the backup **before** executing the command and responding back to the client. In addition it sends a heartbeat to the backup at the end of each step.

```
**primary**
state = init
log = []
in step r:
   on receiving <cmd> from a client:
     send <cmd, client> to the backup
     log.append(cmd)
     state, output = apply(cmd, state)
     send <output> to the client
  on end of step 
     send <heartbeat> to backup
```

The backup remains passive as long as it hears the heartbeat. If it detects that the primary failed it invokes a view change. In a view change the backup may need to resend the responses to the clients.

```
**backup**
state = init
log = []
resend = []
view = 0
in step r:
   on receiving <cmd, client> from the primary (and view ==0):
      log.append(cmd)
      state, output = apply(cmd, state)
      resend[cmd] = (output, client)        
   on receiving <cmd, client> from a client (and view == 1):
      log.append(cmd)
      state, output = apply(cmd, state)
      send <output> to the client
   on missing <heartbeat> from primary
      view = 1
      send <view change 1> to all clients
      for every <cmd> from the primary received in step r-1
         send <resend[cmd].output> to resend[cmd].client 


```


