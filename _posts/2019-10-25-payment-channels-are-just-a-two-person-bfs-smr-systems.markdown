---
title: A Payment Channel is just a two person BFS-SMR system
date: 2019-10-25 14:22:00 -07:00
published: false
tags:
- dist101
- blockchain101
---

Suppose Alice wants to Pay Bob 10,000 times. The obvious solution is to do 10,000 transactions on a main State Machine Replication System. Let's call this system the Layer 1 system. This type of solution may cause the Layer 1 system to have considerable traffic. Payment channels (and more generally Layer 2 solutions) offer a way to relive this traffic and scale the system. 

The basic idea of a payment channel:
1. Alice *opens* the channel by locking value on Layer 1 dedicating it to the channel.
2. Alice and Bob exchange 10,000 payment commands privately in a *payment channel* (in a 2 person *SMR*, see below). They maintain the current balance after each payment.
3. Bob (or Alice) *close* the channel by submitting the latest state of the channel to the Layer 1 system.  

Important details:
1. When Alice locks value on Layer 1 for this payment channel she should not be able to double-spend and use the locked funds for other uses. This can be guaranteed for example by having Alice essentially *pay* the channel.
2. When Alice or Bob try to close the channel they cannot report a channel state (balance) that never occured. This can be guaranteed by having both Alice and Bob sign each transaction and its resulting state. So the Layer 1 system will only accept a state from the layer 2 channel that is singed by both Alice and Bob.
3. When Alice or Bob try to close the channel they cannot report a state that is not the most *recent state*. This requires two things:

3.1. Alice and Bob sign each transaction in a log of operation. In doing this ALice and Bob are essentially implementing a [two person Byzantine Fault Safe State Machine Replication](decentralizedthoughts.github.io/2019-10-25-flavours-of-state-machine-replication/) system.

3.2. If say Alice send an old state to Layer 1 then Bob need to report that there is a new state to Layer 1 in a timely manner. This requires Bob to be able to synchronously communicate with the Layer 1 system. A typical solution is to allow a very large window (say 2 weeks) for Bob to respond.

So at its core a payment channel is a way for any two participants to *open* a private two person BFS-SMR system, execute transactions on this private BFS-SMR system and then *close* the channel under assumptions of synchrony. 
