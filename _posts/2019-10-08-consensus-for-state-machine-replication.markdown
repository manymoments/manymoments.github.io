---
title: Consensus for State Machine Replication
date: 2019-10-08 19:58:00 -07:00
published: false
author: Kartik Nayak
tags:
- dist101
---

We introduced definitions for consensus, Byzantine Broadcast (BB) and Byzantine Agreement (BA), in an [earlier post](https://ittaiab.github.io/2019-06-27-defining-consensus/). In this post, we will discuss a setting called State Machine Replication (SMR), where consensus protocols are used. We will compare and contrast this setting to that of traditional BB and BA.

**State machine.** A state machine at any point stores a state of the system. It receives a set of inputs (also referred to as commands). The state machine applies these inputs in a sequential order using a transition function to generate an output and an updated state of the state machine. The functionality of a state machine can be succinctly described as follows:

```
state = init
log = []
while true:
  on receiving cmd from client:
    log.append(cmd)
    state, output = apply(cmd, state)
    send output to client
```

Here, the state machine is initialized to an initial state `init`. When it receives an input `cmd` from a client, it first adds the input to a `log`. It then *executes* the `cmd` by applying the transition function `apply` to the state. As a result it obtains an updated state and a result `output`. The result is then sent back to the client.

**State machine replication (SMR).** In a client-server setting, the server acts as a state machine and the client sends commands to it. Maintaining a single server is prone to crashes or Byzantine faults. Thus, instead of maintaining a single server, an SMR system uses multiple server replicas, some of which can be faulty. The goal is for the group of servers still present to the client with the same interface like that of a single server. 

The server replicas all initially start with the same state. However, when they receive concurrent requests from a client, honest replicas first need to agree on a on the sequence of client commands received by them. This problem is called **log replication** and it is a multi-shot version of consensus. Then they apply the commands in the log, one by one, using the `apply` transition. Assuming the transition is deterministic, the honest server replicas maintain an identical state at all times.

Thus, an SMR system needs to perform log replication efficiently and then execute the commands on the log. An SMR system needs to guarantee the following:

**(Safety)** Any two replicas store the same sequence of commands in their logs.

**(Liveness)** Honest servers will eventually execute a command proposed by a client.

The requirements for SMR seem similar to those for BB and BA. Safety is similar to the agreement property, whereas liveness is similar to the termination property. However, there are a few differences between them:
1. **Consensus on a sequence of values.** The definition of SMR considers needs multi-shot consensus. Conceptually, one can sequentially compose single-shot consensus protocols. In practice, SMR protocols may optimize without necessarily relying on a sequential composition (more discussed below).

2. **Who are the learners?** In BB and BA, the parties executing the protocol are the ones learning the result. In SMR, the replicas engage in the consensus protocol but eventually need to convince clients of the result. In the presence of Byzantine faults, the clients in an SMR protocol may communicate with multiple replicas before learning about the commit. If there are $f$ Byzantine faults, the client needs to communicate with at least $f+1$ replicas to know that it has communicated with at least one honest replica.

3. **Fault tolerance.** An essential consequence of clients not participating in the protocol is the fault tolerance one can obtain. With BB, we know of protocols such as Dolev-Strong that can tolerate $f < n-1$ faults among $n$ replicas. SMR protocols cannot tolerate more than a minority corruption even if the consensus protocol used is BB.

4. **External validity.** Finally, the definition does not explicitly state a validity property as in BB and BA. SMR protocols generally satisfy *external validity*, i.e., a command is said to be valid so far as the client signs the value.

### Optimizing for a sequence of values

Since SMR protocols agree on a sequence of values, practical approaches for SMR (such as [PBFT](http://pmg.csail.mit.edu/papers/osdi99.pdf), [Paxos](https://lamport.azurewebsites.net/pubs/paxos-simple.pdf), etc.) use a steady-state-and-view-change approach to architect the agreement protocol. In the steady-state, there is a designated leader that drives consensus. Typically, the leader does not change until it fails (e.g., due to network delays) or if Byzantine behavior is detected. If the leader fails, the replicas vote to de-throne the leader and elect a new one. The process of choosing a new leader is called view-change. The presence of a single leader for more extended periods yields simplicity and efficiency when the leader is honest. However, it also reduces the amount of *decentralization* and can cause delays if Byzantine replicas are elected as leaders.
