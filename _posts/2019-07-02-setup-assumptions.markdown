---
layout: post
title: Setup assumptions
date: 'Tue Jul 02 2019 21:29:00 GMT+0300 (Eastern European Summer Time)'
published: false
tags:
  - dist101
  - models
---

Some protocols in distributed computing and cryptography require a **trusted setup**. In this post we will review some of the common assumptions and discuss the implications of trustung the setup and what happens if it fails.


## No setup
When a protocol has no setup then there is nothing to worry about. It's easier to trust such protocols. On the other hand, there are inherent limitations. For example, the [FLM](https://groups.csail.mit.edu/tds/papers/Lynch/FischerLynchMerritt-dc.pdf) lower bounds show that even weak forms of Byzantine Agreement are impossible for $n \geq 3f$ when there is no setup.

## PKI setup
Protocols that assume a [PKI setup](https://en.wikipedia.org/wiki/Public_key_infrastructure) assume that parties are computationally bounded, each party holds a private key and has broadcast its corresponding public key to all other parties.

This assumption implicitly assumes a trust third party that provides a [broadcast](https://ittaiab.github.io/2019-06-27-defining-consensus/) functionality for every party. 

For Byzantine agreement, there is often a risk of a circular argument: With a PKI setup it is possible to solve Byzantine agreement in the synchronous model for $n=2f+1$. But setting up a PKI requires broadcast which requires $n>3f$ if there is no PKI.

## Setups with only public operations

Generalizing the PKI setup, we can consider any setup procedure that requires an ideal functionality that does not hide information. The advantage of these functionalities is that it's often easier to detect that they failed. 

For example, suppose you assume a trusted PKI but later discover that some party did not get the correct public key. If the public output of the setup is verifiable, then propegating this output can sometimes help.

## Setup for threshold signatures

Some trusted setups require the use of secret values. These procedures require assuming the privacy is not violated during the trusted setup phase.

One example of such a setup is the use of threshold signatures (see [Shoup](https://www.iacr.org/archive/eurocrypt2000/1807/18070209-new.pdf) or [BLS](https://www.iacr.org/archive/asiacrypt2001/22480516.pdf) [threshold](https://www.iacr.org/archive/pkc2003/25670031/25670031.pdf)). This scheme requires a trusted setup that distributes shares of a secret private key.

There are two things that can fail in such a setup, the first is that the secret is leaked and the second is that some parties receive incorrect shares. There are ways for a party to verify the validity of their shares, so the main risk is when parties are offline.
 

## Setups that require secrets to compute a common public value

Having a trusted pre-computed procedure with secret values often provides significant benefits.  The risk of these setups is that the properties of the system now depend on the *privacy* of the setup. It is much harder to detect the event of information leak during setup (an attacker that learns secrets can hide this knowledge).

The advantage of requiring the setup to publish a common public value is that it's relatively easy to ensure this property (relative to sending private values to parties). This model is often referred to as a *Common Reference String* [CRS](https://en.wikipedia.org/wiki/Common_reference_string_model) model.



### Setup for efficient Secret Sharing
[Kate, Zaverucha, and Goldberg](https://www.cypherpunks.ca/~iang/pubs/PolyCommit-AsiaCrypt.pdf) propose a scheme that requires a trusted setup to generate a random public generator $g$ and a secret key $alpha$. The setup then broadcast powers of the form $g^(\alpha^i)$. 

### Setup for efficient Zero-Knowledge
Several Zero-Knowledge protocols require CRS setups. Often implementing these setups in a trusted manner requires some [MPC](http://u.cs.biu.ac.il/~lindell/MPC-resources.html) protocol. For example see [here](https://eprint.iacr.org/2017/1050). In fact just running an SMPC protocol is not enough, often a whole [setup ceremony](https://z.cash/technology/paramgen/) is necessary.

### It's not a setup if its a never ending event
On the one hand assuming a trusted setup allows running very efficient protocols but on the other hand shifts considerable amount of trust from the online phase of the system to some historic setup phase. This introduces new risks and security holes. 

One potential solution is to have a never-ending setup phase. In these schemes there is a *continuously updatable CRS*. One recent example is [SONIC](https://eprint.iacr.org/2019/099.pdf).
