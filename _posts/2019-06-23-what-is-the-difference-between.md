---
title: What is the difference between PBFT, Tendermint, SBFT and HotStuff ?
date: 2019-06-23 00:00:00 -07:00
published: false
tags:
- research
layout: post
---

In this post I will try to compare four of my favorite protocols for Byzantine Fault Tolerant ([BFT](https://en.wikipedia.org/wiki/Byzantine_fault)) State Machine Replication ([SMR](https://en.wikipedia.org/wiki/State_machine_replication)):

1. [PBFT](http://pmg.csail.mit.edu/papers/osdi99.pdf). The gold standard for BFT SMR. Highly recommend to see [this video](https://ttv.mit.edu/videos/16444-practical-byzantine-fault-tolerance) of Barbara Liskov from 2001. Here is the PBFT [project page](http://www.pmg.csail.mit.edu/bft/).

2. [Tendermint](https://arxiv.org/abs/1807.04938). A modern BFT algorithm that also uses peer-to-peer gossip protocol among nodes. Here is the [github repository](https://github.com/tendermint/tendermint).


3. [SBFT](https://research.vmware.com/files/attachments/0/0/0/0/0/7/2/sbft_scaling_up_byzantine_fault_tolerance_5_.pdf). A BFT system that builds on PBFT for better scalability and best-case latency. Here is a [github repository](https://github.com/vmware/concord-bft) that implements the SBFT protocol.

4. [HotStuff](https://research.vmware.com/files/attachments/0/0/0/0/0/7/7/podc.pdf). A new BFT protocol that provides both linearity and responsiveness.

This post provides a comparison at the protocol level from the lens of the theory of distributed computing. In particular this is not a comparison of the system or the software. It's a comparison of the *fundamental measures* by which one should look at these different protocols. Much of the comparison can be summarized in this table, which essentially shows that no one protocol pareto dominates all the others.

|           | Best case Latency     | Normal case Communication     | View Change Communication     | View Change Responsive    |
|---------- |--------------------   |----------------------------   |----------------------------   |-----------------------    |
| PBFT      | 2                     |  O(n<sup>2</sup>)                     | O(n<sup>2</sup>)                      | Yes                       |
| Tendermint   | 2                     | O(n) (*)                       | O(n)                          | No                        |
| SBFT      | 1                     | O(n)                          | O(n<sup>2</sup>)                      | Yes                       |
| HotStuff  | 3                     | O(n)                          | O(n)                          | Yes                       |


Before saying how these protocols are different it is important to say how similar they are:

1. They are all protocols for state machine replication (SMR) against a Byzantine adversary.
2. All work in the Partial synchrony model (see [here](https://ittaiab.github.io/2019-06-01-2019-5-31-models/)) and obtain safety (always) and liveness (after GST) in the face of an adversary that controls $f$ replicas out of a total of $n=3f+1$ replicas (see [here](https://ittaiab.github.io/2019-06-07-modeling-the-adversary/) for threshold adversary). 
3. All these protocols are based on the classic leader-based [Primary-Backup](http://pmg.csail.mit.edu/papers/vr.pdf) approach where leaders are replaced in a _view change_ protocol.

## The conceptual difference: rotating leaders vs stable leaders
As mentioned above, all these protocol have the ability to replace leaders. 
One key conceptual difference between \{PBFT,SBFT\} and \{Tendermint, HotStuff\} is that PBFT,SBFT are based on the _stable leaders_ paradigm where a leaders is changed only when a problem is detected, so a leader may stay for many commands. Tendermint and Hotstuff is based on the _rotating leader_ paradigm. A leader is rotated after a single attempt to commit a command. So leader rotation (view-change) is part of the normal operation of the system.


Note that \{PBFT,SBFT\} could be rather easily modified to run in the _rotating leader_ paradigm and similarly \{Tendermint, HotStuff\} could be rather easily modified to run in the _stable leaders_ paradigm.

As in many case this is a **trade-off**. One the one hand, maintaining a stable leader means less overhead and better performance due to stability when the leader is honest and trusted. On the other hand there are some types of behaviours (like setting the internal order of commands in a block) that a stable malicious leader can cause an undetectable but consistent bias. Constantly rotating the leader provides a stronger _fairness_ guarantee.


## Technical differences in the normal case leader commit phase
While PBFT uses all-to-all messages that creates $O(n^2)$ communication complexity during the normal case leader commit phase. It has been [long observed](https://www.cs.unc.edu/~reiter/papers/1994/CCS.pdf) that this phase can be transformed to a linear communication pattern that creates $O(n)$ communication complexity. Both SBFT and HotStuff use this approach to get a linear cost for the leader commit phase. Tendermint uses a gossip all-to-all mechanism, so $O(n \log n)$ messages and $O(n^2)$ words. Since this is not essential for the protocol, in the table above I consider a variant of Tendermont that does $O(n)$ communication in the normal case leader commit phase as well.

## Technical differences in the view change
Traditionally, the view charge mechanism in PBFT is not optimized to be on the critical path. Algorithmically, it required at least $O(n^2)$ words to be sent (and some PBFT variants that do not use public key signatures use more). SBFT also has a similar $O(n^2)$ word view change complexity.

In Tendermint and HotStuff, leader rotation (view change) is part of the critical path because a rotation is done essentially every 3 rounds, so much more effort is put to optimize this part. Algorithmically, the major innovation of Tendermint is a view change protocol that requires just $O(n)$ messages.  Hotstuff has a similar $O(n)$ word view change complexity.

One may ask if the Tendermint view change improvement makes it strictly better than PBFT. The quick answer is that Tendermont does not pareto dominate PBFT, its (not surprisingly) a subtle trade-off with latency and responsiveness.

## Technical differences in Latency and Responsiveness
Latency is measured as the number of round trips it takes to commit a transaction given an honest leader and after GST. To be precise we will measure this from the time the transaction gets to the leader till the first time any participant (leader/replica/client) learns that the transaction is committed. Note that there may be additional latency from the client perspective and potentially due to the learning and checkpointing requirements. These additional latencies are perpendicular to the consensus protocol.

PBFT has a 2 round-trip latency and so does Tendermint. However, the tendermint view change is not _responsive_ while the PBFT view change is responsive. 
A protocol is _reponsive_ if it makes progress at the speed of the network without needing to wait for a predefined time-out that is associated with the Partial synchrony model. Both PBFT and SBFT are responsive, while Tendermint is not.

In particular, it can be shown that even after GST, if the Tendermint protocol does not have a wait period in its view change phase, then a malicious attacker can cause it to lose all liveness and make no progress. With a time-out, Tendermint has no liveness problems (after GST) but this means that it incurs a time-out that happens on the critical path and means it cannot progress faster even if the network delays are significantly smaller than the fixed timeout.

It's important to note that in many applications, not being responsive may be a reasonable design choice. The importance of reponsivness depends on the use case, on the importance of throughput and the variability of the network delays during stable periods. 

Nevertheless one may ask: can we get a linear view change that is also responsive?

This is exactly where HotStuff comes into the picture. HotStuff extends the Tendermint view change approach and provides a protocol that is both linear in complexity and responsive! So does HotStuff strictly dominate Tendermont? No, its a trade-off. The Hotstuff commit path induces a latency of 3 round-trips instead of 2 round-trips for PBFT and Tendermint.

It is natural to ask, is the difference between latency of 2 and 3 round-trips important? Again the answer is that the importance of latency depends on the use case. Many applications may not care if the latency is even, say, 10 round-trips while others may want to minimize latency as much as possible. 

## Reducing Latency
In fact, if you do care about minimizing latency, then in the best-case even one-round latency is possible! This is exactly what SBFT achieves. This is not as easy as it [looks](https://arxiv.org/abs/1712.01367). 

SBFT gets a best-case one-round latency. So is it optimal? It's a trade-off. While SBFT has the best best-case latency, it has a view change protocol that has $O(n^2)$ complexity in the worst case. 


## On using Randomness

From a theoretical perspective, the importance of a linear view change that it implies that after GST, a good leader will be found after at most $O(f)$ rounds for a total of $O(n^2)$ messages (and words).  

Randomization is a powerful tool in distributed computing and cryptography. All the protocols mentioned above are deterministic. One can use a random leader election to gain better bounds and against more adaptive adversaries and models. Two protocols that extend HotStuff and use randomization in powerful ways:
1. [VABA](https://research.vmware.com/files/attachments/0/0/0/0/0/7/8/practical_aba_2_.pdf) gets $O(1)$ expected rounds even in the asynchronous model and a strong adaptive adversary.

2. [LibraBFT](https://developers.libra.org/docs/assets/papers/libra-consensus-state-machine-replication-in-the-libra-blockchain.pdf) can get $O(1)$ expected rounds in the partial synchronous model and a somewhat adaptive adversary. 


More on randomness and these two protocols in later posts.

## Acknowledgments
Special thanks to [Dahlia Malkhi](https://dahliamalkhi.wordpress.com/cv/) for reviewing a draft and sending insightful comments.




