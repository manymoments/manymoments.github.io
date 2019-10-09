---
title: Consensus for State Machine Replication
date: 2019-10-08 19:58:00 -07:00
published: false
tags:
- dist101
---

<p align="center">
  co-authored with <a href="https://users.cs.duke.edu/~kartik">Kartik</a> <a href="https://twitter.com/kartik1507">Nayak</a>
</p>

co-authored with Kartik Nayak
We introduced definitions for consensus, Byzantine Broadcast (BB) and Byzantine Agreement (BA), in an [earlier post](https://ittaiab.github.io/2019-06-27-defining-consensus/). In this post, we will discuss a setting called State Machine Replication (SMR), where consensus protocols are used. We will compare and contrast this setting to that of traditional BB and BA.

In an SMR setting, a server maintains a state machine and applies a sequence of commands sent by clients to this state machine. Maintaining a single server is prone to crashes or Byzantine faults. Thus, instead of maintaining a single server, an SMR system uses multiple server replicas, some of which can be faulty. The group of servers still present to the client with the same interface like that of a single server. 

The server replicas all start with the same state. They agree on the sequence of client commands received by them. Then they apply the commands in the agreed-upon sequence to the state machine. If the state transitions are deterministic, they will maintain an identical state.

The crux of an SMR system is to agree on the sequence of commands. To do so, an SMR system needs to guarantee the following:
***(Safety)*** Any two clients learn the same sequence of commands.
***(Liveness)*** Honest servers will eventually execute a command proposed by a client.

At first glance, the requirements for SMR are similar to those for BB and BA. Safety is similar to the agreement property, whereas liveness is similar to the termination property. However, there are a few differences between them:
1. **Consensus on a sequence of values.** The definition of SMR considers consensus on a sequence of values. On the other hand, BB and BA considered a single-shot consensus setting. Conceptually, one can sequentially compose single-shot consensus protocols. In practice, SMR protocols may optimize without necessarily relying on a sequential composition (more discussed below).

2. **Who are the learners?** In BB and BA, the parties executing the protocol are the ones learning the result. In SMR, the replicas engage in the consensus protocol but eventually need to convince clients of the result. In the presence of Byzantine faults, the clients in an SMR protocol may communicate with multiple replicas before learning about the commit. If there are $f$ Byzantine faults, the client needs to communicate with at least $f+1$ replicas to know that it has communicated with at least one honest replica.

3. **Fault tolerance.** An essential consequence of clients not participating in the protocol is the fault tolerance one can obtain. With BB, we know of protocols such as Dolev-Strong that can tolerate $f < n-1$ faults among $n$ replicas. SMR protocols cannot tolerate more than a minority corruption even if the consensus protocol used is BB.

4. **External validity.** Finally, the definition does not explicitly state a validity property as in BB and BA. SMR protocols generally satisfy *external validity*, i.e., a command is said to be valid so far as the client signs the value.

### Optimizing for a sequence of values.

Since SMR protocols agree on a sequence of values, practical approaches for SMR (such as [PBFT](http://pmg.csail.mit.edu/papers/osdi99.pdf), [Paxos](https://lamport.azurewebsites.net/pubs/paxos-simple.pdf), etc.) use a steady-state-and-view-change approach to architect the agreement protocol. In the steady-state, there is a designated leader that drives consensus. Typically, the leader does not change until it fails (e.g., due to network delays) or if Byzantine behavior is detected. If the leader fails, the replicas vote to de-throne the leader and elect a new one. The process of choosing a new leader is called view-change. The presence of a single leader for more extended periods yields simplicity and efficiency when the leader is honest. However, it also reduces the amount of *decentralization* and can cause delays if Byzantine replicas are elected as leaders.
