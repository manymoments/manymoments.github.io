---
title: The power of the adversary
date: 2019-06-07 20:00:00 -07:00
tags:
- dist101
- models
author: Ittai Abraham
layout: post
---

Once we fix the communication model (synchrony, asynchrony, or partial synchrony see [here](/2019-06-01-2019-5-31-models/)), and we fix a [threshold adversary](/2019-06-17-the-threshold-adversary/) we still need to make important modeling decisions about the adversary power.

Here we will use the simplest model of a _threshold adversary_ that can control up to _f_ nodes given a static group of **_n_** nodes. We will later consider dynamic, permissionless, and bounded resource models.


In addition to the size of the threshold ($n>f$, $n>2f$, or $n>3f$), there are 4 more important parameters:

1. the type of corruption.
2. the computational power of the adversary.
3. the visibility of the adversary.
4. the adaptivity of the adversary.



### 1. Type of corruption
The next critical aspect is what type of corruption the adversary can inflict on the $f$ nodes is can corrupt. There are three classic adversaries: Crash, Omission, and Byzantine.

_Crash_ : once the node is corrupted, it stops sending and receiving all messages.

_Omission_ : once corrupted, the adversary can decide, for each message sent or received, to either drop or allow it to continue.

_Byzantine_ : this gives the adversary full power to control the node and take any (arbitrary) action on the corrupted node.

Note that each corruption type subsumes the previous.
There are other types of corruption (most notable are variants of _Covert_ [adversaries](https://eprint.iacr.org/2007/060.pdf)) that we will cover later. *Covert* adversaries can be used to model rational behavior of a fear of punishment.


### 2. Computational power 
The computational power of the adversary is the next choice. There are two traditional variants and one newer one:
1. _Unbounded_ : the adversary has unbounded computational power. This model often leads to notions of _perfect security_.
2. _Computationally bounded_ : the adversary is at most a polynomial advantage in computational power over the honest parties. Typically this means that the adversary cannot (except with negligible probability) break the cryptographic primitives being used. For example, typically assume the adversary cannot forge signatures of nodes not in his control (see [Goldreich's chapter one](http://www.wisdom.weizmann.ac.il/~oded/PSBookFrag/part1N.pdf) for traditional CS formal definitions of polynomially bounded adversaries). 
3. _Fine-grained computationally bounded_ : there is some concrete measure of computational power and the adversary is limited in a concrete manner. This model is used in proof-of-work based protocols. For example, see [Andrychowicz and Dziembowski](https://www.iacr.org/archive/crypto2015/92160235/92160235.pdf) for a way to model the hash rate.

### 3. Visibility 
The visibility is the power of the adversary to see the messages and the states of the non-corrupted parties. Again, there are two basic variants:

1. _Full information_ : here we assume the adversary sees the internal state of _all_ parties and the content of _all_ message sent. This often limits the protocol designer. See for example: [Feige's](www.wisdom.weizmann.ac.il/~feige/Others/leader.ps) selection protocols, or  [Ben-Or etal's](https://people.csail.mit.edu/vinodv/BA.pdf) Byzantine agreement. 
3. _Private channels_ : in this model we assume the adversary cannot see the internal state of honest parties and cannot see the internal content of messages between honest parties. The adversary does know when a message is being sent and depending on the communication model can decide to delay it by any value that is allowed by the communication model.

### 4. Adaptivity 
Adaptivity is the ability of the adversary to corrupt dynamically based on information the adversary learns during the execution. There are two basic variants: static and adaptive. The adaptive model has several sub-variants but we will cover here only the simplest one.

1. _Static_ : the adversary has to decide which _f_ nodes to corrupt in advance before the execution of the protocol.

2. _Adaptive_ : the adversary can decide dynamically as the protocol progresses who to corrupt based on what the adversary learns over time. The main parameter that still needs to be decided is how long it takes between the adversary _decision_ to corrupt and the _event_ that the control is passed to the adversary. One standard assumption is that this is instantaneous. Another is that it takes an additional round (for example [here](https://web.cs.ucla.edu/~rafail/PUBLIC/05.pdf)). We will later review several other options (for example, see [here](https://users.cs.duke.edu/~kartik/papers/podc2019.pdf)).

### Please leave comments on [Twitter](https://twitter.com/ittaia/status/1141481767121170434?s=20)
