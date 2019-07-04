---
title: The Trusted Setup Phase
date: 2019-07-03 17:29:00 -07:00
published: false
tags:
- dist101
- models
layout: post
---

<p align="center">
  co-authored with <a href="https://www.yanai.io/">Avishay Yanai</a>
</p>

When any system is described, one of the first things you need to ask is: *does it have a trusted setup phase?*

You can ask this for any of your favorite systems. 
Here is a good question: does Bitcoin have a trusted setup phase?

Many protocols in distributed computing and cryptography require a **trusted setup**. A trusted setup is a special case of a multi-phase protocol. We call the first phase the *setup phase* and the second phase the *main phase*. There are two properties that often distinguish a setup phase from the main phase:

1. Typically the main phase implements some repeated task. The setup phase is done once and enables repeating many instances of the main phase.

2. The setup phase is often *input independant*, namely, it does not use the private inputs of the parties. Furthermore, sometimes the setup phase is even *function independent*, meaning that the specific function that the parties wish to compute is irrelevant; the parties at this phase only know that they want to compute *some* function. As such, the setup and main phases are often called *offline* (or *preprocessing*) and *online* respectively (i.e. parties may run the offline phase when they realize that *in some later point in time* they will want to run some function on inputs they do not know yet). 

You can think of a setup phase as an ideal functionality run by a completely trusted entity that we take for granted. For instance, assuming Public-Key Infrastructure means that we assume there is a completely trusted entity to which every party submits its own public encryption (and verification) key and that entity broadcasts those keys to all parties. 
In this post we will review some of the common types of trusted setup assumptions by looking at the ideal functionalities that they imply.

We can model the ideal functionality implied by a setup phase as the evaluation $r_1,r_2,...,r_n \gets F(R)$. That is, suppose there are $n$ parties, the functionality evaluates the function $F$ on a uniformly random string $R$ and outputs $r_i$ to the $i$-th party engaged in the protocol. Note that the function may result with different, possibly correlated, $r_i$'s. In the following we argue that most of those functionalities fall into one of out of four categories below, depending on whether its input $R$ and/or outputs $r_i$'s are kept private from the parties. INTERNAL: I think this abstraction is not sufficient for the categorization we want to make, I want to think about it a little bit more.

