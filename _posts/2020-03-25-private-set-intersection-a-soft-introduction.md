---
layout: post
title: Private set intersection - A Soft Introduction
date: 'Wed Mar 25 2020 09:00:00 GMT+0200 (Israel Standard Time)'
published: false
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

As in any problem in secure computation, we can design a protocol that involves a trusted third party (TTP) $T$ to which Alice and Bob send $A$ and $B$ respectively. Then $T$ computes the set $A\cap B$ and sends it back to Alice and Bob. Such a protocol is not acceptable as Alice and Bob want to avoid a disclosure of their items to anyone (except $A\cap B$ that they accept to reveal to each other).

In addition, Alice and Bob do not want to rely on a hardware solution like SGX or any other trusted execution environment (TEE).

They do, however, agree to use the service of an **untrusted** third party:

### PSI with an untrusted third party (also known as "server aided PSI")

In this setting there is an additional party, Carol, with which Alice and Bob interact. But the privacy requirement remains: Carol should not learn information about the items of Alice and Bob.
In this model we assume **no collusion**.

(It is possible to design a protocol that does not require a third party at all, not even an untrusted one. We'll keep this to a future post).







