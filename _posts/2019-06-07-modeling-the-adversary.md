---
title: Modeling the adversary
date: 2019-06-07 10:00:00 -07:00
published: false
tags:
- dist101
- models
layout: post
---

Once we fix the communication model (synchrony, asynchrony, or partial synchrony see [here](https://ittaiab.github.io/2019-05-31-2019-5-31-models/)), and we fix a [threshold adversary]() we still need to make important modeling decisions about the adversary power.

Here we will use the simplest model is that of a _threshold adversary_ with a static group of **_n_** nodes. We will later consider dynamic and permissionless models.

There are 5 important parameters for a threshold adversary: (1) the size of the threshold, (2) the type of corruption, (3) the computational power of the adversary, (4) the visibility of the adversary, (5) the adaptivity of the adversary.


### Size of the threshold
A threshold adversary is an adversary that controls some **_f_** nodes. There are three typical thresholds:
1. $n>f$ where the adversary can control all parties but one. Sometime called dishonest majority.
2. $n>2f$ where the adversary controls a minority of the nodes.
3. $n>3f$ where the adversary controls less than a third of the nodes.

### Type of corruption
The next critical aspect is what type of corruption the adversary can inflict on the $f$ nodes. There are three classic adversaries: Crash, Omission, and Byzantine.

_Crash_ : after the node is corrupted it stops sending and receiving all messages.

_Omission_ : once corrupted, the adversary can decide, for each message sent or received, to either drop or allow it to continue.

_Byzantine_ : this gives the adversary full power to control the node and take any (arbitrary) action on the corrupted node.

Note that each corruption subsumes the previous.
There are other types of corruptions (most notable are variants of _Covert_ [adversaries](https://eprint.iacr.org/2007/060.pdf)) that we will cover later.


### Computational power of the adversary
The computational power of the adversary is the next choice. There are two basic options:
1. _Unbounded_ : the adversary has  unbounded computational power.
2. _Computationally bounded_ : typically meaning that the adversary cannot (except with negligible probability) break the cryptographic primitives being used. For example, typically assume the adversary cannot forge signatures of nodes not in his control. 

### Visibility of the adversary 
The visibility is the power of the adversary to see and control messages and states of the non-corrupted parties. Again, there are two basic variants.

1. _Full information_ : here we assume the adversary sees the internal state of _all_ parties and the content of _all_ message sent.
3. _Private channels_ : in this model we assume the adversary cannot see the internal state of honest parties and cannot see the internal content of messages between honest parties. The adversary does know when a message is being sent and depending on the communication model can decide to delay it by any value that is allowed by the communication model.

### Adaptivity of the adversary 
Adaptivity is the ability of the adversary to corrupt dynamically based on information the adversary learns during the execution. There are two basic modes: static and adaptive. The adaptive model was several variants but we will cover only the simplest one.

1. _Static_ : the adversary has to decide which _f_ nodes to corrupt in advance before the execution of the protocol.

2. _Adaptive_ : the adversary can decide dynamically as the protocol progresses who to corrupt. The main parameter that still needs to be decided is how long it takes between the adversary _decision_ to corrupt and the _event_ that the control is passed to the adversary. One standard assumption is that this is instantaneous. We will later review several other options and discuss important nuances in this standard assumption.
