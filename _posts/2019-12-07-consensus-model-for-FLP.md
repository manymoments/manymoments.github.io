---
title: Consensus Lower Bounds via Uncommitted Configurations
date: 2019-12-07 09:05:00 -08:00
published: false
tags:
- dist101
- lowerbound
author: Ittai Abraham
---

In this series of three posts, we discuss two of the most important consensus lower bounds:
1. [Lamport, Fischer \[1982\]](https://lamport.azurewebsites.net/pubs/trans.pdf): any protocol solving consensus in the *synchronous* model that is resilient to $t$ crash failures must have an execution with at least $t+1$ rounds.
2. [Fischer, Lynch, and Patterson \[1983, 1985\]](https://groups.csail.mit.edu/tds/papers/Lynch/jacm85.pdf): any protocol solving consensus in the *asynchronous* model that is resilient to even one crash failure must have an infinite execution.

The modern interpretation of these lower bounds is the following:
* **Bad news**: Without using randomness, asynchronous consensus is *impossible*, and synchronous consensus is *slow*.
* **Good news**: With randomization, consensus (both in synchrony and in asynchrony) is possible in a *constant expected number of rounds*. Randomness does not circumvent the lower bounds; it just reduces the probability of bad events implied by the lower bounds. In synchrony, the probability of slow executions can be made exponentially small. In asynchrony, termination happens  [almost surely](https://en.wikipedia.org/wiki/Almost_surely). Formally, the *probability measure* of the complement of the event of terminating in some finite number of rounds is zero.


### The plan

This is a series of three posts:
1. In this *first* post, we provide important definitions and prove the  *Initial Lemma*. This lemma shows that any consensus protocol has some initial input where the the adversary has control over the decision value (it can cause it to be either 0 or 1). This lemma will be used in both lower bounds.

2. In the *second* post, we use the approach of [Aguilera and Toueg \[1999\]](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.22.402&rep=rep1&type=pdf) to show that any protocol solving consensus in the *synchronous* model that is resilient to $t$ crash failures must have an execution with at least $t+1$ rounds. The proof uses the definitions and the lemma in this post.

3. In the *third* post, we show the celebrated [Fischer, Lynch, and Patterson \[1985\]](https://groups.csail.mit.edu/tds/papers/Lynch/jacm85.pdf) result that any protocol solving consensus in the *asynchronous* model that is resilient to even one crash failure must have an infinite execution. The proof uses the same definitions and the lemma in this post.




### Definitions
We assume $n$ parties. Each party is a state machine that has some *initial input* $\in \{0,1\}$. The state machine has a special *decide* action that irrevocably sets its *decision* $\in \{0,1\}$.

We say that a protocol $\mathcal{P}$ solves *agreement against $t$ crash failures* if in any execution with at most $t$ crash failures:
1. **Termination**: all non-faulty parties eventually decide.
2. **Agreement**: all non-faulty parties decide on the same value.
3. **Validity**: if all non-faulty parties have the same input value, then this is the decision value.



Given, $\mathcal{P}$, a *configuration* of a system is just the state of all the parties and the set of all pending, undelivered messages.

The goal of $\mathcal{P}$ is to reach a configuration where all non-faulty parties decide. The *magic moment* of any consensus protocol is when a protocol reaches a *committed configuration*. This is a configuration where no matter what the adversary does, the eventual decision value is already fixed. Note that the point when a configuration becomes committed is an ˛event that is only externally observable. There is no local indication of this event and this can happen much before any party can actually decide!


We choose to use new names to these definitions, which we feel provide a more intuitive and modern viewpoint. The classical names are *bivalent configuration* for uncommitted configuration and *univalent configuration* for committed configuration.


The following formal definitions are crucial:

1. We write **$C \rightarrow C'$**: If in configuration $C$ there is an undelivered message $e$ (or all undelivered messages $E$ in the synchronous model) such that configuration $C$ changes to configuration $C'$ by delivering $e$ (or delivering all $E$ in the synchronous model).
2. We write **$C \rightsquigarrow C'$**: If there exists a sequence $C = C_1 \rightarrow C_2 \rightarrow \dots \rightarrow C_k=C'$ ($\rightsquigarrow$ is the [transitive closure](https://en.wikipedia.org/wiki/Transitive_closure) of $\rightarrow$).
3. **$C$ is a *deciding* configuration**:  if all non-faulty parties have decided in $C$. We say that $C$ is  *1-deciding* if the common decision value is 1, and similarly that $C$ is *0-deciding* if the decision is 0.

    Note that its very easy to check if a configuration is deciding - just look at the local state of each non-faulty party.

4. **$C$ is an *uncommitted* configuration**:  if it has a future 0-deciding configuration and a future 1-deciding configuration. There exists $C \rightsquigarrow D_0$ and $C \rightsquigarrow D_1$ such that $D_0$ is 0-deciding  and $D_1$ is 1-deciding.

    Said differently, an *uncommitted configuration* is a configuration where the adversary still has control over the decision value. There are some adversary actions (crash events, message delivery order) that will cause the parties to decide 0 and some adversary actions that will cause the parties to decide 1.

    An uncommitted configuration is a state of a system as a whole, not something that can be observed locally. Note that there is no simple way to know if a configuration is uncommitted. It requires examining all the possible future configurations (all possible adversary actions).

5. **$C$ is a *committed* configuration**: if every future deciding configuration $D$ (such that $C \rightsquigarrow D$) is deciding on the *same* value. We say that $C$ is *1-committed* if every future ends in a 1-deciding configuration, and similarly that $C$ is *0-committed* if every future ends in a 0-deciding configuration.

    Said differently, a *committed configuration* is a configuration where the adversary has no control over the decision value. When a configuration is committed to $v$, no matter what the adversary does, the decision value will eventually be $v$.

    Note that there is no simple way to know if a configuration is committed or uncommitted. In particular there is no local indication in the configuration, and it may well be that no party knows that the configuration is committed.








### The existence of an initial uncommitted configuration

With the new definitions, one way to state the validity property is: if all non-faulty parties have the same input $b$ then that initial configuration must be $b$-committed.

So perhaps all initial configurations are committed? The following lemma shows that this is not the case: every protocol that can tolerate even one crash failure must have some initial configuration that is *uncommitted*.

**Initial Lemma ([Lemma 2 of FLP85](https://lamport.azurewebsites.net/pubs/trans.pdf))**: If $\mathcal{P}$ solves agreement against at least one crash failure, then $\mathcal{P}$ has an initial *uncommitted* configuration.

A recurring  **proof pattern** for showing the existence of an uncommitted configuration will appear many times in these three posts. We start by stating it in an abstract manner:
1. Proof by *contradiction*: assume all configurations are either 1-committed or 0-committed.
2. Define some notion of adjacency. Find *two adjacent* configurations $C$ and $C'$ such that $C$ is 1-committed and $C'$ is 0-committed.
3. Reach a contradiction due to an indistinguishability argument between the two adjacent configuration $C$ and $C'$. The adjacency allows the adversary to cause indistinguishability via *crashing of just one* party.

**Proof of the Initial Lemma** fits this pattern perfectly:
1. Seeking a contradiction, assume there is no initial configuration that is uncommitted. So all initial configurations are either 1-committed or 0-committed.
2. Define two initial configurations as *$i$-adjacent* if the initial value of all parties other than party $i$ are the same. Consider the sequence (or path) of $n+1$ adjacent initial configurations: $(1,\dots,1),(0,1,\dots,1),(0,0,1\dots,1),\dots,(0,\dots,0)$. Clearly, the leftmost is 1-committed and the rightmost is 0-committed. Obviously, there must be some party $i$ such that the two $i$-adjacent configurations $C,C'$ are 0-committed and 1-committed, respectively.
3. Now consider in both worlds $C$ and $C'$ the case where party $i$ crashes right at the start of the protocol. These two worlds are indistinguishable for all non-faulty parties, which, therefore, must decide the same value. This is a contradiction.

This proves that any protocol $\mathcal{P}$ must have some initial uncommitted configuration. The next two posts will use the existence of an initial uncommitted  configuration and extend it to more rounds!


**Proof by example for n=3**:
Consider the 4 initial configurations $(1,1,1), (0,1,1),(0,0,1),(0,0,0)$. By validity, configuration $(1,1,1)$ must be 1-committed and configuration $(0,0,0)$ must be 0-committed. Seeking a contradiction, lets assume none of the 4 initial configurations is uncommitted. So both $(0,1,1)$ and $(0,0,1)$ are committed. Since all 4 initial configurations are committed there must be two adjacent configurations that are committed to different values. W.l.o.g. assume that $(0,1,1)$ is 1-committed and $(0,0,1)$ is 0-committed. Now suppose that in both configurations, party 2 crashes right at the start of the protocol. Clearly both configurations look like $(1,CRASH,0)$. So both worlds must decide the same, but this is a contradiction because one is 1-committed and the other is 0-committed.  

**Acknowledgment.** We would like to thank Kartik for helpful feedback on this post.


Please leave comments on [Twitter](...)
