---
title: Flavours of State Machine Replication
date: 2019-10-25 12:54:00 -07:00
published: false
author: Ittai Abraham
---

[State Machine Replication](https://www.cs.cornell.edu/fbs/publications/ibmFault.sm.pdf) is a fundamental approach in distributed computing for building fault tolerant systems. This post is a followup to our basic post on [Fault Tolerant State Machine Replication](https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/).


After defining what a state machine is and the transition function `apply` we then defined a FT-SMR as having two properties: 

**(Safety)** Any two honest replicas store the same sequence of commands in their logs.

**(Liveness)** Honest server replicas will eventually (when the system is synchronous) execute a command proposed by a client.

In this post we elaborate on several common types of FT-SMR as a function of the adversary power and the [type of corruption](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/).

### Omission Fault Tolerant State Machine Replication (OFT-SMR)

This is the classic setting of [Paxos](https://lamport.azurewebsites.net/pubs/paxos-simple.pdf) where we assume there are $n>2f$ servers and at most $f$ of them can fail by [omission](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/).  Two examples of OFT-SMR systems that implement the Paxos protocol are [Raft](https://raft.github.io/) and [ZooKeeper](https://www.confluent.io/blog/distributed-consensus-reloaded-apache-zookeeper-and-replication-in-kafka/).

### Byzantine Fault Tolerant State Machine Replication (BFT-SMR)

This is the setting of many *Blockchain* based systems. The canonical example is perhaps [PBFT](http://pmg.csail.mit.edu/papers/osdi99.pdf) and [BASE](http://cygnus-x1.cs.duke.edu/courses/cps210/spring06/papers/base.pdf). We assume there are $n>3f$ servers and at most $f$ of them can fail by being [Byzantine](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/).

## Fault Safety vs Fault Tolerance

The traditional approach to State Machine Replication is to mask failures. We use the term *fault tolerance* to indicate a system's ability to maintain both safety and liveness.

But what if we could design a system that is *safe* but instead of masking failures and maintaining liveness, it would *detect* failures and then allow other systems to handle them?

In this approach we maintain the safety property but modify liveness to be optimistic and add an ability of any honest replica to safely *terminate* if it *detects* that there is a liveness problem.

**(Safety)** Any two honest replicas store the same sequence of commands in their logs.

**(Optimistic Liveness)** If all replicas are honest and the system is synchronous then all honest replicas will execute a command proposed by a client in a timely manner.

**(Safe Termination)** If an honest replicas does not make progress it can guarantee that no honest replica will make further progress.


### Omission Fault Safe State Machine Replication (OFS-SMR)

The idea of building Fault Safe State Machine Replication that are resilient to Fail-Stop failures can be traced to the chain replication work of [van Renesse and Schneider 2004](http://www.cs.cornell.edu/home/rvr/papers/OSDI04.pdf).
This design has been extended to handle transient or Omission failures in [CORFU](http://www.cs.yale.edu/homes/mahesh/papers/corfumain-final.pdf) and was suggested for using to replicate [Flash storage units](https://www.microsoft.com/en-us/research/wp-content/uploads/2012/01/malki-acmstyle.pdf).
[Christopher Meiklejohn](https://paperswelove.org/2015/topic/christopher-meiklejohns-a-brief-history-of-chain-replication/) provides a good overview of chain replication follow up papers.


### Byzantine Fault Safe State Machine Replication (BFS-SMR)

Chain replication was extended to the Byzantine setting by [van Renesse, Ho, and Schiper 2012](http://www.cs.cornell.edu/~ns672/publications/2012OPODIS.pdf). 

 

