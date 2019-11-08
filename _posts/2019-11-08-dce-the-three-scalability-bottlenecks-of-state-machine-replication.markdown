---
title: 'DCE: the Three Scalability Bottlenecks of State Machine Replication'
date: 2019-11-08 09:05:00 -08:00
published: false
---

Any State Machine Replication system (for example a Blockchain) that wants to scale needs to overcome three fundamental bottlenecks: Data, Consensus and Execution (DCE).

1. **Data**: Shipping the commands to all the replicas. For example, if a command contains 1GB of data then the fundamental bottleneck is you need all these bits to arrive to all the validating replicas.

2. **Consensus**: Once the data arrives, replicas engage in a consensus protocol (like the ones discussed [here]()). For example, if the consensus protocol needs 2 rounds and the validators are spread across the globe then there is a fundamental latency bottleneck due to the speed of light and the size of Earth.

3. **Execution**: After the data has arrived and consensus is reached on the total ordering of the commands, the replicas need to execute the commands. The execution engine is a function that takes the old state and applies the ordered commands to compute the new state (and compute the output). For example, if the system requires all replicas to run the execution and the execution requires doing many cryptographic operations then (naively) all replicas will need to repeat these operations.

Note that these three bottlenecks are *not* a tradeoff (or a [trilemma](https://en.wikipedia.org/wiki/Trilemma)) these are independent challenges and the performance of a system is blocked by the *minimum* of all three.

