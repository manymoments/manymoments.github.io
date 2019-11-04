---
title: Authenticated Synchronous BFT
date: 2019-11-03 11:12:00 -08:00
published: false
---

Different modeling assumptions under which we construct BFT protocols often make it hard to compare two protocols and understand their relative contributions. In this post we discuss *[synchronous](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/)* protocols in the *[authenticated](https://decentralizedthoughts.github.io/2019-07-18-setup-assumptions/)* model (assuming a PKI). 

A protocol is assumed to be running in the [synchronous model](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) assumes that:
- **Bounded message delay.** All messages will arrive within a bounded delay of $\Delta$.

A common strengthening of synchronous model is called that *lock-step* model:
- **Lock-step execution.** Replicas execute the protocol in rounds in a synchronized manner. A message sent at the start of a round arrives by the end of the round.

**Lock-step execution vs. bounded message delay.** Some papers refer to their protocol latency in terms of \#rounds, whereas some others in terms of $\Delta$. It turns out that one can obtain lock-step execution from a bounded message delay assumption, by merely using a *clock synchronization* protocol. Due to works by [Dolev et al.](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.499.2250&rep=rep1&type=pdf) and [Abraham et al.](https://eprint.iacr.org/2018/1028.pdf), we have solutions with $O(n^2)$ message complexity to achieve such synchronization. Specifically, they show that a $2\Delta$ time suffices to implement a lock-step round. Thus, conceptually, the two assumptions boil down to just assuming a bounded message delay.

### Is the synchronous model practical?
For practitioners, the synchrony assumption may seem strong. First, if the bounded message delay assumption does not hold *even* for a single message, then we may have a safety violation. Second, lock-step execution may be hard to implement in practice. Finally, waiting for multiple rounds/$\Delta$’s implies a high latency to commit. Research in the synchronous setting has been improving all of these aspects to bring synchrony closer to practice.


### The advantage of authenticated synchrony: tolerating a minority corruption
The [DLS](https://decentralizedthoughts.github.io/2019-06-25-on-the-impossibility-of-byzantine-agreement-for-n-equals-3f-in-partial-synchrony/) lower bound implies that we cannot tolerate a minority corruption by making weaker assumptions such as partial synchrony/asynchrony. The [FLM](https://decentralizedthoughts.github.io/2019-08-02-byzantine-agreement-is-impossible-for-$n-slash-leq-3-f$-is-the-adversary-can-easily-simulate/) lower bound implies that  digital signatures/PoW is also necessary to disallow an adversary from simulating multiple parties and tolerate a minority corruption.

Before we continue here are two subject this post in **not** about:
1. This post is not about BFT protocol in the partial synchrony model, like the ones discussed [here](https://decentralizedthoughts.github.io/2019-06-23-what-is-the-difference-between/).
2. This post is not about permissionless BFT protocols, like [Nakamoto](https://bitcoin.org/bitcoin.pdf) [Consensus](https://eprint.iacr.org/2014/765.pdf) in the synchronous model that use proof-of-work and do not assume a PKI.

To evaluate and compare authenticated synchronous protocols we analyze them in the following dimensions:
1. *Consensus definition/application.* Whether the protocol was intended to solve Byzantine Broadcast ([BB]((https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/))), Byzantine Agreement ([BA]((https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/))), or State Machine Replication ([SMR]((https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/))).
2. *Lock-step vs bounded-message delay.* Whether the protocol requires a lock-step execution of parties/replicas, or can they  rely only on bounded-message delay.
3. *Latency to commit.* For protocols with lock-step execution, we mention the (expected) \#rounds to commit. For protocols which only assume bounded-message delay, we mention the latency in terms of $O(\Delta)$. Using the clock synchronization protocol described earlier, each round can be implemented in $2\Delta$ time. For protocols in SMR that use the [steady-state-and-view-change paradigm](https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/), we mention the latency as a tuple of (steady state time to commit, time for view change).
4. *Message complexity.* The (expected) number of signatures sent by honest parties.
5. *Optimistic responsiveness (OR).* Some protocols can commit in time independent of $\Delta$ when certain *optimistic* conditions hold. e.g., the number of Byzantine adversaries are much lesser than minority. We will discuss this further in a separate post.
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


|   |  Type | Sync/ Lock-Step  | Adaptive/ Partial  | Round Complex  | Message Complex  | Responsive|
|---|---|---|---|---|---|---|
| [Lamport, Shostak, and Pease, 82](https://people.eecs.berkeley.edu/~luca/cs174/byzantine.pdf)  | Agrement  |  Step |   |   | $O(2^n)$  | N |
| [Dolev and Strong, 82](https://www.researchgate.net/publication/220616485_Authenticated_Algorithms_for_Byzantine_Agreement)  |  Broadcast | Step | Adaptive  |  $O(n)$ | $O(n^3)$ | N |
| [Katz and Koo, 06](https://eprint.iacr.org/2006/065.pdf)  | Agrement  | Step  | Adaptive  | $O(1)$  | $O(n^3)$  |  N |
| [XFT protocol, 16](https://www.usenix.org/system/files/conference/osdi16/osdi16-liu.pdf)  | SMR  | Sync  | Partial  | $O(2^n)$  |   | Y |
| [Abraham et al., 17](https://eprint.iacr.org/2018/1028.pdf)  |  A | Step  | Adaptive  | $O(1)$  |  $O(n^2)$ | N |
| [Dfinity Consensus, 18](https://eprint.iacr.org/2018/1153.pdf)  |  SMR | Sync  | Partial  | $O(1)$  | $O(n^2)$  | N |
| [Chan, Pass, Shi, 2018](https://eprint.iacr.org/2018/980.pdf)    | SMR | Sync  | Partial  | $O(1)$ | $(n^2)$| Y |
|  [Sync HotStuff, 19](https://eprint.iacr.org/2019/270.pdf)  | SMR  | Sync  | Partial  | $O(1)$  |  $O(n^2)$ | N |


tolerance
threshold signatures
mobile sluggish model

## old


**Timeline of synchronous consensus protocols.** 
- \[1982\] [Lamport, Shostak, and Pease](https://people.eecs.berkeley.edu/~luca/cs174/byzantine.pdf) introduced the first synchronous protocol in the Byzantine setting. Their protocol, however, required an exponential message complexity. 
- \[1982\] [Dolev and Strong](https://www.researchgate.net/publication/220616485_Authenticated_Algorithms_for_Byzantine_Agreement) provide a simple and elegant [Byzantine Broadcast](https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/) construction with polynomial message complexity. Their protocol required every replica to only send up to two messages to every other replica (but each message could be a chain of size $O(f)$ signatures). However, the protocol executed for $O(n)$ synchronous rounds to tolerate $f < n-1$ Byzantine faults. For a large $n$, the latency is not desirable.
- \[1982\] Separately, it was also shown by [Lamport and Fischer](https://lamport.azurewebsites.net/pubs/trans.pdf) that an $O(f)$ round latency is necessary for any deterministic synchronous protocol. Thus, Dolev-Strong was optimal in terms of commit latency for deterministic protocols. 
- \[2006\] [Katz and Koo](https://eprint.iacr.org/2006/065.pdf) showed the first expected $O(1)$ round protocol with $O(n^2)$ communication assuming $n>2f$. Their protocol required 29 rounds in expectation against an adaptive adversary. 
- \[2016\] The [XFT protocol](https://www.usenix.org/system/files/conference/osdi16/osdi16-liu.pdf) also assume a PKI and $n>2f$ and suggest a different approach to architect the system; in the steady-state, the protocol only relied on messages from a fixed, predetermined set of $f+1$ of replicas. If these replicas are all honest,  they could run the protocol without waiting for any network delay $\Delta$. However, if there are failures, they need to view-change to a new fixed all-honest majority of replicas. It turns out that if the number of faults $f$ is high (e.g., linear in $n$), as is tolerated by most consensus protocols, one will require an *exponential* number of view-changes to arrive at all-honest majority replicas. Thus, XFT provides an interesting design point where the steady-state is fast (independent of $\Delta$), but convergence to the steady state can be extremely slow.
- \[2017\] [Abraham et al.](https://eprint.iacr.org/2018/1028.pdf) showed a different version of the Katz-Koo protocol that terminates in 10 rounds against a static adversary and 16 rounds against an adaptive adversary. Using threshold signatures they obtain the first $O(n^2)$ message complexity protocol in this setting. Their work also introduced the clock synchronization protocol for translating rounds to $\Delta$’s while still maintaining $O(n^2)$ message complexity.
- \[2018\] [Dfinity Consensus](https://eprint.iacr.org/2018/1153.pdf) showed a protocol that takes expected $8\Delta$ time to achieve consensus (assuming $\delta << \Delta$). Similar to XFT, some steps of their protocol did not rely on $\Delta$, and the replicas could run at the "network speed." Importantly, all replicas participated in all views and did not require an exponential number of view-changes. 
- \[2019\] Recently, [Sync HotStuff](https://eprint.iacr.org/2019/270.pdf) presented a simple solution in the SMR setting with a $2\Delta$ latency under a stable leader. This will be discussed more in a later post.

**Remark.** All protocols derived from Nakamoto consensus rely on synchrony. We will discuss them separately in a later post.
