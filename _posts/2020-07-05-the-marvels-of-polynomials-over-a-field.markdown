---
title: The Marvels of Polynomials over a Field
date: 2020-07-05 10:55:00 -07:00
published: false
---

In this series of posts, we study the mathematical foundations that are at the heart of several results in computer science: [secret sharing](https://cs.jhu.edu/~sdoshi/crypto/papers/shamirturing.pdf),
[Multi Party Computation](https://eprint.iacr.org/2011/136.pdf), [Complexity](https://lance.fortnow.com/papers/files/ip.pdf), and [Zero](https://www.iacr.org/archive/asiacrypt2010/6477178/6477178.pdf) [Knowledge](https://cyber.biu.ac.il/event/the-9th-biu-winter-school-on-cryptography/) [protocols](https://eprint.iacr.org/2019/953.pdf).

All this wonder and more can be traced back to a basic fact about polynomials over a field:

**Theorem: any non-trivial polynomial over a field of degree at most $d$ has at most $d$ zeroes**

Lets slowly unpack this statement. A polynomial over a filed is an element of $K[X]$. Here is an example of one:

$$
p=p_0+p_1 X + p_2 X^2 + p_3 X^3 +...+ p_{m-1} X^{m-1} + p_m X^m
$$

Where $p_0,...,p_m \in K$ and $K$ is a field. Recall that a field supports both multiplication and division. Note that the set of polynomials $K[X}$ is a ring, so it supports multiplication, but not every element has an inverse (more on division in $K[X}$ later).

We say that $p$ is *non-trivial* if some $p_i \neq 0$ and define the degree of $p$ to be the maximal $i$ such that $p_i \neq 0$.

We say that $a \in K$ is a zero of $p \in K[X]$ if $p(a)=0$ and say that $p$ has at most $d$ zeroes if there are at most $d$ elements in $K$ that are a zero of $p$.

For example, consider the polynomial $p=X^2-4$. It clearly is a polynomial of degree 2 and we all know that over the rationals it has just two zeroes: 2 and -2.  Let's consider the finite filed $F_7$, then a quick check shows that both $2$ and $5$ are zeroes.


Note that if instead of a field we chose $K$ to be $mod 12$ then the equation $X^4=4 \mod 12$ would have 4 (!) solutions: 2, 4, 8, 10. Way more than the degree!





