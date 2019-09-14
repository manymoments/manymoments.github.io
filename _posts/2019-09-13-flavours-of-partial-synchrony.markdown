---
title: Flavours of Partial Synchrony
date: 2019-09-13 23:57:00 -07:00
published: false
tags:
- dist101
---

### the GST flavour

The standard "Global Stabilization Time" (GST) model for Partial Synchrony assumes that:
1. there is an event called GST that occurs after some finite time.
2. there is no bound on message delays before GST, but after GST all message must arrive within some known bound $\Delta$.

The real world definitely does not behave like this, so why is this model so popular? its because it abstracts away a much more plausible model of how networks behave:

1. in 99% of the time the network is stable and message delays are bounded. For example, it's probably true that internet latencies are less than a second 99% of the time.
2. during times of crisis (for example when under a Denial of Service attack) there is no good way to bound latency.

The GST model allows to build systems that perform well in the best case but maintain safety even if the conservative assumptions on latency fail in rare cases. In fact this allows protocol designers to choose $\Delta$ based on reasonably conservative values.

### the unknown latency model
In the unknown latency model, the system is always synchronous, but the bound of the maximum delay is unknown.

There are several advantages of this model. First, it requires less parameters. Second, it avoids defining and reasoning about asynchronous systems. 

The way the "unknown latency" models the real world is problematic, it essentially strives to set the latency of the protocol to be as large as the worst case latency perceived so far.

Unlike the GST model where $\Delta$ can be set conservatively, in the unknown latency model the estimation of latency needs to grow based on the worst case.

### the equivalence

We will now show that the two models are in theory equivalent: any protocol that solves consensus in one model can be transformed into a protocol that solves it in the other model.

The transformation from a protocol in GST to unknown is efficient.

however the transformation from a protocol in unknown to GST suffers from setting a huge latency...  
