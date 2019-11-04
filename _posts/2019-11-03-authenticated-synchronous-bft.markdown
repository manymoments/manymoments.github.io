---
title: Authenticated Synchronous BFT
date: 2019-11-03 11:12:00 -08:00
published: false
author: Kartik Nayak, Ittai Abraham
---

Different modeling assumptions under which we construct BFT protocols often make it hard to compare two protocols and understand their relative contributions. In this post we discuss *[synchronous](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/)* protocols in the *[authenticated](https://decentralizedthoughts.github.io/2019-07-18-setup-assumptions/)* model (assuming a PKI). 

A protocol is assumed to be running in the [synchronous model](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) assumes a **bounded message delay**, i.e., all messages will arrive within a bounded delay of $\Delta$. A common strengthening of synchronous model is *lock-step* synchrony, i.e., replicas execute the protocol in rounds in a synchronized manner. A message sent at the start of a round arrives by the end of the round.

**Lock-step execution vs. bounded message delay.** Some papers refer to their protocol latency in terms of \#rounds, whereas some others in terms of $\Delta$. It turns out that one can obtain lock-step execution from a bounded message delay assumption, by merely using a *clock synchronization* protocol. Due to works by [Dolev et al.](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.499.2250&rep=rep1&type=pdf) and [Abraham et al.](https://eprint.iacr.org/2018/1028.pdf), we have solutions with $O(n^2)$ message complexity to achieve such synchronization. Specifically, they show that a $2\Delta$ time suffices to implement a lock-step round. Thus, conceptually, the two assumptions boil down to just assuming a bounded message delay.

### Is the synchronous model practical?
For practitioners, the synchrony assumption may seem strong. First, if the bounded message delay assumption does not hold *even* for a single message, then we may have a safety violation. Second, lock-step execution may be hard to implement in practice. Finally, waiting for multiple rounds/$\Delta$’s implies a high latency to commit. Research in the synchronous setting has been improving all of these aspects to bring synchrony closer to practice.

### The advantage of authenticated synchrony: tolerating a minority corruption
The [DLS](https://decentralizedthoughts.github.io/2019-06-25-on-the-impossibility-of-byzantine-agreement-for-n-equals-3f-in-partial-synchrony/) lower bound implies that we cannot tolerate a minority corruption by making weaker assumptions such as partial synchrony/asynchrony. The [FLM](https://decentralizedthoughts.github.io/2019-08-02-byzantine-agreement-is-impossible-for-$n-slash-leq-3-f$-is-the-adversary-can-easily-simulate/) lower bound implies that  digital signatures/PoW is also necessary to disallow an adversary from simulating multiple parties and to tolerate a minority corruption.

### Comparing authenticated synchronous BFT protocols
To evaluate and compare authenticated synchronous protocols we analyze them in the following dimensions:
1. *Consensus definition.* Whether the protocol was intended to solve Byzantine Broadcast ([BB]((https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/))), Byzantine Agreement ([BA]((https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/))), or State Machine Replication ([SMR]((https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/))).
2. *Lock-step vs bounded-message delay.* Whether the protocol requires a lock-step execution of replicas, or can they  rely only on bounded-message delay.
3. *Latency to commit.* For protocols with lock-step execution, we mention the (expected) \#rounds to commit. For protocols which only assume bounded-message delay, we mention the latency in terms of $O(\Delta)$. For protocols in SMR that use the [steady-state-and-view-change paradigm](https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/), we mention the latency as a tuple of (steady state time to commit, time for view change).
4. *Message complexity.* The (expected) number of signatures sent by honest parties.
5. *Optimistic responsiveness (OR).* Some protocols can commit in time independent of $\Delta$ when certain *optimistic* conditions hold. e.g., the number of Byzantine adversaries are much fewer than minority. We will discuss this further in a separate post.
6. *Adaptive adversary.* Is the protocol resilient to an [adaptive adversary](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/)?

|                                                                                                                               | Defn  | Lock-step? | Latency                                             | Message complexity        | OR? | Adaptive? |
|-------------------------------------------------------------------------------------------------------------------------------|-------|------------|-----------------------------------------------------|---------------------------|-----|-----------|
| [LSP \[1982\]](https://people.eecs.berkeley.edu/~luca/cs174/byzantine.pdf)                               | BB/BA | Y          | $O(n)$ rounds                                       | $O(2^n)$                  | N   | Y         |
| [Dolev-Strong \[1982\]](https://www.researchgate.net/publication/220616485_Authenticated_Algorithms_for_Byzantine_Agreement) | BB    | Y          | $O(n)$ rounds                                       | $O(n^2f)$                 | N   | Y         |
| [Katz-Koo \[2006\]](https://eprint.iacr.org/2006/065.pdf)                                                                    | BA    | Y          | $29$ rounds                                         | $O(n^2)$                  | N   | Y         |
| [XFT \[2016\]](https://www.usenix.org/system/files/conference/osdi16/osdi16-liu.pdf)                                    | SMR   |            | $(O(\delta) rounds, O((n choose f) \Delta) rounds)$ | $(O(n), O((n choose f)))$ |     | N         |
| [Abraham et al. \[2017\]](https://eprint.iacr.org/2018/1028.pdf)                                                                 | BB/BA | Y          | $17$ rounds                                         | $O(n^2)$                  | N   | Y         |
| [Dfinity \[2018\]](https://eprint.iacr.org/2018/1153.pdf)                                                              | SMR   | N          | $9\Delta$                                           | Unbounded                 | N   | N         |
| [PiLi \[2018\]](https://eprint.iacr.org/2018/980.pdf)                                                                            | SMR   | Y          | $24$ rounds                                         | $O(n^2)$                  | Y   | N         |
| [Sync HotStuff \[2019\]](https://eprint.iacr.org/2019/270.pdf)                                                                   | SMR   | N          | $(2\Delta, 1\Delta)$                                | $(O(n^2), O(n^2))$        | Y   | N         |

**Notes.**
1. LSP and Dolev-Strong can tolerate a dishonest minority for Byzantine Broadcast.
2. The message complexity of protocols is described assuming the presence of threshold signatures.
3. PiLi and Sync HotStuff also consider weaker synchrony settings with *mobile sluggish faults*. The results in the table are described for assuming the standard synchrony definition. 


**Remark.** All protocols derived from Nakamoto consensus rely on synchrony. We will discuss them separately in a later post.
