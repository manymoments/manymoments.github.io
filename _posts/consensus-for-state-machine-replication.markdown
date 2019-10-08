---
title: Consensus for State Machien Replication
date: 2019-10-08 19:58:00 -07:00
published: false
tags:
- dist101
---

We introduced definitions for consensus, Byzantine Broadcast (BB) and Byzantine Agreement (BA), in an [earlier post](https://ittaiab.github.io/2019-06-27-defining-consensus/). In this post, we will discuss a setting called State Machine Replication (SMR) where consensus protocols are used. We will compare and contrast this setting to BB and BA.

In an SMR setting, a server maintains a state machine and applies a sequence of commands sent by clients to this state machine. To avoid crash or Byzantine faults on the server, an SMR system uses multiple servers, some of which can be faulty. The group of servers still present to the client with the same interface as that of a single server. Intuitively, if the servers start with the same state, agree on the sequence of client commands received by them, and apply them in that sequence to the state machine, they will maintain exactly the same state, so far as the state transitions are deterministic. SMR systems use consensus protocols to agree on these sequence of values.

Specifically, an SMR system needs to guarantee the following:
Safety: Any two clients learn the same sequence of values. Liveness: A value proposed by a client will eventually be executed by honest servers. 

At a first glance, the requirements for SMR are similar to that for BB and BA — safety is similar to consistency whereas liveness is similar to termination. There are a few differences though. 
1. First, the definition of SMR considers consensus on a sequence of values. BB and BA considered a single-shot consensus setting. Conceptually, one can sequentially compose single-shot consensus protocols. SMR protocols tend to optimize for consensus on sequence of values without necessarily relying on a sequential composition.
2. Second, in BB and BA, the parties executing the protocol are the ones ‘learning’ the result. In SMR, the replicas execute the consensus protocol, but eventually need to convince clients who are the learners. In the presence of Byzantine faults, the clients in an SMR protocol may communicate with multiple replicas before ‘learning’ about the commit. If there are f Byzantine faults, the client needs to communicate with at least f+1 replicas.
3. Third, the definition does not explicitly state a validity property as in BB and BA. SMR protocols satisfy external validity, i.e., a command is said to be valid so far as the value is signed by the client.
4. Finally, for BB, we know of protocols such as Dolev-Strong that can tolerate f < n-1. In SMR, since clients do not participate in the protocol and need to be convinced by server replicas about commits, they cannot tolerate more than a minority corruption (even if the consensus protocol used is BB).
