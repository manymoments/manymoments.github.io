---
title: What is a Merkle Tree?
date: 2020-12-22 09:05:00 -05:00
published: false
tags:
- cryptography
- merkle-hash-tree
- collision-resistant-hash-function
- integrity
author: Alin Tomescu
---

In this post, we will demystify _Merkle trees_ using three examples of problems they solve:

 1. Maintaining integrity of files stored on Dropbox.com, or _file outsourcing_,
 1. Prove a transaction between Alice and Bob occurred, or _set membership_,
 1. Transmitting files over unreliable channels, or _anti-entropy_,
 1. Signing many documents fast, or _batch signing_.
 1. **TODO:** Proving Alice's current Ethereum balance is 20 ETH, or _proving dictionary lookups_.

<p hidden>$$
\def\mht{H_{\mathsf{Merkle}}}
\def\mrh{h_{\mathsf{root}}}
\def\vect#1{\boldsymbol{\vec{#1}}}
$$</p>

By the end of the post, you'll be able to understand several **key concepts**:

 1. A Merkle tree is a **collision-resistant hash function** $\mht$ that takes $n$ inputs $(x\_1, \dots, x\_n)$ and outputs a _Merkle root hash_ $h = \mht(x\_1, \dots, x\_n)$,
 1. A verifier who has the root hash $h$ can be given $\hat{x}\_i$ and a **Merkle proof** for $\hat{x}\_i$ which convinces them that $\hat{x}\_i$ was the $i$th input used to compute $h$.
    + In other words, that there exist other $x_i$'s such that $h=\mht(x\_1, \dots, x\_{i-1}, \hat{x}\_i,x\_{i+1},\dots,x\_n)$.
    + You can think of this as a **membership proof** for $\hat{x}_i$ in the Merkle tree with root $h$.
 1. Merkle tree are quite **versatile.** They can be used to hash sets, vectors, dictionaries, directed acyclic graphs (DAGs), and many other types of data.
    + Even better, when used to hash a set (or a dictionary), the Merkle tree can be "organized" carefully to allow for **non-membership proofs** of elements in the set (or of keys in the dictionary)

**Prerequisites:** 
Merkle trees are built using _cryptographic hash functions_, which we assume you understand.
If not, just read [our post on hash functions][hashurl]!

{: .box-note}
**Definition:** A hash function $H$ is collision resistant if it is computationally-intractable[^handwave] for an adversary to find two different inputs $x,x'$ with the same hash (i.e., with $H(x) = H(x')$).

## This is a Merkle tree!

Suppose you have $n=8$ files $(f_1, f_2, \dots, f_8)$ and a [collision-resistant hash function][hashurl] $H$ and you want to have some fun.

You start by hashing each file as:

$$h_1 = H(f_1), h_2 = H(f_2),\dots, h_8=H(f_8)$$

You could have a bit more fun by continuing to hash every two adjacent hashes:

$$h_{1,2} = H(h_1, h_2), h_{3,4} = H(h_3,h_4), h_{5,6} = H(h_5, h_6), h_{7,8} = H(h_7,h_8)$$

You could even go crazy and continue on these newly obtained hashes:

$$h_{1,4} = H(h_{1,2}, h_{3,4}), h_{5,8} = H(h_{5,6}, h_{7,8})$$

And, to top it all of, you could finally hash these last two hashes:

$$h_{1,8} = H(h_{1,4}, h_{4,8})$$

**Congratulations!**
What you have done is computed a Merkle tree on $n=8$ **leaves**, where the $i$th leaf hashes the file $f_i$, as depicted in the picture below.

**TODO:** picture of tree with hashes and data and leaves!

The _Merkle root hash_ is the $h_{1,8}$ hash at the very top.

We often refer to a file $f_i$ as being **in the Merkle tree**, to indicate it was part of the input used to compute the tree.

It is useful to number the levels of a Merkle tree built over $2^{k-1} < n\le 2^k$ leaves from 1 (i.e., the bottom level storing the leaves) to $k+1$ (i.e., the top level storing the root node).

