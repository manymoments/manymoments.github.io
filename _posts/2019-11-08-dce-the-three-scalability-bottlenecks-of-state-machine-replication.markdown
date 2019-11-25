---
title: 'Data, Consensus, Execution: Three Scalability Bottlenecks for State Machine Replication'
date: 2019-11-24 09:05:00 -08:00
published: false
---

If anyone asks you: *how can I scale  my State Machine Replication (Blockchain) system?*

You should answer back with a question: *what is its  **bottleneck**? Is it Data, Consensus or Execution?*

1. **Data**: Shipping the commands to all the replicas. For example, if a command contains 1MB of data then the fundamental bottleneck is that you need all these bits to arrive to all the validating replicas.

2. **Consensus**: Once the data arrives, replicas engage in a consensus protocol (like the ones discussed [here](https://decentralizedthoughts.github.io/2019-06-23-what-is-the-difference-between/) and [here](https://decentralizedthoughts.github.io/2019-11-11-authenticated-synchronous-bft/)). For example, if the consensus protocol needs 2 round-trips and the validating replicas are spread across the globe then there is a fundamental latency bottleneck due to the speed of light and the size of Earth.

3. **Execution**: After the data has arrived and consensus is reached on the total ordering of the commands, the replicas need to *execute* the commands. The execution engine is a function that takes the old state and applies the ordered commands to compute the new state (and compute the output). For example, if the system requires all replicas to run the execution and the execution requires doing many cryptographic operations then (naively) all replicas will need to repeat these operations.

Note that these three bottlenecks are *not* a tradeoff (or a [trilemma](https://en.wikipedia.org/wiki/Trilemma)) these are independent challenges and the performance of a system is blocked by the *minimum* of all three. Here are some directions for addressing these challenges.



#### Scaling Data: better network solutions
In Bitcoin and other cryptocurrencies the ability to scale depends crucially on the ability reduce the latency it takes a winning block to propagate. Systems like [FIBRE](https://bitcoinfibre.org/), [Falcon](https://www.falcon-net.org/), and [bloXroute](https://bloxroute.com/wp-content/uploads/2018/03/bloXroute-whitepaper.pdf) aim to reduce this latency by using pipelining and forward error correction codes to propagate blocks with lower latency.

Another important  way to improve data scalability centers around being able to access content via a content addressable network. See [Kademlia](https://pdos.csail.mit.edu/~petar/papers/maymounkov-kademlia-lncs.pdf) which inspired Ethereum's [RLPx](https://github.com/ethereum/devp2p/blob/master/rlpx.md) and generalized in [libp2p](https://libp2p.io/).

#### Scaling Data: pushing to Layer Two
The extreme solution to scaling data is not to replicate it at all! Solutions like [Lightning](https://lightning.network/lightning-network-paper.pdf), [Plasma](https://www.plasma.io/plasma.pdf), and other layer two solutions aim to reduce data replication by pushing some of the intermediate transactions to a smaller private group and only report periodic summaries to the main system (see our post on [payment channels](https://decentralizedthoughts.github.io/2019-10-25-payment-channels-are-just-a-two-person-bfs-smr-systems/)). This approach has a natural drawback: not replicating all the data creates a data availability problem and increases the reliance on small private groups.

#### Scaling Consensus: the throughput vs latency trade-off

#### Scaling Consensus: scale vs security trade-off


#### Scaling Consensus: sharding




#### Scaling Execution: limiting it
The separation of consensus and execution is one of the fundamental architecture designs of State Machine replication that goes back to [Yin etal 2003](https://www.cs.cornell.edu/lorenzo/papers/sosp03.pdf).
In the traditional SMR design, after a command is replicated and committed, it needs to be executed on all validating replicas.

In many systems the cost of *executing* the commands is the bottleneck. A major denial-of-service attack for an SMR system is to issue legal commands that will cause the system to waste time during execution. Many systems design Domain Specific Languages to prevent this attack. Bitcoin uses [bitcoin script](https://en.bitcoin.it/wiki/Script)  which carefully limits the computational complexity of each transaction. Ethereum uses a [gas mechanism](https://www.ethos.io/what-is-ethereum-gas/) to limit the execution complexity and incentives its usage in an efficient manner.

#### Scaling Execution:  economic incentives and fraud proofs
In this solution the commands are committed as data but the execution is not done by the validators. Instead, there is economically incentivised game where players can become executers by posting bonds. A bonded executer can then commit to the execution outcome. If an incorrect execution outcome is committed then any other bonded player can provide a proof that the fraud has happened.  This approach has origins in the work of [CRR11](https://www.cs.tau.ac.il/~canetti/CRR11.pdf) and later adopt to using on chain incentives in [TrueBit](https://people.cs.uchicago.edu/~teutsch/papers/truebit.pdf) and
[Off-Chain Oracles](https://blog.ethereum.org/2014/09/17/scalability-part-1-building-top/). This approach is now being developed under the name [optimistic rollups](https://thebitcoinpodcast.com/hashing-it-out-67/) (also see [merged consensus](https://ethresear.ch/t/minimal-viable-merged-consensus/5617)).


#### Scaling Execution:  succinct verification
Instead of using games to verifiy computation it is possible to leverage succint proofs. [zk-roll-up](https://ethresear.ch/t/on-chain-scaling-to-potentially-500-tx-sec-through-mass-tx-validation/3477)
