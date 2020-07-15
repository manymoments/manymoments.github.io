---
title: Polynomial Secret Sharing and the Lagrange Basis
date: 2020-07-09 08:36:00 -07:00
published: false
---

In this post, we highlight an amazing result: Shamir's [secret sharing scheme](https://cs.jhu.edu/~sdoshi/crypto/papers/shamirturing.pdf). This is one of the most powerful uses of polynomials over a finite field in distributed computing.


The setting is that there are $n$ parties, with one designated party called the *Dealer*.
A *secret sharing scheme* is composed of two protocols: *Share* and *Recover*.
These protocols are distributed: they are run by the $n$ parties, jointly.
The Dealer has a _secret_ $s$, which is given as _input_ to the Share protocol.
Intuitively, if the Share protocol "succeeds", then the Recover protocol will _output_ that same secret $s$.
<!-- In the Share protocol, the Dealer has some *input value* $s$.
In the Recover protocol, each party outputs a *decision value*.-->

{: .box-warning}
**Alin:**
Two things.
First, this does not actually explain the "threshold" nature of secret sharing.
Second, this seems too formal/verbose for something that could be explained more succinctly: "Secret sharing is a protocol that allows a dealer to "split" or "share" a secret $s$ amongst $n$ (or $n-1$) parties such that any subset of $f+1$ parties can reconstruct $s$ but no fewer can. This is useful for splitting your Bitcoin keys amongst 10 friends such that you can recover it from any 6 friends but no subset of 5 friends or less could recover/steal your key.
Hiding and Binding+Validity can be explained as necessary properties of this Bitcoin secret key splitting scheme.

These properties of a secret sharing scheme can be described more formally as:

**Binding**: Once the first non-faulty completes the Share protocol there exists some value $r$ such that $r$ is the output value of all non-faulty parties that complete the Recover protocol.

**Validity**: If the Dealer is non-faulty then the output of the Recover protocol is the Dealer's input value $s$.

**Hiding**: If the dealer is non-faulty, and no honest party has begun the Recover protocol, then the adversary can gain no information about $s$. 


The first two properties seem well defined, but what about the hiding property? What does it mean that the adversary "gains no information about $s$"? We will be more formal about this later but informally this means that anything the adversary can output by interacting with this protocol, the adversary could have output the same without any interaction at all.

### Shamir's scheme

In Shamir's scheme, we assume a [passive adversary](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) that controls some $f<n$ parties. We will enumerate the parties via the integers $\\{1,2,3,\dots,n\\}$. We also assume there is a commonly known finite field $\mathbb{F}_p$ with $p>n$.

**Share protocol**: Given a secret $s$ as input, the Dealer _randomly_ chooses $f$ values $p_1,\dots,p_f \in_R \mathbb{F}_p$ and defines a degree $\le f$ polynomial

$$p=s+p_1 X + \dots + p_f X^f$$

The Dealer then sends $p(i)$ to each party $i$.
We refer to $p(i)$ as party $i$'s _share_ of the secret $s$.
Note that $p(0) = s$, which is the Dealer's secret.

**Recover protocol**: 
Each party $i$ sends its share $p(i)$ to all other parties. 
Each party receives all the shares $p(1),\dots,p(n)$ and outputs the Dealer's original secret $s$ as follows:

$$s=p(0)=\sum_{i \in I} \lambda_i p_i$$

Here, $I= \\{ 1,\dots,f+1 \\}$ and:

$$\lambda_i = \frac{\prod_{z \in I \setminus \{i\}} z}{\prod_{z \in I \setminus \{i\}} (z-i)}$$

{: .box-warning}
**Alin:** This is strange because we are only using the first $f+1$ shares, which will confuse the reader. Why give all $n$ shares if only the first $f+1$ are used?

This looks like magic, no?
No worries.
We explain how this reconstruction of the secret $s$ from the parties' shares works next.

### Lagrange Basis

Lets dig deeper into how and why the values $\lambda_1,\dots,\lambda_{f+1}$ are defined.

For any set $Z=\\{z_1,\dots,z_{f+1}\\}$ of size $f+1$ we can define the *Lagrange basis* for degree-at-most-$f$ polynomials as follows:

