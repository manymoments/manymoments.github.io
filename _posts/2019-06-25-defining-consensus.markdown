---
title: Defining Consensus
published: false
tags:
- dist101
authors:
- Kartik Nayak
- Ittai Abraham
---

<p align="center">
  co-authored with <a href="https://users.cs.duke.edu/~kartik">Kartik</a> <a href="https://twitter.com/kartik1507">Nayak</a>
</p>

While we broadly understand "consensus" as the notion of different parties agreeing with each other, in the literature we see multiple problems with slightly different nuances. In this post, we summarize these problem definitions and their differences.

One of the most intuitive problems is that of **Byzantine Broadcast (BB)** where among the $n$ parties participating in the protocol, there is a "designated sender" known to all the parties. The designated sender starts with an input $v$ whereas all other parteis do not have an input. Intuitively, the honest parties need to agree upon a value sent by this designated sender. However, since the sender can potentially be Byzantine, honest parties need to agree on the sender's value only if it is honest; otherwise they agree upon any other value. More formally, Byzantine broadcast requires the following three conditions to hold:
- Consistency: If two honest parties agree upon values $v_1$ and $v_2$, then $v_1 = v_2$.
- Validity: If the designated sender is honest and its input is $v$, all honest parties output $v$.
- Termination: Every honest party should eventually output a value.

Some observations are in order. First, the conditions are only placed on honest parties (since we cannot require Byzantine parties to follow the protocol). **_Is this trivial?_** Second, the validity condition effectively rules out trivial solutions; for instance, a protocol that makes every honest party to output $\bot$. Third, the definition above can be modified to be probabilistic **_Is this trivial?_**. Finally, the value $v$ can be restricted to be a single-bit or it can be multi-valued.

A closely related problem is **Byzantine Agreement (BA)**, where all the $n$ parties start with an input. The honest parties agree on a value $v$ _only if_ all of them start with input $v$. Otherwise, they can agree upon any value. Thus, validity condition is the following (consistency and termination are similar to Byzantine Broadcast):
- Validity: If all parties start with the same value $v$, if they output a value $v'$, then $v = v'$. 

The above validity condition is also called strong validity (or strong unanimity). A weaker version requires validity to hold only if all parties are honest. While Byzantine Broadcast is well-defined and achievable even when we have a dishonest majority, we cannot achieve strong validity in Byzantine agreement in this setting. Intuitively, this is because the Byzantine parties can start with a different value and commit to that value without the participaation of honest parties. **_not sure if the argument entirely makes sense_** **_single bit vs multibit; what are the tradeoffs?_**

For our discussion until now, a group of $n$ parties achieved consensus among themselves. A closely related problem is the consensus requirement in a state machine replication (SMR) system. A replicated service takes multiple requests from clients and provides clients with an interface of a single non-faulty server, i.e., it provides clients with the same totally ordered sequence of values. Internally, the replicated service uses multiple servers, also called replicas, to tolerate some number of faulty servers. An SMR service provides the following guarantees:
- Safety: Any two clients learn the same sequence of values.
- Liveness: A value proposed by a client will eventually be committed.

The safety condition is similar to the agreement condition in earlier definitions whereas the liveness condition is similar to termination. Validity is imposed by requiring that only values proposed by a client is committed. **_realized the above defn does not ensure this** Consensus in an SMR setting differs from BA/BB in three ways. First, in BA, consensus is achieved by the parties themselves, whereas in SMR, a replicated service achieves consensus for clients. A client commits a value only if an honest replica has committed a value. To ensure that it has spoken to at least one honest replica, the client communicates with multiple replicas (typically, #Byzantine replicas + 1). Second, as against BB and similar to BA, a state machine replication service _cannot_ achieve safety under a Byzantine majority of replicas. A client may not be able to receive sufficient responses in this scenario. Finally, while BA/BB are typically described as one-shot consensus, SMR solves it for a sequence of values. 


**_IC_**

More recently, with the new "chain-based protocols", there are other requirements, namely, chain consistency, chain quality and chain growth, that are being considered for defining consensus. In spirit, they are similar to the above described requirements but (i) are tailored to chain-based protocols, and (ii) have a more refined notion of validity and liveness.
