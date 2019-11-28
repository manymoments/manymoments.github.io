---
title: Security proof for Nakamoto Consensus
date: 2019-11-27 20:50:00 -08:00
published: false
tags:
- blockchain101
author: Ling Ren
---

Bitcoin's underlying consensus protocol, now known as the Nakamoto consensus, is an extremely simple and elegant solution to the Byzantine consensus problem. One may expect this simple protocol to come with a simple security proof. But that turns out not to be the case. The Bitcoin white paper did not provide a proof. A few academic papers (e.g. [this](https://eprint.iacr.org/2014/765) and [this](https://eprint.iacr.org/2016/454)) later presented rigorous proofs. But these are fairly complicated even for experts and very hard for practioners, beginners, and students to follow. 

In this post, I will walk readers through a [simple proof](https://eprint.iacr.org/2019/943) I wrote recently. Anyone with knowledge in basic probabiity should be able to follow the proof. 

I assume readers are familiar with how Nakamoto consensus works. Below is a concise description that contains all the important details this post needs. (Readers who need a more detailed explanations and descriptions can find plenty of good resource online.)
1. **Longest chain wins.** A node adopts the longest proof-of-work (PoW) chain to its knowledge (breaking ties arbitrarily) and attempts to mine a new block that extends this longest chain;
2. **Disseminate blocks.** Upon adopting a new longest chain, either through mining or by receiving from others, a node broadcasts the newly acquired block(s);
3. **$k$-confirmation commit.** A node commits a block if it is buried at least $k$ blocks deep in the longest chain adopted by that node.

We will make two assumptions. Firstly, PoW mining is modeled by Poisson processes. We use $\alpha$ and $\beta$ to denote the mining rates of honest nodes and malicious nodes, respectively. Secondly, the network is synchronous, i.e., there is a network delay upper bound $\Delta$ between any pair of honest nodes. 

Before moving on to the actual proof, some comments are warranted. Firstly, we give some backround on Poisson processes in case a reader is not familiar with it. A Poisson process models arrivals of a stream of *memoryless* events. It is parameterized by a rate parameter $\lambda$. During a time window of duration $t$, the probability of having $k$ events is $$e^{-\lambda t} \frac{(\lambda t)^k}{k!}.$$
In our context, each event refers to the creation of a new block. Here, the term *memoryless* refers to the property that the time till the next block does not depend on how much time has already elapsed since the previous block. Secondly, we aassume synchrony but not [lock-step execution](https://decentralizedthoughts.github.io/2019-11-11-authenticated-synchronous-bft/). Lastly, some papers mistakenly refer to the non-lock-step synchrony assumption as "asynchrony" or "partial synchrony". A reader can read our [previous post](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) to understand their differences. It is actually not hard to show that Nakamoto consensus is insecure under asynchrony or partial synchrony. We will elaborate on this issue in a future post.

Our goal in this post is to prove that Nakamoto consensus solves [state machine replication](https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/), i.e., it guarantees safety and liveness:
-- **safety**: Honest nodes do not commit different blocks at the same height.
-- **liveness**: Every transaction is eventually committed by all honest nodes. 

Now here is a high-level plan to prove safety. (The liveness proof is easier and will come as a by-product along the way.) We call a block mined by an honest (resp. malicious) node an honest (resp. malicious) block. Ideally, we want to prove that honest blocks contribute to the safety of Nakamoto consensus while malicious blocks undermine it. If this were true, we would be able to prove Nakamoto consensus safe as long as the collective mining rate of honest nodes $\alpha$ is larger the collective mining rate $\beta$ of malicious nodes (this is the well-known honest majority assumption).

Unfortunately, the above simple argument does not hold due to *network delays*. In order for all honest blocks to contribute to safety, they must extend one another and form a chain. But in reality, we known the chain can *fork* even if the malicious nodes do not do anything bad. In this case, not all honest blocks make it to the longest chain, and hence, not all of them contribute to safety. 

The crux of the proof is to show that, under some additional condition, there cannot be too many such honest blocks, i.e., *most* of the honest blocks do contribute to safety. So how do we rigorously distinguish blocks that contribute to safety from those that may not? This brings us to a key notion in the proof: tailgating. 

For now, let us pretend there is no adversary for simplicity. When would two honest blocks *not* extend one another? The only case is that they are mined too closely to each other. So how close is too close? You guessed it, within $\Delta$ time! If two blocks are mined less than $\Delta$ time apart, then the latter one may not be aware of the former one, and this creates a fork. On the other hand, if two blocks are mined at least $\Delta$ time apart, then when the latter block is mined, its creator has received the former block, so the latter block must extend the former (recall that we are pretending all nodes are honest for now). More formally, Let us put all honest blocks on a time axis based on when they are mined. (I will number the definitions/lemmas/theorems to match the [paper](https://eprint.iacr.org/2019/943)). 

**Definition 4(i).** *Suppose an honest block $B$ is mined at time $t$. If no other honest block is mined between time $t-\Delta$ and $t$, then $B$ is a non-tailgater (otherwise, $B$ is a tailgater).*

Non-tailgaters have a nice property:

**Lemma 5(i).** *Non-tailgaters do not have the same height.*

The proof is rather straightforward. Since the two blocks do not tailgate one another, the block mined later is aware of the block mined earlier. Thus, the later block will at least be attempted at a height higher than the earlier block (longest chain wins). Note that the proof holds no matter what the adversary does.

Now an important question is: what fraction of honest blocks are tailgaters vs. non-tailgaters? This turns out to be a well-known result for Poisson processes. The *gap time* $T$ between two blocks (also called the interarrival time between two events) follows an i.i.d. exponential distribution with the same rate (in this case $\alpha$): $\Pr[T>s] = e^{-\alpha s}$. Plugging in $\Delta$ and let $g=e^{-\alpha\Delta}$ for short, each honest block is a tailgater with $g$ probability and is a non-tailgater with $1-g$ probability.

Congratulations if you are still following, because We have pretty much completed the liveness proof. Note that, in expectation, the number of non-tailgaters grow at a rate of $g\alpha$. Also note that non-tailgaters all have different heights (Lemma 5(i)), so the length of the longest chain in Nakamoto will grow at least at the rate of non-tailgaters. QED.  The proof in the paper has extra rigor to take care of some technical details, e.g., proving that the actual outcome is unlikely to deviate much from the expected outcome. But all the main ideas are as preseted above.

Non-tailgaters helped us prove liveness. Now to prove safety, we need an even nicer type of blocks.

**Definition 4(ii).** *Suppose an honest block $B$ is mined at time $t$. If no other honest block is mined between time $t-\Delta$ and $t+\Delta$, then $B$ is a loner.*

**Lemma 5(ii).** *A loner is the only honest block at its height.*

In other words, a loner is an honest block that *does not tailgate* and *is not tailgated*. A loner has the nicer property of Lemma 5(ii). The proof is identical to Lemma 5(i); simply note that a loner and any other honest block do not tailgate one another by definition.

In order to violate safety, there need to be two chains that diverge by more than $k$ blocks, both adopted by honest nodes.
Here, $k$ is a security parameter (6 is common in practice) that controls the probability of incorrect commit. Let us consider the time window in which these two diverging chains are mined. In this window, there has to be more malicious blocks than loners. This is because we can pair each loner with a malicious block: a loner does not share height with other honest blocks, so one of the two blocks at that height must be a malicious block. To summarize, in order to violate safety, there must be a period of time during which the adversary mines more blocks than honest nodes mine loners. Said it the opposite way, if honest nodes can miner loners faster than the adversary can mine blocks, then safety violation is unlikely to occur. The larger $k$ is, the less unlikely an safety violation can occur. 

What is the rate at which honest nodes mine loners? A loner requires two back-to-back non-tailgaters, so the expected loner rate should be $g^2 \alpha$. The adversary mines blocks at a rate $\beta$. So we should the following result: 

**Main Theorem (informal).** *Nakamoto consensus guarantees safety and liveness if $g^2 \alpha >\beta$. *

This final condition $g^2 \alpha > \beta$ has a clear interpretation. It is the *honest majority* assumption once we take into account network delay. $g=e^{-\alpha\Delta}$ (and $g^2$) can be thought of as the *loss* in honest mining rate due to network delay. Most people intuitively understand that the Bitcoin has a large block interval (e.g., 10 min) for a reason. It can be reduced somewhat but not indefinitely. Hopefully this proof gives you a more principled way to understand this. If the block interval is much larger than the network delay, which implies $\alpha\Delta \approx 0$, then $g \approx g^2 \approx 1$, and Nakamoto consensus is safe as long as we have honest majority. On the contrary, if the block interval is very small, say comparable to $\Delta$, then $\alpha\Delta$ is noticeably larger than 0, $g$ is noticeably smaller than 1, and accordingly, the fault tolerance of Nakamoto consensus noticeably worsens.  
