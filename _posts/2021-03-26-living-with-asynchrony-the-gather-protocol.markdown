---
title: 'Living with Asynchrony: the Gather protocol'
date: 2021-03-26 06:54:00 -04:00
published: false
---

A very useful tool in the field of [asynchronus](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) distributed computing is [reliable broadcast](https://decentralizedthoughts.github.io/2020-09-19-living-with-asynchrony-brachas-reliable-broadcast/), or simply called *broadcast*. It allows parties to send and receive messages, knowing that other parties will receive the same messages as well, even if a malicious adversary control $f$ parties and $f<n/3$. Broadcast is deterministic and takes just a constant number of rounds. 


A natural extension of broadcast is a *multi-broadcast*, where each party has an input. Ideally, you may want all parties to *agree on the same set* of outputs - but this primitive, called *Agreement on a Core Set* (ACS) requires to solve consensus in asynchrony, [which we know cannot be done deterministically](https://decentralizedthoughts.github.io/2019-12-15-asynchrony-uncommitted-lower-bound/). Running ACS tyoically also incurs high costs, as $n$ binary agreemtns are required.



In this post we explore the suprising alternative, called **Gather**. To the best of our knowledge this primitive first appeared as the main building block in Cannetti and Rabin's [Asynchronouys Byzantine Agreemnt protocol](https://www.net.t-labs.tu-berlin.de/~petr/FDC-07/papers/CR93.pdf). This primitive has been used in [asynchronous approaximate agreement](https://www.cs.huji.ac.il/~ittaia/papers/AAD-OPODIS04.pdf) and Asuncjhroonous Distributed Key Generation. 


In a gather protocol, each party has an input, and all parties output sets of received values and the parties who sent them (i.e. of pairs $(j,x)$ where $j$ is the index of a party, and $x$ is the value it sent). In addition, there exists some core set $S^*$ of size at least $n-f$ that all nonfaulty parties include in their outputs. In order to avoid trivial solutions, if a nonfaulty party includes $(j,x_j)$ in its output, and $j$ is a nonfaulty party, then $x_j$ must be $j$'s input. Furthermore, all parties that include some pair for a party $j$ agree on the value it sent. More precisely, if two nonfaulty parties include the pairs $(j,x)$ and $(j,x')$ in their outputs, then $x=x'$. At first glance it seems like we are somehow cheating: the parties still agree on the core set and can just output it instead. The crucial observation here is that all parties output sets including $S^*$, but they don't necessarily know what $S^*$ is and can't output it instead.

The following protocol is actually a little stronger than described above, and it achieves a binding property that we will describe later.

## The basic Gather protocol

We will define $x_i$ to be party $i$'s input. Since this protocol uses broadcast, we will assume that $f<\frac{n}{3}$. The protocol proceeds in $4$ conceptual rounds that look very similar to each other:

1. Broadcast $x_i$ (using Bracha's Reliable Broadcast protocol).
2. Define the set $S_i$ of pairs $(j,x_j)$, where $x_j$ was received from $j$. Once $S_i$ contains $n-f$ pairs send $S_i$ to every party.
3. When receiving a message $S_j$ from party $j$, accept the message after receiving the broadcast $x_k$ from $k$ for every $(k,x_k)\in S_j$. After accepting $n-f$ sets $S_j$, send $T_i=\cup S_j$ to all parties.
4. When receiving a message $T_j$ from party $j$, accept the message after receiving the broadcast $x_k$ from $k$ for every $(k,x_k)\in T_j$. After accepting $n-f$ sets $T_j$, output $U_i=\cup T_j$.

See the similarity in rounds 3 and 4? it may seem like adding another identical round doesn't do much, but we will see that is not the case at all.
Lets try to understand the protocol gradually and see what each round adds to the process.

## Round breakdown

### Rounds 1-2
We start off by broadcasting values (via reliable broadcast), then collect $n-f$ broadcasted vause and send them as a set. The property we obtain is that *if an honest party accepts some set then eventually all honest parties will accept that set*. This propoerty is key for the livness of the protocol.


### Round 3
The first non-trivial property we achieve happens after nonfaulty parties accept $n-f$ $S$ sets:

* **Weak core**: Let $G$ be the $n-f$ first nonfuaty that complete round 3. There exists a round 2 set $S^*$ sent by a nonfualty party, and a set $W \subset G$ of size $|W|=f+1$, such that for any $i\in W$: $S^*\subseteq T_i$. 


We count how many sets are received by $G$ that are sent from nonfaulty parties in round 2. Since each party in $G$ gathers $n-f$ sets in round 3, then at least $n-2f$ of those set were sent from nonfaulty parties, and since $f<\frac{n}{3}$, $n-2f\geq f+1$. So, each nonfaulty party in $G$ receives round 2 sets from at least $f+1$ nonfaulty parties. In total, parties in $G$ receive *at least* $(f+1)(n-f)$ round 2 sets.

Assume the property above is false, so every round 2 set from a nonfaulty party is received by at most $f$ nonfaulty parties in $G$. This means that the total number of rounds 2 sets from nonfualty parties that are received by nonfaulty parties is *at most* *$f(n-f)$*. This is a contradiction (clearly $f(n-f)<(f+1)(n-f)$).



### Round 4

We use the weak core property to achieve a common core in one more round. 

* **Common core**: There exists a round 2 set $S^*$ sent by a nonfualty party that all nonfaulty parties include in their $U$ sets. 

By weak core, there is a set $S^*$ that at least $|W|=f+1$ nonfaulty parties include $S^*$ in their round 3 sets. Every nonfaulty party computes their round 4 sets as a union of $n-f$ round 3 sets. At least one such set must have come from $W$, hence $U$ mucst include $S^*$.


## How many words does gather use?

Each party sends a single broadcast, requiring $O(n^3)$ words to be sent overall. In addition we have a constant number of all-to-all communication rounds in which parties send sets of $O(n)$ elements to each other. This also totals in $O(n^3)$ words sent overall. This brings our sum-total to $O(n^3)$ words sent overall.

In future posts we will talk about how to enhance this protocol even further: add binding propoerties, add verification propoweries and see hoow cryptography can help... stay tuned!