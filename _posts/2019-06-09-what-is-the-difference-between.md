---
title: What is the difference between PBFT, Tendermint, SBFT and HotStuff ?
date: 2019-06-09 00:00:00 -07:00
published: false
tags:
- research
layout: post
---

In this post I will try to compare four of my favorite protocols for BFT SMR:

1. [PBFT](http://pmg.csail.mit.edu/papers/osdi99.pdf). The gold standard for BFT State Machine Replication systems.

2. [Tendermint](https://arxiv.org/abs/1807.04938). A modern BFT algorithm that also uses peer-to-peer gossip protocol among nodes.


3. [SBFT](https://research.vmware.com/files/attachments/0/0/0/0/0/7/2/sbft_scaling_up_byzantine_fault_tolerance_5_.pdf). A BFT system that builds on PBFT for better scalability and latency.

4. [HotStuff](https://research.vmware.com/files/attachments/0/0/0/0/0/7/7/podc.pdf). A new BFT algorithm that provides both linearity and responsiveness.

I am going to provide a detailed comparison at the protocol level (not the system level). Much of it can be found in this table, which essentially shows that no one protocol pareto dominates all the others.

|           | Best case Latency     | Normal case Communication     | View Change Communication     | View Change Responsive    |
|---------- |--------------------   |----------------------------   |----------------------------   |-----------------------    |
| PBFT      | 2                     |  O(n<sup>2</sup>)                     | O(n<sup>2</sup>)                      | Yes                       |
| TNDRMNT   | 2                     | O(n)                          | O(n)                          | No                        |
| SBFT      | 1                     | O(n)                          | O(n<sup>2</sup>)                      | Yes                       |
| HotStuff  | 3                     | O(n)                          | O(n)                          | Yes                       |


Before saying how these protocols are different it is important to say how similar they are:

1. They are all protocols for state machine replication (SMR) against a Byzantine adversary.
2. All work in the Partial synchrony model and obtain safety (always) and liveness (after GST) in the face of an adversary that controls _f_ replicas out of a total of _n=3f+1_ replicas. 
3. All these protocols are based on the classic leader-based Primary-Backup approach where leaders are replaced in a _view change_ protocol.

## The conceptual difference: rotating leaders vs stable leaders
As mentioned above, all these protocol have the ability to replace leaders. 
One key conceptual difference between \{PBFT,SBFT\} and \{Tendermint, HotStuff\} is that PBFT,SBFT are based on the _stable leaders_ paradigm where a leaders is changed only when a problem is detected, so a leader may stay for many commands, while in Tendermint and Hotstuff a leader is rotated after a single attempt to commit a command. 

As in many things its a **trade-off**. One the one hand, maintaining a stable leader means less overhead and better performance due to stability when the leader is honest and trusted. On the other hand there are some types of behaviours (like setting the internal order of commands in a block) that a stable malicious leader can cause an undetectable but consistent bias. Constantly rotating the leader provides a stronger _fairness_ guarantee.

## Technical differences in the leader commit phase
While PBFT uses all-to-all messages that creates _O(n<sup>2</sup>)_ communication complexity during the leader commit phase. It has been long observed that this phase can be transformed to a linear communication pattern that creates _O(n)_ communication complexity. All the other three protocols use this approach to get a linear cost for the leader commit phase.

## Technical differences in the view change
Traditionally, the view charge mechanism in PBFT is not optimized to be on the critical path. Algorithmically, it required at least _O(n<sup>2</sup>)_ words to be sent. SBFT also has a similar _O(n<sup>2</sup>)_ word view change complexity.

In Tendermint and HotStuff, leader rotation (view change) is part of the critical path because a rotation is done frequently, so much more effort is put to optimize this part. Algorithmically, the major innovation of Tendermint is a view change protocol that requires just _O(n)_ messages.  Hotstuff has a similar _O(n)_ word view change complexity.

One may ask if the Tendermint view change improvement is strictly better than PBFT. The quick answer is no, its (not surprisingly) a subtle trade-off with latency and responsiveness.

## Technical differences in Latency and Responsiveness
Latency is measured as the number of round trips it takes to commit a transaction given an honest leader. To be precise we will measure this from the time the transaction gets to the Primary till the first time any participant (leader/replica/client) learns that the transaction is committed. Note that there may be additional latency from the client perspective and potentially from the learning requirements. These additional latencies are perpendicular to the consensus protocol.

PBFT has a 2 round-trip latency and so does Tendermint. But the tendermint view change is not _responsive_ while the PBFT view change is responsive. 
A protocol is _reponsive_ if it makes progress at the speed of the network without needing to wait for a pre-defined time-out that is associated with the Partial synchrony model. Both PBFT and SBFT are responsive, while Tendermint is not.

In particular, it can be shown that even after GST, if the Tendermint protocol does not have a wait period in its view change phase, then a malicious attacker can cause it to lose all liveness and make no progress. With a time-out, Tendermint has no liveness problems (after GST) but this means that it incurs a time-out that happens on the critical path.

It's important to note that in many applications, not being responsive may be a reasonable design choice. The importance of reponsivness depends on the use case, on the importance of throughput and the variability of the network delays during stable periods. 

Nevertheless one may ask: can we get a linear view change that is also responsive?

This is exactly where HotStuff comes into the picture. HotStuff extends the Tendermint view change approach and provides a protocol that is both linear in complexity and responsive! So does HotStuff strictly dominate Tendermont? No, again its a trade-off. The Hotstuff commit path indices a latency of 3 round-trips instead of 2 for PBFT and Tendermint.

Again it is natural to ask, is the difference between latency of 2 and 3 important? Again the answer is that the importance of latency depends on the use case. Many applications may not care if the latency is even, say, 10 round trips while others may want to minimize latency as much as possible. 

## Reducing Latency
In fact, if you do care about latency, then in the best-case even one-round is possible. This is exactly what SBFT achieves. This is not as easy as it [looks](https://arxiv.org/abs/1712.01367). 

SBFT gets a best-case one-round latency. So is it optimal? Again it's a trade-off. While SBFT has the best best-case latency, it has a view change protocol that is _O(n<sup>2</sup>)_ complexity in the worst case.