## This is a Merkle proof!

Next, you upload your files and Merkle tree on Dropbox.com and delete everything from your computer except the Merkle root $h_{1,8}$.
Your goal is to later download any one of your files from Dropbox **and** make sure Dropbox did not accidentally corrupt it.

This is the **file integrity** problem and Merkle trees will help you solve it.

The **key idea** is you will download $f_i$ **and** a small part of the Merkle tree called a **Merkle proof**, which will allow you to verify that $f_i$ was indeed in the Merkle tree.
This assures you that $f_i$ has not been modified since you outsourced it to Dropbox.

<!--
Merkle trees allow you to verify that the file $f_i$ you downloaded from Dropbox was indeed the same file used to compute the Merkle root $h_{1,8}$.
-->

But how do you verify?

Well, the **Merkle proof** for $f_i$ is exactly the subset of hashes in the Merkle tree that, together with $f_i$, allow you to recompute the root hash of the Merkle tree _without knowing any of the other hashed files_ and check it matches the real hash $h_{1,8}$.

This is best explained by a picture:

**TODO:** Merkle proof image: show server side and client side

In other words, such a Merkle proof is a **membership proof** of $f_i$ in the Merkle tree with root hash $h_{1,8}$.

### Who needs Merkle proofs anyway...

Forget the Merkle tree!
Since you only have eight files, you could check integrity by storing their hashes $h_i=H(f_i)$ rather than their Merkle root $h_{1,8} = \mht(f_1, \dots, f_8)$.
After all, the $h_i$ hashes are much smaller than the files themselves.

Then, when you download $f_i$, you hash it as $y_i = H(f_i)$ and check that $h_i = y_i$.
Since $H$ is [collision-resistant][hashurl], you can be certain that $f_i$ was not modified.
(Indeed, we already discussed how [hash functions can be used for download file integrity][hashurl] in our previous post.)

One advantage of this approach is you no longer need to download Merkle proofs.

Unfortunately, the problem with this approach is you have to store $n$ hashes when you outsource $n$ files.
While this is fine when $n=8$, it is no so fine when $n$ is one billion!

_"But that's crazy! Who has one billion files?"_ you might protest.

