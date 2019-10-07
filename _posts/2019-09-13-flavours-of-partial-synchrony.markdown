---
title: Flavours of Partial Synchrony
date: 2019-09-13 23:57:00 -07:00
tags:
- dist101
---

This is a follow up post to the post on [Synchrony, Asynchrony and Partial synchrony](https://ittaiab.github.io/2019-06-01-2019-5-31-models/). Here we discuss in more details the two flavours of partial synchrony from [DLS88](https://groups.csail.mit.edu/tds/papers/Lynch/jacm88.pdf): **GST** and **unknown latency**.

We discuss why *in practice* the GST flavour seems to be a better model of the real world and why *in theory*, the two flavours are equivalent.


### The GST flavour of Partial Synchrony

The **Global Stabilization Time** (GST) model for Partial Synchrony assumes that:
1. there is an event called *GST* that occurs after some finite time.
2. there is no bound on message delays before *GST*, but after *GST* all message must arrive within some known bound $\Delta$.

The real world definitely does not behave like this, so why is this model so popular? its because it abstracts away a much more plausible model of how networks behave:

1. say 99% of the time the network is stable and message delays are bounded. For example, it's probably true that internet latencies are less than a second 99% of the time (more formally the 99% percentile of latency is less than a second).
2. during times of crisis (for example when under a Denial of Service attack) there is no good way to bound latency.

The *GST* model allows to build systems that perform well in the best case but maintain safety even if the conservative assumptions on latency fail in rare cases. This allows protocol designers to fix the parameter $\Delta$ based on reasonably conservative values.

### The unknown latency flavour of Partial Synchrony
In the unknown latency model, the system is always synchronous, but the bound of the maximum delay is unknown to the protocol designer.

There are several advantages of this model in terms of simplicity. First, it requires less parameters (no GST, just $
Delta)$. Second, it avoids defining asynchronous communication.  

The way the *unknown latency* models the real world is somewhat problematic, it essentially strives to set the latency of the protocol to be as large as the worst case latency perceived so far.

Unlike the GST model where $\Delta$ can be set conservatively, in the unknown latency model the estimation of latency needs to grow based on the worst case.

In fact many early academic BFT systems had mechanisms that **double** the protocol's estimation of $\Delta$ each time there was a timeout. [Prime](http://www.dsn.jhu.edu/pub/papers/Prime_tdsc_accepted.pdf) showed that this causes a serious denial of service attack.

### The theoretical equivalence of both flavours of Partial Synchrony

We will now show that the two flavours are in theory equivalent: any protocol that solves consensus in one model can be transformed into a protocol that solves it in the other model.

### From GST to unknown latency

Assume we have a protocol that obtains safety and liveness in the GST flavour. How can we transform it to a protocol that runs in the unknown latency flavour?

[DLS88](https://groups.csail.mit.edu/tds/papers/Lynch/jacm88.pdf) propose a very elegant solution: start with some estimation $\Lambda$ of the actual unknown latency $\Delta$. Each time a protocol timeout expires, double $\Lambda$.

Clearly such a protocol is safe (its safe even in asynchrony). For liveness, at some point $\Lambda$ will grow to be more than $
\Delta$ (but no more than $2\Delta$) and at that point liveness will be obtained. In terms of efficiency, note that it may happen that even after $\Lambda>\Delta$ there may still happen at least $f$ timeouts due to malicious primaries. So $\Lambda$ may grow exponentially.


### From unknown latency to GST

Assume we have a protocol that obtains safety and liveness in the unknown latency flavour. How can we transform it to a protocol that runs in the GST flavour?

That's quite easy: let $x$ be the maximum of $\Delta$ and the time until $GST$ starts and observe that if a protocol has safety and liveness assuming that the unknown latency is $x$ then clearly it must have safety and liveness in the GST flavour. Since we assume our protocol works for any finite latency we are done.

Again note that this reduction is extremely wasteful: the value of $x$ may be huge.