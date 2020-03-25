---
layout: post
title: Private set intersection - A Soft Introduction
date: 'Thu Mar 26 2020 12:00:00 GMT+0200 (Israel Standard Time)'
published: false
tags:
  - cryptography
  - private-set-intersection
author: Avishay Yanai
---

Private set intersection (PSI) is a problem within the broader field of [secure computation](https://en.wikipedia.org/wiki/Secure_multi-party_computation).


## The PSI problem

There are two friends Alice and Bob such that Alice has a set of items $A=(a_1,\ldots,a_n)$ and Bob has the set $B=(b_1,\ldots,b_n)$.

_The goal is to design a protocol by which Alice and Bob obtain the intersection $A\cap B$_, under the following privacy restriction: The protocol must not reveal anything about items that are not in the intersection.

If $a_i\notin B$ then Bob learns nothing about it. In other words, Bob's apriori knowledge about whether Alice has item $z$, where $z$ is not in the intersection, is not affected by the execution of the protocol.

For example, the following solution is not private: Alice sends $A$ to Bob, Bob computes $A\cap B$ and sends the result to Alice. This is not private because Bob learns that Alice has item $a_j$ even if $a_j\notin A\cap B$.

### Is PSI an important problem?

The answer is yes, it finds applications in many areas, for a cool application, check out [this paper](https://eprint.iacr.org/2017/738.pdf) by Google. I will cover many interesting applications of PSI in a separate post.

### What are the rules? What can we use when designing a PSI protocol?

As in any problem in secure computation, we can design a protocol that involves a trusted third party (TTP), called Steve, to which Alice and Bob send $A$ and $B$ respectively. Then Steve computes the set $A\cap B$ and sends it back to Alice and Bob. Such a protocol is not acceptable as Alice and Bob want to avoid the disclosure of their items to anyone. They are willing to reveal $A\cap B$ to each other only.

except $A\cap B$ that they accept to reveal to each other).

In addition, Alice and Bob do not want to rely on a hardware solution like SGX or any other trusted execution environment (TEE).

They do, however, agree to use the service of an **untrusted** third party:

## PSI with an untrusted third party (also known as "server aided PSI")

In this setting there is an additional party, called Steve again, with which Alice and Bob interact. But the privacy requirement remains: **Steve should not learn information about the items of Alice and Bob**.

In this model we assume **no collusion**, meaning that Alice and Steve do not collude in order to fool Bob (i.e. make Bob conclude the intersection has more/less items than it really has) nor to break Bob's privacy (i.e. revealing information about Bob's items). Bob and Steve do not collude as well.

(It is possible to design a protocol that does not require a third party at all, not even an untrusted one. We'll keep this to a future post).

## The protocol

We are going to use following ingredient:

> **Pseudorandom function (PRF)** - a function $F$ over two arguments, a key $K$ and an input $X$, outputs $Y$. $F$ is pseudorandom if for every $X$, the output $Y=F(K,X)$ looks random to someone who does not know the key $K$.

Now, the protocol proceeds as follows:
0. Alice has $A=\{a_1,\ldots,a_n\}$, Bob has $B=\{b_1,\ldots,b_n\}$.
1. Alice, Bob and Steve agree on a PRF $F$ they are going to use.
2. Alice and Bob agree on a key $K$ for $F$. This key remains secret to Steve.
3. For each $i=1,\ldots,n$, Alice sends $a'_i=F(K,a_i)$ to Steve. Alice also stores $D_A[a'_i]=a_i$.
4. For each $i=1,\ldots,n$, Bob sends $b'_i=F(K,b_i)$ to Steve. Bob also stores $D_B[b'_i]=b_i$.
5. Steve computes $A'\cap B'$, namely, the intersection between $\{a'_1,\ldots,a'_n\}$ and $\{b'_1,\ldots,b'_n\}$ and send $A'\cap B'$ to Alice and Bob.
6. Let $A'\cap B'=(c_1,\ldots,c_m)$.
7. For each $i=1,\ldots,m$, Alice (resp. Bob) outputs $D_A[c_i]$ (resp. $D_B[c_i]$) as the intersection.

## Is the protocol private?

The only information leaked to Steve is the number of items Alice and Bob originally have and the size of the intersection, $\|A\cap B\|$. But let's assume this is acceptable (for now).

Steve does not learn anything about the _value_ of the items (neither those in the intersection nor the rest) because all he sees are outputs of $F$, and these look random to him, since he doesn't know $K$.

Alice learns only what items are in the intersection and nothing more, since Steve doesn't sends her $b'_j$ that are not in $A'\cap B'$.

## Is the protocol secure?

It depends, if we assume that Steve follows the protocol faithfully then yes. If we suspect Steve tries to cheat (i.e. fool Alice and Bob to conclude with a wrong intersection) then no, the protocol is not secure.

### Steve may cheat (1)

Steve may sed Alice and Bob a different set of values, even values that are not in the intersection. For example let $A=\{a_1,a_2,a_3,a_4,a_5\}$ and $B=\{b_1,b_2,b_3,b_4,b_5\}$ such that $a_1=b_1$ and $a_2=b_2$, namely, $A\cap B=\{a_1,a_2\}=\{b_1,b_2\}$. Then Steve receives $A'=\{a'_1,a'_2,a'_3,a'_4,a'_5\}$ from Alice and $B'=\{b'_1,b'_2,b'_3,b'_4,b'_5\}$ from Bob.

