---
title: What is the difference between PBFT, Tendermint, SBFT and HotStuff ?
date: 2019-06-23 00:00:00 -07:00
tags:
- research
layout: post
---

In this post I will try to compare four of my favorite protocols for Byzantine Fault Tolerant ([BFT](https://en.wikipedia.org/wiki/Byzantine_fault)) State Machine Replication ([SMR](https://en.wikipedia.org/wiki/State_machine_replication)):

1. [PBFT](http://pmg.csail.mit.edu/papers/osdi99.pdf). The gold standard for BFT SMR. Highly recommend to see [this video](https://ttv.mit.edu/videos/16444-practical-byzantine-fault-tolerance) of Barbara Liskov from 2001. Here is the PBFT [project page](http://www.pmg.csail.mit.edu/bft/).

2. [Tendermint](https://arxiv.org/abs/1807.04938). A modern BFT algorithm that also uses peer-to-peer gossip protocol among nodes. Here is the [github repository](https://github.com/tendermint/tendermint).


3. [SBFT](https://research.vmware.com/files/attachments/0/0/0/0/0/7/2/sbft_scaling_up_byzantine_fault_tolerance_5_.pdf). A BFT system that builds on PBFT for better scalability and best-case latency. Here is a [github repository](https://github.com/vmware/concord-bft) that implements the SBFT protocol.

4. [HotStuff](https://research.vmware.com/files/attachments/0/0/0/0/0/7/7/podc.pdf). A new BFT protocol that provides both linearity and responsiveness. The recent [LibraBFT](https://developers.libra.org/docs/assets/papers/libra-consensus-state-machine-replication-in-the-libra-blockchain.pdf) is based on HotStuff. More on that in a later post.

This post provides a comparison at the protocol level from the lens of the theory of distributed computing. In particular, this is not a comparison of the system or the software. It's a comparison of the *fundamental measures* by which one should look at these different protocols. Much of the comparison can be summarized in this table, which essentially shows that no one protocol pareto dominates all the others.

|           | Best-case Latency     | Normal-case Communication     | View-Change Communication     | View-Change Responsive    |
|---------- |--------------------   |----------------------------   |----------------------------   |-----------------------    |
| PBFT      | 2                     |  O(n<sup>2</sup>)                     | O(n<sup>2</sup>)                      | Yes                       |
| Tendermint   | 2                     | O(n) (*)                       | O(n)                          | No                        |
| SBFT      | 1                     | O(n)                          | O(n<sup>2</sup>)                      | Yes                       |
| HotStuff  | 3                     | O(n)                          | O(n)                          | Yes                       |


Before saying how these protocols are different it is important to say how similar they are:

1. They are all protocols for state machine replication (SMR) against a Byzantine adversary.
2. All work in the Partial synchrony model (see [here](https://ittaiab.github.io/2019-06-01-2019-5-31-models/)) and obtain safety (always) and liveness (after GST) in the face of an adversary that controls $f$ replicas out of a total of $n=3f+1$ replicas (see [here](https://ittaiab.github.io/2019-06-07-modeling-the-adversary/) for threshold adversary). 
3. All these protocols are based on the classic leader-based [Primary-Backup](http://pmg.csail.mit.edu/papers/vr.pdf) approach where leaders are replaced in a _view-change_ protocol.

## The conceptual difference: rotating leaders vs stable leaders
As mentioned above, all these protocols have the ability to replace leaders via a _view-change_ protocol. 
One key conceptual difference between \{PBFT,SBFT\} and \{Tendermint, HotStuff\} is that \{PBFT,SBFT\} are based on the _stable leaders_ paradigm where a leader is changed only when a problem is detected, so a leader may stay for many commands/blocks. \{Tendermint and HotStuff\} are based on the _rotating leader_ paradigm. A leader is rotated after a single attempt to commit a command/block. In this paradigm, leader rotation (view-change) is part of the normal operation of the system.


Note that \{PBFT,SBFT\} could be rather easily modified to run in the _rotating leader_ paradigm and similarly \{Tendermint, HotStuff\} could be rather easily modified to run in the _stable leaders_ paradigm.

As in many cases this is a **trade-off**. On the one hand, maintaining a stable leader means less overhead and better performance due to stability when the leader is honest and trusted. On the other hand, a stable malicious leader can cause undetectable malicious actions. For example, setting the internal order of commands in a block in a biased manner. Constantly rotating the leader provides a stronger _fairness_ guarantee.
<!-- ALIN: The 'For example, setting [...]' sentenece is not a sentence. Maybe it should be changed to an '(e.g., setting [...]) -->

## Technical differences in the normal-case leader commit phase
PBFT uses all-to-all messages that creates $O(n^2)$ communication complexity during the normal-case leader commit phase. It has been [long observed](https://www.cs.unc.edu/~reiter/papers/1994/CCS.pdf) that this phase can be transformed to a linear communication pattern that creates $O(n)$ communication complexity. Both SBFT and HotStuff use this approach to get a linear cost for the leader commit phase. Tendermint uses a gossip all-to-all mechanism, so $O(n \log n)$ messages and $O(n^2)$ words. Since this is not essential for the protocol, in the table above I consider a variant of Tendermint that does $O(n)$ communication in the normal-case leader commit phase as well.

## Technical differences in the view-change phase
The view-change mechanism in PBFT is not optimized to be on the critical path. Algorithmically, it required at least $O(n^2)$ words to be sent (and some PBFT variants that do not use public key signatures use more). SBFT also has a similar $O(n^2)$ word view-change complexity.

In Tendermint and HotStuff, leader rotation (view-change) is part of the critical path. A leader rotation is done essentially every 3 rounds, so much more effort is put to optimize this part. Algorithmically, the major innovation of Tendermint is a view-change protocol that requires just $O(n)$ messages (and words).  HotStuff has a similar $O(n)$ word view-change complexity.

One may ask if the Tendermint view-change improvement makes it strictly better than PBFT. The answer is that Tendermint does not dominate PBFT in all aspects, it's (not surprisingly) a subtle **trade-off** with responsiveness and latency.
<!-- ALIN: Should put a dot after 'all aspects' and start a new sentence? -->

## Technical differences in Latency and Responsiveness
Latency is measured as the number of round trips it takes to commit a transaction given an honest leader and after GST. To be precise we will measure this from the time the transaction gets to the leader till the first time any participant (leader/replica/client) learns that the transaction is committed. Note that there may be additional latency from the client perspective and/or potentially due to the learning and checkpointing requirements. These additional latencies are perpendicular to the consensus protocol.

PBFT has a 2 round-trip latency and so does Tendermint. However, the Tendermint view-change is not _responsive_ while the PBFT view-change is responsive. 
A protocol is _reponsive_ if it makes progress at the speed of the network without needing to wait for a predefined time-out that is associated with the Partial synchrony model. Both PBFT and SBFT are responsive, while Tendermint is not.

In particular, it can be shown that even after GST, if the Tendermint protocol does not have a wait period (time-out) in its view-change phase, then a malicious attacker can cause it to lose all liveness and make no progress. With a time-out, Tendermint has no liveness problems (after GST) but this means that it incurs a time-out that happens on the critical path. So it cannot progress faster even if the network delays are significantly smaller than the fixed time-out.

It's important to note that in many applications, not being responsive may be a reasonable design choice. The importance of reponsivness depends on the use case, on the importance of throughput and the variability of the network delays during stable periods. 

Nevertheless one may ask: can we get a linear view-change that is also responsive?

This is exactly where HotStuff comes into the picture. HotStuff extends the Tendermint view-change approach and provides a protocol that is both linear in complexity and responsive! So does HotStuff strictly dominate Tendermint on all dimensions? No, it's a **trade-off**. The HotStuff commit path induces a latency of 3 round-trips instead of 2 round-trips for PBFT and Tendermint.

It is natural to ask, is the difference between latency of 2 round-trips and 3 round-trips important? Again the answer is that the importance of latency depends on the use case. Many applications may not care if the latency is even, say, 10 round-trips while others may want to minimize latency as much as possible. 

## Minimizing Latency
In fact, if you do care about minimizing latency, then in the best-case even one-round latency is possible! This is exactly what SBFT achieves. This is not as easy as it [looks](https://arxiv.org/abs/1712.01367). 

SBFT gets a best-case one-round latency. So is it optimal? You know the answer by now, it's a **trade-off**. While SBFT has the best best-case latency, it has a view-change protocol that has $O(n^2)$ complexity in the worst case. 


## On Throughput: Pipeline and Concurrency 

There is yet another important difference between the PBFT implementation and the _Chained_ HotStuff variant which is related to the different approaches to improve throughput.

In PBFT, the leader maintains a _window_ of open slots and is allowed to concurrently work on committing all open slots in his active window. Conceptually, this is like TCP where a sender does not have to wait for the ACK of packet $i$ before sending message $i+1$. Experiments that modify the window size have validated empirically that this window can significantly increase throughput by allowing the leader to concurrently coordinate several actions of slot commitments. SBFT uses a similar mechanism.

The basic HotStuff protocol works sequentially to commit each block. So throughput is limited to one block per 3 rounds. The _Chained HotStuff_ protocol significantly improves this to an amortized _1 block per round_ by using _pipelining_. Basically, each message sent is the first round message for some slot $i$, the second round message for slot $i-1$ and the third round message for slot $i-2$. So while still working sequentially, Chained HotStuff provides the amortized throughput of one block per round.  The idea of chaining follows from reducing the number of message types. A similar approach for message type reduction was suggested in [Casper](https://ethresear.ch/t/casper-ffg-with-one-message-type-and-simpler-fork-choice-rule/103). Reducing the types of messages and chaining also induces a simpler protocol. This allows simpler and cleaner software implementations. Viewed from the protocol foundations, [Casper FFG](https://arxiv.org/abs/1710.09437) is essentially _Chained Tendermint_.

From a theoretical perspective, the concurrent approach can also obtain the optimal amortized 1 block per round that the pipelined approach obtains. However, the pipelined approach also reduces the number of bits sent (by aggregating several messages into one), this is something that the concurrent approach does not currently do.

<!-- ALIN: I would replace 'Pipeline' with 'Pipelining' here, in the next paragraph and in the title -->
Note that Pipeline and Concurrency are BFT SMR throughput boosting techniques. They are not strongly tied to any particular BFT protocol. For example, one could come up with a _Chained PBFT_ (or SBFT) variant that uses pipelining, or a _Windowed HotStuff_ variant that can switch to a stable leader mode that allows to concurrently make progress on a window of outstanding slots.

In the standard BFT SMR architecture, [committing a block can be separated from executing it](https://www.cs.rochester.edu/meetings/sosp2003/papers/p195-yin.pdf). Typically the execution must be sequential, and often after optimizing the commit throughput (via pipeline or concurrency) the sequential execution becomes the performance bottleneck for throughput. If the execution is indeed the bottleneck, then this is what needs to be optimized. More on this in later posts.  
 

## On Randomness

<!-- ALIN: This sentence is difficult to read for me. I would break it up in a few sentences. -->
From a theoretical perspective, the importance of a linear view-change and a linear normal-case leader commit phase is that together they imply that, after GST, a good leader will be found after at most $O(f)$ rounds for a total of $O(n^2)$ messages (and words).  HotStuff is the first protocol that obtains these bounds.

Randomization is a central tool in the design of protocols for distributed computing and cryptography. All the protocols mentioned above are deterministic. One can use a random leader election to gain better bounds and against more adaptive adversaries and models. There are two recent protocols that extend HotStuff and use randomization in powerful ways:
1. [VABA](https://research.vmware.com/files/attachments/0/0/0/0/0/7/8/practical_aba_2_.pdf) gets $O(1)$ expected rounds even in the asynchronous model and with a strong adaptive adversary.

2. [LibraBFT](https://developers.libra.org/docs/assets/papers/libra-consensus-state-machine-replication-in-the-libra-blockchain.pdf) can get $O(1)$ expected rounds in the partial synchronous model and a somewhat-adaptive adversary. 


More on randomness and these two protocols in later posts.

## Acknowledgments
Special thanks to [Dahlia Malkhi](https://dahliamalkhi.wordpress.com/cv/) and [Benny Pinkas](http://www.pinkas.net/) for reviewing a draft and sending insightful comments.

### Please leave comments on [Twitter](https://twitter.com/ittaia/status/1142845764164554754?s=20)!!

