---
title: Dont Trust. Verify (and Checkpoint).
date: 2019-08-16 13:32:00 -07:00
published: false
tags:
- blockchain101
---

Imagine that that Aliens land on earth with a new superfast SHA256 machine. Suppose they build a chain from the genesis that is longer than any other chain on earth and contains only empty blocks. Could they erase all bitcoin transactions?

Anticipating this type of attack, Satoshi had the following [security safeguard](https://satoshi.nakamotoinstitute.org/posts/bitcointalk/232/): 


>> The security safeguard makes it so even if someone does have more than 50% of the network's CPU power, they can't try to go back and redo the block chain before yesterday.  (if you have this update)
>>
>> I'll probably put a checkpoint in each version from now on.  Once the software has settled what the widely accepted block chain is, there's no point in leaving open the unwanted non-zero possibility of revision months later.  -- [Satoshi 2010](https://bitcointalk.org/index.php?topic=437)

So the answer is that the Aliens will fail. By [default](https://github.com/bitcoin/bitcoin/blob/master/src/validation.cpp#L120) the bitcoin core client enforces a set of [checkpoints](https://github.com/bitcoin/bitcoin/blob/master/src/chainparams.cpp#L138). While some believe this is not a security feature, it does effectively enforce a consensus checkpoint that depends essentially on the github repository.

The idea of adding checkpoints is controversial. It's essentially a way for a community to add a hard fork of the system that creates a new gensis and effecivly disallows any alternative chains.

https://github.com/bitcoin/bitcoin/issues/15095 


https://bitcoin.stackexchange.com/questions/39097/do-all-bitcoin-client-enforce-checkpoints 

https://github.com/jamesob/assumeutxo-docs/tree/2019-04-proposal/proposal

