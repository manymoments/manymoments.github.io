---
title: Byzantine Agreement is impossible for $n \leq 3 f$ is the Adversary can easily
  Simulate
date: 2019-07-18 03:55:00 -07:00
published: false
---

<p align="center">
  co-authored with <a href="https://users.cs.duke.edu/~kartik">Kartik</a> <a href="https://twitter.com/kartik1507">Nayak</a>
</p>

> When nothing is known, anything is possible
> <cite> [Margaret Drabble](http://jacobjwalker.effectiveeducation.org/blog/2013/11/29/quote-of-the-day-when-nothing-is-known-anything-is-possible/)</cite>

In this series of posts we are revisiting classic lower bounds from the 1980's. Most of them focused on *deterministic* protocols and computationally *unbounded* adversaries. Part of our goal is to provide a more modern view that also considers *randomized* protocols and *computational restrictions* on the adversary.

In our [first post](https://ittaiab.github.io/2019-06-25-on-the-impossibility-of-byzantine-agreement-for-n-equals-3f-in-partial-synchrony/) we reviewed the classic lower for [Partial synchrony](https://ittaiab.github.io/2019-06-01-2019-5-31-models/). This lower bound turned out to be very robust, it holds even against a static adversary and even if there is [trusted PKI setup](https://ittaiab.github.io/2019-07-18-setup-assumptions/).


In this post we discuss another classic impossibility result. This time in the [synchronous model](https://ittaiab.github.io/2019-06-01-2019-5-31-models/). This lower bound shows that 3 people cannot solve Byzantine agreement, - this is why you need at least 4.

Informally this lower bound captures the following obvious fact:
*if there are only three people $A,B,C$ and say $B$ and $C$ blame each other for being corrupt and lying, then $A$ has no way to decide correctly between $B$ and $C$. $A$ has no way to know who to trust and who to label as corrupt.* 

**[Fisher, Lynch and Merritt 1985](https://groups.csail.mit.edu/tds/papers/Lynch/FischerLynchMerritt-dc.pdf): It is impossible to solve  [Agreement](https://ittaiab.github.io/2019-06-27-defining-consensus/) against a computationally unbounded Byzantine adversary if $f \geq n/3$.**

Just like our previous lower bound we will use two powerful techniques: *indistinguishability* (where some parties can not tell between two potential worlds) and *hybridization* (where we build intermediate worlds between the two contradicting worlds and use a chain of indistinguishability arguments for a contradiction.).


Here we go, lets define worlds 1, 2, and 3:

**World 1:**
<p align="center">
  <img src="/uploads/FLM-world1.jpg" width="256" title="FLM world 1">
</p>

In World 1 parties in $A$ and $B$ start with the value 1. Corrupt parties $C$ simulates...

**World 2:**
<p align="center">
  <img src="/uploads/FLM-world2.jpg" width="256" title="FLM world 2">
</p>

In World 2 party $B$ starts with 1 and party $C$ starts with the value 0. Corrupt parties $A$ simulates...

**World 3:**
<p align="center">
  <img src="/uploads/FLM-world3.jpg" width="256" title="FLM world 3">
</p>


In World 3 parties in $C$ and $A$ start with the value 0. Corrupt parties $A$ simulates...



TODO: This lower bound first appeared in the original Lamport paper... but here we present the FLM proof...

The extension of this lower bound to [computationally bounded adversaries](https://ittaiab.github.io/2019-06-07-modeling-the-adversary/) is non-trivial:
1. Under the *classic* computational assumptions that assume the adversary is *polynomially bounded*, this lower bound still holds. The only know way to circumvent it is to assume both a [trusted PKI setup](https://ittaiab.github.io/2019-07-18-setup-assumptions/) and a [computationally bounded](http://www.ccs.neu.edu/home/alina/classes/Spring2018/Lecture3.pdf) adversary.
2. Under more fine grained assumptions where the adversaries power to solve certain computational puzzles is restricted, it is in fact possible to circumvent this lower bound! See [KMS](https://eprint.iacr.org/2014/857.pdf), [AD](https://www.iacr.org/archive/crypto2015/92160235/92160235.pdf), and [GGLP](https://eprint.iacr.org/2016/991.pdf).



TODO: talk about the fact that the main point in the proof is the ability of the adversary to **simulate** 4 nodes (2 bad and 4 good)...

### discussion

Cases were you can simulate:
1. everything is deterministic
2. there is no setup and you have a polynomial advantage over the good guys

Cases where you cannot simulate
1. there is a PKI (even if you have a polynomial advantage)...
2. use computational puzzles and assume tight computational bounds...

Please leave comments on [Twitter](...)

