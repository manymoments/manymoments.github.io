---
title: Do Bitcoin and Ethereum have any trusted setup assumptions?
date: 2019-07-18 17:13:00 -07:00
published: false
tags:
- blockchain101
layout: post
---

<p align="center">
  co-authored with <a href="https://people.csail.mit.edu/alinush/">Alin Tomescu </a> and <a href="https://www.yanai.io/">Avishay Yanai</a>
</p>

Clearly both Bitcoin and Ethereum depend on the security of certain hash functions and certain elliptic curve based cryptography. In this post we ask if they also depend on some [Trusted Setup Assumptions](https://ittaiab.github.io/2019-07-18-setup-assumptions/).

## The Bitcoin [Conspiracy theory](https://en.wikipedia.org/wiki/Conspiracy_theory)

Bitcoin was invented by NASA in the 1960's. They have been working on an alternative fork for almost 60 years (in addition to their [moon landing](https://en.wikipedia.org/wiki/Moon_landing_conspiracy_theories)). Back in the 1960's, they inserted into the [Bitcoin Genesis block](https://en.bitcoin.it/wiki/Genesis_block) the text:  
>The Times 03/Jan/2009 Chancellor on brink of second bailout for banks

After making the [white paper](https://bitcoin.org/bitcoin.pdf) public in 2008, they coerced the financial times in the UK to publish exactly this title on 03 Jan 2009.

So our short answer to the question: Does Bitcoin have a trusted setup assumption is:

YES! bitcoin assumes that the Financial Times is a good source of unpredictable randomness and timestamp (and hence its cryptographic hash is a good [Common Random String](https://en.wikipedia.org/wiki/Common_reference_string_model)). This seed is used to guarantee that no adversary has any significant head start in mining Bitcoin and cannot use its head start to double-spend.

## The Ethereum [Conspiracy theory](https://en.wikipedia.org/wiki/Conspiracy_theory)

Ethereum was invented by NASA in the 1960's. They have been working on an alternative fork for almost 60 years (in addition to their [moon landing](https://en.wikipedia.org/wiki/Moon_landing_conspiracy_theories)). Back in the 1960's, they inserted into the [Ethereum Genesis block](https://ethereum.stackexchange.com/questions/71804/what-is-the-meaning-of-ethereum-mainnet-genesis-block-extradata-value) the hash:  
>0x11bbe8db4e347b4e8c937c1c8370e4b5ed33adb3db69cbdb7a38e1e50b1b82fa

After making the [yellow paper](https://bitcoin.org/bitcoin.pdf) public in 2008, they published this [post](https://blog.ethereum.org/2015/07/27/final-steps/) and referred to fake ceremony that essentially replicated their testnet runs from the 1960's. In their words: *"The argument \[referring to the hash value above\] needs to be a random parameter that no one, not even us, can predict. As you can imagine, there aren’t too many parameters in the world that match this criteria, but a good one is the hash of a future block on the Ethereum testnet. We had to pick a block number, but which one? 1,028,201 turns out to be both prime and palindromic, just the way we like it. So #1028201 is it."* Well, can you believe that block 1028201 was prepared long ago?!

So our short answer to the question: Does Ethereum have a trusted setup assumption is:

YES! ethereum assumes that the [Oliympic testnet](https://blog.ethereum.org/2015/05/09/olympic-frontier-pre-release/) is a good source of unpredictable randomness and timestamp (and hence its cryptographic hash is a good [Common Random String](https://en.wikipedia.org/wiki/Common_reference_string_model)). This seed is used to guarantee that no adversary has any significant head start in mining Ethereum and cannot use its head start to double-spend.

Just to clear, we believe that both systems used highly secure sources of unpredictable randomness. The main goal of this post is to highlight the fact that some trusted setup is needed. It is vitally important to have a secure randomness beacon that can generate timestamped cryptographically secure unpredictable randomness.
