---
title: What is a Hash Function?
date: 2020-07-21 10:05:00 -07:00
published: false
tags:
- cryptography
- hashing
- hash-function
- random-oracle
- collision-resistance
- one-wayness
- integrity
author: Alin Tomescu
---

If you ever tried to understand Bitcoin as a beginner, you've probably banged your head against the wall trying to understand what is a **(cryptographic) hash function**?
The goal of this article is to:

1. Give you a very simple mental model for how hash functions work
2. Give you several applications of hash functions
3. Leave you with an intuitive understanding of what a hash function _does_ and _what it is useful for_.

The goal of this article is **NOT** to explain to you how a concrete hash function like SHA256 works.
Teaching you the internals of SHA256 (or any other hash function) would be like teaching a new driver how the engine of a car works before teaching them how to drive it: most people would get bored fast and lose interest.

Finally, this post is in no way a formal treatment of hash functions and their many interesting properties.
At the same time, this does not oversimplify hash functions either.
Our hope is that, by the end of the post, you'll be curious enough to dig deeper into hash functions yourself.
(As a starting point, use the references at the end of this post.)

## A hash function is a "guy in the sky," flipping coins

My favorite analogy for how a hash function works is the **"guy in the sky"** analogy, as illustrated below.

![guy-in-the-sky](/uploads/guy-in-the-sky.png)

<!--
You should think of a hash function as a **box**.
This box takes an **input** of arbitrary size.
In simpler words, you feed _data_ into this box: i.e., bits, bytes, files, videos, pictures, PDFs, etc.
Then, the box gives you a _random_ **output** of _fixed_ size.
Specifically, it outputs 256 "random" _bits_: i.e., a sequence of ones and zeros.
"Random" means that every bit in this sequence has a 50% chance of being a one and 50% chance of being a zero.
Most importantly, the box "remembers" the output it gave for every input.
In other words, if you feed the box twice with the same picture, it will give you the same output both times, rather than picking a new sequence of 256 random bits for the second time.
-->

Here's the analogy.
There's a "guy in the sky."
You can give him an arbitrarily-sized input $x$.
In return, he'll give you a fixed-size, "random looking" output $y$ back.
_Super-importantly_, if you ever give him $x$ again, he'll give you that same $y$ back!
How does he do it?

