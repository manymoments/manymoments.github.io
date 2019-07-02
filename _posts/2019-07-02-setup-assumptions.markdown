---
title: Setup assumptions
date: 2019-07-02 11:29:00 -07:00
published: false
tags:
- dist101
- models
---

Some protocols in distributed computing and cryptography require a **trusted setup**. In this post we will review some of the common assumptions and discuss the implications of setup.


## No setup
When a protocol has no setup then there is nothing to worry about. It's easier to trust such protocols. On the other hand, there are inherent limitations. For example, the [FLM](https://groups.csail.mit.edu/tds/papers/Lynch/FischerLynchMerritt-dc.pdf) lower bounds show that even weak forms of Byzantine Agreement are impossible for $n \geq 3f$.

## PKI setup
Protocols that assume a PKI setup assume that parties are computationally bounded, each party holds a private key and has broadcast its corresponding public key to all other parties.

This assumption implicitly assumes a trust third party that provides a [broadcast] functionality



no setup

PKI setup

CRS setup