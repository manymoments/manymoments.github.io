---
title: Polynomial Secret Sharing and the Lagrange Basis
date: 2020-07-09 08:36:00 -07:00
published: false
---

In this post, we introduce an amazing result: Shamir's [secret sharing scheme](https://cs.jhu.edu/~sdoshi/crypto/papers/shamirturing.pdf). The setting is that there are $n$ parties with one designated party called the *Dealer*. The secret sharing scheme is composed of two protocols: *Share* and *Recover*. In the *Share* protocol, the Dealer has some *input value* $s$. In the Recover protocol, each party outputs a *decision value*.

There are three properties we want to have:

**Binding**: Once the first non-faulty completes the Share protocol there exists some value $r$ such that $r$ is the output value of all non-faulty parties that complete the Recover protocol.

**Validity**: If the Dealer is non-faulty then the output is the Dealer's input value $s$.

**Hiding**: If the dealer is non-faulty, and no honest party has begun the Recover protocol, then the adversary can gain no information about $s$. 


The first two properties seem clear, but what about the hiding property. What does it mean that the adversary "gains no information about $s$"? We will be more formal about this later but informally this means that anything the adversary can output by interacting with this protocol, the adversary could have output the same without any interaction at all.

### Shamir's scheme

In Shamir's scheme, we assume a [passive adversary](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) that controls some $f<n$ parties. We will enumerate the parties via the integers $\{1,2,3,\dots,n\}$. We also assume there is a commonly known finite field $F_p$ with $p>n$.


**Share protocol**: Given input $s$, the Dealer randomly chooses $f$ values $p_1,\dots,p_f \in_R F_p$ and defines a degree $f$ polynomial 
$$
p=s+p_1 X + \dots + p_f X^f
$$
the Dealer then sends party $i$ the value p(i).

**Recover protocol**: party $i$ sends its share $p_i$ to all parties. Each party receives all the shares $p_1,\dots,p_n$ and outputs $p_0=\sum_{1\leq i \leq f+1} \Lambda_i p_i$.

### Lagrange Basis

One thing left unspecified is the values $\Lambda_1,\dots,Lambda_{f+1}$.

For a set $X$ of size $|X| = f+1$ we can define the LaGrange basis of degree at most $d$ polynomials as follows:

For every $x \in X$, let $L_x:X \to \{0,1\}$ be the function that that $L_x(y)= 1$ if $x=y$ and $L_x(y)=0 if $x \neq y$. We can then extend this function to be $L_x:F_p \to \{0,1\}$  by defining degree $f$ polynomials:
$$
L_x(Y)= \prod_{z \in X \setminus \{\x}} (Y-z) / \prod_{z \in X \setminus \{\x}} (x-z)
$$
We can now represent *any* degree $f$ polynomial $p$ as follows:
$$
p=\sum_{x \in X} L_x(Y) p(x)
$$
Why does the equality hold? its because both $p$ and $\sum_{x \in X} L_x(Y) p(x)$ are degree at most $f$ polynomials so $p-\sum_{x \in X} L_x(Y) p(x)$ is also of degree at most $f$ and has $f+1$ zeros. From the Theorem of out previous post this means that $p-\sum_{x \in X} L_x(Y) p(x)$ must be the zero polynomial!

This argument actually shows that there is a *unique representation* of $p$ for the Lagrange Basis induced by $X$, this is the set $\{(x,p(x))\}_{x \in X}$.

Since degree at most $f$ polynomials have at most $f+1$ coefficients then the number of degrees at most $f$ polynomials is exactly $F_p^{f+1}$. The number of possible values for lagrage basis for any set $|X|=f+1$ is also $F_p^{f+1}$.

This proves that indeed the mapping from $f+1$ coefficients to the mapping of $f+1$ values of the polynomials to the points of $X$ is indeed an isomorphism. This means that indeed \{L_x\}_{x\in X} is a basis that spans all polynomials of degree at most $f$.

### Proof of the properties

**Proof for Binding**: 
