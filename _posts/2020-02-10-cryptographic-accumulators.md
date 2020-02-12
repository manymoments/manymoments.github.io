---
title: "Cryptographic Accumulators 101"
date: 2020-02-10 09:05:00 -08:00
tags:
- cryptography
- accumulators
author: Alin Tomescu
published: false
---

Accumulators are an alternative to Merkle Hash Trees (MHTs) for committing to **sets** of **elements**.
<!-- TODO: ref MHT -->
They support *constant-sized* **membership** and **non-membership proofs**, an improvement over the logarithmic-sized proofs in MHTs.
However, this comes at the cost of more computation, typically elliptic curve group operations or hidden-order group operations (e.g., in $\mathbb{Z}_N^\*$).
Accumulators also offer constant-sized proofs for set relations such as subset, disjointness and difference.
<!-- TODO: ref Babis's papers -->

Accumulators are a good choice if you are willing to sacrifice speed for one of the following:
 
 - very small proofs, 
 - an algebraic commitment to a set, which allows you to *efficiently* prove things about committed elements,
<!-- TODO: ref papers that build credential systems from accumulators -->
 - proving multiple set relations (e.g., subset and disjointness)
<!-- TODO: ref papers that use set operations -->

In this article, we'll talk about the ins and outs of two types of accumulators: **bilinear accumulators** and **RSA accumulators**.
<!-- TODO: ref papers -->

## The setting

Just like with MHTs, we'll consider accumulators in the setting of a **prover** and one or more **verifiers**.
The prover will be the party committing to the set and computing proofs (e.g., membership, non-membership, disjointness).
The verifiers will be the parties that verify proofs.

Typically, there will be some **public parameters (PPs)** needed for the prover to commit to a set and compute proofs.
Furthermore, the verifier might need (a subset of) these parameters to verify proofs.

For example, for MHTs, the public parameters are simply the collision-resistant hash function (CRHF) used to compute the MHT, shared by both the prover and verifier.
With accumulators, however, the PPs will typically consist of the description of an algebraic group (e.g., an elliptic curve or $\mathbb{Z}_N^\*$) as well as some other group elements.
(We'll discuss this below.)

## Bilinear accumulators

### Setting up an accumulator scheme

Recall that to set up an MHT scheme, all that must be done is to agree on what CRHF will be used to hash the tree.
With bilinear accumulators, things are a bit more complicated.

First, bilinear accumulators work in **bilinear groups** $\mathbb{G}$.
Such groups have an efficiently-computable **bilinear map** $e : \mathbb{G}\times\mathbb{G}\rightarrow\mathbb{G}_T$, where $\mathbb{G}_T$ is another group called the **target group**. <!-- TODO: note about pairing type -->
Let $g$ denote the generator of $\mathbb{G}$.
Recall that bilinear maps have very useful algebraic properties:

$$e(g^a,g^b)=e(g^a,g)^b=e(g,g^b)^a=e(g,g)^{ab}$$

Second, bilinear accumulators can only be used to commit to sets of _bounded_ size $\ell$.
For this, they need **$\ell$-Strong Diffie-Hellman ($\ell$-SDH)** public parameters:

$$\left(g^{\tau^i}\right)_{i=0}^{\ell} = (g, g^\tau, g^{\tau^2}, g^{\tau^3},\dots,g^{\tau^\ell})$$

To generate these $\ell$-SDH PPs, a bilinear accumulator requires a **trusted setup phase**, where a **trusted third party (TTP)** takes as input the maximum size $\ell$ of sets that will be committed to.
Importantly, this TTP *must forget* the **trapdoor** $\tau$ which, if exposed, can be used to break the soundness of accumulator proofs.
Thus, since TTPs should be avoided in practice, the TTP is implemented in a "decentralized" manner via multiple parties.
This way, all parties must collude in order to learn $\tau$, which means a single honest party suffices to keep $\tau$ secret.

**Note:** This requirement of a trusted setup phase is a disadvantage of bilinear accumulators, since it complicates the set up of a bilinear accumulator scheme.
As we'll see later, RSA accumulators do not necessarily need a trusted setup.

### Committing to sets

Recall that a group $\mathbb{G}$ with generator $g\in \mathbb{G}$ is part of the public parameters of the accumulator.
Let $p$ denote the order of $\mathbb{G}$.
Then, bilinear accumulators can commit to any set $T=\\{e_1,e_2,\dots,e_n\\}$ where $e_i \in \mathbb{Z}_p$.

To commit, to $T$, the prover first computes an **accumulator polynomial** $\alpha$ which has roots at all the $e_i$'s:

$$\alpha(X) = (X-e_1)(X-e_2)\cdots(X-e_n)$$

Specifically, the prover actually obtains the coefficients $(a_0, a_1, \dots, a_n)$ of the polynomial $\alpha$.
(This can be done in $O(n\log^2{n})$ time by starting with monomials $(X-e_i)$ as leaves of a binary tree and multiplying up the tree to obtain $\alpha(X)$'s coefficients at the root.)

Then, the **digest** of $T$, often referred to as the **accumulator** of T, is set to $a=g^{\alpha(\tau)}$.
It can be computed from the coefficients $a_i$ of $\alpha$ and the $\ell$-SDH PPs as follows:

\begin{align\*}
    a &= \prod_{i=0}^n \left(g^{\tau^i}\right)^{a_i}\\\
      &= \prod_{i=0}^n g^{a_i \tau^i}\\\
      &= g^{\sum_{i=0}^n {a_i \tau^i}}\\\
      &= g^{\alpha(\tau)}
\end{align\*}

If you missed the last step, it just uses the fact that any polynomial $\alpha$ evaluated at any point $\tau$ is equal to $\sum_{i=0}^n a_i \tau^i = \alpha(\tau)$.

The time to commit to a set is $O(n\log^2{n})$, dominated by the time to compute the coefficients of $\alpha$ from its roots.
However, in practice, more time is spent in the equation above to compute $g^{\alpha(\tau)}$.
For speed, this step should be implemented using a fast multi-exponentiation algorithm. <!-- TODO: cite -->

And that's it! The digest of the set is just the single group element $a\in \mathbb{G}$.
Depending on the types of algebraic groups used, this could be as small as 32 bytes! 

Next, lets see how proofs in bilinear accumulators are also single group elements.