For every $z \in Z$, let $L_y:Z \mapsto \\{0,1\\}$ be the [indicator function](https://en.wikipedia.org/wiki/Indicator_function) such that:

$$L_z(x) = \begin{cases} 1,\ \text{if}\ x=z\\0,\ \text{if}\ x \neq z\end{cases}$$

We can then extend this function to be $L\_z : \mathbb{F}\_p \mapsto \\{0,1\\}$ by defining it as a degree $f$ polynomial:

$$L_z(X)= \frac{\prod_{y \in Z \setminus \{z\}} (X-y)}{\prod_{y \in Z \setminus \{z\}} (z-y)}$$

We can now claim that, for *any* degree $f$ polynomial $p$, we have:
$$p(X)=\sum_{z \in Z} L_z(X) p(z)$$

Why does this equality hold?
It's because both $p(X)$ and $\sum_{z \in Z} L_z(X) p(z)$ are degree-at-most-$f$ polynomials so their difference is also of degree-at-most-$f$ and has $f+1$ zeros, since $|Z|=f+1$.
From the [main theorem in our previous post on polynomials](/2020-07-05-the-marvels-of-polynomials-over-a-field), this means that $p(X)-\sum_{z\in Z} L_z(X) p(z)$ must be the zero polynomial.
Thus, it follows that $p(X)=\sum_{z \in Z} L_z(X) p(z)$!

This argument shows that there is a *unique representation* of $p=\\{p_0,\dots,p_f\\}$ for the Lagrange basis induced by $Z=\\{z_1,\dots,z_{f+1}\\}$.
Specifically, this representation is the set $\\{p(z_1),\dots,p(z_{f+1})\\}$.

Let
$$
\phi(p_0,\dots,p_f) = (p(z_1),\dots,p(z_{f+1}))
$$
for $Z=\\{ z_1,\dots,z_{f+1}\\}$. 

{: .box-note}
**Claim:** $\phi$ is a bijective map from the set of degree-at-most-$f$ polynomials to their evaluations at the points in $Z$, where $\|Z\|=f+1$.

**Proof.** To show that $\phi : \mathbb{F}_p^{f+1} \mapsto \mathbb{F}_p^{f+1}$ is [bijective](https://en.wikipedia.org/wiki/Bijection), it is enough to show that $\phi$'s domain and [image](https://en.wikipedia.org/wiki/Image_(mathematics)) are of the same size and that $\phi$ is [injective](https://en.wikipedia.org/wiki/Injective_function).

<!--
Since any degree-at-most-$f$ polynomial has at most $f+1$ coefficients, then the number of degree-at-most-$f$ polynomials is exactly $\|\mathbb{F_p}\|^{f+1} = p^{f+1}$.
Similarly, the number of possible output values for all $\phi(z), z \in Z$, with $\|Z\|=f+1$, is also $p^{f+1}$.
-->

Since $\phi$ takes as input degree-at-most-$f$ polynomials with coefficients over $\mathbb{F}\_p$, there are exactly $\|\mathbb{F\_p}\|^{f+1} = p^{f+1}$ such polynomials.
In other words, $\phi$'s domain is $\mathbb{F}\_p^{f+1}$.
Also, since its image is the set of all possible $f+1$ evaluations $(p(z_1),\dots,p(z_{f+1}))$, with each evaluation being an element of $\mathbb{F}\_p$, it follows that $\phi$'s image is exactly $\mathbb{F}\_p^{f+1}$.
Thus, $\phi$'s domain is of the same size as its image.

To show that $\phi$ is injective, assume the opposite.
This means there exist two polynomials $p=(p_0,\dots,p_f)$ and $p'=(p'_0, \dots, p'_f)$ such that $p\ne p'$ but $\phi(p_0, \dots, p_f) = \phi(p'_0, \dots, p'_f)$.
In other words, we have $p(z)=p'(z)$ for all $z \in Z$.
But this implies that $p-p'$ is a degree-at-most-$f$ polynomial that has at least $f+1$ zeros.
From the [main theorem of our previous post](/2020-07-05-the-marvels-of-polynomials-over-a-field), this means that $p-p'=0$ and hence $p=p'$.
Contradiction, therefore $\phi$ is injective.

We conclude that $\phi$ is bijective. In fact $\phi$ is a [linear isomorphisim](https://en.wikipedia.org/wiki/Linear_map) and so $L_{z_1},\dots,L_{z_{f+1}}$ is a [basis](https://en.wikipedia.org/wiki/Basis_(linear_algebra)) for the set of degree-at-most-$f$ polynomials. 

### Proof of the properties

**Proof for Binding and Validity**:

Since the adversary is passive, all we need to do is show that indeed all parties will output $s$. This follows directly from the fact that  $p(X)=\sum_{1\leq i \leq f+1} L_i(X) p(i)$ and so $p(0)= \sum_{1\leq i \leq f+1} L_i(0) p(i) = \sum_{1\leq i \leq f+1} \lambda_i p_i$.

**Proof of Hiding**: 

Let's define the *view* of an adversary that controls the parties $B=\\{b_1,\dots,b_f\\}$ as the messages that the adversary sees during the Share protocol.
In our case, this is just $\\{ p(b_1),\dots,p(b_{f}) \\}$, which are the shares that the parties in $B$ receive from the Dealer during the Share protocol.

To prove the hiding property we will show that, no matter what the secret $s$ is, the distribution of the view of the adversary is a uniform distribution.

We have shown above that $\phi$ is a bijective mapping from $p_0,\dots,p_{f+1}$ to $p(z_1),\dots,p(z_{f+1})$ for any set $Z=\\{z_1,\dots,z_{f+1}\\}$. 

Consider the set $Z=\\{0\\} \cup B$ where $B=\\{b_1,\dots,b_f\\}$ is the set pf parties controlled by the passive adversary.
(Here, we use the assumption that party identities start from 1.)
1. Observe that, since $0 \in Z$, the first input of $\phi$ is $p_0$ and the first output of $\phi$ is $p(0)=p_0$, so they match.
2. Since $\phi$ is a bijection, it maps the uniform distribution on $p_0,p_1,\dots,p_{f+1}$ to the uniform distribution on $p(0),p(b_1),\dots, p(b_{f})$.

{: .box-warning}
**Alin:** Can you prove point number (2) above? Or at least provide a reference.

From the above two observations, we immediately get that for any *fixed* $p_0$, $\phi$ must map the uniform distribution on $p_1,\dots,p_{f+1}$ to the uniform distribution on $p(b_1),\dots,p(b_{f})$.

Since, for any input $s$, the Dealer uses the uniform distribution to pick the coefficients $p_1,\dots,p_{f+1}$, then for any input $s$ the *view* of the adversary $p(b_1),\dots,p(b_f)$ is also uniformly distributed!

In what sense does this mean that the adversary learns nothing about the secret $s=p(0)=p_0$? In the sense that, no matter what the secret is, the *distribution of the view* of the adversary is the same and is independent of the actual secret.

In other words, anything the adversary could learn by observing the distribution of its views, it could learn by just sampling from this distribution without any interaction.

**Acknowledgment.** Thanks to [Alin](https://research.vmware.com/researchers/alin-tomescu) for helpful feedback on this post.


Please leave comments on [Twitter](...).
