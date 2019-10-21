---
title: Flavours of Broadcast
date: 2019-10-21 07:44:00 -07:00
published: false
tags:
- dist101
Field name: 
---

What is the difference between broadcast, crusader broadcast, gradecast, weak broadcast and broadcast with abort? This post is a follow up to our basic post on: [What is Broadcast?](https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/)

Let's start by defining the basic *Broadcast problem* again. We assume a set of $n$ parties. One party is designated as being called the *sender*. We assume the sender has some initial *value*.

A protocol solves the (classic) **broadcast** problem:
1. **Agreement**: If an honest party outputs $x$, then all honest parties output $x$.
2. **Validity**: If sender is honest, then all honest parties output the sender's value.

### Weak Broadcast

If we keep the agreement property and relax the validity property we arrive to the classic weak Byzantine Broadcast problem of [Lamport 84](https://zoo.cs.yale.edu/classes/cs426/2014/bib/lamport83theweak.pdf). A protocol solves the **weak broadcast** problem:
1. **Agreement**: If an honest party outputs x, then all honest parties output x.
2a. **Weak Validity**: If sender is honest, then all honest parties output either sender's value or ⊥.
2b. **Non-triviality**: If all parties are honest, then all parties output the sender's value.
 
Note on lower bounds: https://groups.csail.mit.edu/tds/papers/Lynch/FischerLynchMerritt-dc.pdf FLM lower bound

### Crusader Broadcast and Gradecase

An alternate way to relax broadcast, is to keep the validity property and relax the agreement property. This gives us the **Crusader boradcats** of [Dolev 81](http://infolab.stanford.edu/pub/cstr/reports/cs/tr/81/846/CS-TR-81-846.pdf).

A protocol solves the **crusader broadcast** problem:
1. **Weak Agreement**: If an honest party outputs x , then all honest parties output either x or ⊥.
2. **Validity**: If sender is honest, then all honest parties output the sender's value.

Feldman and Micali

(Gradecast is even stronger, so call this gradecast)





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







