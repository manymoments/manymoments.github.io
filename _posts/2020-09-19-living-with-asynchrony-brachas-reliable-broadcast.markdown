---
title: 'Living with Asynchrony: Bracha''s Reliable Broadcast'
date: 2020-09-19 06:05:00 -07:00
published: false
author: Ittai Abraham
---

In this series of posts, we explore what can be done in the Asynchronous model. This model seems challenging because the adversary can delay messages by any bounded time. By the end of this series, you will see that almost everything that can be done in synchrony can be obtained in asynchrony.

We begin with [Bracha's Reliable Broadcast from 1987](https://core.ac.uk/download/pdf/82523202.pdf). This is one of the most important build blocks for [Byzantine Fault Tolerant](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) protocols in the [Asynchronous model](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/). In this standard setting there are $n$ parties, where one of them is designated as the leader. The [threshold adversary](https://decentralizedthoughts.github.io/2019-06-17-the-threshold-adversary/) can control at most $f<n/3$ parties. The leader has some input value $v$ and a party that terminates needs to output a single value.



## Reliable Broadcast Properties
There are just two simple properties: 

1. If the leader is non-faulty then eventually all non-faulty parties will output the leader's input.

2. If some non-faulty party outputs a value then eventually all non-faulty parties will output the same value.

Since this protocol is supposed to work in the asynchronous model, both these properties use the term *eventually*. This term is often used in asynchrony to indicate that no matter what the adversary does and for how long it delays messages, some event will after a bounded number of message processing at each party.

## Reliable Broadcast

The high level idea is simple:

1. First, we force the leader to send just one message: we do this by requiring each party to *echo* just one message and wait for $n-f$ echo messages before *voting* for it. Since any two sets of $n-f$ must intersect by at least $f+1$ parties, it cannot be that two different non-faulty parties  

2. Second, we make sure that if a non-faulty accepts this message then all non-faulty will. We do this by requiring a party to send a vote after seeing $n-f$ echo messages or after seeing $f+1$ votes. So if any party see $n-f$ votes then all non-faulty will see $n-2f \geq f+1$ votes.

       // Party j
       echo = true
       vote = true
       
       on receiving <v> from leader:
          if echo == true:
             send <echo, v> to all parties
             echo = false

       on receiving <echo, v> from n-f unique parties:
          if vote == true:
             send <vote, v> to all parties
             vote = false

       on receiving <vote, v> from f+1 unique parties:
           if vote == true:
             send <vote, v> to all parties
             vote = false

       on receiving <vote, v> from n-f unique parties:
           deliver v

### Analysis

**Claim 1:**: If the leader is honest and sends <v> to all parties then all non-faulty will eventually deliver <V>.

*Proof:* All non-faulty will eventually send <echo,v>, so eventually all non-fualty will receive $n-f$ echoes for $v$ and at most $f$ echos for other value. So all non-fualty will eventually send <vote, v>, so eventually all non-fualty will receive $n-f$ votes for $v$ and at most $f$ votes for other value.




**Claim 2:**: No two non-faulty will send conflicting votes.

*Proof:* Two send a conflicting vote, one non-faulty must see $n-f$ echos for $v$ and another $n-f$ echoes for $v' \neq v$. But this implies that there must be at least $f+1$ parties that sent an echo to both of them, which implies that at least one non-faulty party sent two votes for different values, which contradicts the code.
 

**Claim 3:**: If a non-faulty delivers $v$, then all non-faulty will eventually deliver $v$.

*Proof:* From the previous claim, we know that all non-faulty that vote will vote for the same value. So if a non-faulty delivers it has seen $n-f$ unique votes, of which at least $n-2f \geq f+1$ came from non-faulty parties. So eventually all non-faulty parties will either vote $v$ due to seeing $n-f$ echoes or due to seeing the votes from these $f+1$ non-faulty parties.

### Notes

Bracha used Reliable Broadcast to improve Ben-Or's [Asynchonrus Byzanitne Agreement](https://allquantor.at/blockchainbib/pdf/ben1983another.pdf) from $n>5f$ to the optimal resilience of $n>3f$. 

Reliable broadcast requires sending $O(n^2)$ messages that contain the value $v$.  In the next post of this series, we will see what we can improve if we allow using collision-resistant hash functions. 



### Scratch your Brains!

Prove correctness (or provide a counterexample) of the following optimization that simplifies Bracha's original protocol and saves a round!

        on receiving <v> from leader:
          if echo == true:
             send <echo, v> to all parties
             echo = false

        on receiving <echo, v> from f+1 unique parties:
           if echo == true:
             send <echo, v> to all parties
             vote = false

        on receiving <echo, v> from n-f unique parties:
           deliver v




Please answer/discuss/comment/ask on [Twitter](). 

