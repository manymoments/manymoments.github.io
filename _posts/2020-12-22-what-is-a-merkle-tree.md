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
 1. Proving a transaction between Alice and Bob occurred, or _set membership_,
 1. Transmitting files over unreliable channels, or _anti-entropy_,
 <!-- 1. Signing many documents fast, or _batch signing_. -->
 1. Proving Alice's current Ethereum balance is 20 ETH, or _proving dictionary lookups_.

<p hidden>$$
\def\mht{H_{\mathsf{Merkle}}}
\def\mrh{h_{\mathsf{root}}}
\def\vect#1{\boldsymbol{\vec{#1}}}
$$</p>

By the end of the post, you'll be able to understand several **key concepts**:

 1. A Merkle tree is a **collision-resistant hash function** $\mht$ that takes $n$ inputs $(x\_1, \dots, x\_n)$ and outputs a _Merkle root hash_ $h = \mht(x\_1, \dots, x\_n)$,
 1. A verifier who has the root hash $h$ can be given $\hat{x}\_i$ and a **Merkle proof** for $\hat{x}\_i$ which convinces them that $\hat{x}\_i$ was the $i$th input used to compute $h$.
    + In other words, that there exist other $x_i$'s such that $h=\mht(x\_1, \dots, x\_{i-1}, \hat{x}\_i,x\_{i+1},\dots,x\_n)$.
    + This is often referred to as a **membership proof** for $\hat{x}_i$ in the Merkle tree with root $h$.
 1. Merkle tree are quite **versatile.** They can be used to hash sets, vectors, dictionaries, directed acyclic graphs (DAGs), and many other types of data.
    + Even better, when used to hash a set (or a dictionary), the Merkle tree can be "organized" carefully to allow for **non-membership proofs** of elements in the set (or of keys in the dictionary)

## Prerequisites

Merkle trees are built using _cryptographic hash functions_, which we assume you understand.
If not, just read [our post on hash functions][hashurl]!

{: .box-note}
**Definition:** A hash function $H$ is collision resistant if it is computationally-intractable[^handwave] for an adversary to find two different inputs $x,x'$ with the same hash (i.e., with $H(x) = H(x')$).

**Notation:**

 - We often use $[k] = \\{1,2,\dots, k\\}$ and $[i,j] = \\{i, i+1,\dots,j-1,j\\}$.
 - Although a hash function $H(x)$ is formalized as taking a single input $x$, we often call it with two inputs as $H(x,y)$. Just think of this as $H(z)$ where $z=(x\ \|\ y)$, where $\|$ is a special delimiter character.

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

You could easily generalize this and compute a Merkle tree over any number $n$ of files.

We often refer to a file $f_i$ as being **in the Merkle tree**, to indicate it was part of the input used to compute the tree.

It is useful to number the **levels** of a Merkle tree built over $2^{k-1} < n\le 2^k$ leaves from 1 (i.e., the bottom level storing the leaves) to $k+1$ (i.e., the top level storing the root node).

## This is a Merkle proof!

Next, you upload your files **and** Merkle tree on Dropbox.com and delete everything from your computer except the Merkle root $h_{1,8}$.
Your goal is to later download any one of your files from Dropbox **and** make sure Dropbox did not accidentally corrupt it.

This is the **file integrity** problem and Merkle trees will help you solve it.

The **key idea** is you will download $f_i$ **and** a small part of the Merkle tree called a **Merkle proof**, which will allow you to verify that $f_i$ was indeed in the Merkle tree.
This guarantees to you that $f_i$ has not been modified since you outsourced it to Dropbox.

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
These Merkle trees easily have hundreds of millions of leaves and are designed to scale to billions.

## What else is a Merkle tree useful for?

Now that we know how a Merkle tree is computed and how Merkle proofs work, let's dig into a few more use-cases.

<!-- You are probably on this blog because you are interested in blockchains, so let's use a few relevant examples. -->

### Efficiently proving Bitcoin transactions were validated

Recall that a Bitcoin block is just a _set of transactions_ that were validated by a miner.

**Problem:**
Sometimes it is useful for _Alice_, who is running Bitcoin on her mobile phone, to verify that she received a payment transaction from _Bob_.

