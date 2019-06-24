---
title: On the impossibility of Byzantine Agreement for $n \leq 3 f$  in Partial synchrony
date: 2019-06-16 07:06:00 -07:00
published: false
tags:
- dist101
- lowerbound
---

The following is a simplified and high level overview of the [DLS88](https://groups.csail.mit.edu/tds/papers/Lynch/jacm88.pdf) lower bound from section 4.3 (in particular see Theorem 4.4).

One of the most basic lower bounds is the impossibility of Byzantine Agreement when $n \leq  3f$ in Partial Synchrony. Here we consider the case $n=3f$ but it can easily be adapted to any $n \leq 3f$.

Seeking a contradiction, let's assume there is a protocol _P_ that claims to solve Byzantine Agreement and it terminates after the honest parties send at most an expected _x_ messages (no matter what the adversary does) after GST.

We will have three sets of nodes: _A,B,C_ where each set contains _f_ parties and all the parties in _B_ are corrupt. Moreover, let's assume all the honest parties in _A_ start with 1 and all the honest parties in _C_ start with 0.

The adversary will launch the classic **split-brain** attack:
1. Since it controls delays during the asynchronous phase, it will delay all communication between _A_ and _C_.
2. The corrupt parties in _B_ will behave as if they have input of 1 towards _A_ and as if they have input of 0 towards _C_.

We now claim that if the adversary does this and delays messages for long enough (say waits for _4x_ messages) then the parties in _A_ will decide 1 and the parties in _B_ will decide 0 with a (large) constant probability. The proof uses the powerful idea of **indistinguishability**.

The view of the parties in _A_ during this execution is identical to a synchronous execution where _A,B_ are honest and start with 1 while _C_ have crashed.

Similarly, the view of the parties in _C_ during this execution is identical to a synchronous execution where _C,B_ are honest and start with 0 while _A_ have crashed.

## Notes

1. This lower bound holds even if we assume a secure setup between the parties.
2. This lower bound holds even if the adversary is static.
3. This lower bound holds even for protocols that solve Byzantine Agreement with some small constant error probability.
4. A similar lower bound for crash (or omission) failures holds for $n\leq 2f$. This is a good exercise. 

## More formal definitions

In the most basic binary Byzantine Agreement problem there are $n$ nodes and each node has an input of either 0 or 1. Each honest node must decide on a value 0 or 1. Once decided a node cannot change his mind. We say that a protocol solves Byzantine Agreement if
1. (validity): if all honest have the same input then this is the decision of all honest.
2. (agreement): no two honest decide different values.
3. (termination): all honest eventually decide.

This definition can be extended to randomized protocols that allow some $0<\epsilon <0.1$ probability of error.

