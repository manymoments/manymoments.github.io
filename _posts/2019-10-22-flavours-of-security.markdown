---
title: Three basic types of Security
date: 2019-10-22 06:23:00 -07:00
published: false
---

Given a problem $X$ like [Agreement](https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/), and a protocol $P$. What does it mean that **$P$ solves $X$?**

There are three important notions of security that aim to formally define what **$P$ solves $X$** means. We will discuss them at a high level in this post.

### Perfect Security

This is the highest standard for solving a problem. We say that $P$ solves $X$ with **perfect security** when the desired properties $X$ are always maintained. For example, we could say that [Ben-Or's protocol](https://allquantor.at/blockchainbib/pdf/ben1983another.pdf) solves Asynchronous Byzantine Agreement with perfect security (but in exponential time). In particular, note that for perfect security there is no restriction on the adversary's computational power.

### Unconditional security

This definition still allows the adversary to have unbounded computational power, but now we allow the protocol to fail with some small probability. When we say that   $P$ solves $X$ with **unconditional security** we are typically saying that there is some security parameter $\lambda$ and some error probability $\epsilon=\epsilon(P,\lambda)$ such that when $P$ is instantiated with parameter $\lambda$ then the desired properties of $X$ are maintained with probability $1-\epsilon$.

In many cases we can choose $\lambda$ so that $P$ with $\lambda$ is still efficient and the resulting $\epsilon$ error probability is so low that we call the error probability *polynomial small* in the security parameter. For example, [Canetti and Rabin](https://www.net.t-labs.tu-berlin.de/~petr/FDC-07/papers/CR93.pdf) solve Asynchronous Byzantine Agreement with unconditional security. Their solution has optimal resilient and when they terminate they do it in constant expected time. Note that there is some small probability that their protocol does not reach agreement or event does not terminate. But that probability can be made exponentially small using polynomial sized messages.

### computational security

This definition assumes the adversary is *computationally bounded*. Just defining this notion requires 