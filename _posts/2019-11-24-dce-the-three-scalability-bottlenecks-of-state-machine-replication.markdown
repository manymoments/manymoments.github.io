---
title: 'Data, Consensus, Execution: Three Scalability Bottlenecks for State Machine
  Replication'
date: 2019-11-24 09:05:00 -08:00
published: true
tags:
- blockchain101
author: Ittai Abraham
---

If anyone asks you: *how can I **scale**  my State Machine Replication (Blockchain) system?*

You should answer back with a question: *what is your  **bottleneck**? Is it Data, Consensus or Execution?*

1. **Data**: Shipping the commands to all the replicas. For example, if a [block contains 1MB](https://en.bitcoin.it/wiki/Block_size_limit_controversy) of commands then the fundamental bottleneck is that you need all these bits to arrive to all the validating replicas.

2. **Consensus**: Once the data arrives, replicas engage in a consensus protocol (like the ones discussed here for [partial synchrony](https://decentralizedthoughts.github.io/2019-06-23-what-is-the-difference-between/) or [synchrony](https://decentralizedthoughts.github.io/2019-11-11-authenticated-synchronous-bft/)). For example, if the consensus protocol needs 2 round-trips and the validating replicas are spread across the globe then there is a fundamental latency bottleneck due to the speed of light and the size of Earth.

3. **Execution**: After the data has arrived and consensus is reached on the total ordering of the commands, the replicas need to *execute* the commands. The [execution engine
](https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/) is a function that takes the old state and applies the ordered commands to compute the new state (and compute the output). For example, if an execution requires doing many cryptographic operations, then all replicas need to re-execute these cryptographic operations.



These three bottlenecks are *not* a tradeoff or a dilemma or even a [trilemma](https://en.wikipedia.org/wiki/Trilemma) they are independent challenges. The ability of a State Machine Replication system to scale is bottlenecked by the *minimum* of all three. Here are some directions for addressing these challenges.



#### Scaling Data: better network solutions
In Bitcoin and other cryptocurrencies the ability to scale depends crucially on the ability reduce the latency it takes a winning block to propagate. Systems like [FIBRE](https://bitcoinfibre.org/), [Falcon](https://www.falcon-net.org/), and [bloXroute](https://bloxroute.com/wp-content/uploads/2018/03/bloXroute-whitepaper.pdf) aim to reduce this latency by using pipelining and forward error correction codes to propagate blocks with lower latency.

Another  way to improve data scalability centers around being able to access content via a content addressable network. See [Kademlia](https://pdos.csail.mit.edu/~petar/papers/maymounkov-kademlia-lncs.pdf) which inspired Ethereum's [RLPx](https://github.com/ethereum/devp2p/blob/master/rlpx.md) and generalized in [libp2p](https://libp2p.io/).

#### Scaling Data: pushing to layer two
One solution to scaling the problem of data replication is not to replicate it at all! Solutions like [Lightning](https://lightning.network/lightning-network-paper.pdf), [Plasma](https://www.plasma.io/plasma.pdf), and other layer two solutions aim to reduce data replication by pushing some of the intermediate transactions to a smaller private group and only report periodic summaries to the main system (see our post on [payment channels](https://decentralizedthoughts.github.io/2019-10-25-payment-channels-are-just-a-two-person-bfs-smr-systems/)). This approach has a natural drawback: not replicating all the data creates a data availability problem and increases the reliance on small private groups.

#### Scaling Data: reducing the size of the full history
Another line of works aims to minimize the required size of the history that is needed to maintain in order to be able to independently verify that the current state is correct. Protocols like [Mimblewimble](https://scalingbitcoin.org/papers/mimblewimble.txt) introduce the ideas of aggregating intermediary inputs and outputs in chains of transactions in order to allow for smaller block sizes.


#### Scaling Consensus: the throughput vs latency trade-off
Some people talk about Transactions-Per-Second (TPS) as the measure of how scalable a consensus protocol it. TPS is a measure of throughput and optimizing it alone is a misunderstanding of the challenge. A solution for scaling consensus must address both throughput *and* latency. Just improving throughput is easy in systems with instant finality: increase latency and commit blocks just once a day instead of every few seconds and clearly the cost of the consensus will be easily amortized.  *Batching* is an important technique to increase latency and increase throughput, but batching not a magic solution to scale performance.

The [PBFT journal version](http://www.pmg.csail.mit.edu/papers/bft-tocs.pdf) has a good discussion of latency and throughput.


#### Scaling Consensus: scale vs security trade-off
Some people improve performance of consensus simply by running it on a smaller  group of validating replicas. Running consensus on a set of about twenty replicas is clearly less secure than running on a set of several hundreds of replicas.

Decreasing the set of validating replicas increases the performance but reduces security. This is yet another fundamental trade-off: security vs scalability.

One way to improve consensus performance it to actually improve the protocol. For example, reducing the number of rounds or changing the message complexity from quadratic to linear. This post discusses protocol improvements  in [partial synchrony](https://decentralizedthoughts.github.io/2019-06-23-what-is-the-difference-between/) and this post discusses protocol improvements in [synchrony](https://decentralizedthoughts.github.io/2019-11-11-authenticated-synchronous-bft/).

Note that security is not just about the size of the adversary (which is controlled by the total number of validating replicas) but also about the [adaptive power](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) of the adversary.



#### Scaling Consensus: sharding
Sharing is the idea of partitioning the state and the set of validating replicas. Each shard controls some part of the state and consensus is run by some part of the total validating replica population. Some cross shard mechanism must also be in place. The definitive document [Sharding FAQ](https://github.com/ethereum/wiki/wiki/Sharding-FAQ) in Ethereum is a great resource.

Sharding is a way to parallelize the *data*, *consensus* and *execution* bottlenecks. But from a consensus perspective, its essentially a scale vs security trade-off: instead of using all validating replicas to secure one state machine (chain) it suggest to create partitions (many shards). Having many shards (when contention is low) can obviously improve performance, but since each shard is secured by less validating votes, it may also reduce security.

[Ethereum 2.0](https://medium.com/chainsafe-systems/ethereum-2-0-a-complete-guide-scaling-ethereum-part-two-sharding-902370ac3be) plans to overcome this by using a two level scheme. A top level single high-security chain and multiple lower-security shards. The lower level  shards can use the top level single high security chain to increase the overall resilience.






#### Scaling Execution: limiting it
The separation of consensus and execution is one of the fundamental architecture designs of State Machine replication that goes back to [Yin etal 2003](https://www.cs.cornell.edu/lorenzo/papers/sosp03.pdf).
In the traditional SMR design, after a command is replicated and committed, it needs to be executed on all validating replicas.

In many systems the cost of *executing* the commands is the bottleneck. A major denial-of-service attack for an SMR system is to issue legal commands that will cause the system to waste time during execution. Many systems design Domain Specific Languages to prevent this attack. Bitcoin uses [bitcoin script](https://en.bitcoin.it/wiki/Script)  which carefully limits the computational complexity of each transaction. Ethereum uses a [gas mechanism](https://www.ethos.io/what-is-ethereum-gas/) to limit the execution complexity and incentives its usage in an efficient manner.

#### Scaling Execution: parallelizing it
One promising way to speedup execution is to leverage parallelization. This approach works when commands in the block are mostly contention free (commutative). The main idea is to find ways to simulate a sequential execution via a protocol that exploits parallelism in the optimistic contention-free case but maintains safety. See [Dickerson Gazzillo Herlihy Koskinen 2017](https://arxiv.org/abs/1702.04467)  and [Saraph Herlihy 2019](https://arxiv.org/abs/1901.01376).


#### Scaling Execution:  don't execute, verify using economic incentives and fraud proofs
In this solution the commands are committed as *data* but the execution is not done by the validating replicas. The validating replicas just acts as a data availability layer.


Instead of having replicas execute the commands, there is economically incentivized game where players can become executers by posting bonds. A bonded executer can then commit to the execution outcome. Any bonded reporting agent can provide a proof that the fraud has happened. If the fraud proof is correct then the executer is slashed and the reporting agent is partially rewarded. If the reporting agent lies about the fraud proof, then its bond can be slashed. Protocols for efficiently challenging the prover has origins in the work of [Feige Kilian 2000](https://courses.cs.washington.edu/courses/cse533/05au/feige-kilian-journal.pdf), then [Canetti Riva Rothblum 2011](https://www.cs.tau.ac.il/~canetti/CRR11.pdf) and was later adopted to using on chain incentives in *TrueBit* [Teutsch Reitwießner 2017](https://people.cs.uchicago.edu/~teutsch/papers/truebit.pdf) and in Buterin's
[Off-Chain Oracles](https://blog.ethereum.org/2014/09/17/scalability-part-1-building-top/). This approach is now being developed under the name [optimistic rollups](https://thebitcoinpodcast.com/hashing-it-out-67/) (also see Adler's [merged consensus](https://ethresear.ch/t/minimal-viable-merged-consensus/5617)).


#### Scaling Execution:  don't execute, verify using succinct proofs (PCPs)
In this solution again the commands are committed as *data* but the execution is not done by the validating replicas. The validating replicas just acts as a data availability layer for the commands/inputs.

Instead of using games to verify computation it is possible to leverage succinct proofs ([PCP](https://en.wikipedia.org/wiki/PCP_theorem)). These cryptographic techniques allow a prover to generate very short proofs that can be efficiently verified with high soundness and completeness. Execution (and proof generation) need to happen only at one node. Once a short proof exist then validating replicas of the execution engine just need to validate a short proof instead of re-executing the long commands/transactions.


This is the approach taken in  Buterin's [zk-roll-up](https://ethresear.ch/t/on-chain-scaling-to-potentially-500-tx-sec-through-mass-tx-validation/3477). See [this video](https://www.youtube.com/watch?v=mOm47gBMfg8) for a way to add privacy to the succinct proofs.
