---
title: A Simple and Succinct Zero Knowledge Proof
date: 2020-07-11 13:37:00 -04:00
published: false
---

Many people have popularized the idea that succinct proofs and zero-knowledge proofs are a type of [moon math](https://medium.com/@VitalikButerin/quadratic-arithmetic-programs-from-zero-to-hero-f6d558cea649). In this post, our goal is to present a simple proof system that can provide an introduction and intuition to this space. Perhaps surprisingly, the only tool we will use is the [Theorem](first post) that non-trivial degree-at-most-$d$ polynomials over a field have at most $d$ roots.

### Start with Succinctness, add Zero Knowledge later
The traditional CS educational approach typically first shows a zero-knowledge scheme related to proving [3-colorability of a graph](https://crypto.stanford.edu/cs355/18sp/lec3.pdf), or proving the existence of a [Hamiltonian cycle](https://people.eecs.berkeley.edu/~sanjamg/classes/cs294-spring16/scribes/7.pdf). Succinct proofs are often taught at a [later phase](https://crypto.stanford.edu/cs355/19sp/lec17.pdf) and in connection to the [PCP](https://en.wikipedia.org/wiki/PCP_theorem) theorem.

Since Colorability, Hamilonicity and Satisfiability are all [NP-complete](https://en.wikipedia.org/wiki/NP-completeness) problems, the advantage of this approach is that it immediately gives very general Theoretical Computer Science results via [Karp-based reductions](https://en.wikipedia.org/wiki/Polynomial-time_reduction) to any problem in NP.

In this post, we take a different approach.
We start with a seemly useless problem (that is solvable in polynomial time) as our goal is to give an intuition for later constructions, not to prove general complexity results.

### The setting
We will assume two parties: a Prover, and a Verifier.

The Prover has an input $S=\langle s_0,\dots,s_{d-1}\rangle $ which is a vector of say $d=10^{10}$ field elements (so $s_i \in \mathbb{F}_p$). It will be important that assume $p$ is large relative to $d$ (so $p \gg  d$). All the Prover wants to do is prove to the Verifier this simple fact:
> Is $S$ the all-zero vector or not?

We will assume the only way the Prover and Verifier can interact is via a special communication channel we will call the *virtual cloud*:
1. The Prover has to *commit* to its input $S$ by uploading a degree-at-most-$d$ polynomial $g(x) = \sum\_{i\in[0,d)} s\_i \prod\_{j\in[0, d), j\ne i} \frac{x - s\_j}{s\_i - s\_j}$ to the virtual cloud. Note that $g(i)=s_i$. This polynomial $g$ is the [Largeange basis](https://decentralizedthoughts.github.io/2020-07-17-polynomial-secret-sharing-and-the-lagrange-basis/) of $S$. 


2. The verifier is allowed to query the virtual cloud by sending it an element $r$ and the virtual cloud responds back with $g(r)$, the evaluation of $r$ on $g$.


### A non-succinct solution, with no error
How can the verifier be sure that $S$ is all-zero and hence $g$ is the zero (trivial) polynomial? 

Observe that when $S$ is all-zero then $g$ is the (trivial) zero polynomial! But if $S$ is not all-zero then the [fundamental theorem of arithmetic adopted to finite field polynomials](https://decentralizedthoughts.github.io/2020-07-17-the-marvels-of-polynomials-over-a-field/) says that $g$ has at most $d$ roots. So the verifier has a simple way to distinguish: it can query $d+1=10^{10} +1$ distinct points and check if they are all zero.

This solution is not succinct as it requires the Verifier to send $d+1$ queries, which is too many. Can the Verifier use less queries?

### A succinct solution
We will now recall that we are working over the field $\mathbb{F}_p$ where $p\gg d$. By now, it should be quite clear how the Verifier can get a succinct proof that $S$ is all-zero or not.

> The Verifier chooses a uniformly random element $r \in_R \mathbb{F}_p$ and queries the virtual cloud just once with $r$:

1. Clearly, if $g(r) \neq 0$, then $g$ is not the trivial polynomial, so $S$ is not all-zeros.
2. What if $g(r)=0$? Then, we use the Theorem that $g$ has at most $d$ roots to say: If $r\in_R \mathbb{F_p}$ and $g(r)=0$ then the probability that $g$ is non-zero is at most $d/p$ (where $p$ is the size of the Field).

We can choose $p\gg d$, so the error probability is as low as we want. So if $g(r)=0$, then the Verifier declares that $S$ is all-zero.

That's it! this is a very succinct proof: instead of querying $d+1=10^{10} +1$ points, the Verifier can succinctly query just one (local) point and learn about a (global) property $S$ (with a small error probability).

### Adding Zero Knowledge

The prover managed to prove that $S$ is not zero using a succinct proof. Clearly, if $g=0$ then we know everything about $S$. However, when $g\neq 0$, what if we would also want the verifier to learn nothing about $S$ other than that it's not all-zero?

The verifier can ask for say $g(i)$ and learn some $s_i \in S$, so the first thing we need to do is restrict the verifier to choose a random element $x$ that is outside of $\\{0,\dots,d-1\\}$.

Even that may leak information, for example, for $d=1$, the vector $S$ is of size $2$ and $g$ is a degree one polynomial. If the Verifier learns, say $g(10)$, then it has learned some linear relation between $s_0$ and $s_1$.

To overcome this, the Prover simply adds one more random element $r$ to its vector, $S'=\langle s_0,\dots,s_{d-1}, r\rangle $ and works with a polynomial $g'$ of degree $d+1$. Using an argument that is similar to the one in [our second post](...), it can be seen that for any $S$, the Verifier's view, $g(x)$, for $x>d+1$, is uniformly distributed in $\mathbb{F}_p$. Hence the only information the Verifier gains from the protocol, the Verifier could have simulated locally. So the verifies gains no information at all.

So we have shown a way for the verifier to obtain a succinct zero-knowledge proof!

### Removing the strange virtual cloud communication channel

A major complaint against this scheme is the strange communication mechanism.
1. First, it required the Prover to upload the polynomial $g$. This naively seems to be a non-succulent operation and requires some trusted cloud to store a lot of information. Luckily, we will show in a later post how cryptographic tools can implement this succinctly over a standard communication channel.
2. Secondly, it required the virtual cloud to respond to a query $x$ with the value $g(x)$. This may seem to require a trusted computing cloud. Luckily again, we will show in a later post how cryptographic tools can implement this functionality over a standard communication channel.
3. Finally, recall that we needed $d\ll p$. There is sometimes a challenge in forcing the Prover to use a degree-at-most-$d$ polynomial and not one of higher degree. Again we will see techniques in later posts to force the Prover to use a low degree.
