---
title: 'DCE: Three Scalability Bottlenecks for State Machine Replication'
date: 2019-11-08 09:05:00 -08:00
published: false
---

If anyone asks you: *how can I scale this State Machine Replication (Blockchain) system?* you should answer back with a question: *what is the bottleneck? Is it Data, Consensus or Execution (DCE)?*

1. **Data**: Shipping the commands to all the replicas. For example, if a command contains 1GB of data then the fundamental bottleneck is that you need all these bits to arrive to all the validating replicas.mmmmm

2. **Consensus**: Once the data arrives, replicas engage in a consensus protocol (like the ones discussed [here](https://decentralizedthoughts.github.io/2019-06-23-what-is-the-difference-between/) and [here](https://decentralizedthoughts.github.io/2019-11-11-authenticated-synchronous-bft/)). For example, if the consensus protocol needs 2 round-trips and the validating replicas are spread across the globe then there is a fundamental latency bottleneck due to the speed of light and the size of Earth.

3. **Execution**: After the data has arrived and consensus is reached on the total ordering of the commands, the replicas need to *execute* the commands. The execution engine is a function that takes the old state and applies the ordered commands to compute the new state (and compute the output). For example, if the system requires all replicas to run the execution and the execution requires doing many cryptographic operations then (naively) all replicas will need to repeat these operations.

Note that these three bottlenecks are *not* a tradeoff (or a [trilemma](https://en.wikipedia.org/wiki/Trilemma)) these are independent challenges and the performance of a system is blocked by the *minimum* of all three.


## Scaling Data
In Bitcoin and other cryptocurrencies the ability to scale depends crucially on the ability reduce the latency it takes a winning block to propagate. Systems like [FIBRE](https://bitcoinfibre.org/), [Falcon](https://www.falcon-net.org/), and [bloXroute](https://bloxroute.com/wp-content/uploads/2018/03/bloXroute-whitepaper.pdf) aim to reduce this latency by using pipelining and forward error correction codes.

Another important  way to improve data scalability centers around creating a content addressable network. See [Kademlia]() which inspired Ethereum's [RLPx](https://github.com/ethereum/devp2p/blob/master/rlpx.md) and generalized in [libp2p](https://libp2p.io/).

## Scaling Consensus

Throughput vs Latency trade-off

Scale vs security trade-off

Sharding

## Scaling Execution
