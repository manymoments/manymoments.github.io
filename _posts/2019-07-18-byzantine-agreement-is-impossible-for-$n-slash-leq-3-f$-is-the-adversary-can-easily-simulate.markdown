---
title: Byzantine Agreement is impossible for $n \leq 3 f$ is the Adversary can easily
  Simulate
date: 2019-07-18 03:55:00 -07:00
published: false
---

<p align="center">
  co-authored with <a href="https://users.cs.duke.edu/~kartik">Kartik</a> <a href="https://twitter.com/kartik1507">Nayak</a>
</p>


Lower bounds in distributed computing are very helpful. Obviously, they prevent you from wasting time trying to do impossible things :-). Even more importantly, understanding them well often helps in finding ways to focus on what is optimally possible or ways to circumvent them by altering the assumptions or problem formulation.


> Its either easy or impossible
> -- <cite>Salvador Dali</cite>

In this post we discuss a classic impossibility result in the [synchronous model](blog post):

**[FLM85](...): It is impossible to solve  [Agreement](https://ittaiab.github.io/2019-06-27-defining-consensus/) against a computationally unbounded Byzantine adversary if $f \geq n/3$.**

TODO: This lower bound first appeared in the original Lamport paper... but here we present the FLM proof...

The extension of this lower bound to computationally bounded adversaries is non-trivial:
1. Under the classic computational assumptions that assume the adversary is polynomially bounded, this lower bound still holds. The only know way to circumvent it is to assume both a [trusted PKI setup](..) and a [computationally bounded](...) adversary.
2. Under more fine grained assumptions where the adversaries power to solve certain computational puzzles is restricted, it is in fact possible to circumvent this lower bound. See [KMS](https://eprint.iacr.org/2014/857.pdf), [AD](https://www.iacr.org/archive/crypto2015/92160235/92160235.pdf), and [GGLP](https://eprint.iacr.org/2016/991.pdf).


## The proof.. TODO...


talk about the fact that the main point in the proof is the ability of the adversary to simulate 4 nodes (2 bad and 4 good)...

Cases were you can simulate:
1. everything is deterministic
2. there is no setup and you have a polynomial advantage over the good guys

cases where you cannot simulate
1. there is a PKI (even if you have a polynomial advantage)
2. use computational puzzles...
