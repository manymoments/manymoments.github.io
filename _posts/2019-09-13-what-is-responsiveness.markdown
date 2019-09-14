---
title: What is Responsiveness?
date: 2019-09-13 23:17:00 -07:00
published: false
tags:
- dist101
---

Intuitively speaking a protocol is **responsive** if it runs as fast as the network allows.

More formally, consider a model where messages arrive after at most $\delta$ time. We say that a protocol is responsive if the time to completion goes to zero as $\delta$ goes to zero.

Clearly any protocol that is live in an [asynchronous model] is responsive. In fact  one of the main advantages of protocols that work in the asynchronous model is that they do not depend on any timeout and can run as fast as the network allows them.

It turns out that reasoning about responsiveness is important even for protocols that are designed in the [partial synchrony] model or the synchrony model. Pass and Shi introduced the notion of *conditional responsiveness*. In this framework, there are some conditions and these conditions the protocol "runs as fast as the network allows".

### Responsiveness in Synchrony

Pass and Shi suggest the following striking idea: they design a protocol for Byzantine Agreement in the synchronous model assuming the adversary controls $f$ parties and that $f<n/2$. Their protocol has an additional surprising property: in execution where the adversary controls just $f<n/4$ parties then the protocol for  Byzantine Agreement is responsive. They call this optimistic responsiveness.

In executions where the adversary controls less than a forth, their protocol is responsive and in execution where the adversary controls less than a half, their protocol is still safe, but the time it takes to terminate depends on $\Delta$ (which is the upper bound for message delays), even if the real message delays $\delta$ are much smaller than $\Delta$ (even if $\delta << \Delta$). 

TALK ABOUT LOWER BOUNDS

### Responsiveness in Partial Synchrony

PBFT and SBFT are responsive

Tendermint and Casper are not

Can you get linearity and responsivness?
