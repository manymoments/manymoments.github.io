---
title: 2019 11 05 Sync Hot Stuff
date: 2019-11-02 22:10:15.724000000 -07:00
---

In this post, we will discuss Sync HotStuff, a simple and elegant synchronous protocol for tolerating $f < n/2$ faults that we worked on in the past year. We will first present one of the key ideas of the protocol. Later, we will discuss some of the other results.

The goal is to commit client commands within $2\Delta$ time, where $\Delta$ is the bounded message delay. In the steady state, the protocol proceeds as follows. For simplicity, we describe the key idea for agreement on a single value. All messages are digitally signed.

1. **Propose.** The leader proposes a command cmd.
2. **Vote.** Broadcast a vote for the first valid value received from the leader. When a replica votes, it also forwards the leader proposal.
3. **Commit.** If a replica does not observe a proposal for a conflicting command cmd’ $\neq$ cmd within $2\Delta$ time after voting, commit cmd.

A pictorial illustration for a three replica execution is presented in the figure. The key question is *why does a $2\Delta$ time after vote suffice to commit?* It turns out that this time suffices for two invariants to be satisfied if the committing replica receives no conflicting command: (i) cmd will be certified, i.e., it will be voted for by all honest replicas, and (ii) no conflicting command will be certified. 

Suppose replica 1 is committing cmd at time t. Let us understand the sequence of events from its point-of-view. 

Since replica 1 committed at time t, it must have voted at time $t - 2\Delta$. This vote also acts as a *re-proposal*, and hence all honest replicas receive the proposal by time $t- \Delta$. If no honest replica has received a conflicting command at $t-\Delta$, then it will vote for cmd and cmd will be certified. If an honest replica receives a conflicting command cmd’ after $t-\Delta$, then it will not be voted for (a replica votes for the first valid value). If it received cmd’ before $t-\Delta$, it will indeed vote for cmd’. But this vote will arrive at replica 1 before time $t$, causing replica 1 to not commit. 
