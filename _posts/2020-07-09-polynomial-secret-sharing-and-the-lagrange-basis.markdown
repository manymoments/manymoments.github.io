---
title: Polynomial Secret Sharing and the Lagrange Basis
date: 2020-07-09 08:36:00 -07:00
published: false
---

In this post, we introduce an amazing result: Shamir's [secret sharing scheme](https://cs.jhu.edu/~sdoshi/crypto/papers/shamirturing.pdf). The setting is that there are $n$ parties with one designated party called the *Dealer*. The secret sharing scheme is composed of two protocols: *Share* and *Recover*. In the *Share* protocol, the Dealer has some *input value* $s$. In the Recover protocol, each party outputs a *decision value*.

There are three properties for the secret sharing scheme that we want to have:

**Binding**: Once the first non-faulty completes the Share protocol there exists some value $r$ such that $r$ is the output value of all non-faulty parties that complete the Recover protocol.

**Validity**: If the Dealer is non-faulty then the output is the Dealer's input value $s$.

**Hiding**: If the dealer is non-faulty, and no honest party has begun the Recover protocol, then the adversary can gain no information about $s$. 


The first two properties seem well defined, but what about the hiding property? What does it mean that the adversary "gains no information about $s$"? We will be more formal about this later but informally this means that anything the adversary can output by interacting with this protocol, the adversary could have output the same without any interaction at all.

### Shamir's scheme

In Shamir's scheme, we assume a [passive adversary](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) that controls some $f<n$ parties. We will enumerate the parties via the integers $\{1,2,3,\dots,n\}$. We also assume there is a commonly known finite field $F_p$ with $p>n$.


**Share protocol**: Given input $s$, the Dealer randomly chooses $f$ values $p_1,\dots,p_f \in_R F_p$ and defines a degree $f$ polynomial 
$$
p=s+p_1 X + \dots + p_f X^f
$$
the Dealer then sends party $i$ the value p(i).

**Recover protocol**: party $i$ sends its share $p_i$ to all parties. Each party receives all the shares $p_1,\dots,p_n$ and outputs 
$$
p_0=\sum_{1\leq i \leq f+1} \lambda_i p_i
$$
Where $I= \{ 1,\dots,f+1 \}$ and
$$
\lambda_i = \frac{\prod_{z \in I \setminus \{i\}} z} {\prod_{z \in I \setminus \{i\}} (z-i)}
$$

### Lagrange Basis

Lets dig deeper into how and why the values $\lambda_1,\dots,\lambda_{f+1}$ are defined.

For any set $Z=\{z_1,\dots,z_{f+1}\}$ of size $f+1$ we can define the *LaGrange basis* for degree-at-most-$f$ polynomials as follows:

