---
title: Flavours of Partial Synchrony
date: 2019-09-13 18:00:00 -04:00
tags:
- dist101
author: Ittai Abraham
---

This is a follow up post to the post on [Synchrony, Asynchrony and Partial synchrony](https://ittaiab.github.io/2019-06-01-2019-5-31-models/). The partial synchrony model of [DLS88](https://groups.csail.mit.edu/tds/papers/Lynch/jacm88.pdf) comes in two flavours: **GST** and **Unknown Latency**. In this post we discuss:

1. why, *in practice*, the GST flavour seems to be a better model of the real world.
2. why, *in theory*, the two flavours are equivalent.


### The GST flavour of Partial Synchrony

The **Global Stabilization Time** (GST) model for Partial Synchrony assumes that:
1. there is an event called *GST* that occurs after some finite time.
2. there is no bound on message delays before *GST*, but after *GST* all message must arrive within some known bound $\Delta$.

The real world definitely does not behave like this, so why is this model so popular? its because it abstracts away a much more plausible model of how networks behave:

1. say 99% of the time the network is stable and message delays are bounded. For example, it's probably true that internet latencies are less than a second 99% of the time (more formally, the 99% percentile of latency is less than a second).
2. during times of crisis (for example, when under a Denial-of-Service attack) there is no good way to bound latency.

The *GST* flavour allows to build systems that perform well in the *best case* but maintain safety even if the conservative assumptions on latency fail in *rare cases*. This allows protocol designers to fix the parameter $\Delta$ based on reasonably conservative values.

### The Unknown Latency flavour of Partial Synchrony
In the UL flavour, the system is always *synchronous*, but the bound of the maximum delay is *unknown* to the protocol designer.

There are several advantages of this flavour in terms of simplicity. First, it requires fewer parameters (no GST, just $\Delta)$. Second, it avoids defining asynchronous communication.  

The way the *Unknown Latency* models the real world is somewhat problematic, it essentially strives to set the latency of the protocol to be as large as the *worst case* latency that will ever occur.

Unlike the GST flavour where $\Delta$ can be set conservatively, in the UL flavour the estimation of latency needs to grow based on the worst case behavior of the system.

In fact, many early academic BFT systems had mechanisms that **double** the protocol's estimation of $\Delta$ each time there was a timeout. [Prime](http://www.dsn.jhu.edu/pub/papers/Prime_tdsc_accepted.pdf) showed that this may cause a serious denial of service attack.

### Theoretical equivalence of both flavours of Partial Synchrony

The two flavours are in theory equivalent: any protocol that solves consensus in one flavour can be transformed into a protocol that solves it in the other flavour.

### From Global Stabilization Time to Unknown Latency

Assume we have a protocol $P$ that obtains safety and liveness in the GST flavour. How can we transform it to a protocol $P'$ to obtain safety and liveness in the Unknown Latency flavour?

$P$ must have a timeout mechanism that is based on the parameter that represents the latency after GST. Let's assume this parameter is $\Lambda$.

[DLS88](https://groups.csail.mit.edu/tds/papers/Lynch/jacm88.pdf) propose an elegant solution: start with some estimation $\Lambda$ of the actual UL parameter $\Delta$. Each time a protocol timeout expires, increment $\Lambda$.

Clearly, such a protocol is safe (by definition, it is safe even in asynchrony). For liveness, at some point $\Lambda$ will grow to be large enough (more than $\Delta$). At that point and onwards, liveness will be obtained.

In terms of efficiency:
1. incrementing $\Lambda$ too slowly means that it may take a lot of time to reach consensus. This is a type of a denial-of-service that slows down the system.
2. incrementing  $\Lambda$ too aggressively (say by doubling) means that while we may reach  $\Lambda>\Delta$ quickly, it may still happen that there are at least $f$ more timeouts due to malicious primaries. So $\Lambda$ may grow exponentially. This again may cause a denial-of-service that slows down the system.

In practice systems often adjust their estimate of $\Delta$ both up and down (sometimes using and explore-exploit type online learning algorithm). 


### From Unknown Latency to Global Stabilization Time

Assume we have a protocol $Q$ that obtains safety and liveness in the Unknown Latency flavour. How can we transform it to a protocol $Q'$ to obtain safety and liveness in the GST flavour?

That's quite easy: let $\Gamma$ be the maximum of $\Delta$ and the time until $GST$ starts and observe that if a protocol has safety and liveness assuming that the unknown latency is $\Gamma$ then clearly it must have safety and liveness in the GST flavour. Since we assume our protocol works for any finite latency we are done.

Again note that this reduction is extremely wasteful: the value of $\Gamma$ may be huge. Again real systems may want to adjust their estimate of $\Delta$ both up and down.

**Acknowledgment.** We would like to thank [L. Astefanoaei](https://twitter.com/3zambile)  for helpful feedback on this post.

Please leave comments on [Twitter](https://twitter.com/ittaia/status/1181013611491184640?s=20)
