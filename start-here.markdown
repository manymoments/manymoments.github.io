---
title: Start Here
date: 2020-09-21 09:34:00 -04:00
---

{: .box-note}
This page contains material for a graduate course on Blockchains and Distributed Computing with a dash of Cryptography (stay tuned for more). Or read [posts chronologically](https://decentralizedthoughts.github.io/).

We would love to get your feedback. If you find a post helpful or have a suggestion to improve, drop us a comment on [Twitter](https://twitter.com/ittaia/status/1421066572207169544?s=20).


# Basics, Foundations, and Classics

Start with the definition of [Consensus and Agreement](/2019-06-27-defining-consensus/). Then learn about the [network model](/2019-06-01-2019-5-31-models/), the [threshold adversary](/2019-06-17-the-threshold-adversary/) model, and the [power of the adversary](/2019-06-07-modeling-the-adversary/). Many protocols need a [trusted setup phase](/2019-07-19-setup-assumptions/).
The [consensus cheat sheet](https://decentralizedthoughts.github.io/2021-10-29-consensus-cheat-sheet/) gives a quick overview of what is possible and impossible. You can build half a course just from the upper bounds and lower bounds linked from it. 

## Variants of Consensus and Broadcast 

[Approximate agreement](https://decentralizedthoughts.github.io/2022-06-07-approx-agreement-one/) is a variation that considers rational input values.

This post covers several [relaxations of Broadcast](/2019-10-22-flavours-of-broadcast/).



## Synchronous Protocols

The Synchronous model is a good place to start because protocols are simpler. 

For a simple and classic synchronous Byzantine agreement protocol, checkout [Phase-King](https://decentralizedthoughts.github.io/2022-06-09-phase-king-via-gradecast/).

Under synchrony, a classic Byzantine Broadcast protocol (with a PKI) is the [Dolev-Strong Authenticated Broadcast protocol](/2019-12-22-dolev-strong/). 

More recent State Machine Replication protocols such as [Sync HotStuff](/2019-11-12-Sync-HotStuff/), an [optimal optimistically responsive synchronous protocol](/2020-06-12-optimal-optimistic-responsiveness/), and a simple, streamlined synchronous protocol called [Streamlet](/2020-05-14-streamlet/). This post provides a survey of [authenticated protocols under the synchrony assumption](/2019-11-11-authenticated-synchronous-bft/).

For a simple non-equivocation protocol, see [Crusader Broadcast](https://decentralizedthoughts.github.io/2022-06-19-crusader-braodcast/). 


## Partially Synchronous Protocols

[Partial synchrony](/2019-09-14-flavours-of-partial-synchrony/) is one of the most used models in real word systems today.

Modern variants of the classic protocols of Paxos and Raft are covered in [Benign Hotstuff](https://decentralizedthoughts.github.io/2021-04-02-benign-hotstuff/) and [Simplifing Raft with Chaining](https://decentralizedthoughts.github.io/2021-07-17-simplifying-raft-with-chaining/). [Log Paxos](https://decentralizedthoughts.github.io/2021-09-30-distributed-consensus-made-simple-for-real-this-time/) is a modern take on multi-Paxos. It is both surprisingly simple and concretely efficient. 

An important building block is [provable broadcast](https://decentralizedthoughts.github.io/2022-09-10-provable-broadcast/).


Single shot [Paxos](https://decentralizedthoughts.github.io/2022-11-04-paxos-via-recoverable-broadcast/), followed by single shot [PBFT](https://decentralizedthoughts.github.io/2022-11-20-pbft-via-locked-braodcast/), followed by [Two Round HotStuff](https://decentralizedthoughts.github.io/2022-11-24-two-round-HS/). The path from single shot to SMR is covered [here](https://decentralizedthoughts.github.io/2022-11-19-from-single-shot-to-smr/).

For Byzantine adversaries, see [Information Theoretic HotStuff](https://decentralizedthoughts.github.io/2021-09-20-information-theoretic-hotstuff-it-hs-part-one/).

## Asynchronous Protocols

One of the core challenges of distributed computing is tolerating failures in an asynchronous network. The classic [FLP lower bound](/2019-12-15-consensus-model-for-FLP/) is a fundamental result showing the impossibility of consensus under even one crash fault. 

A basic building block in asynchrony is the [Reliable Broadcast](https://decentralizedthoughts.github.io/2020-09-19-living-with-asynchrony-brachas-reliable-broadcast/) protocol. 

How do you measure [round complexity in asynchrony](https://decentralizedthoughts.github.io/2021-09-29-the-round-complexity-of-reliable-broadcast/) (and can you improve the round complexity of reliable broadcast)? 

The multi-leader generalization of reliable broadcast is called [Reliable Gather](https://decentralizedthoughts.github.io/2021-03-26-living-with-asynchrony-the-gather-protocol/). 

Series on Asynchronous Agreement: 

1. [define the problem](https://decentralizedthoughts.github.io/2022-03-30-asynchronous-agreement-part-one-defining-the-problem/);
2. present [Ben-Or's protocol](https://decentralizedthoughts.github.io/2022-03-30-asynchronous-agreement-part-two-ben-ors-protocol/);
3. provide a [modern version](https://decentralizedthoughts.github.io/2022-03-30-asynchronous-agreement-part-three-a-modern-version-of-ben-ors-protocol/);
4. Introduce [Crusader Agreement and Binding Crusader Agreement](https://decentralizedthoughts.github.io/2022-04-05-aa-part-four-CA-and-BCA/); 
5. use BCA to efficiently solve [Binary Byzantine Agreement from a strong common coin](https://decentralizedthoughts.github.io/2022-04-05-aa-part-five-ABBA/).
 


# State Machine Replication

This post defines [state machine replication](/2019-10-15-consensus-for-state-machine-replication/) (SMR). There are several levels of [SMR fault tolerance](/2019-10-25-flavours-of-state-machine-replication/). 

This post formally defines the [ideal state machine model and Linearizability](https://decentralizedthoughts.github.io/2021-10-16-the-ideal-state-machine-model-multiple-clients-and-linearizability/). 

The scalability and performance of a State Machine Replication system are not just about [consensus, but also about data and execution](/2019-12-06-dce-the-three-scalability-bottlenecks-of-state-machine-replication/).

How [DAGs improve the performance of SMR](https://decentralizedthoughts.github.io/2022-06-28-DAG-meets-BFT/).

To learn about upper bounds, start with a [simple SMR for crash failures](/2019-11-01-primary-backup/). Then extend SMR to omission failures: [First via single shot](/2020-09-13-synchronous-consensus-omission-faults/) and then via the [lock-commit](https://decentralizedthoughts.github.io/2020-11-30-the-lock-commit-paradigm-multi-shot-and-mixed-faults/) paradigm to [multi-shot consensus](https://decentralizedthoughts.github.io/2020-11-30-the-lock-commit-paradigm-multi-shot-and-mixed-faults/).


In partial synchrony, [Log Paxos](https://decentralizedthoughts.github.io/2021-09-30-distributed-consensus-made-simple-for-real-this-time/) shows how to extend Paxos to multi-Paxos in a straightforward and efficient manner.


# Lower Bounds

Lower bounds give us powerful tools to understand the fundamental limitations and model assumptions. 

- Folklore (aka CAP theorem): [Consensus with Omission failures](/2019-11-02-primary-backup-for-2-servers-and-omission-failures-is-impossible/) requires $f<n/2$.

- Dwork, Lynch, Stockmeyer 1988 ([DLS](https://groups.csail.mit.edu/tds/papers/Lynch/jacm88.pdf)) lower bound: [Byzantine Consensus in Partial Synchrony](/2019-06-25-on-the-impossibility-of-byzantine-agreement-for-n-equals-3f-in-partial-synchrony/) requires $f<n/3$.

- Fischer, Lynch, Merritt ([FLM](https://groups.csail.mit.edu/tds/papers/Lynch/FischerLynchMerritt-dc.pdf))lower bound: [Byzantine Consensus with no PKI](/2019-08-02-byzantine-agreement-is-impossible-for-$n-slash-leq-3-f$-is-the-adversary-can-easily-simulate/) (or more generally when the adversary can simulate) requires $f<n/3$. 

- Strengthening the FLM lower bound: [Crusader Agreement with $\leq 1/3$ Error is Impossible for $n\leq 3f$ if the Adversary can Simulate](https://decentralizedthoughts.github.io/2021-10-04-crusader-agreement-with-dollars-slash-leq-1-slash-3$-error-is-impossible-for-$n-slash-leq-3f$-if-the-adversary-can-simulate/).

- Dolev and Reischuk 1982 ([DR](https://www.cs.huji.ac.il/~dolev/pubs/p132-dolev.pdf)) lower bound: [Consensus often needs a quadratic number of messages](/2019-08-16-byzantine-agreement-needs-quadratic-messages/).

- Fischer, Lynch, Paterson 1985 ([FLP](https://groups.csail.mit.edu/tds/papers/Lynch/jacm85.pdf)) lower bound: Consensus must have some initial state that is [uncommitted](/2019-12-15-consensus-model-for-FLP/) and this implies [executions with at least $f+1$ rounds in Synchrony](/2019-12-15-synchrony-uncommitted-lower-bound/) and [non-terminating executions in Asynchrony](/2019-12-15-asynchrony-uncommitted-lower-bound/) (the FLP impossibility).

-  Ben-Or, Kelmer, Rabin 1994 ([BKR](https://dl.acm.org/doi/10.1145/197917.198088)) lower bound: Asynchronous Verifiable Secret Sharing must have a [non-zero probability of not terminating](https://decentralizedthoughts.github.io/2020-07-15-asynchronous-fault-tolerant-computation-with-optimal-resilience/).

- Raft does not guarantee liveness under [omission faults](https://decentralizedthoughts.github.io/2020-12-12-raft-liveness-full-omission/).

- CJKR lower bound: Neither Non-equivocation nor Transferability alone is enough for [tolerating minority corruptions in asynchrony](https://decentralizedthoughts.github.io/2021-06-14-neither-non-equivocation-nor-transferability-alone-is-enough-for-tolerating-minority-corruptions-in-asynchrony/).

# Blockchains

What is a [blockchain?](https://decentralizedthoughts.github.io/2022-09-05-what-is-a-blockchain/)

What was the [first blockchain (or how to timestamp a digital document)](/2020-07-05-the-first-blockchain-or-how-to-time-stamp-a-digital-document/)?  

Do proof-of-work blockchains need any [setup assumptions?](/2019-07-18-do-bitcoin-and-ethereum-have-any-trusted-setup-assumptions/)?

What does [checkpointing a blockchain](/2019-09-13-dont-trust-checkpoint/) mean?  

What is [Nakamoto Consensus](/2021-10-15-Nakamoto-Consensus/)? 

How do you [prove Nakamoto Consensus is secure](/2019-11-29-Analysis-Nakamoto/)? 

What is the problem of [selfish mining](/2020-02-26-selfish-mining/)?

The simplest L2 solution is a [payment channel](/2019-10-25-payment-channels-are-just-a-two-person-bfs-smr-systems/).

# Cryptography

Some important tools:

- [Cryptographic hash functions](/2020-08-28-what-is-a-cryptographic-hash-function/).

- [Merkle Ttrees](https://decentralizedthoughts.github.io/2020-12-22-what-is-a-merkle-tree/).

- A lightweight mathematical intro to [Polynomials over a finite field](/2020-07-17-the-marvels-of-polynomials-over-a-field/).

- The basics of [Polynomial secret sharing](/2020-07-17-polynomial-secret-sharing-and-the-lagrange-basis/).

- A glimpse at [Zero knowledge proofs](https://decentralizedthoughts.github.io/2020-12-08-a-simple-and-succinct-zero-knowledge-proof/)

- [Bilinear accumulators](/2020-04-02-bilinear-accumulators-for-cryptocurrency/) from polynomial commitments.

- [range proofs](/2020-03-03-range-proofs-from-polynomial-commitments-reexplained/) from polynomial commmitments.

- Private set intersection: [part 1](/2020-03-29-private-set-intersection-a-soft-introduction/) and [part 2](/2020-07-26-private-set-intersection-2/). Apple is using PSI for [CSAM detection](https://decentralizedthoughts.github.io/2021-08-29-the-private-set-intersection-psi-protocol-of-the-apple-csam-detection-system/).

## Secret Sharing

Polynomial secret sharing is a base for deep connections between cryptography and distributed computing.

Polynomial secret sharing agains a [passive adversary](https://decentralizedthoughts.github.io/2020-07-17-polynomial-secret-sharing-and-the-lagrange-basis/), against a [crash adversary](https://decentralizedthoughts.github.io/2022-08-17-secret-sharing-with-crash/).

The [BGW88](https://inst.eecs.berkeley.edu/~cs276/fa20/notes/BGW88.pdf) protocol for [Verifiable Secret Sharing](https://decentralizedthoughts.github.io/2022-08-24-BGW-secret-sharing/).

Chaum’s [Dining Cryptographers](https://users.ece.cmu.edu/~adrian/731-sp04/readings/dcnets.html) and [the additivity of polynomial secret sharing](https://decentralizedthoughts.github.io/2022-08-25-dining-cryptographers-additive/).

# Research Oriented Posts

- [What is the difference between PBFT, Tendermint, SBFT, and HotStuff ?](/2019-06-23-what-is-the-difference-between/)

- [Survey of modern Authenticated Synchronous BFT protocols](/2019-11-11-authenticated-synchronous-bft/) (updated in March 2021).

- [Sync HotStuff](/2019-11-12-Sync-HotStuff/).

- [Optimal Optimistic Responsivness](/2020-06-12-optimal-optimistic-responsiveness/).

- Encrypted Blockchain Databases [part 1](/2020-07-10-encrypted-blockchain-databases-part-i/) and [part 2](/2020-07-10-encrypted-blockchain-databases-part-ii/).

- [Asynchronous Fault-Tolerant Computation with Optimal Resilience](/2020-07-15-asynchronous-fault-tolerant-computation-with-optimal-resilience/).

- [Resolving the Availability-Finality Dilemma](/2020-10-31-ebb-and-flow-protocols-a-resolution-of-the-availability-finality-dilemma/).

- [BFT Protocol Forensics](/2020-11-19-bft-protocol-forensics/).

- Good-case Latency of Byzantine Broadcast: [the Synchronous Case](https://decentralizedthoughts.github.io/2021-03-09-good-case-latency-of-byzantine-broadcast-the-synchronous-case/) and [a Complete Categorization](https://decentralizedthoughts.github.io/2021-02-28-good-case-latency-of-byzantine-broadcast-a-complete-categorization/).

- [2-round BFT SMR with n=4, f=1](https://decentralizedthoughts.github.io/2021-03-03-2-round-bft-smr-with-n-equals-4-f-equals-1/).

- [Optimal Communication Complexity of Authenticated Byzantine Agreement](https://decentralizedthoughts.github.io/2021-09-20-optimal-communication-complexity-of-authenticated-byzantine-agreement/)

- [Good-case Latency of Rotating Leader Synchronous BFT](https://decentralizedthoughts.github.io/2021-12-07-good-case-latency-of-rotating-leader-synchronous-bft/)

- [EIP-1559 in Retrospect](https://decentralizedthoughts.github.io/2022-03-10-eip1559/)

- [Colordag: From always-almost to almost-always 50% selfish mining resilience](https://decentralizedthoughts.github.io/2022-03-07-colordag-from-always-almost-to-almost-always-50-percent-selfish-mining-resilience/)

- [Consensus by Dfinity: in synchrony](https://decentralizedthoughts.github.io/2022-03-12-dfinity-synchrony/) and [Consensus by Dfinity - Part II (Internet Computer Consensus): in partial synchrony](https://decentralizedthoughts.github.io/2022-03-12-dfinity-partial-synchrony/) 

- [Sandglass: Safe Permissionless Consensus](https://decentralizedthoughts.github.io/2022-06-21-sandglass/).

- [DAG Meets BFT - The Next Generation of BFT Consensus](https://decentralizedthoughts.github.io/2022-06-28-DAG-meets-BFT/).

- [He-HTLC - Revisiting Incentives in HTLC](https://decentralizedthoughts.github.io/2022-08-12-hehtlc/).