1. *Minimal setup*: This is simplest case, in which we don't even run $F$ in the setup phase (in other words, the setup phase does not require randomness). Note that even here we do rely on a functionality that at least assigns identities to the parties. INTERNAL: Does bitcoin needs this functionality that assign identities? I think this point should be rephrased..
2. *Public input and output*: We assume setup whose implementation requires no secrets. The canonical example is a [PKI setup](https://en.wikipedia.org/wiki/Public_key_infrastructure) that requires just [broadcast](https://ittaiab.github.io/2019-06-27-defining-consensus/) to convey the public keys. 
3. *Private input and public output*: often called the *Common Reference String* [CRS](https://en.wikipedia.org/wiki/Common_reference_string_model) model. Many cryptographic protocols leverage this setup for improved efficiency. A special case of this setup is a [randomness beacon](http://www.copenhagen-interpretation.com/home/cryptography/cryptographic-beacons).
4. *Generic setup*: often called the *offline phase* in the context of SMPC protocols. Here the setup phase computes rather complex output that is party dependant. For example, [OT and multiplication triples](https://github.com/bristolcrypto/SPDZ-2).

Lets detail these four setup variants, give some examples and discuss their advantages and disadvantages. In the end we will also discuss some potential alternatives for having a setup phase.


## No setup
When a protocol has no setup then there is nothing to worry about. It's easier to trust such protocols. On the other hand, there are inherent limitations. For example, the [FLM](https://groups.csail.mit.edu/tds/papers/Lynch/FischerLynchMerritt-dc.pdf) lower bounds show that even weak forms of Byzantine Agreement are impossible for $n \geq 3f$ when there is no setup.


## Fully public setup
The canonical example are protocols that use a trust third party to [broadcast](https://ittaiab.github.io/2019-06-27-defining-consensus/) the public keys of all parties. 

For Byzantine agreement, there is a risk of a circular argument: With a PKI setup it is possible to solve Byzantine agreement in the synchronous model for $n=2f+1$. But setting up a PKI requires broadcast which requires $n>3f$ if there is no PKI.

Advantages: an important advantage of a fully public setup is its relative simplicity and reduced attack surface.

Risks: failure of this setup often means equivocation. Giving different parties different keys may cause later protocols to fail.

## Setups that require secrets to compute a common public value

Having a trusted pre-computed procedure with secret values often provides significant benefits.  The risk of these setups is that the properties of the system now depend on the *privacy* of the setup. It is much harder to detect the event of information leak during setup (an attacker that learns secrets can hide this knowledge).

The advantage of requiring the setup to publish a common public value is that it's relatively easy to ensure this property (relative to sending private values to parties). This model is often referred to as a *Common Reference String* [CRS](https://en.wikipedia.org/wiki/Common_reference_string_model) model.
Here we give two examples:

1. Setup for efficient Verifiable Secret Sharing
[Kate, Zaverucha, and Goldberg](https://www.cypherpunks.ca/~iang/pubs/PolyCommit-AsiaCrypt.pdf) propose a scheme that requires a trusted setup to generate a random public generator $g$ and a secret key $alpha$. The setup then broadcast powers of the form $g^(\alpha^i)$. Using this setup one can obtain the most efficient [Asynchronous Verifiable Secret Sharing](https://eprint.iacr.org/2012/619). 

2. Setup for efficient Zero-Knowledge
Several efficient Zero-Knowledge protocols require CRS setups. Often implementing these setups in a trusted manner requires some non-trivial [MPC](http://u.cs.biu.ac.il/~lindell/MPC-resources.html) protocol. For example, see [Bowe, Gabizon and Miers](https://eprint.iacr.org/2017/1050). In fact just running an SMPC protocol is not enough, often a whole [setup ceremony](https://z.cash/technology/paramgen/) is necessary in order to create a publicly trusted setup.

## Generic Setup protocols
This is the most general form of setup. Obviously the big advantage here is the power to run powerful protocols and the risk is also that the complexity of these protocols creates a relatively large attack surface.

We focus here on two type of examples: Distributed Key Generation and Offline phases for Secure Multi-Party Computation.


1. Distributed Key Generation and setup for threshold signatures

[Threshold](https://www.iacr.org/archive/eurocrypt2000/1807/18070209-new.pdf) signatures [schemes](https://www.iacr.org/archive/pkc2003/25670031/25670031.pdf) often provide benefits in terms of reduced word complexity and reduced total computation cost (see for example [here](https://eprint.iacr.org/2000/034.pdf)). The problem with threshold signatures is that they require a setup.




Setting up a threshold signature scheme is often referred to as a Distributed Key Generation [DKG](https://en.wikipedia.org/wiki/Distributed_key_generation) algorithm. This setup is a specialized form of a [SMPC](https://en.wikipedia.org/wiki/Secure_multi-party_computation) protocol.

Risks: There are two things that can fail in such a setup, the first is that the secret is leaked and the second is that some parties receive incorrect shares. There are ways for a party to verify the validity of their shares, so the main risk is when parties are offline.
 
2. TALK HERE ABOUT OT SETUP AND TRIPTET SETUP ETC...

...
risks (??) and advantages (much faster online phase) 

# Are there alternatives to Trusted Setups?

Here he mention two alternatives:
1. On the one hand assuming a trusted setup allows running very efficient protocols but on the other hand shifts considerable amount of trust from the online phase of the system to some historic setup phase. This introduces new risks and security holes. 

One potential solution is to have a never-ending setup phase. In these schemes there is a *continuously updatable CRS*. One recent example is [SONIC](https://eprint.iacr.org/2019/099.pdf).

2. Another approach it to have multiple setups generating multiple common reference strings.
In this approach we assume that some fraction of them is done in a trusted manner. See [Groth and Ostrovsky](https://eprint.iacr.org/2006/407.pdf).
