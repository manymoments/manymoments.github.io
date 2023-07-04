---
title: Flavours of Partial Synchrony
date: 2019-09-13 18:00:00 -04:00
tags:
- dist101
author: Ittai Abraham
---

This is a follow up post to the post on [Synchrony, Asynchrony and Partial synchrony](https://ittaiab.github.io/2019-06-01-2019-5-31-models/). The partial synchrony model of [DLS88](https://groups.csail.mit.edu/tds/papers/Lynch/jacm88.pdf) comes in two flavours: **GST** and **Unknown Latency**. In this post we discuss:

1. why, *in practice*, the GST flavour seems to be a better model of the real world.
2. why, *in theory*, a solution for the Unknown Latency flavour implies a solution for the GST flavours - but the opposite is not clear.

{: .box-note}
**Important:** this post was updated in July 2023. The previous version of this post claimed the two flavours are equivalent but one direction of the proof was **incorrect**. To the best of my knowledge, formally resolving the relationship remains an **open question**. 


### The GST flavour of Partial Synchrony

The **Global Stabilization Time** (GST) model for Partial Synchrony assumes that:
1. There is an event called *GST* that occurs after some finite time. 
2. There is no bound on message delays before *GST*, but after *GST* all message must arrive within some known bound $\Delta$.

Note that in this model, there is no signal that GST happened and no party knows when GST will happen.

The real world definitely does not behave like this, so why is this model so popular? its because it abstracts away a much more plausible model of how networks behave:

1. Say 99% of the time the network is stable and message delays are bounded. For example, it's probably true that internet latencies are less than a second 99% of the time (more formally, the 99% percentile of latency is less than a second).
2. During times of crisis (for example, when under a Denial-of-Service attack) there is no good way to bound latency.

The *GST* flavour allows to build systems that perform well in the *best case* but maintain safety even if the conservative assumptions on latency fail in *rare cases*. This allows protocol designers to fix the parameter $\Delta$ based on reasonably conservative values.

### The Unknown Latency flavour of Partial Synchrony
In the *UL* flavour, the system is always *synchronous*, but the bound of the maximum delay is *unknown* to the protocol designer.

There are several advantages of this flavour in terms of simplicity. First, it requires fewer parameters (no GST, just $\Delta)$. Second, it avoids defining asynchronous communication.  

The way the *Unknown Latency* models the real world is somewhat problematic, it essentially strives to set the latency of the protocol to be as large as the *worst case* latency that will ever occur.

Unlike the GST flavour where $\Delta$ can be set conservatively, in the UL flavour the estimation of latency needs to grow based on the worst case behavior of the system.

For example, many early academic BFT systems had mechanisms that **double** the protocol's estimation of $\Delta$ each time there was a timeout. [Prime](http://www.dsn.jhu.edu/pub/papers/Prime_tdsc_accepted.pdf) showed that this may cause a serious denial of service attack.

### Theoretical relationship between the flavours of Partial Synchrony

We start with the easy observation that a protocol that solves agreement in the UL flavour also solves agreement in the GST model.

We then discus the challenges of a reduction in the other direction.

### From Unknown Latency to Global Stabilization Time

Assume a protocol $Q$ that obtains safety and liveness in the Unknown Latency flavour. Does $Q$ also obtain safety and liveness in the GST flavour?

Yes! consider an execution in the GST flavour and let $\Gamma$ be the maximum of $\Delta$ and the time until $GST$ starts. Observe that by definition, $Q$ has safety and liveness assuming that the unknown latency is $\Gamma$, because its true for any finite latency.

Note that this reduction is extremely wasteful: the value of $\Gamma$ may be huge. Many systems may strive to adjust their estimate of $\Delta$ both up and down.
### From Global Stabilization Time to Unknown Latency

{: .box-note}
**Important:** a previous version of this post claimed a solution for the GST flavour can be reduced in a black box manner to a solution for the UL flavour. The proof for that was **incorrect**.


For completeness, here is the failed proof approach: The idea was to start with some estimation $\Lambda$ of the actual UL parameter $\Delta$. Each time a protocol timeout expires, increment $\Lambda$.

For safety, we need to argue that incrementing $\Lambda$ does not break safety, one trivial way to do that is assume this is a property of $P$. It is not clear that a generic protocol has this property. For example, as currently stated, $P$ may do very different things for different values of $\Lambda$.

For liveness, the idea was to say that at some point $\Lambda$ will grow to be large enough. At that point and onwards, we need to argue that the protocol obtains liveness. Again one trivial way to do that is assume this is a property of $P$. It is not clear that a generic protocol has this property. For example, perhaps liveness of $P$ is lost when the timeouts are too large?

Nevertheless, this idea of dynamically incrementing the estimation of the maximum latency is a well used technique:

In terms of efficiency:
1. incrementing $\Lambda$ too slowly means that it may take a lot of time to reach consensus. This is a type of a denial-of-service that slows down the system.
2. incrementing  $\Lambda$ too aggressively (say by doubling) means that while we may reach  $\Lambda>\Delta$ quickly, it may still happen that there are at least $f$ more timeouts due to malicious primaries. So $\Lambda$ may grow exponentially. This again may cause a denial-of-service that slows down the system.

In practice systems often adjust their estimate of $\Delta$ both up and down (sometimes using an explore-exploit type online learning algorithm). 




**Acknowledgment.** We would like to thank [L. Astefanoaei](https://twitter.com/3zambile)  for helpful feedback on this post.

We would like to thank Ling Ren and Tim Roughgarden for pointing out the incorrect proof in the previous version.

Please leave comments on [Twitter](https://twitter.com/ittaia/status/1181013611491184640?s=20)
