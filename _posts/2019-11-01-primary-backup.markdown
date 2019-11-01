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
while true:
  on receiving cmd from a client:
    log.append(cmd)
    state, output = apply(cmd, state)
    send output to the client
```

### Primary-Backup protocol