Well, just take a look at [Certificate Transparency (CT)](https://en.wikipedia.org/wiki/Certificate_Transparency), which builds a Merkle tree over the set of all digital certificates of HTTPS websites.
These Merkle trees have hundreds of millions of leaves.

## What else is a Merkle tree useful for?

Alright, so now that we know how a Merkle tree is computed and how Merkle proofs work, let's dig into a few more use-cases.

<!-- You are probably on this blog because you are interested in blockchains, so let's use a few relevant examples. -->

### Efficiently proving Bitcoin transactions were validated

Recall that a Bitcoin block is just a _set of transactions_ that were validated by a miner.

**Problem:**
Sometimes it is useful for _Alice_, who is running Bitcoin on her mobile phone, to verify that she received a payment transaction from _Bob_.

**Inefficient solution:**
Alice could simply download every newly mined Bitcoin block on her phone and inspect the block for a transaction from Bob that pays her.
This requires Alice to download a lot of data (1 MiB / block), which can be slow or expensive (e.g., mobile data costs money).

{: .box-warn}
Note that Alice cannot just simply ask nodes on the Bitcoin network, _"Hey, was I paid by Bob?"_ since nodes can lie and say _"Yes, you were"_ showing her a transaction from Bob that is actually not yet incorporated into a block.
Alternatively, they can also lie and say _"No, you weren't"_ and Alice would have no way to check this claim without actually downloading every new block and inspecting it.

**Efficient solution:**
If Alice was indeed paid by Bob, then Bitcoin can prove this to her via a **Merkle proof**. 
Specifically, Alice will ask a Bitcoin node if she was paid by Bob in the latest block, but instead of simply trusting the _"Yes, you were paid and here's the transaction"_ answer, she will ask the node to _prove membership of the transaction_ in the block via a Merkle proof.

Importantly, Alice never has to download the full block: she only needs to download the **block's header**, which contains the root of a Merkle tree built over all transactions in that block.
This way, Alice can verify the Merkle proof leading to Bob's transaction in this tree, which will assure her that transaction is in the block without having to download the other transactions.

**TODO: depict this via Catena picture**

That's the beauty of Merkle trees: a prover has a large set of data (e.g., thousands of transactions) and a verifier, who has access to this set's Merkle root hash, can easily make sure, via a Merkle proof, that a piece of data (e.g., a single transaction) is in this large set.

### Anti-entropy via Merkle trees

In our previous example, we showed how you could outsource your files to Dropbox and detect malicious or accidental modifications of any of your files.

Suppose the accidental modifications occurred because of a unreliable connection to Dropbox.
It would be nice if we could not just detect but modifications actually recover from them and download the correct file.

**The naive solution** would be to simply restart the file download whenever we detect a modification.
However, this could be painfully slow or not even ever terminate if the connection is sufficiently unreliable.

**A better solution** is to build a Merkle tree over the files as before, but at a **finer granularity**.
Specifically, we will split each file $f_i$ into equal-sized blocks $f_i^1, f_i^2,\dots, f_i^b$.
(For simplicity, assume each file has $b$ blocks.)
Then, we will build a Merkle tree over these $n\times b$ blocks of all our files and store it on Dropbox.com.

**TODO: picture with full upper & lower Merkle tree**

Note that the Merkle tree for a file $f_i$ can be regarded as two different Merkle trees:

 1. The Merkle tree for the left blocks of the file $f_i^1,\dots,f_i^{b/2}$ with root hash **TODO**
 2. The Merkle tree for the right blocks of the file $f_i^{b/2+1},\dots,f_i^b$ with root hash **TODO**

Also note that the root hash of $f_i$'s Merkle tree is just the hash of **TODO** and **TODO**.

This is the key observation that helps us identify which parts of $f_i$ have been corrupted during a download.
Specifically, if $f_i$'s hash doesn't match the Merkle root **TODO**, we can split the problem into two halves by checking if the left blocks of $f_i$ have the correct hash **and** if the right blocks of $f_i$ have the correct hash.

After we download a file, say $f_i$ of $b=4$ blocks, we will start an **anti-entropy protocol** to detect which blocks of the file have been incorrectly downloaded:
<!-- ask for a Merkle proof to check its integrity.
If it verifies, we are done.
Otherwise, we will -->

 1. We ask Dropbox for a Merkle proof to the _lower Merkle root_ for $f_i$ (i.e., **TODO: notation** in the figure above).
 1. We check it matches the actual Merkle root hash of the downloaded $f_i$, which we compute as $\mht(f_i^1,\dots,f_i^4)$.
 1. If it matches, we've downloaded the correct $f_i$.
 1. Otherwise, we recursively check if we correctly downloaded the left half of the file $f_i^1,f_i^2$ and the right half of the file $f_i^3, \dots,f_i^4$.
 1. Note that due to the recursive structure of the Merkle tree, both halves of the files have their own Merkle trees, whose roots are the children of **TODO: notation from above**.

### Proving account balances in Ethereum via ordered Merkle trees

**TODO:** Merkle prefix trees: sparse or non-sparse?

### Batch signing via Merkle trees

## Bonus: A Merkle tree is a collision-resistant hash function

A very simple way to think of a Merkle hash tree with $n$ _leaves_ is as a collision-resistant hash function $\mht$ that takes $n$ inputs[^contrast] and ouputs a 256-bit hash, a.k.a. the _Merkle root hash_.
More formally, the _Merkle hash function_ is defined as:

$$\mht : \left(\{0,1\}^*\right)^n \rightarrow \{0,1\}^{2\lambda}$$

And the Merkle root of some input $\vect{x} = (x_1,\dots, x_n)$ is denoted by:

$$h = \mht(x_1,\dots,x_n)$$

Here, $\lambda$ is a _security parameter_ typically set to 128, which implies Merkle root hashes are 256 bits.

Importantly, **Merkle trees are collision-resistant**: it is unfeasible to find two sets of leaves $\vect{x} = (x_1, \dots, x_n)$ and $\vect{x}' = (x_1', \dots, x_n')$ such that $\vect{x}\ne \vect{x}'$ but $\mht(\vect{x}) = \mht(\vect{x'})$.

**Proof sketch:**
Suppose you have $\vect{x}\ne \vect{x'}$ and their two Merkle trees, which have the same root hash $h$ but could have different internal hashes.
First, since the two inputs are different, this means there exists an index $i$ such that $x_i\ne x_i'$.
(We'll stick to inputs of size $n=2^k$, since they induce a full Merkle tree without any missing leaves, like the one in Figure **TODO**, which are easier to visualize.)

Consider the Merkle proofs to $x_i$ and $x_i'$ in the two Merkle trees.
The proof for $x_i$ is $\pi = ((h_1, b_1), \dots, (h_k,b_1))$, where:

 - $h_i$ are the **sibling hashes** along the path from $x_i$'s leaf to the root node in the tree (see example in Figure **TODO**).
 - If $b_i = 0$, then $h_i$ is a left child of its parent node in the tree; otherwise, if $b_i=1$, then it's a right child
    - We refer to these $b_i$'s as **direction bits**. They tell the verifier whether $h_i$ should be the left or right input to $H(\cdot,\cdot)$ when hashing at level $i$ in the tree, which helps them correctly recompute the Merkle root when verifying the proof.

Similarly, the proof for $x_i'$ is $\pi' = ((h_1', b_1), \dots, (h_k', b_1))$.
Note that the $h_i'$ hashes could differ from the $h_i$ hashes, but the direction bits are the same, since both proofs are for the same position $i$ in the tree.

We show how that, if both proofs verify, then this implies a break of the collision-resistance of the underlying hash function $H$ used to compute these Merkle trees.

The verification of first proof for $x_i$ will proceed by computing the hashes $(z_1, \dots, z_k)$ along the path from $x_i$ to the root:

 1. First, $z_1$ is just set to $x_i$.
 2. Then, for each $i\in[2,k]$, $z_i$ is computed as follows:
    + If $b\_{i-1} = 1$, then $z\_i = H(z\_{i-1}, h\_{i-1})$
    + If $b\_{i-1} = 0$, then $z\_i = H(h\_{i-1}, z\_{i-1})$
    + This is what we call _"hashing up the tree"_ from position $i$
 3. Lastly, the root hash $h$ is checked:
    + If $b_k = 1$, then check if $h=H(z\_k, h\_k)$
    - If $b_k = 0$, then check if $h=H(h\_k, z\_k)$

Similarly, the verification of the second proof for $x_i$ will compute hashes $z_i'$ along the same path from $x_i'$ to the root.
 
<!-- Second, let $h_1,\dots, h_k$ be the proof for $x_i$ and $h_1',\dots,h_k'$ be the proof for $x_i'$. -->
Since the leaves $x_i$ and $x_i'$ being verified with the two proofs are different, as they get hashed up the tree with the sibling hashes from their corresponding Merkle proofs, they ultimately both compute the same Merkle root.
This means that at some level along this path there must be two different inputs $(\ell, r)$ and $(\ell', r')$ such that $H(\ell, r) = H(\ell', r')$.
But this would break the collision-resistance of $H$, which is a contradiction.

{% include_relative bib.md %}

[^handwave]: Computational intractability would deserve its own post. For now, just think of it as _"nobody we know is able to come up with an algorithm that breaks collision resistance **and** finishes executing before the heat death of the Universe."_

[^contrast]: In contrast, the collision-resistant functions $H$ we discussed in our [previous post][hashurl] take just one input $x$ and hash it as $h = H(x)$.

[hashurl]: /2020-08-28-what-is-a-cryptographic-hash-function