When he gets your input $x$, he initially ignores it!
Then, he flips 256 coins, getting a sequence of 256 random bits (i.e., ones and zeros), denoted by $y=\langle y_1, y_2, \dots, y_{256}\rangle$.
Next, he forever remembers that your input $x$ maps to output $y$ by writing down $(x,y)$ in his magic scroll.
This way, if you ever give this "guy in the sky" the same input $x$, he will give you back the same output $y$ (rather than flip new coins and give you a new random 256-bit output $y'\ne y$).

**That's it!**
The simplest way you can think of a hash function is as a "guy in the sky" who flips coins for each input you give him, remembering what coins he got for every input you gave him, just in case you give him that input again.
Since inputs are arbitrarily-sized and outputs are fixed-size, a hash function effectively "compresses" the input.
However, the key insight you should keep in mind is that this "compression" is done by picking the output randomly, which has many interesting implications!
(Well, the devil is in the details, but for now this intuition is good enough.)

## A hash function is "random oracle"

Now, let's take a step away from mythical creatures in the sky and a step closer towards formalizing hash functions.

What we are saying is that a hash function is a kind of "algorithm" or "oracle" that "compresses" inputs to outputs as follows:

1. You give it an arbitrarily-sized input.
2. It checks if it already generated 256 random bits for that input.
   - If so, it gives you those 256 random bits as output.
   - If not, it flips 256 random coins, associates them to this input, and gives you the coins as output.

This idealization of hash functions is called the _random oracle model_[^BR93].
Simple enough, no?
Get an input, flip some coins for it (unless already done so in the past) and return those coins!

### Limitations of the random oracle model

It turns out the random oracle model is incredibly useful to reason about the properties of hash functions.
It's also a very simple mental model for how a hash function works!

Of course, in practice, we need to actually build an algorithm that behaves like this "guy in the sky" or this random oracle.
Unfortunately, this is [impossible](https://en.wikipedia.org/wiki/Random_oracle#Limitations).

Kthxbye, end of post!

<!--(at least given our current theoretical understanding of what is computable using a Turing Machine).-->
Just kidding.
Fortunately, in practice, we can circumvent this impossibility in a few ways.
For example, in some applications, we settle for hash functions whose outputs are not random but have other useful properties that are implied by the random oracle model.
One such property is **collision-resistance**, which says it is infeasible to find two inputs $x\ne x'$ such that their outputs $y$ and $y'$ are equal.
(We'll touch upon this later.)
In other applications, cryptographers simply "hope" that replacing the idealized random oracle with a concrete hash function like SHA256 will not lead to security breaks in practice.

{: .box-warning}
**Note:** There is reason to be skeptical of such hope.
We know that, for certain cryptosystems proven secure with a random oracle, replacing the random oracle with _any_ concrete hash function makes them insecure[^CGH98].

## Hash functions as mathematical functions

We've established that a hash function can be thought of as a random oracle that, given some input $$x\in \{0,1\}^*$$ (i.e., an arbitrarily-sized sequence of bits) returns a "random," fixed-size input $$y\in \{0,1\}^{256}$$ (i.e., 256 bits) and will always return that same $y$ given that same $x$ as input.
(We assume the output size is 256 bits. We'll explain later why.)

Formally, we can define a hash function as a [mathematical function](https://en.wikipedia.org/wiki/Function_(mathematics)) $$H : \{0,1\}^* \mapsto \{0,1\}^{256}$$.
We use $H(x) = y$ to denote that $y$ is the output of $H$ on input $x$.

<!-- TODO: I am not sure what "maps each input to a random, uniform 256-bit output" means when the input space is of infinite size (e.g., {0,1}^*) -->

### Collision-resistance and the pigeonhole principle

This definition brings one limitation of hash functions into light, which is worth discussing now.

Note that a hash function maps the set of all arbitrarily-sized binary strings (which is of infinite size) to the set of binary strings of length 256 (which is of size $2^{256}$).
For the mathematically-inclined, the ["pigeonhole principle"](https://en.wikipedia.org/wiki/Pigeonhole_principle) immediately tells us that, as a consequence, there must exist two inputs $x\ne x'$ such that $H(x)=H(x')$.
Such a pair $(x,x')$ is called a **collision** and can be disastrous in many applications of hash functions, as we'll discuss later.

{: .box-note}
_For the less mathematically-inclined:_ It's as if we have an infinite amount of puppies and $2^{256}$ people who want to pet them. This tells us that, if all puppies are to be petted by someone, then someone has to pet more than one puppy!
In other words, there will be two puppies $x$ and $x'$ that are petted by the same person $y$[^bliss]$^,$[^ppp].

Restated formally, because the _domain_ $$\{0,1\}^*$$ of $H$ is larger than the _range_ $$\{0,1\}^{256}$$ of $H$, there must exist two inputs $x\ne x'$ that map to the same output $y=H(x)=H(x')$.

Fortunately, in the random oracle model, one can show that finding such a collision is infeasible, requiring on average $2^{128}$ hash function invocations, which is an astronomical number that is outside the realm of practicality.
(We'll describe this collision-finding algorithm, which is called the _birthday attack_, in another post.)
Even better, as cryptographers, we know how to construct **collision-resistant** hash functions from hard computational problems such as _computing discrete logarithms_.

<!-- **TODO:** Cite birthday attack or write post about it -->

## What can I do with a hash function?

By now, you know that a hash function "compresses" an arbitrarily-large output to a fixed-size input, which is uniquely determined by flipping some coins.
Next, let's see what a hash function is useful for.

### Downloading files correctly over the Internet

<!--
CR holds => TCR holds => (+compression) => OW holds
q-SBDH holds => q-SDH holds => DL holds
-->

Did you ever notice how sometimes websites display a hash next to a file after you click the download button?
For example, this is what you see if you try to download Apache OpenOffice:

<img src="/uploads/download-hash.png" width="720" />

The website has links to the SHA256 and SHA512 hashes for the OpenOffice installer file $f$ being downloaded.
A careful user will download the file $f$, hash it to compute $h=H(f)$ and check if the $h$ they got is the same as the one on the website.
Then, they will be convinced their download has not been maliciously modified by an attacker, who could've replaced $f$ with $f'$ by controlling the network.

{: .box-warning}
**Important:** For this to work, we assume that the user can correctly download the hash of $f$!
So, in a sense, we are replacing the problem of downloading $f$ correctly with the problem of obtaining $h$ correctly.
Once $h$ is obtained correctly, the user can verify the larger file $f$ against $h$.

#### Why the adversary can't replace $f$ with a different file $f'$

The adversary's goal is to trick the user, who has the hash $h$, and give him a different file $f'\ne f$ such that $H(f')=H(f)$.
Let's see why he can't do this.

If we think of $H$ as a random oracle, what can the adversary do to find such an $f'$?
The adversary can only query $H$ at whatever points he might think will return $H(f)$.
But since the random oracle $H$ returns random coin flips for whatever input the adversary provides, this means the adversary has no particular strategy other than brute-force for finding an $f'$ with $H(f')=H(f)$.
With a little probability theory, one can show that the adversary has to query $H$ around $2^{256}$ times to actually find such an $f'$.
Since this is outside the realm of practicality, our file downloading scheme is considered secure!

{: .box-note}
**Remark:** In the attack above, the attacker is trying to find a collision $f'$ w.r.t. a particular _fixed_ file $f$.
However, depending on the application, the attacker might have more "freedom."
Specifically, the attacker could try and find _any_ collision $(f,f')$ in the hash function.
This would take him a smaller, but still astronomical, amount of time: $2^{128}$ rather than $2^{256}$ hash function invocations.
If the attacker is successful, he could trick users who have the same $h$ into downloading different files.
(As an exercise, try and think of application scenarios where that might be problematic!)

### Proof of work

Suppose you want to convince me you've done some amount of computational work.
Specifically, let's assume you want to convince me you've computed roughly $n$ hashes by calling $H$ on $n$ different inputs.
Such a protocol is called a **proof of work** and you can leverage the random oracle nature of hash functions to implement it!

Note that if I send you a random value $r$, and you give me back $y=H(r)$, I can check that you computed $H(r)$ correctly by recomputing it myself.
But it seems like in order to check that you've computed $n$ hashes, I have to give you $n$ different $r$'s and re-compute the $n$ hashes you computed too.
While this protocol could be thought of as a "proof-of-work," it's not very efficient for me to check that you've done the work.
Can I verify your work faster?

Since $H$ can be viewed as a random oracle, we know that every $H(r)$ is obtained by flipping 256 random coins.
For the mathematically-inclined, we also know that, if we want the first $k$ coins flips to be all "heads", then we have to flip these 256 random coins around $2^k$ times.
For the less mathematically-inclined, if you have 1 in 3 chances to win a teddy bear in a game, you kind of know that if you play around 3 times you're very likely to win.
Similarly, there are 1 in $2^k$ chances for the first $k$ coins to be all "heads", which is why you have to flip the coins around $2^k$ times.

So, it takes $2^k$ tries to get 256 random coins where the first $k$ coins all heads.
That's like saying it takes around $2^k$ hash computations to get a hash whose first $k$ bits are equal to zero!

In other words, say I give you a random value $r$ and you give me a pair $\langle i, h_i = H(i \mid r)\rangle$, where $h_i$ has the first $k$ bits all set to zero and $|$ denotes concatenation.
Then, I can easily check that $h_i = H(i \mid r)$ using only _one_ hash computation and I'll be pretty sure that it took you around $2^k$ hash computations to find such an $i$.
I say "pretty sure" because it's also possible you got very lucky and the first $i$ you picked happened to give you an $H(i \mid r)$ with the first $k$ bits zero.
(But the probability of that happening is pretty low, around $1/2^k$.)

#### Why you can't easily trick me when you haven't done the work

Your goal, as the adversary, is to find an $i$ such that $$h_i = H(i \mid r)$$ has $k$ leading zeros, but you want to do so while computing much fewer than $2^k$ hashes.

Once again, since $H$ is a random oracle, your only strategy is to simply query $H$ at inputs of the form $$i\mid r$$.
Each query gives you an output $h_i$ whose probability of having $k$ leading zeros is $1/2^k$.
As a result, to ensure you get such an $h_i$ you have to "try" computing different $h_i$'s around $2^k$ times.

{: .box-note}
Why is the probability of a hash having $k$ leading zeros equal to $1/2^k$? 
Because $H$ is a random oracle and each bit of the output has probability $1/2$ of being a zero and $1/2$ of being a one!
As a consequence, the probability that you get $k$ consecutive zeros is $\underbrace{1/2 \cdot 1/2 \cdot \cdots \cdot 1/2}_{k\ \text{times}}=(1/2)^k = 1/2^k$.

### Commitments

## References

[^bliss]: In fact, each person will pet an infinite amount of puppies, which incidentally is the most blissful thing I can imagine right now!
[^BR93]: **Random Oracles Are Practical: A Paradigm for Designing Efficient Protocols**, by Bellare, Mihir and Rogaway, Phillip, *in Proceedings of the 1st ACM Conference on Computer and Communications Security*, 1993, [[URL]](https://doi.org/10.1145/168588.168596)
[^CGH98]: **The Random Oracle Methodology, Revisited**, by Ran Canetti, Oded Goldreich, Shai Halevi, *in Cryptology ePrint Archive, Report 1998/011*, 1998, [[URL]](https://eprint.iacr.org/1998/011)
[^CLRS09]: **Introduction to Algorithms, Third Edition**, by Cormen, Thomas H. and Leiserson, Charles E. and Rivest, Ronald L. and Stein, Clifford, 2009
[^KL15]: **Introduction to Modern Cryptography**, by Jonathan Katz and Yehuda Lindell, 2007
[^KM15]: **The Random Oracle Model: A Twenty-Year Retrospective**, by Neal Koblitz and Alfred Menezes, *in Cryptology ePrint Archive, Report 2015/140*, 2015, [[URL]](https://eprint.iacr.org/2015/140)
[^Merkle87]: **A Digital Signature Based on a Conventional Encryption Function**, by Merkle, Ralph C., *in CRYPTO '87*, 1988
[^ppp]: Henceforth, everybody shall stop using the Pigenhole Principle and adopt this more modern Puppy Petting Principle, which has the advantage of both filling your heart with joy and your mind with mathematics.
[^RS04]: **Cryptographic Hash-Function Basics: Definitions, Implications and Separations for Preimage Resistance, Second-Preimage Resistance, and Collision Resistance**, by Phillip Rogaway and Thomas Shrimpton, *in Cryptology ePrint Archive, Report 2004/035*, 2004, [[URL]](https://eprint.iacr.org/2004/035)
[^SRP]: **Secure Remote Password protocol**, by Wikipedia contributors, [[URL]](https://en.wikipedia.org/wiki/Secure_Remote_Password_protocol)
[^ECSplus15]: **The Pythia PRF Service**, by Adam Everspaugh and Rahul Chatterjee and Samuel Scott and Ari Juels and Thomas Ristenpart, *in Cryptology ePrint Archive, Report 2015/644*, 2015, [[URL]](https://eprint.iacr.org/2015/644)
