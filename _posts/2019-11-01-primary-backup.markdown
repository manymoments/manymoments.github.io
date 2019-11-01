---
title: Primary-Backup State Machine Replication
date: 2019-11-01 03:10:00 -07:00
tags:
- dist101
- SMR
author: Ittai Abraham
---

We continue our series of posts on [State Machine Replication](https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/) (SMR). In this post we discuss what is perhaps the most simple form of SMR: Primary-Backup for crash failures. 

### The Setting
We are in the client-server setting. The servers are called *replicas*.

There are two replicas: one called *Primary* and the other called *Backup*. We assume the adversary has the power to [crash](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) at most one replica. In this sense we are in the special case of $n=2,f=1$ of the [dishonest majority](https://decentralizedthoughts.github.io/2019-06-17-the-threshold-adversary/) setting ($n>f$) threshold adversary.

We assume [synchrony](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) and for simplicity in this post we assume [lock-step synchrony](https://groups.csail.mit.edu/tds/papers/Lynch/jacm88.pdf).

The clients communicate only with the replicas and are unreliable. We assume the adversary can cause any clients to have [omission failures](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/).

### The Goal

The goal is to give the clients exactly the same experience as if they are interacting with an ideal state machine (a trusted third party that never fails). Here is a simplified ```ideal state machine```:

```
ideal state machine

state = init
log = []
in step r:
   on receiving <cmd> from a client:
      log.append(cmd)
      state, output = apply(cmd, state)
      send <output> to the client
```


A client may have omission failures even in the ideal world. To overcome this, each client command has a unique identifier and the output returned by the state machine contains this identifier. 

We assume both the client and the ideal state machine know how to handle and ignore duplicate commands and outputs. A client that does not receive a response has a retry mechanism that re-sends the request until an output is received.


### Primary-Backup protocol

As detailed above we assume the client already handles re-tries and duplicate outputs. WE augment the client with a *client library*. 
The ```client library``` has a mechanism to switch from the primary to the backup:

```
client library 

view = 0
replica = [primary, backup]
in step r:
   on receiving <view change 1> from backup
      view = 1
   on receiving <cmd> from client
      send <cmd> to replica[view]
   on receiving <output> from a replica
      send <output> to client
```

The ```primary``` needs to maintain the invariant: **sends the command to the backup before responding back to the client**. In addition it sends a heartbeat to the backup at the end of each step.


```
primary

state = init
log = []
in step r:
   on receiving <cmd> from a client:
     send <cmd> to the backup
     log.append(cmd)
     state, output = apply(cmd, state)
     send <output> to the client
  on end of step 
     send <heartbeat> to backup
```

The ```backup``` passively replicates as long as it hears the heartbeat. If it detects that the primary failed it invokes a view change. In a view change the backup may need to resend the responses to the clients.


```
backup

state = init
log = []
view = 0
in step r:
   on receiving <cmd> from the primary (and view == 0):
      log.append(cmd)
      state, output = apply(cmd, state)   
   on receiving <cmd> from a client (and view == 1):
      log.append(cmd)
      state, output = apply(cmd, state)
      send <output> to the client
   on missing <heartbeat> from primary
      view = 1
      send <view change 1> to all clients
```

By maintaining the invariant, a client knows that the response from the primary must have been sent to the backup. If the backup is faulty then the primary will continue to serve the clients. If the primary is faulty and crashes then the backup is guaranteed to have seen all the commands that whose output was returned to the clients. The backup may also see commands that were not sent to the client (in the last round of the primary). The client retry mechanism will eventually learn that this these commands were executed.



### Generalized Primary-Backup

When there are $n>2$ replicas the new primary must continue to maintain the invariant: **send the command to all the backups before responding back to the client**.

To do this each ```replica j``` maintains a *resend* set and resends the last round commands when it does a view change. Assume $n$ replicas with identifiers $\{0,1,2,\dots,n-1\}$.



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
      resend[r].add(cmd)        
   // as a Primary
   on receiving <cmd> from a client (and view == j):
      send <cmd> to all replicas
      log.append(cmd)
      state, output = apply(cmd, state)
      send <output> to the client
   // View change
   on missing <heartbeat> from replica[view]
      view = view +1
      if view == j
         send <view change j> to all clients
         let t be a highest non empty entry in resend
         for each cmd in resend[t]
            send <cmd> to all replicas (in order)
  on end of step 
     if view == j
         send <heartbeat> to all replicas (in order)
```


