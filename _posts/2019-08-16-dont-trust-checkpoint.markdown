---
title: Dont Trust. Verify (and Checkpoint).
date: 2019-08-16 13:32:00 -07:00
published: false
tags:
- blockchain101
---

Imagine that that Aliens land on earth with a new superfast SHA256 machine. Suppose they build a chain from the genesis that is longer than any other chain on earth and contains only empty blocks. Could they erase all bitcoin transactions?

Anticipating this type of attack, Satoshi suggested the following [security safeguard](https://satoshi.nakamotoinstitute.org/posts/bitcointalk/232/): 


>> The security safeguard makes it so even if someone does have more than 50% of the network's CPU power, they can't try to go back and redo the block chain before yesterday.  (if you have this update)
>>
>> I'll probably put a checkpoint in each version from now on.  Once the software has settled what the widely accepted block chain is, there's no point in leaving open the unwanted non-zero possibility of revision months later.  -- [Satoshi 2010](https://bitcointalk.org/index.php?topic=437)

So the answer is that the Aliens will fail. By [default](https://github.com/bitcoin/bitcoin/blob/master/src/validation.cpp#L120) the bitcoin core client enforces a set of [checkpoints](https://github.com/bitcoin/bitcoin/blob/master/src/chainparams.cpp#L138). 

A **checkpoint** on a blockchain is pair (block number, hash). For example the checkpoint (295000, 0x00000000000000004d9b4ef50f0f9d686fd69db2e03af35a100370c64632a983) indicates that the hash of the 295000th block must be 0x00000000000000004d9b4ef50f0f9d686fd69db2e03af35a100370c64632a983.
A checkpoint provides **finality**, all the transactions till block 295000 are final, there is no way to revert them, even if you are an alien. 

While some believe this is [not a security feature](https://bitcoin.stackexchange.com/questions/39097/do-all-bitcoin-client-enforce-checkpoints), it does effectively enforce a consensus decision checkpoint that forces all users using the same codebase to accept this checkpoint as final.

The idea of adding checkpoints is somewhat controversial. It's essentially a way for a code base to add a hard fork of the system that creates a new genesis and effectively disallows any alternative chain from the previous genesis.

The Bitcoin core client uses checkpoints in a sporadic manner. Their motivation seems to be that it [protects against header flooding attacks](https://github.com/bitcoin/bitcoin/issues/15095 
). However there seems to be no systematic reasoning as to when to use checkpoints.

The [Casper finality gadget](https://arxiv.org/abs/1710.09437) can be viewed as a way to use a BFT based sub-system to decide on checkpoints. 


