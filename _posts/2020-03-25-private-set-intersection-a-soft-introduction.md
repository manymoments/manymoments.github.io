---
title: Private set intersection - A Soft Introduction
date: 2020-03-25 18:00:00 -07:00
published: false
layout: post
---

Private set intersection (PSI) is a problem within the broader field of [secure computation](https://en.wikipedia.org/wiki/Secure_multi-party_computation).


## The PSI problem

There are two friends Alice and Bob such that Alice has a set of items $A=(a_1,\ldots,a_n)$ and Bob has the set $B=(b_1,\ldots,b_n)$.

_The goal is to design a protocol by which Alice and Bob obtain the intersection $A\cap B$_, under the following privacy restriction: The protocol must not reveal anything about items that are not in the intersection.

If $a_i\notin B$ then Bob learns nothing about it. In other words, Bob's apriori knowledge about whether Alice has item $z$, where $z$ is not in the intersection, is not affected by the execution of the protocol.

For example, the following solution is not private: Alice sends A to Bob, Bob computes $A\cap B$ and sends the result to Alice. This is not private because Bob learns that Alice has item $a_j$ even if $a_j\notin A\cap B$.

### Is PSI an important problem?

The answer is yes, it finds applications in many areas, for a cool application, check out [this paper](https://eprint.iacr.org/2017/738.pdf) by Google. I will cover the many applications of PSI in a separate post.

### What are the rules? What can we use when designing a protocol?

As in any problem in secure computation, we can design a protocol that involves a trusted third party (TTP), called Steve, to which Alice and Bob send $A$ and $B$ respectively. Then Steve computes the set $A\cap B$ and sends it back to Alice and Bob. Such a protocol is not acceptable as Alice and Bob want to avoid the disclosure of their items to anyone (except $A\cap B$ that they accept to reveal to each other).

In addition, Alice and Bob do not want to rely on a hardware solution like SGX or any other trusted execution environment (TEE).

They do, however, agree to use the service of an **untrusted** third party:

## PSI with an untrusted third party (also known as "server aided PSI")

In this setting there is an additional party, called Steve again, with which Alice and Bob interact. But the privacy requirement remains: Steve should not learn information about the items of Alice and Bob.

In this model we assume **no collusion**, meaning that Alice and Steve do not collude in order to fool Bob (i.e. make Bob conclude the intersection has more/less items than it really has) nor to break Bob's privacy (i.e. revealing information about Bob's items).

(It is possible to design a protocol that does not require a third party at all, not even an untrusted one. We'll keep this to a future post).

## The protocol

We are going to use following ingredient:

> **Pseudorandom function (PRF)** - a function $F$ over two arguments, a key $K$ and an input $X$, outputs $y$. $F$ is pseudorandom if for every $X$, the output $F(K,X)$ looks random to someone who does not know the key $K$.

Now, the protocol proceeds as follows:
1. Alice, Bob and Steve agree on a PRF $F$ they are going to use.
2. Alice and Bob agree on a key $K$ for $F$. This key remains secret to Steve.
3. For each $i=1,\ldots,n$, Alice sends $a'_i=F(K,a_i)$ to Steve. Alice also stores $D_A[a'_i]=a_i$.
4. For each $i=1,\ldots,n$, Bob sends $b'_i=F(K,b_i)$ to Steve. Bob also stores $D_B[b'_i]=b_i$.
5. Steve computes $A'\cap B'$, namely, the intersection between $\{a'_1,\ldots,a'_n\}$ and $\{b'_1,\ldots,b'_n\}$ and send $A'\cap B'$ to Alice and Bob.
6. Let $A'\cap B'=(c_1,\ldots,c_m)$.
7. For each $i=1,\ldots,m$, Alice (resp. Bob) outputs $D_A[c_i]$ (resp. $D_B[c_i]$) as the intersection.

### Is that protocol private?

The only information leaked to Steve is the number of items Alice and Bob originally have and the size of the intersection, $|A\cap B|$.

Steve does not learn anything about the _value_ of the items (neither those in the intersection nor the rest) because all he sees are outputs of $F$, and these look random to him, since he doesn't know $K$.








