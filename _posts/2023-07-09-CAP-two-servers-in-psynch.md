---
title: The CAP theorem and why State Machine Replication for Two Servers and One Crash Failure is Impossible in Partial Synchrony
date: 2023-07-09 14:00:00 -04:00
tags:
- lowerbound
- SMR
- dist101
author: Ittai Abraham
---

In 1999, Fox and Brewer published a paper on the [*CAP principle*](https://s3.amazonaws.com/systemsandpapers/papers/FOX_Brewer_99-Harvest_Yield_and_Scalable_Tolerant_Systems.pdf), where they wrote:

> **Strong CAP Principle.** Strong Consistency, High Availability, Partition-resilience: Pick at most 2.

Yes its a [trilemma](https://en.wikipedia.org/wiki/Trilemma) and yes in [hindsight](https://twitter.com/el33th4xor/status/1191820205456023552?s=20&t=RcutJw0wQUsTmrO0OXzpXw) even Brewer says that "2 of 3" is [misleading](https://ieeexplore.ieee.org/document/6133253).

At [PODC 2000](https://www.podc.org/podc2000/brewer.html),  Brewer gave an invited talk where he popularized the [*CAP theorem*](https://sites.cs.ucsb.edu/~rich/class/cs293-cloud/papers/Brewer_podc_keynote_2000.pdf) (an unproven conjecture at the time), which was later formalized into a lower bound by [Gilbert and Lynch, 2002](https://www.comp.nus.edu.sg/~gilbert/pubs/BrewersConjecture-SigAct.pdf). In this post we will state and prove a slightly stronger result whose essence appeared as early as PODC 1984 by [DLS84 Theorem 5](https://groups.csail.mit.edu/tds/papers/Lynch/podc84-DLS.pdf):

**Theorem:** *It is impossible to implement [State Machine Replication](https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/) with $n$ replicas for at least two clients and an adversary that can cause crash failures to $f\geq n/2$ replicas (and any number of crash failures to clients) in the partial synchrony model.* 

The consensus version of this theorem appears in [DSL88 Theorem 4.3](https://groups.csail.mit.edu/tds/papers/Lynch/jacm88.pdf), the shared memory version in [Lynch96, Theorem 17.6](https://dl.acm.org/doi/book/10.5555/2821576), and the SMR version in [Gilbet and Lynch, 2002](https://www.comp.nus.edu.sg/~gilbert/pubs/BrewersConjecture-SigAct.pdf).

In a [previous post](https://decentralizedthoughts.github.io/2019-11-02-primary-backup-for-2-servers-and-omission-failures-is-impossible/), we showed a similar result: that $f \geq n/2$  *omission failures* is impossible in a *lock step* model.

Before we show the (rather simple) proof, lets connect this to the CAP theorem.

### What does the CAP theorem say?

A system cannot have all three properties: **Consistency**, **Availability**, and **Partition tolerance**. We now formally explain these in the context of [State Machine Replication](https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/).

**Consistency**: sometimes also called **Safety** - that clients see responses that come from a common prefix of a total ordering of commands.

**Availability**: sometimes also called **Liveness** - that a non-faulty client will eventually get a response.

**Partition Tolerance**: this typically refers to the property that even if the adversary creates a partition of the system, each part will continue to provide the desired safety and/or liveness (consistency and/or availability). We will show how using crash failures and asynchrony we can essentially create such partitions.

As [Gilbet and Lynch, 2012](https://groups.csail.mit.edu/tds/papers/Gilbert/Brewer2.pdf) conclude:

> The CAP Theorem, in this light, is simply one example of the fundamental fact that you cannot achieve both *safety* and *liveness* in an unreliable distributed system.

### Fox and Brewer's categorization

Due to this impossibility, Fox and Brewer categorized all solutions into three buckets:

1. **CA**: Consistent and Available - but not partition tolerant. The trivial solution is a centralized system. As there is no resilience to partitions, its not clear this is an interesting choice.

2. **AP**: Available even during Partitions - but not always consistent. This is the space of [weak consistency](http://www.bailis.org/blog/safety-and-liveness-eventual-consistency-is-not-safe/) and [eventual consistency](https://dl.acm.org/doi/pdf/10.1145/224056.224070) that is common for some applications (HTTP Web caching is a great example). This [approach](https://www.usenix.org/conference/osdi-04/secure-untrusted-data-repository-sundr), in the Byzantine setting, has several important [use cases](https://www.youtube.com/watch?v=UKdLJ7-0iFM) and connections to [Eclipse attacks](https://decentralizedthoughts.github.io/2022-08-14-new-DR-LB/) that will be a topic of future posts.

3. **CP**: Consistent even during Partitions - but not always available. The systems is always consistent and during a partition my loose availability. The trivial solution is a centralized system. A more interesting solution is [Two Phase Commit](https://cs.brown.edu/courses/csci1380/s19/lectures/Day13_2019.pdf)  which allows replication and obtains consistency at the cost of loosing availability for partitions. Many distributed systems and databases use this approach, but even one failed/partitioned server can block the system. Can we get slightly better availability?


### CP-MAJ-A

A powerful approach to address the CAP theorem is to obtain Consistency even during Partitions and in addition a *Majority partition availability* property:

**Majority partition availability (MAJ-A)**: A partition that has *the majority of the replicas* can continue to have availability (in partial synchrony).

This is exactly what [Paxos](https://www.microsoft.com/en-us/research/publication/part-time-parliament/) obtains and what many modern state machine replication systems provide (Raft, etcd, etc). Recall that Paxos is:

* Always Safe.
* Maintains Availability, after [GST](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/), for the majority partition.

### A lower bound for both CAP and CP-MAJ-A

In one lower bound we prove:

* It is impossible to get both consistency and availability for a system with two servers that can be partitioned (via an adversary controlling one server failure and partial synchrony).

This impossibility has two implications:

1. It proves the CAP theorem - by showing a specific problematic partition into two parts of equal size. This is the essence of [Gilbet and Lynch 2002, Theorem 2](https://www.comp.nus.edu.sg/~gilbert/pubs/BrewersConjecture-SigAct.pdf).
2. It proves that the fault tolerance of CP-MAJ-A protocols like Paxos is optimal. The best one can hope for is $f<n/2$ failures, because when $f \geq n/2$ it is possible to partition the network into two parts of equal size. This is the essence of [DSL88, Theorem 4.3](https://groups.csail.mit.edu/tds/papers/Lynch/jacm88.pdf).

### The Proof

Assume a protocol that is [safe and live](https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/) for two replicas and two clients in partial synchrony and reach a contradiction. The adversary can cause one replica crash failure and any number of client crash failures. The proof is word for word very similar to the proof for [lock step synchrony and omission failures](https://decentralizedthoughts.github.io/2019-11-02-primary-backup-for-2-servers-and-omission-failures-is-impossible/). 

### World A:
Client $1$ sends command $C1$, and the adversary crashes server $2$ and client $2$ (or causes a partition between $1$ and $2$). All messages arrive immediately. Since the protocol is safe and live, the system must notify client $1$ that command $C1$ is the only committed command.

### World B:
Client $2$ sends command $C2$, and the adversary crashes server $1$ and client $2$ (or causes a partition between $1$ and $2$). All messages arrive immediately. Since the protocol is safe and live, the system must notify client $2$ that command $C2$ is the only committed command.

### World C:
Client $1$ sends command $C1$, and client $2$ sends command $C2$. Using partial synchrony, the adversary delays all communication between:
1. Client $1$ and server $2$;
2. Client $2$ and server $1$;
3. Server $1$ and server $2$.

All other messages arrive immediately.

Observe that the view of server 1 in world A and world C is indistinguishable. Since in worlds A and C, client $1$ only communicates with server $1$, it also has indistinguishable views.

Similarly, the view of server 2 in world B and world C is indistinguishable. Since in worlds B and C, client $2$ only communicates with server $2$, it also has indistinguishable views.

So in world C, the two clients will see conflicting states and this is a violation of safety.

### Notes

The proof captures the essence of the inability to tell the difference between a crash and a delay in partial synchrony.

Its a good exercise to extend this proof to any $f \geq n/2$.

Please leave comments on [Twitter](...)