**Inefficient, consensus-based solution:**
Alice could simply download every newly mined Bitcoin block on her phone and inspect the block for a transaction from Bob that pays her.
This requires Alice to download a lot of data (1 MiB / block), which can be either slow or expensive, since mobile data costs money.
_(The unstated assumption here is that Alice relies on Bitcoin's proof-of-work consensus protocol to decide whether a block is valid. These consensus-related details are covered in other posts[^post1]$^,$[^post2] on this blog.)_

{: .box-warning}
**Insecure, polling-based solution:**
Note that Alice cannot just simply ask nodes on the Bitcoin network, _"Hey, was I paid by Bob?"_ since nodes can lie and say _"Yes, you were"_ showing her a transaction from Bob that is actually not yet incorporated into a block.
Alternatively, they can also lie and say _"No, you weren't"_ and Alice would have no way to check this claim without actually downloading every new block and inspecting it.

**Efficient, Merkle-based solution:**
If Alice was indeed paid by Bob, then Bitcoin can prove this to her via a **Merkle proof**. 
Specifically, Alice will ask a Bitcoin node if she was paid by Bob in the latest block, but instead of simply trusting the _"Yes, you were paid and here's the transaction"_ answer, she will ask the node to _prove membership of the transaction_ in the block via a Merkle proof.

Importantly, Alice never has to download the full block: she only needs to download the **block's header**, which contains the root of a Merkle tree built over all transactions in that block.
This way, Alice can verify the Merkle proof leading to Bob's transaction in this tree, which will assure her that transaction is in the block without having to download the other transactions.

{: .box-note}
Of course, this Merkle-based solution still assumes Alice relies on Bitcoin's proof-of-work consensus to validate block _headers_. However, since headers are 80 bytes, this is much more efficient than downloading full (1 MiB) blocks.

**TODO: depict this via Catena picture**

That's the beauty of Merkle trees: a prover has a large set of data (e.g., thousands of transactions) and a verifier, who has access to this set's Merkle root hash, can easily make sure, via a Merkle proof, that a piece of data (e.g., a single transaction) is in this large set.

### Anti-entropy via Merkle trees

In our previous example, we showed how you could outsource your files to Dropbox and detect malicious or accidental modifications of any of your files.

Suppose the modifications were accidental due to an unreliable connection to Dropbox.
It would be nice if you could not just _detect_ these modifications but actually **recover** from them and eventually download the original, unmodified file.

**The naive solution** would be to simply restart the file download whenever you detect a modification via the Merkle-based technique we discussed before.
However, this could be painfully slow.
In fact, if the connection is sufficiently unreliable and the file is sufficiently large, this might never terminate.

#### Finer-grained Merkle trees

A better solution is to build a Merkle tree over the files as before, but at a _finer granularity_.
Specifically, you will split each file $f_i$ into equal-sized blocks:

$$f_i = ( f_i^1, f_i^2,\dots, f_i^b )$$

For simplicity, assume each file has $b$ blocks.
Since you have $n$ files, this means you'll have $n\times b$ blocks in total.

You can now build a Merkle tree over these $n\times b$ blocks and store it on Dropbox.com.

At this point, it is useful to _think of computing the Merkle tree as computing a hash function_ $\mht$ that takes multiple inputs (e.g., the $n\times b$ blocks) and outputs the Merkle root $h$:

$$h=\mht(f_1^1,\dots,f_1^b\mathbf{, }\ f_2^1,\dots, f_2^b\mathbf{, }\ \dots\mathbf{, }\ f_n^1,\dots,f_n^b)$$ 

**TODO: picture with full upper & lower Merkle tree**

Next, let us focus on the Merkle **sub**tree built over just the blocks of file $f_i$.
We notice two things.
First, this is just a Merkle tree over the $b$ blocks of file $f_i$.
We'll call this the $i$th **lower Merkle tree** and we'll use $\ell_i$ to denote its root hash:

$$\ell_i = \mht(f_i^1,\dots,f_i^b)$$

Second, the Merkle tree defined above with root hash $h$ can be regarded as a Merkle tree built over all these $\ell_i$ Merkle hashes.

\begin{align}
h &= \mht(\ell_1, \dots, \ell_n)\\\\\
  &= \mht(f_1^1,\dots,f_1^b\mathbf{, }\ f_2^1,\dots, f_2^b\mathbf{, }\ \dots\mathbf{, }\ f_n^1,\dots,f_n^b)
\end{align}

We call this Merkle tree built over the $\ell_i$'s the **upper Merkle tree**.
Note that it has $n$ leaves, where $\ell_i$ is the $i$th leaf.

#### Recovering corrupted file blocks

Suppose you are trying to download $f_i$ from Dropbox and you have the Merkle root $h$ built over all the files.
First, you ask Dropbox for $f_i$'s lower Merkle tree root $\ell_i$, together with a Merkle proof w.r.t. the root hash $h$.
Since the connection is unreliable, you might get a bad $\ell_i$, or a bad proof, or both. 
Nonetheless you repeat until you get the correct $\ell_i$.

You now have the Merkle root $\ell_i$, which was built over $f_i$'s blocks.

In principle, you can now verify any downloaded block via a Merkle proof.
If the proof does not verify, ask for the block and the proof again.
Unfortunately, this **naive solution** would involve downloading $b-1$ hashes (roughly[^pow2]), in addition to the blocks themselves.

A **better solution** is to observe that you can first optimistically download all $b$ blocks, and rebuild the Merkle tree over them.
If you get the same root $h$, you have downloaded the file correctly and are done!

Otherwise, you divide and conquer!
It could be that some of the first $b/2$ blocks were downloaded incorrectly, or some of the last $b/2$ blocks, or both!

To tell which half of the file is invalid, you ask for the left and right hashes $h_L, h_R$ under the root $h$ such that $h = H(h_L, h_R)$.
Importantly, note that $h_L$ is the Merkle root built over the first $b/2$ blocks while $h_R$ is the one for the last $b/2$ blocks:

\begin{align}
h_L &= \mht(f_i^1,\dots,f_i^{b/2})\\\\\
h_R &= \mht(f_i^{b/2+1},\dots,f_i^b)
\end{align}

You have now reduced the problem of downloading a file of $b$ blocks correctly to two **subproblems** of half the size!

This is very nice in practice, since it could turn out that, say, the last $b/2$ blocks under $h_R$ are all correct, in which case, you never need to ask for any more Merkle hashes in that side of $f_i$'s lower Merkle tree.

Even if both halves of the file are corrupted, you can identify the individual corrupted blocks by repeating the process above recursively until you get to a subproblem of size one: i.e., you have the correct hash of two blocks in the bottom of the tree but the two blocks you've downloaded do not verify against this hash.
Therefore, you can ask Dropbox.com to resend those two blocks until they verify.

{: .box-warning}
Note that only one of these two blocks might be corrupted, but you would have no way of knowing which one.
This is why you must ask for both.
To avoid this overhead, you can build the Merkle tree over hashes of the blocks $f_i^j$, rather than over the blocks directly.
This way, a subproblem of size one involves you having the hash of single block and asking the server for that block only. 

Note that this approach merely refines the naive approach which downloaded a Merkle proof for every block, even when all blocks were correct.
Specifically, this approach can be regarded as only downloading a Merkle proof per corrupted block.

<!--

Note that the lower Merkle tree for a file $f_i$ can be split into a _left_ and _right_ Merkle trees:

 1. The Merkle tree for the left blocks of the file $f_i^1,\dots,f_i^{b/2}$ with root hash **TODO**
 2. The Merkle tree for the right blocks of the file $f_i^{b/2+1},\dots,f_i^b$ with root hash **TODO**

Also note that the root hash of $f_i$'s Merkle tree is just the hash of **TODO** and **TODO**.

This is the key observation that helps us identify which parts of $f_i$ have been corrupted during a download.
Specifically, if $f_i$'s hash doesn't match the Merkle root **TODO**, we can split the problem into two halves by checking if the left blocks of $f_i$ have the correct hash **and** if the right blocks of $f_i$ have the correct hash.

After we download a file, say $f_i$ of $b=4$ blocks, we will start an **anti-entropy protocol** to detect which blocks of the file have been incorrectly downloaded:
<!-- ask for a Merkle proof to check its integrity.
If it verifies, we are done.
Otherwise, we will -->

<!--

 1. We ask Dropbox for a Merkle proof to the _lower Merkle root_ for $f_i$ (i.e., **TODO: notation** in the figure above).
 1. We check it matches the actual Merkle root hash of the downloaded $f_i$, which we compute as $\mht(f_i^1,\dots,f_i^4)$.
 1. If it matches, we've downloaded the correct $f_i$.
 1. Otherwise, we recursively check if we correctly downloaded the left half of the file $f_i^1,f_i^2$ and the right half of the file $f_i^3, \dots,f_i^4$.
 1. Note that due to the recursive structure of the Merkle tree, both halves of the files have their own Merkle trees, whose roots are the children of **TODO: notation from above**.

-->

### Proving account balances in Ethereum via ordered Merkle trees

So far, we've discussed building Merkle trees over **vectors** of elements numbered from $1$ to $n$.
The elements were either full files, or blocks of files.
However, there's a plethora of other _data structures_, beyond vectors, that one can **"Merkleize"** or compute a Merkle tree over.

A useful data structure is a **dictionary**, which maps a **key** to a _unique_ **value**.
For example, the state of the Ethereum cryptocurrency is represented as a dictionary that maps each user's _address_ to that user's balance in ETH. 
Here, the address is the key and the balance is the value. 
<small>(If you do not recall, a user's address is just the hash of that user's public key.)</small>

In Ethereum, it is sometimes useful to prove a user's balance to a validator who only has access to the Ethereum block hashes, rather than the Ethereum full state (which would make the validator's job trivial).
For example, so-called stateless validators who get a transaction transferring $v$ ETH from Alice to Bob will need a proof that Alice has balance $\ge v$.

