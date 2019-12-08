---
title: Synchronous Consensus Lower Bound via Uncommitted Configurations
date: 2019-12-07 09:05:00 -08:00
published: false
tags:
- dist101
- lowerbound
author: Ittai Abraham
---

In this second post we show the fundamental lower bound on the number rounds for consensus protocols in the synchronous model.

**Theorem 1**: any protocol solving consensus in the *synchronous* model that is resilient to $t$ crash failures must have an execution with at least $t+1$ rounds.

We use the proof approach of [Aguilera and Toueg](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.22.402&rep=rep1&type=pdf) that is based on uncommitted configurations.


This post assumes you are familiar with the [definitions of the previous post](...) and with the Initial Uncommitted Lemma we proved in the previous post:


**Lemma 1: Initial Uncommitted ([Lemma 2 of FLP85](https://lamport.azurewebsites.net/pubs/trans.pdf))**: $\mathcal{P}$ has an initial uncommitted configuration.

To prove the theorem we will prove the following two Lemma:

**Lemma 2: Round $(t-1)$ Uncommitted ([Lemma 3 of AT99](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.22.402&rep=rep1&type=pdf))**: If $\mathcal{P}$ is tolerant to an adversary that can can crashe at most one party every round, then there must exists an uncommitted configuration in the end of round $t-1$.

Recall the **proof pattern** for showing the existence of an uncommitted configuration:
1. Proof by *contradiction*: assume all configurations are either 1-committed or 0-committed.
2. Define some notion of adjacency. Find *two adjacent* configurations $C$ and $C'$ such that $C$ is 1-committed and $C'$ is 0-committed.
3. Reach a contradiction due to an indistinguishability argument between the two adjacent configuration $C$ and $C'$. The adjacency allows  the adversary to cause indistinguishability via *crashing of just one* party.


The **proof** of the Round $(t-1)$ Uncommitted Lemma works by induction, each time showing an uncommitted configuration in round $0 \leq k \leq t-1$. The base case of $k=0$ follows from the  *Initial Uncommitted Lemma*. For the induction step,  assume we are at an uncommitted round $k$ configuration $C_k$ and show that there must exist a round $k+1$ uncommitted configuration $C_{k-1}$. Naturally we will use the recurring *proof pattern*:
1. Assume all round $k+1$ configurations $C_k \rightarrow C$  are either 1-committed or 0-committed.
2. Define two round-$k+1$ configuration $C,C'$ as *$j,i$-adjacent* if the only difference is that in $C$ party $j$ crashes right before sending to non-crashed party $i$ and in $C'$ party $j$ crashes right after sending to party $i$ (and $j$ is the only new crash happening in round $k+1$).

    2.1. Claim: there must exist two $j,i$-adjacent configurations at the end of round $k+1$ such that $C$ is 1-committed and $C'$ is 0-committed.

    2.2. Proof: assume with no crashes in round $k+1$ the system is 1-committed at the end of round $k+1$. There must be some party $j$ whose crash in $k+1$ before sending to $i$ changes the configuration to be 0-committed. In particular it cannot be that $j$ crashes after sending all its messages because that will be indistinguishable from $j$ crashing only in round $k+2$.



3. Now un-surprisingly, consider in both words $C$ and $C'$ the case where party $i$ crashes at the beginning of round k+2. Clearly these two worlds are indistinguishable and must decide the same value. This is a contradiction.

This concludes the proof of the Lemma 2.


So we reached round $t-1$ with an uncommitted configuration. Can we decide in one round and terminate in round $t$? The following Lemma shows we cannot, and completes the Theorem:

**Lemma 3: Round $t$ Cannot Always Decide ([Lemma 1 of AT99](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.22.402&rep=rep1&type=pdf))**: If $\mathcal{P}$ has an execution that crashes at most one party every round and leads to an uncommitted configuration in the end of round $t-1$, then in that execution $\mathcal{P}$ cannot always commit by the end of round $t$.


The **proof** is a trivial variation of the the **proof pattern** that looks at deciding configurations instead of committed configurations.

1. Assume that $\mathcal{P}$ always decides after $t$ rounds. So all $C_{t-1} \rightarrow C$ are either 0-deciding or 1-deciding.

2. Define two round-$t$ configurations $C,C'$ as *$j,i$-adjacent* if the only difference is that in $C$ party $j$ crashes right before sending to non-crashed party $i$ and in $C'$ party $j$ crashes right after sending to party $i$ (and $j$ is the only new crash happening in round $k+1$).  So there must exist two $j,i$-adjacent configurations in the end of round $t$ such that $C$ is 1-committed and $C'$ is 0-committed.


3. Given $n>t+1$ there are at least two non-crashed parties in round $t$, so at least one of them is not $i$ or $j$. However this honest has no way to distinguish between the two deciding configurations $C$ and $C'$. This is a contradiction.

This concludes the proof of Lemma 3. Which concludes the proof of Theorem 1.


####Discussion

The proof started with an  initial uncommitted configuration (Lemma 1) and then showed that we can continue for $t-1$ rounds to reach an uncommitted configuration (Lemma 2). Finally we used one more crash to show that we cannot always decide in $t$ rounds (Lemma 3). Note that the theorem is non-constructive and all it shows is that a $t+1$ round execution must exist (but does not say it must occur with high probability).

A fascinating observation from this lower bound is that in order to create a long execution the adversary must corrupt just party every round. This observation is critical for upper bounds and will be discussed in later posts.

In the next post we will show that the same proof approach can be used to show that in the *asynchronous* model there must exists an *infinite* execution even for protocols that are resilient to just one crash failure.
