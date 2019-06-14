---
title: What is the difference between PBFT, TEndermint, SBFT and HotStuff ?
date: 2019-06-09 00:00:00 -07:00
published: false
tags:
- research
layout: post
---

In this post I will try to compare found protocols:

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


Before saying how these protocols are different it is important to state how similar they are. They are all protocols for state machine replication (SMR) that work in the PArtial synchrony model and obtain safety (always) and liveness (after GST) in the face of an adversary that controls _f_ replicas out of a total of _n=3f+1_ replicas. Moreover all these protocol are based on the classic leader-based approach where leaders are replaced in a _view change_ protocol.




