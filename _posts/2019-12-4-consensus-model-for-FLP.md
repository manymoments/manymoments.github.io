---
title: 'Consensus Lower Bounds via Uncommitted Configurations'
date: 2019-12-4 09:05:00 -08:00
published: false
tags:
- dist101
- lowerbound
author: Ittai Abraham
---


In this series of posts we discusses two of the most important consensus lower bounds:
1. [Lamport, Fischer 1982](https://groups.csail.mit.edu/tds/papers/Lynch/jacm85.pdf): any protocol solving consensus in the *synchronous* model that is resilient to $t$ crash failures must have an execution with at least $t+1$ rounds.
2. [Fischer, Lynch, and Patterson 1983, 1985](https://lamport.azurewebsites.net/pubs/trans.pdf) any protocol solving consensus in the *asynchronous* model that is resilient to even one crash failure must have an infinite execution.

The modern interpretation of these lower bounds:
* **Bad news**: Without using randomness: asynchronous consensus is *impossible* and synchronous consensus is *slow*.
*  **Good news**: with randomization, consensus (both in synchrony and in asynchrony) is possible in a constant expected number of rounds. Randomness does not circumvent the lower bounds, it just reduces the probability of bad events implied by the lower bounds. In synchrony, the probability of slow executions is exponentially small. In asynchrony, the infinite execution will [almost surly](https://en.wikipedia.org/wiki/Almost_surely) not happen (will happen with probability $0$).


### The plan

This is a three post series:
1. In this *first* post we will provide the models and definitions and prove the important *Initial Uncommitted Lemma*: any consensus protocol has some initial input that makes the problem non-trivial.

2. In the *second* post we use the approach of [Aguilera and Toueg 1999](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.22.402&rep=rep1&type=pdf) to show that any protocol solving consensus in the *synchronous* model that is resilient to $t$ crash failures must have an execution with at least $t+1$ rounds. The proof will use the models, definitions and the Initial Uncommitted Lemma of this post.

3. In the third post we show the celebrated [Fischer, Lynch, and Patterson 1985](https://lamport.azurewebsites.net/pubs/trans.pdf) result that any protocol solving consensus in the *asynchronous* model that is resilient to even one crash failure must have an infinite execution. The proof will use the same models, definitions and the Initial Lemma of this post.




### Models and Definitions
We assume $n$ parties. Each party $i$ is a  state machine that has some *initial input* $v_i \in \{0,1\}$. The state machine has a special *decide*
 action that irrevocably sets its decision $d_i \in \{0,1\}$.

We say that a protocol $\mathcal{P}$ solves agreement against $t$ crash failures if in any execution with at most $t$ crash failures:
1. **Termination**: all non-faulty parties eventually decide.
2. **Agreement**: all non-faulty parties decide on the same value.
3. **Validity**: if all non-faulty parties have the same input value then this is the decision value.



A *Configuration* of a system is just the state of all the parties and the set of all incoming undelivered messages. The following definitions are crucial:

1. We write **$C \rightarrow C'$**: If in configuration $C$ there is an undelivered message $e$ (or all undelivered messages $E$ in the synchronous model) such that configuration $C$ changes to configuration $C'$ by delivering $e$ (or delivering all $E$ in the synchronous model).
2. We write **$C \rightsquigarrow C'$**: If there exists a sequence $C=C_1 \rightarrow C_2 \rightarrow \dots \rightarrow C_k=C'$ ($\rightsquigarrow$ is the [transitive closure](https://en.wikipedia.org/wiki/Transitive_closure) of $\rightarrow$).
3. **$C$ is a *deciding* configuration**:  if all non-faulty parties have decided in $C$. We say that $C$ is  *1-deciding* if the decision is 1 and the $C$ is *0-deciding* if the decision is 0.
4. **$C$ is an *uncommitted* configuration**:  if it can become 0-deciding and 1-deciding. There exists $C \rightsquigarrow D_0$ and $C \rightsquigarrow D_1$ such that $D_0$ is 0-deciding  and $D_1$ is 1-deciding.
5. **$C$ is a *committed* configuration**: if every deciding configuration $D$ such that $C \rightsquigarrow D$ is deciding on the same value. We say that $C$ is *1-committed* if every future deciding configuration  is 1-deciding, and similarly that $C$ is *0-committed* if every future ends in a 0-deciding configuration.


The magic moment of any consensus protocol is when a protocol reaches a committed configuration. Note that this event happens much before any party can actually decide!


Note that we chose to use new names to these definitions that we feel provide a more intuitive and modern viewpoint (the classical names are *bivalent* for uncommitted and *univalent* for committed).




### Initial Uncommitted Lemma: existence of an  initial uncommitted configuration

With our new definitions, one way to state the validity property is: if all non-faulty parties have the same input $b$ then that initial configuration must be $b$-committed.

So perhaps all initial configurations are committed? The following lemma shows that this is not the case: every protocol that can tolerate even one crash failure must have an  initial  configuration that is *uncommitted*.

**Initial Uncommitted Lemma ([Lemma 2 of FLP85](https://lamport.azurewebsites.net/pubs/trans.pdf))**: $\mathcal{P}$ has an initial uncommitted configuration.

A recurring  **proof pattern** for showing the existence of an uncommitted configuration will appear many times in these three posts:
1. Proof by *contradiction*: assume all configurations are either 1-committed or 0-committed.
2. Find a *local structure*: two adjacent configurations $C$ and $C'$ such that $C$ is 1-committed and $C_0$ is 0-committed.
3. Reach a contradiction due to an indistinguishability argument between the two adjacent configuration $C$ and $C'$. The adjacency will allow  the adversary to cause indistinguishability via crashing of just one party.

The **proof** of the Initial Uncommitted Lemma fits this pattern perfectly:
1. Assume all initial configurations are either 1-committed or 0-committed.
2. Define two initial configuration as $i$-adjacent if the initial value of all parties other than party $i$ are the same. Consider the sequence of adjacent initial configurations: $(1,\dots,1),(0,1,\dots,1),(0,0,1\dots,1),\dots,(0,\dots,0)$ clearly the leftmost is 1-committed and the rightmost is 0-committed. Obviously, there must be some party $i$ such that the two $i$-adjacent configurations $C,C'$ are 0-committed and 1-committed.
3. Now consider in both worlds $C$ and $C'$ the case where party $i$ immediately crashes. Clearly these two worlds are indistinguishable and must decided the same value. This is a contradiction.

The next two posts will use the existence of this uncommitted configuration and extend it to more rounds!
