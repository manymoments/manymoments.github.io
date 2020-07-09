---
title: Asynchronous Fault Tolerant Computation with Optimal Resilience
date: 2020-07-09 01:39:00 -07:00
published: false
---

OLD VERSION, SEE HACKERMD 

A basic question of distributed computing is:
**Is there a fundamental limit to fault tolerant computation in the Asynchronous model?**

The celebrated [FLP](https://decentralizedthoughts.github.io/2019-12-15-asynchrony-uncommitted-lower-bound/) theorem says that any protocol that solves Agreement in the asynchronous
model that is resilient to at least one crash failure must have a non-terminating execution. This means that deterministic asynchronous consensus is *impossible*, but with randomization, asynchronous consensus is possible in constant expected time. Randomization does not circumvent the existence of a non-terminating execution, it just reduces the probability measure of this event to have [measure zero](https://en.wikipedia.org/wiki/Almost_surely).

Given the above, the following question is natural:
**Is this potentially measure zero event of non-termination the only limitation for fault tolerant computation in the asynchronous model?**



In 1983,  [Ben-Or, Canetti, and Goldreich](https://dl.acm.org/doi/10.1145/167088.167109) initiated the study of secure multiparty computation in the asynchronous model. Their fundamental result is that the answer above is **yes** when there are $n >4t$ servers and an adversary that can corrupt at most $t$ parties in a Byzantine manner. They show that **perfect** security with finite expected run time can be obtained for any functionality.

The BCG work left open the domain of $3t<n \le 4t$.
In 1993, [Canetti and Rabin](https://dl.acm.org/doi/10.1145/167088.167105) obtained a protocol for Asynchronous Byzantine Agreement with optimal resilience ($3t<n$). Their protocol had an *"annoying property"*: the non-termination event has a **non-zero** probability measure. This problematic non-zero probability of non-termination came from their verifiable secret sharing protocol.

In 1994, [Ben-Or, Kelmer, and Rabin](https://dl.acm.org/doi/10.1145/197917.198088) addressed this problem. They provided an optimal resilience asynchronous secure multiparty computation protocol with the same "annoying property": the non-termination event has a **on-zero** probability measure. Moreover, BKR  claim that this is unavoidable. That is, if $n\le 4t$ then any t-resilient asynchronous verifiable secret sharing protocol $A$ must have some **non-zero** probability $q_A>0$ of not terminating. 

In other words, there is a fundamental limit to Asynchronous Fault Tolerant Computation with Optimal Resilience:

**Theorem [BCG]: any protocol solving verifiable secret sharing in the asynchronous model with optimal resilience mus have a positive probability of deadlock.**

In this blog post, we provide a proof overview of this lower bound. For a full proof (and a fascinating new upper bound) please see our [PODC 2020 paper](https://arxiv.org/pdf/2006.16686.pdf). 

### What is Verifiable Secret Sharing (VSS)?

Verifiable Secret Sharing (VSS) is a pair of protocols: *Share* and *Recover*, with one designated party, called the *Dealer*. The Dealer has an *input value* $s$ for the Share protocol. The Recover protocol has an output value. VSS has the following properties:

**Termination:**
1. If the dealer is non-faulty, then all non-faulty will complete the Share protocol.
2. If any non-faulty completes the Share protocol, then all non-faulty will complete the Share protocol.
3. If all non-faulty complete the Share protocol, then if all non-faulty start the Recover protocol, then all non-faulty will complete the Recover protocol.

**Binding:**
Once the first non-faulty completes the Share protocol there exists some value $r$ such that:
1. If the dealer is honest, then $r=s$ ($r$ is the Dealer's input value).
2. Any non-faulty that completes the Recover protocol outputs $r$.

**Hiding:**
If the dealer is non-faulty, and no honest party has begun the Recover protocol, then the adversary can gain no information about $s$.


In other words, the Share protocol allows the dealer to *commit* to a value without revealing it. In particular, if the dealer is non-faulty, the Hiding property keeps the value hidden from the adversary. If the dealer is faulty, the Binding property prevents the adversary from changing the committed value (once one non-faulty competed the Share protocol). 

### Lower bound techniques

Like many of previous lower bounds, this lower bound heavily relies on two powerful techniques: *indistinguishability* (where some parties can not tell between two potential worlds) and *hybridization* (where we build intermediate worlds between the two contradicting worlds and use a chain of indistinguishability arguments for a contradiction.). Unlike these previous lower bounds, this one uses indistinguishability in a more subtle manner. I will call this **indistinguishability boosting**:
1. Start with a very weak notion of *conditional indistinguishability*: that there is a non-zero probability event during the Share protocol, such that conditioned on this event two worlds are indistinguishable.
2. Boost this conditional indistinguishability in the Share protocol to a full indistinguishability argument in the Recover protocol. 

### The setting
We have four parties $A,B,C,D$, where $D$ is the dealer and at most one party may be byzantine. The network is fully synchronous so messages can be delayed by any finite amount.

**Share World A:**
In Share World A, party $C$ is slow, $D$ has input 0, party $B$ is malicious and acts as if $D$ has input 1.


**Share World B:**
In Share World 1, party $C$ is slow, $D$ has input 1, party $A$ is malicious and acts as if $D$ has input 0.

**Share World Hybrid:**
In Share World Hybrid, party $C$ has crashed, party $D$ is malicious, and acts as if its input is 0 to $A$ and as if its input is 1 to $B$.


Note that Share Worlds A and B, all non-faulty must complete the Share Protocol. The important question to ask if the Share World Hybrid will complete the Share protocol. Because if it always completes then one could derive an easy lower bound. Either in Share Worlds A or in B there would be a violation of the Binding property (that $r=s$) with constant probability.

BKR's insight was that it's enough to prove that the Share World Hybrid has some non-zero probability of completing the Share protocol! Indeed it can be shown that if the Adversary guesses the random bits of the honest parties then completion of the Share protocol is guaranteed. This happens because conditioned on this event, the view of the non-faulty non-dealer party is indistinguishable from its view in the Share world of its name. 

To conclude, we created a strategy for a malicious dealer such that with an extremely small (but non-zero) probability, the Share protocol will complete, and if it completes then the two non-faulty parties $A$ and $B$ are at a disagreement about the Recover output value.

This already shows an important point: **perfect VSS is impossible in this setting and some (non-zero) probability of error is unavoidable**. But BKR claimed something stronger: that some (non-zero) probability of deadlock is unavoidable!

### Bosting a non-zero error probability in the Share protocol to a constant error probability in the Recover protocol

The idea will be to boost this non-zero probability of an indistinguishability result for the Share phase, under the assumption that there is no deadlock, to a constant probability of error during the Recover protocol.

**Recover World A:**
In Recover World A, party $C$ is slow during Share, $D$ has input 0 and is slow during Recover, party $B$ is malicious: during Share, it acts correctly, but during Recover, it acts as if $D$ had input 1.


**Recover World B:**
In Recover World B, party $C$ is slow during Share, $D$ has input 1 and is slow during Recover, party $A$ is malicious: during Share, it acts correctly, but during Recover, it acts as if $D$ had input 0.

The main challenge here is to show that the malicious party can "act as if $D$ had the opposite value" by using the probability distribution induced by the conditional event of completing the Share protocol in the Share World Hybrid. 

We can now finally look at party $C$ and claim an indistinguishability argument between Recover World A and Recover World B. This indistinguishability implies that party $C$ must output the wrong value with a constant (large) probability. Proving this indistinguishability by using the conditional probability distribution of completing the Share protocol in the Share World Hybrid is subtle and non-trivial. It relies heavily on the Hiding property of the Share protocol to allow the adversary (party $A$ or $B$) to sample from this distribution during the Recover protocol without knowing the actual random bits of the non-faulty Dealer during the Share protocol.

Observe that to get a constant probability of error, we strongly used the fact that party $C$ **must** complete the Recover protocol and output some value. If a small probability of deadlock is allowed, then party $C$ could just not terminate. This would only violate the termination property of the Recovery protocol in Share World Hybrid, but would only do so with a very small probability.

To conclude we showed that if you assume there is no deadlock, then a malicious strategy in the Share protocol causing a small (non-zero) error probability can be boosted to a malicious strategy in the Recover protocol causing a large (constant) probability of error, under the assumption that there is never a deadlock.

The contrapositive is: there cannot be a protocol that is both correct with constant probability and has a measure zero probability of deadlock. This concludes the lower bound overview.

For a full proof (and a fascinating new upper bound showing what can be done without a non-zero probability of non-termination) please see our [PODC 2020 paper](https://arxiv.org/pdf/2006.16686.pdf). 

Please leave comments on [Twitter](...).




