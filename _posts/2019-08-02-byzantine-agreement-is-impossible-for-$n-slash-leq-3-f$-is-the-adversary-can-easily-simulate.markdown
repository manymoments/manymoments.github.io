---
title: Byzantine Agreement is Impossible for $n \leq 3 f$ if the Adversary can Simulate
date: 2019-08-02 03:55:00 -07:00
tags:
- dist101
- lowerbound
share-img: "/uploads/FLM-world3.pn"
Field name: 
---

<p align="center">
  co-authored with <a href="https://users.cs.duke.edu/~kartik">Kartik</a> <a href="https://twitter.com/kartik1507">Nayak</a>
</p>

> When nothing is known, anything is possible
> <cite> [Margaret Drabble](http://jacobjwalker.effectiveeducation.org/blog/2013/11/29/quote-of-the-day-when-nothing-is-known-anything-is-possible/)</cite>

In this series of posts we are revisiting classic lower bounds from the 1980's. Most of them focused on *deterministic* protocols and computationally *unbounded* adversaries. Part of our goal is to provide a more modern view that also considers *randomized* protocols and *computational restrictions* on the adversary.

In our [first post](https://ittaiab.github.io/2019-06-25-on-the-impossibility-of-byzantine-agreement-for-n-equals-3f-in-partial-synchrony/) we reviewed the classic lower for [Partial synchrony](https://ittaiab.github.io/2019-06-01-2019-5-31-models/). This lower bound turned out to be very robust, it holds even against a static adversary and even if there is [trusted PKI setup](https://ittaiab.github.io/2019-07-18-setup-assumptions/).

In this post we discuss another classic impossibility result. This time in the [synchronous model](https://ittaiab.github.io/2019-06-01-2019-5-31-models/). This lower bound shows that with $n=3f$ parties one cannot solve Byzantine agreement in the face of an adversary controlling $f$ parties. We show the version where $n=3$ parties.

Informally this lower bound captures the following:
*if there are only three parties $A,B,C$ and say $B$ and $C$ blame each other for lying and provide no proof-of-malice to $A$, then $A$ has no way to decide between $B$ and $C$. $A$ has no way to know who to trust and agree with.* 

**[Fisher, Lynch and Merritt 1985](https://groups.csail.mit.edu/tds/papers/Lynch/FischerLynchMerritt-dc.pdf): It is impossible to solve synchronous [agreement](https://ittaiab.github.io/2019-06-27-defining-consensus/) in a plain authenticated channels model if $f \geq n/3$.** 



The high-level approach to the lower bound will be similar to our previous lower bound. We will use two powerful techniques: *indistinguishability* (where some parties can not tell between two potential worlds) and *hybridization* (where we build intermediate worlds between the two contradicting worlds and use a chain of indistinguishability arguments for a contradiction.). 



In the previous lower bound, we used messages delays due to partial synchrony to create the indistinguishability arguments. In this lower bound, we are crucially going to rely on the ability of an adversary to *simulate* different worlds and present different views of the worlds to different parties. 

We prove this result by contradiction. Suppose there is a protocol that can achieve Byzantine agreement with three parties. We will define worlds 1, 2, and 3:

**World 1:**
<p align="center">
  <img src="/uploads/FLM-world1.png" width="256" title="FLM world 1">
</p>

In World 1, parties $A$ and $B$ start with input 1. Corrupt party $C$ simulates the worlds of four players, $C, A', B', C'$ connected in a peculiar fashion as shown in the figure. $C$ starts with input 1 whereas, $A', B'$ and $C'$ start with input 0. Thus, $A$ interacts with an instance of $C$ that starts with input 1 and $B$ interacts with an instance of $C$ (i.e., $C'$) that starts with input 0. Intuitively, by sending messages to $B$ based on what it receives from $A'$, $C$ is framing $A$ as if $A$ started with input 0. Similarly, $C'$ is framing $B$ by sending messages received from $B'$. The connections in the peculiar order ensures that the simulated parties can send appropriate messages to $A$ and $B$.

Now, since validity property holds despite what the corrupt party $C$ does, $A$ and $B$ commit to 1.

**World 2:**
<p align="center">
  <img src="/uploads/FLM-world2.png" width="256" title="FLM world 2">
</p>

In World 2, parties $B$ and $C$ start with input 0. Corrupt party $A$ simulates the worlds of four players, $A$, $B'$, $C'$, and $A'$ connected as shown in the figure. The simulation is similar to world 1. Here, when $A$ is sending messages to $B$, it is framing $C$ to have sent 1. Similarly, $A'$ is framing $B$. Again, since the validity property holds, $B$ and $C$ commit to 0. 

**World 3:**
<p align="center">
  <img src="/uploads/FLM-world3.png" width="256" title="FLM world 3">
</p>

In World 3, party $A$ starts with 1 and $C$ starts with 0. Corrupt party $B$ simulates the worlds of four players, $B$, $C'$, $A'$, and $B'$ as shown in the figure. Parties $B$ and $C'$ start with input 1 whereas $A'$ and $B'$ start with input 0. 

The question is: what do $A$ and $C$ output?

We argue that $A$ outputs 1 and $C$ outputs 0. Why?

<p align="center">
  <img src="/uploads/FLM-indistinguishability.png" width="512" title="Indistinguishability between World 1 and World 3 for A">
</p>

Observe that from party $A$'s perspective, World 3 is the same as World 1. From the figure, it can be seen that if we start from a double-circled $A$ and go clock-wise, the connections and inputs from parties are exactly the same. Intuitively, observe that in World 1, $C'$ started with input 0 and framed $B$ to have input 0 (the fully connected hexagon is necessary to make the argument more formal). However, $A$ decided to output 1 in World 1. Thus, since it obtains exactly the same set of messages in World 3, party $A$ outputs 1. By a similar argument party $C$ outputs 0.

Thus, if the validity property holds in Worlds 1 and 2, the agreement property cannot hold in World 3 (we cannot show absence of validity in World 3 since the honest parties started with different values).

**Simulation of parties by the adversary**

The main thing to observe is that the lower bound requires the adversary to simulate $4$ parties (in general, $n+f$ parties). So this lower bound does not hold if the adversary cannot simulate. Here are a couple of interesting cases:
- Trusted setup: Under the *classic* computational assumptions that assume the adversary is *polynomially bounded*, this lower bound still holds assuming there is not setup. If there is a [trusted PKI setup](https://ittaiab.github.io/2019-07-18-setup-assumptions/), then the adversary will not be able to simulate all of the other parties with different inputs.
- Computationally bounded adversaries: Under more fine grained assumptions where the adversaries' power to solve certain computational puzzles is restricted, it is in fact possible to circumvent this lower bound - without any trusted setup. See [KMS](https://eprint.iacr.org/2014/857.pdf), [AD](https://www.iacr.org/archive/crypto2015/92160235/92160235.pdf), and [GGLP](https://eprint.iacr.org/2016/991.pdf).

The other thing to observe is that when the FLM bound holds, it holds in a strong way for randomized protocols, disallowing even protocols that reach agreement with a small constant probability of error.


**[FLM 85 modern version] It is impossible to solve synchronous agreement with probability $> 2/3$ against a Byzantine adversary that can simulate $n+f$ parties if $f \geq n/3$.** 



Please leave comments on [Twitter](https://twitter.com/ittaia/status/1158276207860838400?s=20)

