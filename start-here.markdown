---
title: Start Here
date: 2020-09-21 02:34:00 -11:00
---

{: .box-note}
this page is a dynamically changing index of all our posts, it's one more place to start reading Decentralized Thoughts

# Basics, Foundations, and Classics

Start with the definition of [Consensus and Agreement](https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/). Then learn about the [network model](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/), the [threshold adversary](https://decentralizedthoughts.github.io/2019-06-17-the-threshold-adversary/) model, and the
[power of the adversary](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/).
Finally, many protocols need a [trusted setup phase](https://decentralizedthoughts.github.io/2019-07-18-setup-assumptions/).

You can learn more about [Partial Synchrony](https://decentralizedthoughts.github.io/2019-09-13-flavours-of-partial-synchrony/) and about different [relaxations of Broadcast](https://decentralizedthoughts.github.io/2019-10-22-flavours-of-broadcast/).

One of the classic protocols of distributed computing is the [Dolev-Strong Authenticated Broadcast protocol](https://decentralizedthoughts.github.io/2019-12-22-dolev-strong/).

# State Machine Replication

We begin by defining [State Machine Replication](https://decentralizedthoughts.github.io/2019-10-15-consensus-for-state-machine-replication/) (SMR) and talk about different degrees of [SMR fault tolerance](https://decentralizedthoughts.github.io/2019-10-25-flavours-of-state-machine-replication/). The scalability and performance of a State Machine Replication system is not just about [Consensus, but also about Data and Execution](https://decentralizedthoughts.github.io/2019-12-06-dce-the-three-scalability-bottlenecks-of-state-machine-replication/).

We start with a [simple SMR for crash failures](https://decentralizedthoughts.github.io/2019-11-01-primary-backup/). We later extend this to omission failures. [First via single shot](https://decentralizedthoughts.github.io/2020-09-13-synchronous-consensus-omission-faults/).


# Lower Bounds

- [Consensus with Ommsion failures](https://decentralizedthoughts.github.io/2019-11-02-primary-backup-for-2-servers-and-omission-failures-is-impossible/) requires $f<n/2$.


- [Byzantine Consensus in Partial Synchrony](https://decentralizedthoughts.github.io/2019-06-25-on-the-impossibility-of-byzantine-agreement-for-n-equals-3f-in-partial-synchrony/) requires $f<n/3$.

- [Byzantine Consensus with no PKI](https://decentralizedthoughts.github.io/2019-08-02-byzantine-agreement-is-impossible-for-$n-slash-leq-3-f$-is-the-adversary-can-easily-simulate/) (or more generally when the adversary can simulate) requires $f<n/3$.

- [Consensus often needs a quadratic number of messages](https://decentralizedthoughts.github.io/2019-08-16-byzantine-agreement-needs-quadratic-messages/).


- Consensus is challenging because [some initial state must be uncommitted](https://decentralizedthoughts.github.io/2019-12-15-consensus-model-for-FLP/) and this imples [executions with at least $f+1$ rounds in Synchrony](https://decentralizedthoughts.github.io/2019-12-15-synchrony-uncommitted-lower-bound/) and [non-terminating executions in Asynchrony](https://decentralizedthoughts.github.io/2019-12-15-asynchrony-uncommitted-lower-bound/) (the FLP impossibility).

# Blockchains

- [The first blockchain (or how to timestamp a digital document)](https://decentralizedthoughts.github.io/2020-07-05-the-first-blockchain-or-how-to-time-stamp-a-digital-document/).

- [Setup assumptions in Bitcoin and Ethereum](https://decentralizedthoughts.github.io/2019-07-18-do-bitcoin-and-ethereum-have-any-trusted-setup-assumptions/) and the notion of [checkpointing a blockchain](https://decentralizedthoughts.github.io/2019-09-13-dont-trust-checkpoint/). 

- [Security analysis of Nakamoto Consensus](https://decentralizedthoughts.github.io/2019-11-29-Analysis-Nakamoto/)


- [Blockchain Selfish Mining](https://decentralizedthoughts.github.io/2020-02-26-selfish-mining/). 

- [Payment Channels](https://decentralizedthoughts.github.io/2019-10-25-payment-channels-are-just-a-two-person-bfs-smr-systems/)

# Cryptography

The basics:

- [Cryptographic hash function](https://decentralizedthoughts.github.io/2020-08-28-what-is-a-cryptographic-hash-function/)

- [Polynomials over a finite field](https://decentralizedthoughts.github.io/2020-07-17-the-marvels-of-polynomials-over-a-field/)

- [Polinomial secret sharing](https://decentralizedthoughts.github.io/2020-07-17-polynomial-secret-sharing-and-the-lagrange-basis/).

More advanced:

- [Bilinear Accumulators](https://decentralizedthoughts.github.io/2020-04-02-bilinear-accumulators-for-cryptocurrency/) and [range proofs](https://decentralizedthoughts.github.io/2020-03-03-range-proofs-from-polynomial-commitments-reexplained/).

- Private set intersection: [part 1](https://decentralizedthoughts.github.io/2020-03-29-private-set-intersection-a-soft-introduction/) and [part 2](https://decentralizedthoughts.github.io/2020-07-26-private-set-intersection-2/)

# Research

- [What is the difference between PBFT, Tendermint, SBFT, and HotStuff ?](https://decentralizedthoughts.github.io/2019-06-23-what-is-the-difference-between/)

- [Survay of modern Authenticated Synchronous BFT protocols](https://decentralizedthoughts.github.io/2019-11-11-authenticated-synchronous-bft/)

- [Sync HotStuff](https://decentralizedthoughts.github.io/2019-11-12-Sync-HotStuff/)

- [Streamlet](https://decentralizedthoughts.github.io/2020-05-14-streamlet/)

- [Optimal Optimistic Responsivness](https://decentralizedthoughts.github.io/2020-06-12-optimal-optimistic-responsiveness/)

- Encrypted Blockchain Databases [part 1](https://decentralizedthoughts.github.io/2020-07-10-encrypted-blockchain-databases-part-i/) and [part 2](https://decentralizedthoughts.github.io/2020-07-10-encrypted-blockchain-databases-part-ii/).

- [Asynchronous Fault-Tolerant Computation with Optimal Resilience](https://decentralizedthoughts.github.io/2020-07-15-asynchronous-fault-tolerant-computation-with-optimal-resilience/)

- [Resolving the Availability-Finality Dilemma](https://decentralizedthoughts.github.io/2020-10-31-ebb-and-flow-protocols-a-resolution-of-the-availability-finality-dilemma/)

- [BFT Protocol Forensics](https://decentralizedthoughts.github.io/2020-11-19-bft-protocol-forensics/)
