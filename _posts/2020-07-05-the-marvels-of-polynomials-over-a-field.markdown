---
title: The Marvels of Polynomials over a Field
date: 2020-07-05 10:55:00 -07:00
published: false
---

In this series of posts, we study the mathematical foundations of polynomials over a field. These objects are at the heart of several results in computer science: [secret sharing](https://cs.jhu.edu/~sdoshi/crypto/papers/shamirturing.pdf),
[Multi Party Computation](https://eprint.iacr.org/2011/136.pdf), [Complexity](https://lance.fortnow.com/papers/files/ip.pdf), and [Zero](https://www.iacr.org/archive/asiacrypt2010/6477178/6477178.pdf) [Knowledge](https://cyber.biu.ac.il/event/the-9th-biu-winter-school-on-cryptography/) [protocols](https://eprint.iacr.org/2019/953.pdf).

All this wonder and more can be traced back to a very useful fact about polynomials over a field:

**Theorem: any non-trivial polynomial over a field of degree at most $d$ has at most $d$ zeroes**

Lets slowly unpack this statement. A polynomial over a filed is an element of $K[X]$. Here is an example of one:

$$
p=p_0+p_1 X + p_2 X^2 + p_3 X^3 +...+ p_{m-1} X^{m-1} + p_m X^m
$$

Where $p_0,...,p_m \in K$ and $K$ is a [field](https://en.wikipedia.org/wiki/Field_(mathematics)). Recall that a field supports both multiplication and division (every element has a unique multiplicative inverse). Note that the set of [polynomials](https://en.wikipedia.org/wiki/Polynomial_ring) $K[X]$ is a [ring](https://en.wikipedia.org/wiki/Ring_(mathematics)), so it supports multiplication, but not every element has a multiplicative inverse (more on division in $K[X]$ later).

We say that a polynomial $p$ is *non-trivial* if some $p_i \neq 0$. Define the *degree* of $p$ to be the maximal $i$ such that $p_i \neq 0$ (its natural to define the degree of the trivial polynomial to be $- \infty$).

We say that $a \in K$ is a *zero* of $p \in K[X]$ if $p(a)=0$ and say that $p$ has *at most $d$ zeroes* if there are at most $d$ elements in $K$ that are a zero of $p$.

For example, consider the polynomial $p=2X-4$. It clearly is a polynomial of degree one and we all know that over the rational field it has just one zero (at $2$).  Now consider that $K$ is the finite filed $\mathcal{F}_7$, then a quick check shows that $2$ is still the only zero of $p$. In other words, the equation $2X=4 \mod 7$ has exactly one solution: $2$.


Note that if instead of a field we chose $K$ to be $\mod 12$ (formally $\mathcal{Z}/\mathcal{Z}_{12}$) then the equation $2X=4 \mod 12$ would have 2 (!) solutions: $2$ and $8$ (because 16-12=4). More than the degree!

**Proof of the Theorem**
Not surprisingly, the proof will be via induction on $d$. 

For $d=0$ the statement is trivial, since $p$ is non-trivial then $p_0 \neq 0$ and hence $p$ has no zeros.

For $d=1$, as we have been above, we need to use the fact that $K$ is a field. Hence the unique zero of $p=p_0+p_1 X$ is the unique element $-p_0/p_1 = -(p_0) (p_1)^{-1}$. Note that if $K$ was just a ring and not a field then the inverse of $p_1$ may not exist or more worrisome may not be unique!

For $d\geq 2$ we will use an induction step, suppose $p$ is of degree $d$. There are two cases, if $p$ has no zeroes then we are done. Otherwise let $a \in K$ be such that $p(a)=0$, we will prove that there exists a polynomial $q$ of degree $<d$ such that $p=(X-a) q$. Since $q$ has a degree that is smaller than $d$ we can use the induction hypothesis. So $p$ can have at most $d-1$ zeros from $q$ and at most one more zero (at $a$) from the degree 1 polynomial $X-a$.

So to complete the induction argument we need to prove the following claim:

**Claim: if $p$ has degree $d\ge 1$ and $p(a)=0$ then there exists $q$ such that $p=(X-a)q$ and $q$ has a lower degree than $p$**

Not surprisingly, we will prove this claim by induction as well. For $d=1$ we again use the fact that $K$ is a field and can set $a= (p_0) (p_1)^{-1}$ and $q=p_1$ is a non-trivial degree zero polymonial.

For $d>1$, we will define a new polynomial $p' = p - p_d X^{d-1} (X-a)$, note that $p_d$ is the largest coefficeint of $p$. Lets make a few observations:
1. The degree of $p'$ is smaller than $d$, this is becasue the $d$th coeffieicent of $p_d X^{d-1} (X-a)$ equals $p_d$ so will cancel out.
2. $p'$ has the propoerty that $p'(a)=0$, this is because $p(a)=0$ and becuase $p_d X^{d-1} (X-a)$ also zeros at $a$.

Hence we can apply the induction hypothesis on $p'$ to obtain that there exists $q'$ such that $p'=(X-a)q'$ and the degree of $q'$ is lower than $d-1$.

Since 
$$
p=p'+ p_d X^{d-1} (X-a)
$$
then we can substituie and get 
$$
p= (X-a)q' + (X-a) p_d X^{d-1}.
$$
Hence we have proved that 
$$
p= (X-a)q$ with $q=q_1+p_d X^{d-1}.
$$
It is direct to see that $q$ has a lower degree than $d$.

In the next posts, we will use this very useful fact. First as the foundations for Secret Sharing and then as the foundation for Zero Knowledge proofs.