Without going into an exact, Ethereum-specific description, here's how a cryptocurrency like Ethereum can use Merkle trees to validate Alice's balance.

<!-- ### Batch signing via Merkle trees -->

## Bonus: A Merkle tree is a collision-resistant hash function

A very simple way to think of a Merkle hash tree with $n$ _leaves_ is as a collision-resistant hash function $\mht$ that takes $n$ inputs[^contrast] and ouputs a 256-bit hash, a.k.a. the _Merkle root hash_.
More formally, the _Merkle hash function_ is defined as:

$$\mht : \left(\{0,1\}^*\right)^n \rightarrow \{0,1\}^{2\lambda}$$

And the Merkle root of some input $\vect{x} = (x_1,\dots, x_n)$ is denoted by:

$$h = \mht(x_1,\dots,x_n)$$

Here, $\lambda$ is a _security parameter_ typically set to 128, which implies Merkle root hashes are 256 bits.

{: .box-warning}
**Theorem:** Merkle trees are collision-resistant; i.e., it is unfeasible to find two sets of leaves $\vect{x} = (x_1, \dots, x_n)$ and $\vect{x}' = (x_1', \dots, x_n')$ such that $\vect{x}\ne \vect{x}'$ but $\mht(\vect{x}) = \mht(\vect{x'})$.

**Proof sketch:**
Suppose you have $\vect{x}\ne \vect{x'}$ and their two Merkle trees, which have the same root hash $h$ but could have different internal hashes.
First, since the two inputs are different, this means there exists an index $i$ such that $x_i\ne x_i'$.
(We'll stick to inputs of size $n=2^k$, since they induce a full Merkle tree without any missing leaves, like the one in Figure **TODO**, which are easier to visualize.)

Consider the Merkle proofs to $x_i$ and $x_i'$ in the two Merkle trees.
The proof for $x_i$ is $\pi = ((h_1, b_1), \dots, (h_k,b_k))$, where the $h_i$'s are **sibling hashes** and the $b_i$'s are **direction bits**.

To verify $\pi_i$, the verifier uses $x_i$ together with the sibling hashes and the direction bitss to compute the hashes $(z_1, \dots, z_{k+1})$ along the path from $x_i$ to the root and checks if $z_{k+1}$ equals the Merkle root hash $h$.
If it does, then the verification succeeds.
Otherwise, it fails.

More formally, the verifier:

 1. First, sets $z_1 = x_i$.
 2. Then, for each $j\in[2,k]$, $z_j$ is computed as follows:
    + If $b\_{j-1} = 1$, then $z\_j = H(z\_{j-1}, h\_{j-1})$
    + If $b\_{j-1} = 0$, then $z\_j = H(h\_{j-1}, z\_{j-1})$
    + This is what we call _"hashing up the tree"_ from position $i$
    - *Note:* If $b_i = 0$, then $h_i$ is a left child of its parent node in the tree and if $b_i=1$, then it's a right child.

{: .box-note}
**TODO:** Give an example w.r.t. to previous MHT figure.

Similarly, the proof for $x_i'$ is $\pi' = ((h_1', b_1), \dots, (h_k', b_k))$.
Note that the $h_i'$ hashes could differ from the $h_i$ hashes, but the direction bits are the same, since both proofs are for the same position $i$ in the tree.

Since both proofs verify, the verification of the second proof $\pi_i'$ for $x_i'$ will yield hashes $\\{z\_1',z\_2',\dots,z\_{k+1}'\\}$ along the same path from $x_i'$ to the root such that $z_{k+1}' = h$.

But recall from the verification of the first proof $\pi_i$ that we also have $z_{k+1} = h$.
Thus, $z_{k+1} = z_{k+1}'$.

The next step is to reason about how two different leaves $x_i\ne x_i'$ could have possibly "hashed up" to the same root hash $h=z_{k+1} = z_{k+1}'$.
I think this is best explained by considering a few extreme cases and then generalizing.

**Extreme case \#1**: 
One way would have been for the proof verification to yield $z\_j \ne z\_j'$ for all $j\in[k]$.
(Note that, since both proofs verify, it must be that $z_{k+1} = z_{k+1}' = h$.)
In this case, without loss of generality, assume $b_k = 1$.
Then, we would have $h = z\_{k+1} = H(z\_k, h\_k)$ and $h = z\_{k+1}' = H(z\_k', h\_k')$.
But since $z\_k \ne z\_k'$, this gives a collision in $H$!
(Alternatively, if $b_k = 0$, just switch the inputs to the hash function.)

**Extreme case \#2**: 
Another way would have been for the proof verification to yield $z\_j = z\_j'$ for all $j\in[k+1]$.
In this case, without loss of generality, assume $b_1 = 1$.
Then, we would have $z\_2 = H(x\_1, h\_1)$ and $z\_2' = H(x\_1', h\_1')$.
(Again, if $b_k = 0$, just switch $H$'s inputs.)
But since $z\_2 = z\_2'$ and $x\_i\ne x\_i'$, this gives a collision in $H$!

You should now be able to see more easily that, as long as $x_i\ne x_i'$ but the computed root hashes are the same (i.e., $z_{k+1} = z_{k+1}' = h$), then there must exist some level $j\in [k]$ where there is a collision:

$$\exists\ \text{level}\ j\in [k]\ \text{s.t.}\ H(z_{j-1}, h_{j-1}) = H(z_{j-1}', h_{j-1}')\ \text{but}\ z_{j-1}\ne z_{j-1}'\ \text{or}\ h_{j-1}\ne h_{j-1}'$$

(Again, recall that $z_1 = x_i$ and $z_1'=x_i'$.)
But this would break the collision-resistance of $H$, which is a contradiction.
QED.

{: .box-note}
The claim about the existence of such a level $j$ might not be easy to understand at first glance.
Here's some intuition:
<br />
<br />
Start at the root of the tree!
Since both proofs verify and yield the same root hash, it could be that we either have a collision in $H$ at this level or we don't.
If we do have a collision, we are done.
If we do not, then the two inputs to $H$ are the same: i.e., $z_k = z_k'$ and $h_k = h_k'$.
<br />
<br />
Next, work your way down and continue with $z_k = z_k'$.
Again, it must be that either there was a collision, or the two inputs are the same: i.e., $z_{k-1} = z_{k-1}'$ and $h_{k-1} = h_{k-1}'$.
If there was a collision, we are done.
Otherwise, we continue.
<br />
<br />
In the end, we will get to the bottom level which is guaranteed to have $z_1\ne z_1'$ (because $x_i\ne x_i'$) but $z_2 = z_2'$, which yields a collision.
This is actually the _extreme case \#2_ that we've handled above!
No matter what, there will always be a collision!

{% include_relative bib.md %}

[^handwave]: Computational intractability would deserve its own post. For now, just think of it as _"nobody we know is able to come up with an algorithm that breaks collision resistance **and** finishes executing before the heat death of the Universe."_
[^contrast]: In contrast, the collision-resistant functions $H$ we discussed in our [previous post][hashurl] take just one input $x$ and hash it as $h = H(x)$.
[^post1]: [The First Blockchain or How to Time-Stamp a Digital Document](/2020-07-05-the-first-blockchain-or-how-to-time-stamp-a-digital-document/)
[^post2]: [Security proof for Nakamoto Consensus](/2019-11-29-Analysis-Nakamoto/)
[^pow2]: If a Merkle tree has $b$ leaves **and** $b=2^k$, then it has $b-1$ internal hashes (including the root hash). For example, a tree of 4 leaves has 3 internal hashes: the two parents and the root.

[hashurl]: /2020-08-28-what-is-a-cryptographic-hash-function