Steve may send $\{a'_1,a'_2,a'_3\}$ back to Alice and $\{b'_3, b'_4\}$ back to Bob so Alice outputs $a_1, a_2, a_3$ and Bob outputs $b_3,b_4$ as the intersection. This way, not only Alice and Bob do not agree on the result, they output incorrect results, specifically none of $a_3, b_3$ and $b_4$ are in the intersection.

**A solution by equality test.**
Fortunately, this cheat can be detected by Alice and Bob as follows: Alice and Bob will sort the items that they are about to output as the intersection and compute a hash on that set. Then, they will verify that they obtained the same hash value, this could be done by Alice sending the hash value to Bob, or in a safer way, by running a private equality test (PET) protocol on their results.

### Steve may cheat (2)

The above verification that the two output sets are the same is not sufficient. Specifically, Steve may send the same set to both Alice and Bob and still result in an incorrect output. For example, Steve may send the value $a'_1$, alone, to the parties, by which they output only $a_1$ as the intersection (instead of $\{a_1,a_2\}$). 

In general, Steve could claim that the intersection is smaller than it really is.


## How to detect cheating?

We will show 2 different ways to detect the above cheating strategy:


## Redundancy-based proof (based on [[KMRS14]](https://fc14.ifca.ai/papers/fc14_submission_52.pdf))
This is based on a work by Seny Kamara, Payman Mohassel, Mariana Raykova and Saeed Sadeghian.

The idea is this, choose some redundancy parameter $t$, now Alice, instead of sending to Steve only $a'_i=F(K,a_i)$ (for all $i$), she will send $t$ values $a'_i^1, a'_i^2,\ldots,a'_i^t$ where $a'_i^j=F(K,a_i||j)$ (the term $a_i||j$ means a concatenation of values $a_i$ and $j$). In additin, Alice stores $D_A[a'_i^j]=a_i$ for every $i=1,\ldots,n$ and $j=1,\ldots,t$.
Bob will do the same, for every $i=1,\ldots, n$ he sends $b'_i^1, b'_i^2,\ldots, b'_i^t$ where $b'_i^j=F(K,b_i||k)$. In additin, Bob stores $D_B[b'_i^j]=b_i$ for every $i=1,\ldots,n$ and $j=1,\ldots,t$.

But now, it is important that before Alice and Bob sends $A'$ and $B'$ to Steve, they will shuffle them. This is in order to prevent a linkage between the $t$ PRF's results (e.g. $a'_i^1, a'_i^2,\ldots,a'_i^t$) that actually refer to the same original item (e.g. $a_i$).

Steve receives $n\cdot t$ values in total from Alice and from Bob. Obviously, if $|A\cap B|=q$ then now Steve finds that $|A'\cap B'|=q\cdo t$ because each value appears $t$ times.

When Alice and Bob receive the list $A'\cap B'$ from Steve, they will check that each item appears $t$ times. That is, Alice will check that for each item $x$ in the intersection there are exactly $t$ values $c_1,\ldots,c_t$ such that $D_A[c_i]=x$. If that doesn't hold then Alice conclude that either Steve is cheating or Bob is cheating.

Now, suppose Steve wants to omit one value, say $a_i$, from the intersection, he will have to omit $t$ values $a'_i^1, a'_i^2,\ldots,a'_i^t$, but those are spread all over the list $A'$ and it could not tell (except with small probability) where they are.

Take our concrete example above and fix $t=3$, Steve receives $n\cdot t=5\dcot 3=15$ values from Alice and from Bob. If Steve wants to omit $a_1$ from the result intersection then it has to find the 3 values associated with $a_1$, that is, the values $a'_1^1, a'_1^2$ and $a'_1^3$. Since the set $A'$ is shuffled, the probability of succeeding is $\binom{5}{3}^{-1}=1/10$. In general, the probability to remove one value from the intersection would be $\binom{n}{t}^{-1}$.

### Are we done?

No. There are two edge cases:
1. Steve can omit _all_ values from the intersection and simply give back an empty list to Alice and Bob. The condition of having each value in the intersection appearing $t$ times in the list returned from Steve holds here, because there are no values at all in the intersection.
2. Steve can send back to Alice her _entire list_ $A'$ and to Bob his _entire list_ $B'$. The condition holds also here. However, recall that we have already treated this case. This is considered as cheating only if $A'\neq B'$, which is covered by the equality test performed by Alice and Bob after receiving the result. 

To solve the first case, Alice and Bob agree on a set of $s$ values $E=\{e_1,\ldots,e_s\}$ such that both Alice and Bob take $E$ as part of their input sets. So now instead of computing the intersection $A\cap B$, they will compute the intersection $(A\cup E)\cap (B\cup E)$ which has at least $s$ items. This way, Bob could not return an empty set.


## Polynomial-based proof (based on [[LRG19]](https://eprint.iacr.org/2019/1338.pdf))
Phi Hung Le, Samuel Ranellucci and Dov Gordon proposed a different approach for solving the above cheating potential by Steve without the need for redunduncy. In their solution, Steve sends back to Alice and Bob the intersection $A'\cap B'$ as described above. In addition, if $|A'\cap B'|=k$, then Steve also proves to Alice and Bob that there are at least $2n-k$ values in the union $A\cup B$ and at least $k$ values in the intersection. Since the intersection and union sizes complete each other to a sum of $2n$, these two proofs are sufficient for convincing Alice and Bob that Steve does not cheat.

Let's keep the description of the polynomial-based proofs to the next post :)
