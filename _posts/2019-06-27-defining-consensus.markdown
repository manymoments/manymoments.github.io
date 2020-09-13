---
title: What is Consensus?
date: 2019-06-27 00:00:00 -07:00
tags:
- dist101
author: Kartik Nayak, Ittai Abraham
---

We all broadly understand "consensus" as the notion of different parties agreeing with each other. In distributed computing, Consensus is one of the core functionalities. In this post, we define the consensus problem and discuss some variants and their differences.

> In modern parliaments, the passing of decrees is hindered by disagreement among legislators
> -- <cite> Leslie Lamport, [Part-Time Parliament](https://lamport.azurewebsites.net/pubs/lamport-paxos.pdf) </cite>

Let us begin with the simplest consensus problem: agreement.


## The Agreement Problem
In this problem, we assume a set of $n$ nodes where each node $i$ has some input $v_i$ from some known set of input values $v_i \in V$. A protocol that solves Agreement must have the following properties.

**(agreement):** no two honest nodes *decide* on different values.

**(validity):** if all honest nodes have the same input value $v$ then $v$ must be the decision value.

**(termination):** all honest nodes must eventually *decide* on a value in $V$ and terminate.



Obviously, Agreement is easily solvable if all nodes are honest and the system is synchronous. To make the problem non-trivial we need to fix the communication model [synchrony, asynchrony or partial synchrony](https://ittaiab.github.io/2019-06-01-2019-5-31-models/) and then fix the [threshold of the adversary](https://ittaiab.github.io/2019-06-17-the-threshold-adversary/) and other details about the [power](https://ittaiab.github.io/2019-06-07-modeling-the-adversary/) of the adversary.

In the _binary agreement problem_, we assume the set of possible inputs $V$ contains just two values: 0 and 1.

For lower bounds it's often beneficial to define an even easier problem of _agreement  with weak validity_ where we replace validity with:

**(weak validity):** if all nodes are honest and all have the same input value $v$ then $v$ must be the decision value.


### Uniform vs. non-uniform agreement
In addition to the properties above, we can place an additional requirement on what values faulty nodes can commit -- this is especially relevant when faulty nodes are either crash or omission faults. If the faulty nodes do not commit to a different value from the honest nodes, then we call the agreement property *uniform agreement*. Otherwise, it is a *non-uniform agreement*. The difference will be relevant in a [state machine replication](https://ittaiab.github.io/2019-06-07-modeling-the-adversary/) setting since this determines the "number of replica responses" the client needs to wait for.

## The Broadcast Problem
Here we assume a designated node, often called the leader (or dealer) that has some input $v$. A protocol that solves Broadcast must have the following properties.

**(agreement):** no two honest nodes *decide* on different values.

**(validity):** if the leader is honest then $v$ must be the decision value.

**(termination):** all honest nodes must eventually *decide* on a value in $V$ and terminate.


Observe that the two problems are deeply connected. A nice exercise is to try to solve Broadcast given Agreement. Another good exercise is to try to solve Agreement given Broadcast.

