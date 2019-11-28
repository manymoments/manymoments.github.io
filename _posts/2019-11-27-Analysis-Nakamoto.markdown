---
title: Security proof for Nakamoto Consensus
date: 2019-11-27 20:50:00 -08:00
tags:
- blockchain101
published: false
author: Ling Ren
---

Bitcoin's underlying consensus protocol, now known as the Nakamoto consensus, is an extremely simple and elegant solution to the Byzantine consensus problem.
One may expect this simple protocol to come with a simple security proof. But that turns out not to be the case.
The Bitcoin white paper did not provide a proof.
A few academic papers (e.g. [this](https://eprint.iacr.org/2014/765) and [this](https://eprint.iacr.org/2016/454)) later presented rigorous proofs.
But these are fairly complicated even for experts and very hard for practioners, beginners, and students to follow. 

In this post, I will walk readers through a [simple proof](https://eprint.iacr.org/2019/943) I wrote recently.
I believe anyone with knowledge in basic probabiity can follow the proof. 

I assume readers are familiar with how Nakamoto consensus works. 
Below is a concise description that contains all the important details this post needs.
Readers who need a more detailed explanations and descriptions can find plenty of good resource online. 
1. **Longest chain wins.** A node adopts the longest proof-of-work (PoW) chain to its knowledge (breaking ties arbitrarily) and attempts to mine a new block that extends this longest chain;
2. **Disseminate blocks.** Upon adopting a new longest chain, either through mining or by receiving from others, a node broadcasts the newly acquired block(s);
3. **$k$-confirmation commit.** A node commits a block if it is buried at least $k$ blocks deep in the longest chain adopted by that node.


We will make two assumptions.
Firstly, PoW mining is modeled by Poisson processes. 
A Poisson process models arrivals of a stream of "memoryless" events.
It is parameterized by a rate parameter $\lambda$.
During a time window of duration $t$, the probability of having $k$ events is $e^{-\lambda t} \frac{(\lambda t)^k}{k!}$.
In our context, each event refers to the creation of a new block.
Here, the term "memoryless" refers to the property that the time till the next block does not depend on how much time has already elapsed since the previous block.
We will use $\alpha$ and $\beta$ to denote the mining rates of honest nodes and malicious nodes, respectively.

Secondly, the network is synchronous but not [lock-step](https://decentralizedthoughts.github.io/2019-11-11-authenticated-synchronous-bft/), 
i.e., there is a network delay upper bound $\Delta$ but nodes do not take actions in a synchronized fashion.
It is important to note that some papers mistakenly refer to the non-lock-step synchrony assump[tion as "asynchrony" or "partial synchrony".
A reader can read the [previous post](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) to understand why they are different.
we will elaborate on this important discinction further in a future post.

Our goal in this post is to prove that Nakamoto consensus, under some condition and with good probability,
solves [state machine replication](https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/),
i.e., achieves the safety and liveness conditions below.
-- **safety**: Honest nodes do not commit different blocks at the same height.
-- **liveness**: Every transaction is eventually committed by all honest nodes. 