For every $z \in Z$, let $L_y:Z \mapsto \{0,1\}$ be the [indicator function](https://en.wikipedia.org/wiki/Indicator_function) such that 
$L_z(x)= 1$ if $x=z$ and $L_z(x)=0$ if $x \neq z$. We can then extend this function to be $L_z:F_p \mapsto \{0,1\}$  by defining it as a degree $f$ polynomial:
$$
L_z(X)= \prod_{y \in Z \setminus \{z\}} (X-y) / \prod_{y \in Z \setminus \{z\}} (z-y)
$$
We can now represent *any* degree $f$ polynomial $p$ as follows:
$$
p(X)=\sum_{z \in Z} L_z(X) p(x)
$$
Why does the equality hold? its because both $p(x)$ and $l(x)=\sum_{z \in Z} L_z(X) p(x)$ are degree-at-most-$f$ polynomials so $p-l$ is also of degree-at-most-$f$ and has $f+1$ zeros. From the [Theorem of our previous](...) post this means that $p-l=0$ must be the zero polynomial, so they are equal!

This argument shows that there is a *unique representation* of $p=\{p_0,\dots,p_{f+1}\}$ for the Lagrange Basis induced by $Z=\{z_1,\dots,z_{f+1}\}$, this is the set $\{p(z_1),\dots,p(z_{f+1})\}$.

Let 
$$
\phi(p_0,\dots,p_{f+1}) = (p(z_1),\dots,p(z_{f+1}))
$$
for $Z=\{ z_1,\dots,z_{f+1} \}$. 

**Claim: $\phi$ is a bijective map from the set of degree-at-most-$f$ polynomials and their interpolations at the points in $Z$ where $|Z|=f+1$.**

To show that $\phi$ is bijective it is enough to show that the source and target sets are of the same size and that $\phi$ is [injective](https://en.wikipedia.org/wiki/Injective_function).

Since any degree-at-most-$f$ polynomial has at most $f+1$ coefficients then the number of degree-at-most-$f$ polynomials is exactly $|F|^{f+1}$ (where $|F|=|F_p|=p$). The number of possible output values for $\phi$, for any set $|Z|=f+1$, is also $|F|^{f+1}$.

To show that $\phi$ is injective, assume that two degree-at-most-$f$ polynomials $p, p'$ are such that $p(z)=p'(z)$ for all $z \in Z$. This impleis that $p-p'$ is a degree-at-most-$f$ polynomial that has at least $f+1$ zeros. From the [Theorem of our previous](...) post this means that $p-p'=0$ and hence $p=p'$.

We conclude that $\phi$ is [bijective](https://en.wikipedia.org/wiki/Bijection). In fact $\phi$ is a [linear isomorphisim](https://en.wikipedia.org/wiki/Linear_map) and so $L_{x_1},\dots,L_{x_{f+1}}$ is a [basis](https://en.wikipedia.org/wiki/Basis_(linear_algebra)) for the set of degree-at-most-$f$ polynomials. 

### Proof of the properties

**Proof for Binding and Validity**: Since the adversary is passive, all we need to do is show that indeed all parties will output $s$. This follows directly from the fact that  $p(X)=\sum_{1\leq i \leq f+1} L_i(X) p(i)$ and so $p(0)= \sum_{1\leq i \leq f+1} L_i(0) p(i) = \sum_{1\leq i \leq f+1} \lambda_i p_i$.

**Proof of Hiding**: 

Let's define the *view* of an adversary that controls the parties $B=\{b_1,\dots,b_f\}$ as the messages that the adversary sees during the Share protocol.  In our case this is just $\{ p(b_1),\dots,p(b_{f}) \}$ which are the shares that the parties in $B$ receive from the Dealer during the Share protocol.

To prove the hiding property we will show that no matter what the secret $s$ is, the distribution of the view of the adversary is a uniform distribution.


We have shown above that $\phi$ is a bijective mapping from $p_0,\dots,p_{f+1}$ to $p(z_1),\dots,p(z_{f+1})$ for any set $Z=\{z_1,\dots,z_{f+1}\}$. 

Consider the set $Z=\{0\} \cup B$ where $B=\{b_1,\dots,b_f\}$ is the set pf parties controlled by the passive adversary (here we use the assumption that party identities start from 1). 
1. Observe that when $0 \in Z$, then the first input of $\phi$ is $p_0$, and the first output of $\phi$, are the same: $p(0)=p_0$.
2. Since $\phi$ is a binjection, it maps the uniform distribution on $p_0,p_1,\dots,p_{f+1}$ to the uniform distribution on $p(0),p(b_1),\dots, p(b_{f})$.

From the above two obeservations, we immediately get that for any *fixed* $p_0$, $\phi$ must map the uniform distribution on $p_1,\dots,p_{f+1}$ to the uniform distribution on $p(b_1),\dots,p(b_{f})$.

Since for any input $s$ the Delaer uses the uniform distribution to pick the coefficients $p_1,\dots,p_{f+1}$, then for any input $s$ the *view* of the adversary $p(b_1),\dots,p(b_f)$ is also uniformly distributed!

In what sense does this mean that the adversary learns nothing about the secret $s=p(0)=p_0$? In the sense that no matter what the secret is, the *distribution of the view* of the adversary is the same and is independent of the actual secret.

In other words, anything the adversary could learn by observing the distribution of its views, it could learn by just sampling from this distribution without any interaction.

**Acknowledgment.** Thanks to [Alin](https://research.vmware.com/researchers/alin-tomescu) for helpful feedback on this post.


Please leave comments on [Twitter](...).