---
title: What is the difference between PBFT, Tendermint, SBFT and HotStuff ?
date: 2019-06-09 00:00:00 -07:00
published: false
tags:
- research
layout: post
---

In this post I will compare four of my favorite protocols for Byzantine Fault Tolerant ([BFT](https://en.wikipedia.org/wiki/Byzantine_fault)) State Machine Replication ([SMR](https://en.wikipedia.org/wiki/State_machine_replication)) protocols:

1. [PBFT](http://pmg.csail.mit.edu/papers/osdi99.pdf). The gold standard for BFT SMR. Highly recommend to see [this video](https://ttv.mit.edu/videos/16444-practical-byzantine-fault-tolerance) of Barbara Liskov from 2001. Here is the PBFT [project page](http://www.pmg.csail.mit.edu/bft/).

2. [Tendermint](https://arxiv.org/abs/1807.04938). A modern BFT algorithm that also uses peer-to-peer gossip protocol among nodes. Here is the [github repository](https://github.com/tendermint/tendermint).


3. [SBFT](https://research.vmware.com/files/attachments/0/0/0/0/0/7/2/sbft_scaling_up_byzantine_fault_tolerance_5_.pdf). A BFT system that builds on PBFT for better scalability and best-case latency. Here is a [github repository](https://github.com/vmware/concord-bft) that implements the SBFT protocol.

4. [HotStuff](https://research.vmware.com/files/attachments/0/0/0/0/0/7/7/podc.pdf). A new BFT protocol that provides both linearity and responsiveness.

This post provides a comparison at the **protocol level** from the lens of the _theory of distributed computing_. In particular this is not a comparison of the systems or their software. Much of the comparison can be summarized in this table, which essentially shows that no one protocol pareto dominates all the others.

|           | Best case Latency     | Normal case Communication     | View Change Communication     | View Change Responsive    |
|---------- |--------------------   |----------------------------   |----------------------------   |-----------------------    |
| PBFT      | 2                     |  O(n<sup>2</sup>)                     | O(n<sup>2</sup>)                      | Yes                       |
| TNDRMNT   | 2                     | O(n)                          | O(n)                          | No                        |
| SBFT      | 1                     | O(n)                          | O(n<sup>2</sup>)                      | Yes                       |
| HotStuff  | 3                     | O(n)                          | O(n)                          | Yes                       |


Before saying how these protocols are different it is important to say how similar they are:

1. They are all protocols for state machine replication (SMR) against a Byzantine adversary. All assume a threshold adversary controlling less than a third (see [here](https://ittaiab.github.io/2019-06-17-the-threshold-adversary/)).
2. All work in the Partial synchrony model (see [here](https://ittaiab.github.io/2019-06-01-2019-5-31-models/)) and obtain safety (always) and liveness (after GST) in the face of an adversary that controls _f_ replicas out of a total of _n=3f+1_ replicas. 
3. All these protocols are based on the classic leader-based Primary-Backup approach where leaders are replaced in a _view change_ protocol.

## The conceptual difference: rotating leaders vs stable leaders
As mentioned above, all these protocol have the ability to replace leaders. 
One key conceptual difference between \{PBFT,SBFT\} and \{Tendermint, HotStuff\} is that PBFT,SBFT are based on the _stable leaders_ paradigm where a leader is changed only when a problem is detected, so a leader may stay for many commands. Tendermint and Hotstuff is based on the _rotating leader_ paradigm. A leader is rotated after a single attempt to commit a command. So leader rotation (view-change) is part of the normal operation of the system.

As in many cases this is a **trade-off**. One the one hand, maintaining a stable leader means less client overhead and better performance due to stability when the leader is honest and trusted.  On the other hand, there are some types of malicious behaviours that a stable malicious leader can cause and remain undetected. For example  a malicious leader can bias the internal order of commands in a block. Constantly rotating the leader provides a stronger _fairness_ guarantee.

## Technical differences in the normal case leader commit phase
While PBFT uses all-to-all messages that creates _O(n<sup>2</sup>)_ communication complexity during the normal case leader commit phase. It has been [long observed](https://www.cs.unc.edu/~reiter/papers/1994/CCS.pdf) that this phase can be transformed to a linear communication pattern that creates _O(n)_ communication complexity. All the other three protocols use this approach to get a linear cost for the leader commit phase.

## Technical differences in the view change
Traditionally, the view charge mechanism in PBFT is not optimized to be on the critical path. Algorithmically, it required at least _O(n<sup>2</sup>)_ words to be sent (and some PBFT variants that do not use public key signatures use more). SBFT also has a similar _O(n<sup>2</sup>)_ word view change complexity.

In Tendermint and HotStuff, leader rotation (view change) is part of the critical path because a rotation is done essentially every constant number of rounds, so much more effort is put to optimize this part. Algorithmically, the major innovation of Tendermint is a new view change protocol that requires just _O(n)_ messages.  Hotstuff has a similar _O(n)_ word view change complexity.

One may ask if the Tendermint view change improvement makes it strictly better than PBFT. The quick answer is that Tendermont does not pareto dominate PBFT, its (not surprisingly) a subtle trade-off with latency and responsiveness.

## Differences in Latency and Responsiveness
Latency is measured as the number of round trips it takes to commit a transaction given an honest leader and after GST. To be precise we will measure this from the time the transaction gets to the Primary till the first time any participant (leader/replica/client) learns that the transaction is committed. Note that there may be additional latency from the client perspective and potentially due to the learning and checkpointing requirements. These additional latencies are perpendicular to the consensus protocol.

PBFT has a 2 round-trip latency and so does Tendermint. However, the tendermint view change is not _optimistically responsive_ while the PBFT view change is optimistically responsive. 
A protocol is _optimistically reponsive_ if (for a series of non-faulty primaries) it makes progress at the speed of the network without needing to wait for a predefined time-out that is associated with the Partial synchrony model. Both PBFT and SBFT are responsive, while Tendermint is not.

In particular, it can be shown that even after GST, if the Tendermint protocol does not have a wait period in its view change phase, then a malicious attacker can cause it to lose all liveness and make no progress. With a time-out, Tendermint has no liveness problems (after GST) but this means that it incurs a time-out that happens on the critical path and means it cannot progress faster even if the network delays are significantly smaller than the fixed timeout.

It's important to note that in many applications, not being responsive may be a reasonable design choice. The importance of reponsivness depends on the use case, on the importance of throughput and the variability of the network delays during stable periods. 

Nevertheless one may ask: can we get a linear view change that is also optimistically responsive?

This is exactly where HotStuff comes into the picture. HotStuff extends the Tendermint view change approach and provides a protocol that is both linear in complexity and responsive! So does HotStuff strictly dominate Tendermont? No, again its a trade-off. The Hotstuff commit path induces a latency of 3 round-trips instead of 2 round-trips for PBFT and Tendermint.

Again it is natural to ask, is the difference between latency of 2 and 3 round-trips important? Again the answer is that the importance of latency depends on the use case. Many applications may not care if the latency is even, say, 10 round-trips while others may want to minimize latency as much as possible. 

## Reducing Latency
In fact, if you do care about minimizing latency, then in the best-case even one-round latency is possible! This is exactly what SBFT obtains. This is not as easy as it [looks](https://arxiv.org/abs/1712.01367). 

SBFT gets a best-case one-round latency. So is it optimal? No, again it's a trade-off. While SBFT has the best best-case latency, it has a view change protocol that has _O(n<sup>2</sup>)_ complexity in the worst case. 

# On Throughput: pipeline and concurrency 

There is yet another important difference between the PBFT implementation and the _Chained_ HotStuff variant which is related to the different approaches to improve throughput.

In PBFT, the primary maintains a _window_ of open slots and is allowed to concurrently work on committing all open slots in his active window. Conceptually, this is like TCP where a sender does not have to wait for the ACK of packet $i$ before sending message $i+1$. Experiments that modify the window size have validated empirically that this window can significantly increase throughput by allowing the primary to concurrently coordinate several actions of slot commitments. SBFT uses a similar mechanism.

The basic Hotstuff protocol works sequentially to commit each block. So throughput is limited to one block per 3 rounds. The _Chained HotStuff_ protocol significantly improves this to 1 block per round by using _pipelining_. Basically, each message sent is the first round message for some slot $i$, the second round message for slot $i-1$ and the third round message for slot $i-2$. So while still working sequentially, Chained HotStuff provides the throughput of one block per round.  The idea of chaining follows from reducing the number of message types. A similar approach for message type reduction was suggested in [Casper](https://ethresear.ch/t/casper-ffg-with-one-message-type-and-simpler-fork-choice-rule/103). Reducing the types of message and chaining also induces a simpler protocol. This allows simpler and cleaner software implementations.

Recall that [committing a block can be separated from executing it](https://www.cs.rochester.edu/meetings/sosp2003/papers/p195-yin.pdf). Typically the execution must be sequential, and often after optimizing the commit throughput (via pipeline or concurrency) the sequential execution becomes the performance bottleneck for throughput. If the execution is ineed the bottleneck - then this is what needs to be optimized - more on this in later posts.  
 



