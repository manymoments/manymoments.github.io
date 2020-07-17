---
title: Polynomial Secret Sharing and the Lagrange Basis
date: 2020-07-09 08:36:00 -07:00
published: false
author: Ittai Abraham, Alin Tomescu
---

In this post, we highlight an amazing result: Shamir's [secret sharing scheme](https://cs.jhu.edu/~sdoshi/crypto/papers/shamirturing.pdf). This is one of the most powerful uses of polynomials over a finite field in distributed computing.
Intuitively, this scheme allows a $Dealer$ to *commit* to a *secret* $s$ by splitting it into *shares* distributed to $n$ parties. The secret is hidden and requires a threshold of $f+1$ parties in order to be reconstructed. 


In the basic scheme, we will assume a [passive adversary](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) that controls [all parties but one](https://decentralizedthoughts.github.io/2019-06-17-the-threshold-adversary/) (any $f<n$ parties).
A passive adversary (sometimes called [Honest-But-Curious](https://eprint.iacr.org/2011/136.pdf) or [Semi-Honest](http://www.wisdom.weizmann.ac.il/~oded/foc-vol2.html)) does not deviate from the protocol but can learn all possible information from its view (the messages received by parties it controls). In later posts, we will extend the secret sharing scheme to [crash and then malicious](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) adversaries.




A *secret sharing scheme* is composed of two protocols: *Share* and *Reconstruct*.
These protocols are distributed: they are run by the $n$ parties, jointly.
The Dealer has a *secret* $s$, which is given as _input_ to the Share protocol.
Intuitively, if the Share protocol "succeeds", then the Reconstruct protocol will *outputWe * that same secret $s$.


These properties of a secret sharing scheme can be described more formally as:

**Binding**: Once the first non-faulty completes the Share protocol there exists some value $r$ such that $r$ is the output value of all non-faulty parties that complete the Reconstruct protocol.

**Validity**: If the Dealer is non-faulty then the output of the Reconstruct protocol is the Dealer's input value $s$.

**Hiding**: If the dealer is non-faulty, and no honest party has begun the Reconstruct protocol, then the adversary can gain no information about $s$. 


The first two properties seem well defined, but what about the hiding property? What does it mean that the adversary "gains no information about $s$"? We will be more formal about this later but informally this means that anything the adversary can output by interacting with this protocol, the adversary could have output the same without any interaction at all.

### Shamir's scheme

We enumerate the parties via the integers $\{1,2,3,\dots,n\}$. We also assume there is a commonly known finite field $\mathbb{F}_p$ with $p>n$.

**Share protocol**: Given a secret $s$ as input, the Dealer _randomly_ chooses $f$ values $p_1,\dots,p_f \in_R \mathbb{F}_p$ and defines a degree $\le f$ polynomial

$$p=s+p_1 X + \dots + p_f X^f$$

The Dealer then sends $p(i)$ to each party $i$.
We refer to $p(i)$ as party $i$'s _share_ of the secret $s$.
Note that $p(0) = s$, which is the Dealer's secret.

**Reconstruct protocol**: 
Each party $i$ sends its share $p(i)$ to all other parties. 
Each party receives all the shares $p(1),\dots,p(n)$ and outputs the Dealer's original secret $s$ as follows:

$$s=p(0)=\sum_{i \in I} \lambda_i p_i$$

Here, $I= \{ 1,\dots,f+1 \}$, and for any $i \in I$:

$$\lambda_i = \frac{\prod_{j \in I \setminus \{i\}} j}{\prod_{j \in I \setminus \{i\}} (j-i)}$$





This looks like magic, no?
No worries.
We explain how this reconstruction of the secret $s$ from the parties' shares works next. 

### Lagrange Basis

Lets dig deeper into how and why the values $\lambda_1,\dots,\lambda_{f+1}$ are defined. In fact, we could have used *any* set of $f+1$ shares to reconstruct the secret.

For any set $Z=\{z_1,\dots,z_{f+1}\}$ of size $f+1$ we can define the *Lagrange basis* for degree-at-most-$f$ polynomials as follows:

For every $z \in Z$, let $\mathcal{L}_z:Z \mapsto \{0,1\}$ be the [indicator function](https://en.wikipedia.org/wiki/Indicator_function) such that:

$$\mathcal{L}_z(x) = \begin{cases} 1,\ \text{if}\ x=z\\0,\ \text{if}\ x \neq z\end{cases}$$

We can then *extend* this function $\mathcal{L}_z(x)$ to a function $L_z : \mathbb{F}_p \mapsto \mathbb{F}_p$, such that for all $x\in Z:\ \mathcal{L}_z(X)=L_z(X)$ by defining $L_z(X)$ as a degree $f$ polynomial!

$$L_z(X)= \frac{\prod_{j \in Z \setminus \{z\}} (X-j)}{\prod_{j \in Z \setminus \{z\}} (z-j)}$$


Take a moment to verify the equality on all $x\in Z$. This seemingly simple idea of [extedning](http://people.cs.georgetown.edu/jthaler/IPsandextensions.pdf) a function from $Z \mapsto \{0,1\}$ to a low degree polynomial is a very powerful tool! It and its multi-variable generalization are the basis of [many](https://pdfs.semanticscholar.org/a87d/3febd2e02c41a9b0a4e423089b6677eaef3b.pdf) [results](https://eccc.weizmann.ac.il/report/2017/108/download/) in computer science. 

We can now claim that, for *any* degree $f$ polynomial $p$, we have:
$$p(X)=\sum_{z \in Z} L_z(X) p(z)$$


Why does this equality hold?
It's because both $p(X)$ and $\sum_{z \in Z} L_z(X) p(z)$ are degree-at-most-$f$ polynomials so their difference is also of degree-at-most-$f$ and has $f+1$ zeros, since $|Z|=f+1$.
From the [main theorem in our previous post on polynomials](/2020-07-05-the-marvels-of-polynomials-over-a-field), this means that $p(X)-\sum_{z\in Z} L_z(X) p(z)$ must be the zero polynomial.
Thus, $p(X)=\sum_{z \in Z} L_z(X) p(z)$ follows from the fact that non-trivial degree-at-most-$f$ polynomaisl have at most $d$ roots!

This argument shows that there is a *unique representation* of $p=\{p_0,\dots,p_f\}$ for the Lagrange basis induced by $Z=\{z_1,\dots,z_{f+1}\}$.
Specifically, this representation is the set $\{p(z_1),\dots,p(z_{f+1})\}$.

Let
$$
\phi(p_0,\dots,p_f) = (p(z_1),\dots,p(z_{f+1}))
$$
for $Z=\{ z_1,\dots,z_{f+1}\}$. 


**Claim:** $\phi$ is a bijective map from the set of degree-at-most-$f$ polynomials to their evaluations at the points in $Z$, where $\|Z\|=f+1$.

**Proof.** To show that $\phi : \mathbb{F}_p^{f+1} \mapsto \mathbb{F}_p^{f+1}$ is [bijective](https://en.wikipedia.org/wiki/Bijection), it is enough to show that $\phi$'s domain and [image](https://en.wikipedia.org/wiki/Image_(mathematics)) are of the same size and that $\phi$ is [injective](https://en.wikipedia.org/wiki/Injective_function).


Since $\phi$ takes as input degree-at-most-$f$ polynomials with coefficients over $\mathbb{F}\_





p$, there are exactly $\|\mathbb{F\_p}\|^{f+1} = p^{f+1}$ such polynomials.
In other words, $\phi$'s domain is $\mathbb{F}\_p^{f+1}$.
Also, since its image is the set of all possible $f+1$ evaluations $(p(z_1),\dots,p(z_{f+1}))$, with each evaluation being an element of $\mathbb{F}\_p$, it follows that $\phi$'s image is exactly $\mathbb{F}\_p^{f+1}$.
Thus, $\phi$'s domain is of the same size as its image.

To show that $\phi$ is injective, assume the opposite.
This means there exist two polynomials $p=(p_0,\dots,p_f)$ and $p'=(p'_0, \dots, p'_f)$ such that $p\ne p'$ but $\phi(p_0, \dots, p_f) = \phi(p'_0, \dots, p'_f)$.
In other words, we have $p(z)=p'(z)$ for all $z \in Z$.
But this implies that $p-p'$ is a degree-at-most-$f$ polynomial that has at least $f+1$ zeros.
From the [main theorem of our previous post](/2020-07-05-the-marvels-of-polynomials-over-a-field), this means that $p-p'=0$ and hence $p=p'$.
Contradiction, therefore $\phi$ is injective.

We conclude that $\phi$ is bijective. In fact $\phi$ is a [linear isomorphisim](https://en.wikipedia.org/wiki/Linear_map) and so $L_{z_1},\dots,L_{z_{f+1}}$ is a [basis](https://en.wikipedia.org/wiki/Basis_(linear_algebra)) for the set of degree-at-most-$f$ polynomials (for any set $Z=\{z_1, \dots,z_{f+1}\}$). 

We can now use our new insights to prove the secret sharing properties. 

### Proof of the Secret Sharing properties

**Proof for Binding and Validity**:

Since the adversary is passive, all we need to do is show that indeed all parties will output $s$. Recall that the Reconstruct protocol outputs:

$$p(0)=\sum_{1\leq i \leq f+1} \lambda_i p_i$$

where

$$\lambda_i = \frac{\prod_{j \in \{1,
\dots,f+1\} \setminus \{i\}} j}{\prod_{j \in \{1,
\dots,f+1\} \setminus \{i\}} (j-i)}$$


The proof follows directly from the fact that  $p(X)=\sum_{1\leq i \leq f+1} L_i(X) p(i)$ and so $p(0)= \sum_{1\leq i \leq f+1} L_i(0) p(i) = \sum_{1\leq i \leq f+1} \lambda_i p_i$ = p(0)=s where $p_i=p(i)$ is the share of party $i$.

**Proof of Hiding**: 

Let's define the *view* of an adversary that controls the parties $B=\{b_1,\dots,b_f\}$ as the messages that the adversary sees during the Share protocol.
In our case, this is just $\{ p(b_1),\dots,p(b_{f}) \}$, which are the shares that the parties in $B$ receive from the Dealer during the Share protocol.

To prove the hiding property we will show that, no matter what the secret $s$ is, the distribution of the view of the adversary is a [uniform distribution](https://en.wikipedia.org/wiki/Discrete_uniform_distribution).

We have shown above that $\phi$ is a bijective mapping from $p_0,\dots,p_{f+1}$ to $p(z_1),\dots,p(z_{f+1})$ for any set $Z=\{z_1,\dots,z_{f+1}\}$. 

Consider the set $Z=\{0\} \cup B$ where $B=\{b_1,\dots,b_f\}$ is the set of parties controlled by the passive adversary.
(Here, we use the assumption that party identities start from 1.)

**Claim:** $\phi$ maps the uniform distribution $\mathcal{D}$ on $p_0,p_1,\dots,p_{f+1}$ to the uniform distribution on $p(0),p(b_1),\dots, p(b_{f})$.


**Proof:** For *any* $z_0,\dots,z_{f} \in \mathbb{F}\_{p}^{f+1}$, the uniform distrubtion implies $\Pr_{ \mathcal{D} } [\bigwedge p_i=z_i] = 1/ \| \mathbb{F}\_{p} \|^{f+1}$. From the bijection of $\phi$ we get that for *any* $y_0,\dots, y_{f} \in \mathbb{F}\_{p}^{f+1}$ we have that there must exists unique $z_0,\dots,z_{f} \in \mathbb{F}\_{p}^{f+1}$ such that
$\Pr_{\mathcal{D}}[\bigwedge p(i)=y_i] = \Pr_{\mathcal{D}}[\bigwedge \phi^{-1}(p(0),\dots,p(f))_i=z_i] = 1/ \|\mathbb{F}\_p\|^{f+1}$.


Observe that, since $0 \in Z$, the first output of $\phi$ is $p(0)=p_0$, so the first input of $\phi$ ($p_0$) matches the first output of $\phi$ ($p(0)$).

From the above observation, we immediately get that for any *fixed* $s=p_0$, $\phi$ must map the uniform distribution on $p_1,\dots,p_{f+1}$ to the uniform distribution on $p(b_1),\dots,p(b_{f})$.

Since, for any input $s=p_0$, the Dealer uses the uniform distribution to pick the coefficients $p_1,\dots,p_{f+1}$, then for any input $s$ the *view* of the adversary $p(b_1),\dots,p(b_f)$ is also uniformly distributed!

In what sense does this mean that the adversary learns nothing about the secret $s=p(0)=p_0$? In the sense that, no matter what the secret is, the *distribution of the view* of the adversary is the same and is independent of the actual secret.

In other words, anything the adversary could learn by observing the distribution of its views, it could learn by just sampling from this distribution without any interaction.



Please leave comments on [Twitter](...).
