---
title: The Marvels of Polynomials over a Field
date: 2020-07-05 10:55:00 -07:00
published: false
author: Ittai Abraham
---

In this series of posts, we explore the mathematical foundations of polynomials over a [field](https://en.wikipedia.org/wiki/Field_(mathematics)). These objects are at the heart of several results in computer science: [secret sharing](https://cs.jhu.edu/~sdoshi/crypto/papers/shamirturing.pdf),
[Multi Party Computation](https://eprint.iacr.org/2011/136.pdf), [Complexity](https://lance.fortnow.com/papers/files/ip.pdf), and [Zero](https://www.iacr.org/archive/asiacrypt2010/6477178/6477178.pdf) [Knowledge](https://cyber.biu.ac.il/event/the-9th-biu-winter-school-on-cryptography/) [protocols](https://eprint.iacr.org/2019/953.pdf).

All this wonder and more can be traced back to a very useful fact about polynomials over a field:

**Theorem: any non-trivial polynomial over a field of degree at most $d$ has at most $d$ zeroes**

Let us slowly unpack this statement.
Let $K$ be a [field](https://en.wikipedia.org/wiki/Field_(mathematics)) and let $p_0,...,p_m \in K$ be _coefficients_.
A polynomial over $K$ is an element of $K[X]$. Here is an example of one:

$$
p=p_0+p_1 X + p_2 X^2 + p_3 X^3 +...+ p_{m-1} X^{m-1} + p_m X^m
$$

 Recall that a field supports both multiplication and division (i.e., every element has a unique multiplicative inverse). Note that the set of [polynomials](https://en.wikipedia.org/wiki/Polynomial_ring) $K[X]$ is a [ring](https://en.wikipedia.org/wiki/Ring_(mathematics)), so it supports multiplication, but not every element has a multiplicative inverse (more on division in $K[X]$ later).

We say that a polynomial $p$ is *non-trivial* if some coefficient $p_i \neq 0$. Then, we define the *degree* of $p$ to be the maximal $i$ such that $p_i \neq 0$ (it is natural to define the degree of the trivial polynomial to be $- \infty$).

We say that $a \in K$ is a *zero* of $p \in K[X]$ if $p(a)=0$ and say that $p$ has *at most $d$ zeroes* if there are at most $d$ elements in $K$ that are a zero of $p$. The zeroes of polynomials are also referred to as *roots*.

For example, consider the polynomial $p=2X-4$. It is clearly a polynomial of degree one and we all know that, over the rational field $K=\mathbb{Q}$, it has just one zero (at $2$).  Now, consider that same polynomial over the finite field $K=\mathbb{Z}_7$, which are just the integers modulo 7: i.e., $\\{0,1,2,\dots,6\\}$.
Then, a quick check shows that $2$ is still the only zero of $p$. In other words, the equation $2X=4 \pmod 7$ has exactly one solution: $2$.

Note that if instead of a field $K=\mathbb{Z}\_7$ we chose a _ring_ $K=\mathbb{Z}_{12}$, then the equation $2X=4 \pmod {12}$ would have 2 (!) solutions: $2$ (because $2\times 2 - 4 = 0$ and $8$ (because $2\times 8 - 4 = 16 - 4 = 12$, which is equal to 0 modulo 12). In other words, $p$ has more zeros (two) than its degree (one)!

**Proof of the Theorem:**
Not surprisingly, the proof will be via induction on $d$. 

For $d=0$, since $p$ is non-trivial, we have $p_0 \neq 0$ and hence $p$ has no zeros (as it should be).

For $d=1$, as exemplified above, we will use the fact that $K$ is a field. 
Note that the unique zero of $p=p_0+p_1 X$ is the unique element $-p_0/p_1 = -(p_0) (p_1)^{-1}$. 
In particular, if $K$ were just a ring and not a field (e.g., $K=\mathbb{Z}_{12}$), then the inverse of $p_1$ may not exist or, more worrisome, may not be unique!

For $d\geq 2$, we will use an induction step. There are two cases.
First, if $p$ has no zeroes, then we are done.
Otherwise, let $a \in K$ be such that $p(a)=0$. Suppose that we could prove that there exists a polynomial $q$ of degree $<d$ such that $p=(X-a) q$. Since $q$ has a degree that is smaller than $d$ we can use the induction hypothesis on $q$. So $p$ can have at most $d-1$ zeros from $q$ and at most one more zero (at $a$) from the degree 1 polynomial $X-a$.

So to complete the induction argument we need to prove the existence of such $q$ using the following claim:

**Claim: if $p$ has degree $d\ge 1$ and $p(a)=0$ then there exists $q$ such that $p=(X-a)q$ and $q$ has a lower degree than $p$**

Not surprisingly, we will prove this claim by induction as well. For $d=1$, we again use the fact that $K$ is a field and can set $a= (p_0) (p_1)^{-1}$ and $q=p_1$ is a non-trivial degree zero polymonial.

For $d>1$, we will define a new polynomial $p' = p - p_d X^{d-1} (X-a)$, note that $p_d$ is the largest coefficeint of $p$. Lets make a few observations:
1. The degree of $p'$ is smaller than $d$. This is because the $d$th coefficient of $p_d X^{d-1} (X-a)$ equals $p_d$, so it will cancel out.
2. $p'$ has the property that $p'(a)=0$. This is because $p(a)=0$ and because $p_d X^{d-1} (X-a)$ also zeros at $a$.

Hence, we can apply the induction hypothesis on $p'$ to obtain that there exists $q'$ such that $p'=(X-a)q'$ and the degree of $q'$ is lower than $d-1$.

Since:

$$
p=p'+ p_d X^{d-1} (X-a)
$$

Then, we can substitute $p'=(X-a)q'$ and get:

$$
p= (X-a)q' + (X-a) p_d X^{d-1}
$$

Hence, we have proved that:

$$
p= (X-a)q\ \text{with}\ q=q'+p_d X^{d-1}
$$

It is direct to see that $q$ has degree $d-1$.

In the next posts, we will use this very useful fact about roots of polynomials over finite fields.
First, we will use it as the foundation for Secret Sharing and then as the foundation for Zero Knowledge Proofs.

A significantly more general result about polynomials over a field views them as a special case of a [unique factorization domain](https://en.wikipedia.org/wiki/Unique_factorization_domain). This view exposes deep connections between the natural numbers, polynomials over a field, and the [fundamental theorem of Arithmetic](https://www.maths.tcd.ie/pub/Maths/Courseware/Primality/Primality.pdf).  


**Acknowledgment.** Thanks to [Alin](https://research.vmware.com/researchers/alin-tomescu) for helpful feedback on this post.


Please leave comments on [Twitter](...).



