---
title: What is Consensus?
date: 2019-06-25 00:00:00 -07:00
published: false
tags:
- dist101
authors:
- Kartik Nayak
- Ittai Abraham
---

<p align="center">
  co-authored with <a href="https://users.cs.duke.edu/~kartik">Kartik</a> <a href="https://twitter.com/kartik1507">Nayak</a>
</p>

We all broadly understand "consensus" as the notion of different parties agreeing with each other. In distributed computing, Consensus is one of the core functionalities. In this post, we define the Consensus problem and discuss some variants and their differences.

> In modern parliaments, the passing of decrees is hindered by disagreement among legislators
> -- <cite> Leslie Lamport, [Part-Time Parliament](https://lamport.azurewebsites.net/pubs/lamport-paxos.pdf) </cite>

Lets begin with the simplest consensus problem: agreement.


## The Agreement problem
In this problem we assume a set of $n$ nodes where each node $i$ has some input $v_i$ from some known set of input values $v_i \in V$. A protocol that solves Agreement must have the following properties.

**(agreement):** no two honest nodes *decide* on different values.

**(validity):** if all honest nodes have the same input value $v$ then $v$ must be the decision value.

**(termination):** all honest nodes must eventually *decide* on a value in $V$ and terminate.



Obviously Agreement is easily solvable if all nodes are honest and the system is synchronous. To make the problem non-trivial we need to fix the communication model [Synchrony, Asynchrony or Partial synchrony](https://ittaiab.github.io/2019-06-01-2019-5-31-models/) and then fix the [threshold of the adversary](https://ittaiab.github.io/2019-06-17-the-threshold-adversary/) and other details about the [power](https://ittaiab.github.io/2019-06-07-modeling-the-adversary/) of the adversary.

In the _binary agreement problem_ we assume the set of possible inputs $V$ contains just two values: 0 and 1.

For lower bounds it's often beneficial to define an even easier problem of _agreement  with weak validity_ where we replace validity with:

**(weak validity):** if all nodes are honest and all have the same input value $v$ then $v$ must be the decision value.


## The Broadcast problem
Here we assume a designated node, often called the leader (or dealer) that has some input $v$. A protocol that solves Broadcast must have the following properties.

**(agreement):** no two honest nodes *decide* on different values.

**(validity):** if the leader is honest then $v$ must be the decision value.

**(termination):** all honest nodes must eventually *decide* on a value in $V$ and terminate.


Observe that the two problems are deeply connected. A nice exercise is to try to solve Broadcast given Agreement. A good exercise is to try to solve agreement given Broadcast.

