---
title: Progress in synchronous protocols
date: 2019-10-13 19:58:00 -07:00
published: false
author: Kartik Nayak
tags:
- dist101
- synchronus protocols
---

In this post, we overview synchronous consensus protocols and their progress in the last few decades. Due to the different modeling assumptions and constraints under which BFT protocols are modeled, it is often hard to compare two protocols and understand their relative contributions. In this post, we explain the assumptions made in synchronous protocols and present a timeline of synchronous consensus protocols that use digital signatures.

Generally, whenever a protocol is assumed to be running in the synchronous setting, they mean either or both of the following:
- **Bounded message delay.** All messages will arrive within a bounded delay $\Delta$.
- **Lock-step execution.** Replicas execute the protocol in rounds where they start and end a round at the same time. 

**Lock-step execution vs. bounded message delay.** Some papers refer to their protocol latency in terms of \#rounds, whereas some others in terms of $\Delta$. It turns out, that one can obtain lock-step execution from a bounded message delay assumption, by simply using a *clock synchronization* protocol. Due to works by Dolev et al. and Abraham et al., we have protocols with $O(n^2)$ message complexity to achieve clock synchronization. They show that lock-step round can be implemented in $2\Delta$ time. Thus, conceptually, the two assumptions boil down to just assuming a bounded message delay.

**Are the above assumptions reasonable?** For practitioners, the assumptions may seem strong. First, if the bounded message delay assumption does not hold even for a single message, then we may have a safety violation. Second, if lock-step execution is required, it may be hard to implement in practice. Finally, waiting for multiple rounds/$\Delta$’s implies poor latency to commit. Research in the synchronous setting has been improving all of these aspects to bring synchrony closer to practice.

**Well, why should we tackle all of these problems and improve synchronous protocols?** Because the lower bound by [DLS](https://decentralizedthoughts.github.io/2019-06-25-on-the-impossibility-of-byzantine-agreement-for-n-equals-3f-in-partial-synchrony/) says that we cannot tolerate a minority corruption by making weaker assumptions such as partial synchrony/asynchrony. (Due to the [FLM](https://decentralizedthoughts.github.io/2019-08-02-byzantine-agreement-is-impossible-for-$n-slash-leq-3-f$-is-the-adversary-can-easily-simulate/) lower bound, digital signatures/PoW is also necessary to disallow an adversary from simulating multiple parties and tolerate a minority corruption.)

*A note on the bounded message delay.* Bounded message delay $\Delta$ refers to a pessimistic bound on the time it takes a message to arrive. In practice, the actual message delay in the network, denoted as $\delta$, can be much smaller.

**History of synchronous conensus protocols.** 
- \[1982\] The first synchronous protocol in the Byzantine setting was introduced by Lamport, Shostak, and Pease. Their protocol, however, required an exponential communication complexity. 
- \[1982\] Dolev and Strong improved this protocol to have a simple and elegant Byzantine Broadcast construction with polynomial message complexity. Their protocol required every replica to only send up to two messages to every other replica (but each message could be a chain of size $O(f)$). However, the protocol executed for O(n) synchronous rounds to tolerate f < n-1 Byzantine faults. 
- \[1982\] Separately, it was also shown by Lamport and Fischer that that an $O(f)$ round latency is necessary for any deterministic synchronous protocol. Thus, Dolev-Strong was optimal in terms of commit latency for deterministic protocols. 
- \[2006\] Katz and Koo showed the first expected $O(1)$ round protocol with $O(n^2)$ communication. More specifically, their protocol required 29 rounds in expectation against an adaptive adversary. 
- \[2017\] Abraham et al. showed a conceptually simpler version of the Katz-Koo protocol that terminates in 10 rounds against a static adversary (and 16 rounds against an adaptive adversary). Their work also introduced the clock synchronization protocol for translating rounds to $\Delta$’s while still maintaining $O(n^2)$ message complexity.
- \[2018\] Dfinity ... 
