---
title: What is the difference between PBFT, TENDERMINT, SBFT and HOTSTUFF ?
date: 2019-06-09 00:00:00 -07:00
published: false
tags:
- research
layout: post
---

In this post I will try to compare found protocols:

1. [PBFT](http://pmg.csail.mit.edu/papers/osdi99.pdf)

2. [Tendermint](https://arxiv.org/abs/1807.04938)

3. [SBFT](https://research.vmware.com/files/attachments/0/0/0/0/0/7/2/sbft_scaling_up_byzantine_fault_tolerance_5_.pdf)

4. [HotStuff](https://research.vmware.com/files/attachments/0/0/0/0/0/7/7/podc.pdf)

|           | Best case Latency     | Normal case Communication     | View Change Communication     | View Change Responsive    |
|---------- |--------------------   |----------------------------   |----------------------------   |-----------------------    |
| PBFT      | 2                     |  O(n<sup>2</sup>)                     | O(n<sup>2</sup>)                      | Yes                       |
| TNDRMNT   | 2                     | O(n)                          | O(n)                          | No                        |
| SBFT      | 1                     | O(n)                          | O(n<sup>2</sup>)                      | Yes                       |
| HotStuff  | 3                     | O(n)                          | O(n)                          | Yes                       |