---
title: Flavours of Broadcast
date: 2019-10-21 07:44:00 -07:00
published: false
tags:
- dist101
Field name: 
---

What is the difference between broadcast, crusader broadcast, gradecast, weak broadcast and broadcast with abort? This post is a follow up to our basic post on: [What is Broadcast?](https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/)

The focus of this post is on [computationally unbounded adversaries](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) in the [synchronous model](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/), but we begin with considering both bounded and unbounded adversaries for the class Broadcast problem. 

### Broadcast

Let's start by defining the basic *Broadcast problem* again. We assume a set of $n$ parties. One party is designated as being called the *sender*. We assume the sender has some initial *value*.

A protocol solves the (classic) **broadcast** problem:
1. **Agreement**: If an honest party outputs $x$, then all honest parties output $x$.
2. **Validity**: If sender is honest, then all honest parties output the sender's value.

Assuming a PKI and a [computationally bounded](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) adversary, the [Dolev-Strong](https://www.cs.huji.ac.il/~dolev/pubs/authenticated.pdf) Broadcast protocol solves Byzantine broadcast assuming an adversary that can control up to $n−1$ parties out of $n$ in the Synchronous model.

For computationally unbounded adversaries the [FLM lower bound](https://decentralizedthoughts.github.io/2019-08-02-byzantine-agreement-is-impossible-for-$n-slash-leq-3-f$-is-the-adversary-can-easily-simulate/) shows that broadcast is possible only when $n>3f$.

So for computationally unbounded adversaries it is natural to ask *are there relaxations of broadcast that circumvent the $n\leq 3f$ lower bound?* 


### Weak Broadcast

If we keep the agreement property and relax the validity property we arrive at the classic weak Byzantine Broadcast problem of [Lamport from 1984](https://zoo.cs.yale.edu/classes/cs426/2014/bib/lamport83theweak.pdf). 

A protocol solves the **weak broadcast** problem:
1. **Agreement**: If an honest party outputs $x$, then all honest parties output $x$.
2a. **Weak Validity**: If sender is honest, then all honest parties output either sender's value or *⊥*.
2b. **Non-triviality**: If all parties are honest, then all parties output the sender's value.
 
Note on lower bounds: [Fischer, Lynch, and Merritt](https://groups.csail.mit.edu/tds/papers/Lynch/FischerLynchMerritt-dc.pdf) show that weak broadcast is impossible for deterministic protocols for $n
\leq 3f$. For randomized protocols [Karlin and Yao 1984, unpublished](http://www.math.ucsd.edu/~ronspubs/89_08_byzantine.pdf) show that Broadcast must have a constant (more than $1/3$) error probability for $n\leq 3f$. 

This lower bound for randomized protocols does not hold for weak Broadcast. Using randomization, [Fitzi, Gisin, Maurer, and von Rotz 2002](https://iacr.org/archive/eurocrypt2002/23320478/qbc.pdf
) show that it is possible to solve weak broadcast for $n>2f$ with just a [negligible error probability](post on security definitions). 

### Crusader Broadcast and Gradecast

An alternate way to relax broadcast, is to keep the validity property and relax the agreement property. This gives us the **Crusader boradcats** of [Dolev 1981](http://infolab.stanford.edu/pub/cstr/reports/cs/tr/81/846/CS-TR-81-846.pdf).

A protocol solves the **crusader broadcast** problem:
1. **Weak Agreement**: If an honest party outputs x , then all honest parties output either x or ⊥.
2. **Validity**: If sender is honest, then all honest parties output the sender's value.

[Feldman and Micali 1988, 1997](https://people.csail.mit.edu/silvio/Selected%20Scientific%20Papers/Distributed%20Computation/An%20Optimal%20Probabilistic%20Algorithm%20for%20Byzantine%20Agreement.pdf) strengthened the definition of crusader agreement so the output of the protocol is both a decision value and a $grade \in \{0,1,2\}$.

A protocol solves the **Gradecast** problem:
1. **Grade**: each honest party outputs a $grade \in \{0,1,2\}$ in addition to a value.
1a. **Knowledge of Agreement**: If an honest party outputs x with grade 2 then all honest parties output $x$ with $grade \in \{1,2\}$.
1b.  **Weak Agreement**: If an honest party outputs x, then all honest parties output either x or ⊥.
2. **Validity**: If sender is honest, then all honest parties output the sender's value with grade $2$.


### Broadcast with Abort

Unconditional Byzantine Agreement and
Multi-Party Computation Secure Against
Dishonest Minorities from Scratch
https://iacr.org/archive/eurocrypt2002/23320478/qbc.pdf



Secure Multi-Party Computation Without Agreement
Shafi Goldwasser
Yehuda Lindell

http://groups.csail.mit.edu/cis/pubs/shafi/2002-disc.pdf
https://eprint.iacr.org/2002/040.pdf


Detectable Byzantine Agreement Secure Against Faulty
Majorities

https://groups.csail.mit.edu/tds/papers/Smith-Adam/fghhs-PODC2002-new-final.pdf









A protocol solves the **broadcast with abort** problem:
1. **Weak Agreement**: If an honest party outputs x, then all honest parties output either x or ⊥.
2a. **Weak Validity*: If sender is honest, then all honest parties output either sender's value or ⊥.
2b. **Non-triviality**: If all parties are honest, then all parties output the sender's value.







