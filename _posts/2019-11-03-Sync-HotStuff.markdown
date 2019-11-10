---
title: Sync HotStuff, A Simple and Practical State Machine Replication
date: 2019-11-03 02:10:00 -08:00
published: false
tags:
- dist101
- SMR
author: Kartik Nayak, Ling Ren
---

In the last post, we discussed progress in authenticated synchronous consensus protocols. In this post, we will discuss [Sync HotStuff](https://eprint.iacr.org/2019/270), a simple and elegant synchronous protocol for tolerating $f < n/2$ faults that we worked on in the past year. The protocol does not assume lock-step synchrony.


We will first present one of the key ideas of the protocol. Later, we will briefly discuss some extensions of the protocol. 
The goal is for the replicas to commit with as low latency as possible. 
Sync HotStuff works in the [steady-state-and-view-change](https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/) paradigm. In the steady state, it achieves a latency of  $2\Delta$ time, where $\Delta$ is the bounded-message delay. Here's how we achieve it. 
For simplicity, we describe the key idea for agreement on a single value in the steady state. All messages are digitally signed.


1. **Propose.** The leader proposes a command cmd.
2. **Vote.** On receiving the first valid proposal from the leader, broadcast a vote for it. When a replica votes, it also forwards the leader proposal to all other replicas.
3. **Commit.** If a replica does not receive a proposal for a conflicting command cmd’ $\neq$ cmd within $2\Delta$ time after voting, commit cmd.

<p align="center">
  <img src="/uploads/steady-state.png" width="256" title="Steady state of the protocol">
</p>

A pictorial illustration for a three replica execution is presented in the figure. The key question is *why does a $2\Delta$ time after vote suffice to commit? How does it ensure safety?* It turns out that this time suffices for two invariants to be satisfied if the committing replica receives no conflicting command: (i) cmd will be certified, i.e., it will be voted for by all honest replicas, and (ii) no conflicting command will be certified. 

Suppose replica 1 is committing cmd at time t. Let us understand the sequence of events from its point-of-view, pictorially represented in the picture below.

<p align="center">
  <img src="/uploads/sync-hotstuff-proof.png" width="256" title="Sequence of events from the PoV of replica 1">
</p>

Since replica 1 committed at time t, it must have voted at time $t - 2\Delta$. This vote also acts as a *re-proposal*, and hence all honest replicas receive the proposal by time $t-\Delta$. If no honest replica has received a conflicting command at $t-\Delta$, then the honest replica will vote for cmd and cmd will be certified. If an honest replica receives a conflicting command cmd’ after $t-\Delta$, then cmd' will not be voted for (a replica only votes for the first valid proposal). If it received cmd’ before $t-\Delta$, it will indeed vote for cmd’. But this vote will arrive at replica 1 before time $t$, causing replica 1 to not commit. Thus, a $2\Delta$ wait after a vote suffices to commit.

The above description only explains the scenario where the leader is honest and there are no conflicting proposals. Otherwise, we will need a mechanism to identify conflicting proposals or lack of progress and perform a view change. We refer readers to the [paper](https://eprint.iacr.org/2019/270) for the details on the view change procedure. 
The paper also discusses two extensions of the protocol. 
One of them is about how to handle a weaker synchrony model proposed by [Guo et al.](https://eprint.iacr.org/2019/179), which allows the synchrony assumption to be violated at a small fraction of honest nodes at a time.
The other is about how to achieve [optimistic responsiveness](https://eprint.iacr.org/2017/913): i.e., commit in less than $\Delta$ time when $>3n/4$ nodes are honest.



