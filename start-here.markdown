---
title: Start Here
date: 2020-09-21 09:34:00 -04:00
---

{: .box-note}
this page is a dynamically changing index of all our posts, it's one more place to start reading Decentralized Thoughts

# Basics, Foundations, and Classics

Start with the definition of [Consensus and Agreement](/2019-06-27-defining-consensus/). Then learn about the [network model](/2019-06-01-2019-5-31-models/), the [threshold adversary](/2019-06-17-the-threshold-adversary/) model, and the
[power of the adversary](/2019-06-07-modeling-the-adversary/).
Finally, many protocols need a [trusted setup phase](/2019-07-19-setup-assumptions/).

You can learn more about [Partial Synchrony](/2019-09-14-flavours-of-partial-synchrony/) and about different [relaxations of Broadcast](/2019-10-22-flavours-of-broadcast/).

One of the classic protocols of distributed computing is the [Dolev-Strong Authenticated Broadcast protocol](/2019-12-22-dolev-strong/).

# State Machine Replication

We begin by defining [State Machine Replication](/2019-10-15-consensus-for-state-machine-replication/) (SMR) and talk about different degrees of [SMR fault tolerance](/2019-10-25-flavours-of-state-machine-replication/). The scalability and performance of a State Machine Replication system is not just about [Consensus, but also about Data and Execution](/2019-12-06-dce-the-three-scalability-bottlenecks-of-state-machine-replication/).

We start with a [simple SMR for crash failures](/2019-11-01-primary-backup/). We later extend this to omission failures. [First via single shot](/2020-09-13-synchronous-consensus-omission-faults/) and then via the [Lock-commit](https://decentralizedthoughts.github.io/2020-11-30-the-lock-commit-paradigm-multi-shot-and-mixed-faults/) paradigm to [multi-shot consensus](https://decentralizedthoughts.github.io/2020-11-30-the-lock-commit-paradigm-multi-shot-and-mixed-faults/).

# Living with Asynchrony

One of the core challenges in fault-tolerant distributed computing is Asynchrony. The classic [FLP lower bound](/2019-12-15-consensus-model-for-FLP/) is a fundamental result. The basic building blocks are [Reliable Broadcast](https://decentralizedthoughts.github.io/2020-09-19-living-with-asynchrony-brachas-reliable-broadcast/) and [Gather](https://decentralizedthoughts.github.io/2021-03-26-living-with-asynchrony-the-gather-protocol/). 


# Lower Bounds

- [Consensus with Ommsion failures](/2019-11-02-primary-backup-for-2-servers-and-omission-failures-is-impossible/) requires $f<n/2$.


- [Byzantine Consensus in Partial Synchrony](/2019-06-25-on-the-impossibility-of-byzantine-agreement-for-n-equals-3f-in-partial-synchrony/) requires $f<n/3$.

- [Byzantine Consensus with no PKI](/2019-08-02-byzantine-agreement-is-impossible-for-$n-slash-leq-3-f$-is-the-adversary-can-easily-simulate/) (or more generally when the adversary can simulate) requires $f<n/3$.

- [Consensus often needs a quadratic number of messages](/2019-08-16-byzantine-agreement-needs-quadratic-messages/).


- Consensus is challenging because [some initial state must be uncommitted](/2019-12-15-consensus-model-for-FLP/) and this imples [executions with at least $f+1$ rounds in Synchrony](/2019-12-15-synchrony-uncommitted-lower-bound/) and [non-terminating executions in Asynchrony](/2019-12-15-asynchrony-uncommitted-lower-bound/) (the FLP impossibility).

# Blockchains

- [The first blockchain (or how to timestamp a digital document)](/2020-07-05-the-first-blockchain-or-how-to-time-stamp-a-digital-document/).

- [Setup assumptions in Bitcoin and Ethereum](/2019-07-18-do-bitcoin-and-ethereum-have-any-trusted-setup-assumptions/) and the notion of [checkpointing a blockchain](/2019-09-13-dont-trust-checkpoint/). 

- [Security analysis of Nakamoto Consensus](/2019-11-29-Analysis-Nakamoto/)


- [Blockchain Selfish Mining](/2020-02-26-selfish-mining/). 

- [Payment Channels](/2019-10-25-payment-channels-are-just-a-two-person-bfs-smr-systems/)

# Cryptography

The basics:

- [Cryptographic hash function](/2020-08-28-what-is-a-cryptographic-hash-function/) and [Merkle Trees](https://decentralizedthoughts.github.io/2020-12-22-what-is-a-merkle-tree/)

- [Polynomials over a finite field](/2020-07-17-the-marvels-of-polynomials-over-a-field/) and their use for [Polinomial secret sharing](/2020-07-17-polynomial-secret-sharing-and-the-lagrange-basis/) and even [Zero knowledge proofs](https://decentralizedthoughts.github.io/2020-12-08-a-simple-and-succinct-zero-knowledge-proof/)

More advanced:

- [Bilinear Accumulators](/2020-04-01-bilinear-accumulators-for-cryptocurrency/) and [range proofs](/2020-03-02-range-proofs-from-polynomial-commitments-reexplained/).


- Private set intersection: [part 1](/2020-03-29-private-set-intersection-a-soft-introduction/) and [part 2](/2020-07-26-private-set-intersection-2/)

# Research

- [What is the difference between PBFT, Tendermint, SBFT, and HotStuff ?](/2019-06-23-what-is-the-difference-between/)

- [Survay of modern Authenticated Synchronous BFT protocols](/2019-11-11-authenticated-synchronous-bft/)

- [Sync HotStuff](/2019-11-12-Sync-HotStuff/)

- [Streamlet](/2020-05-14-streamlet/)

- [Optimal Optimistic Responsivness](/2020-06-12-optimal-optimistic-responsiveness/)

- Encrypted Blockchain Databases [part 1](/2020-07-10-encrypted-blockchain-databases-part-i/) and [part 2](/2020-07-10-encrypted-blockchain-databases-part-ii/).

- [Asynchronous Fault-Tolerant Computation with Optimal Resilience](/2020-07-15-asynchronous-fault-tolerant-computation-with-optimal-resilience/).

- [Resolving the Availability-Finality Dilemma](/2020-10-31-ebb-and-flow-protocols-a-resolution-of-the-availability-finality-dilemma/).

- [BFT Protocol Forensics](/2020-11-19-bft-protocol-forensics/).

- Good-case Latency of Byzantine Broadcast: [the Synchronous Case](https://decentralizedthoughts.github.io/2021-03-09-good-case-latency-of-byzantine-broadcast-the-synchronous-case/) and [a Complete Categorization](https://decentralizedthoughts.github.io/2021-02-28-good-case-latency-of-byzantine-broadcast-a-complete-categorization/).

- [2-round BFT SMR with n=4, f=1](https://decentralizedthoughts.github.io/2021-03-03-2-round-bft-smr-with-n-equals-4-f-equals-1/)

-
