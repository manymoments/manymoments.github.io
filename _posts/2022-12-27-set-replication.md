---
title: Set Replication - fault tolerance without total ordering
date: 2022-12-27 04:00:00 -05:00
tags:
- dist101
author: Ittai Abraham
---

While state machine replication is the gold standard for implementing any (public) ideal functionality, its power comes at the cost of needing to totally order all transactions and as a consequence solve (Byzantine) agreement. In some cases this overhead is unnecessary.

In the non-byzantine setting, the *fundamental* observation that sometimes a weaker problem than consensus needs to be solved goes back to the foundational work of [Lamport 2005](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/tr-2005-33.pdf):

> Consensus has been regarded as the fundamental problem that must be solved to implement a fault-tolerant distributed system. However, only a weaker problem than traditional consensus need be solved. We generalize the consensus problem to include both traditional consensus and this weaker version. --[Generalized Consensus and Paxos, 2005](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/tr-2005-33.pdf)

There is considerable research in ways to relax total ordering requirements to gain better performance. For example, see [EPaxos](https://www.cs.cmu.edu/~dga/papers/epaxos-sosp2013.pdf) (and also [EPaxos Revisited](https://www.usenix.org/conference/nsdi21/presentation/tollman)). The first work that aimed to relax the total order requirements in the blockchain space is by [Lewenberg, Sompolinsky, and Zohar, 2015](https://fc15.ifca.ai/preproceedings/paper_101.pdf) and it’s follow-up work [Specture, 2016](https://eprint.iacr.org/2016/1159.pdf). See this post on [DAG-based protocols](https://decentralizedthoughts.github.io/2022-06-28-DAG-meets-BFT/) for advances in recent years and how DAG-based protocols are emerging as a powerful tool for getting better throughput mempools and BFT.

It turns out that in many natural use cases, in particular the canonical simple token payment use case, do not need total ordering. As a concrete example, suppose Alice is transferring a token to Bob and Carol is transferring a token to Dan. There is no need to totally order these two transactions. 

This approach is taken by [FastPay](https://arxiv.org/pdf/2003.11506.pdf), [Guerraoui et al, 2019](https://arxiv.org/pdf/1906.05574), [Sliwinski and Wattenhofer, 2019](https://arxiv.org/abs/1909.10926), applied to privacy preserving transactions (see [UTT](https://eprint.iacr.org/2022/452.pdf) and [Zef](https://eprint.iacr.org/2022/083.pdf)), planned to be used in the [Sui platform](https://github.com/MystenLabs/sui/blob/main/doc/paper/sui.pdf) and in [Linera](https://linera.io/whitepaper).

In a totally ordered system, clients write to and read from the same *ordered log* of transactions. Here we just want to write to and read from the same *unordered set* of transactions. Let's start with a refresh of *log replication* and then define *set replication*.

### Reminder: definition of Log Replication

Recall the definition of [log replication](https://decentralizedthoughts.github.io/2022-11-19-from-single-shot-to-smr/):
Clients and $n$ servers. Clients can make two types of requests: ```read``` which returns a **log of values** (or $\bot$ for the empty log)  as a response; and ```write(v)``` which gets an input value and also returns a response that is a log of values.

Clients can have multiple input values at different times. 

**Termination**: If a non-faulty client issues a *request* then it eventually receives a *response*.

**Agreement**: Any two requests return logs then one is a prefix of the other.

**Validity**: Each value in the log can be uniquely mapped to a valid write request.

**Correctness**: For a write request with value $v$, its response, and any response from a request that started after this write response, returns a log of values that includes $v$.

We simply **remove the agreement property** to get ***set replication***.

### Definition of Set Replication

Clients and $n$ servers. Clients can make two types of requests: ```read``` which returns a **set of values** (or $\bot$ for the empty set)  as a response; and ```write(v)``` which gets an input value and also returns a response that is a set of values.

**Termination**: If a non-faulty client issues a valid *request* then it eventually receives a *response*.

**Validity**: Each value in the set can be uniquely mapped to a valid write request.

**Correctness**: For a write request with value $v$, its response, and any response from a request that started after this write response, returns a set of values that includes $v$.

### Discussion: no difference for a single writer

Observe that when there is a just a single writer client there is no difference between log replication and set replication - the (single writer) client can sequentially submit commands by adding a sequence number to its operations and implement a log of its commands on top of the set abstraction.


In fact set replication is solving multi-shot consensus for single writer objects (see [Guerraoui et al, 2019](https://arxiv.org/pdf/1906.05574)).


Moreover, the space is partitioned into objects, and each object can be written to by a single client (the owner of the private key associated with the object's public key) then multiple clients can transact in parallel as long as each one is writing to a different object.

The difference between log replication and set replication can be seen when there are two or more writers. For example if two writers need to decide which one wrote first (say they both want to swap money on an [AMM](https://arxiv.org/pdf/2102.11350.pdf)) then log replication will provide an ordering of these two transactions but set replication cannot do this. 


### Implementing Set Replication via Locked Broadcast

Log replication requires solving multi-shot agreement and even one agreement may take $f+1$ rounds in the worst case. In previous posts [we showed](https://decentralizedthoughts.github.io/2022-11-20-pbft-via-locked-braodcast/) how to solve [log replication](https://decentralizedthoughts.github.io/2022-11-24-two-round-HS/) via a repeated application of [locked broadcast](https://decentralizedthoughts.github.io/2022-09-10-provable-broadcast/).



Set replication is an easier problem. It can be implemented as a single instance of *locked broadcast*:

```
Write(v): 
    client drives LockedBroadcast(v)

Read():
    client queries all the replicas
    replicas respond with the set all values that have a lock-certificate
    client waits for n-f responses and takes the union
```




Writing a value is just running a single locked broadcast. Reading all values is just reading all the lock certificates. Note that both Write and Read take constant rounds and work in asynchrony!




### Analysis

Recall that Locked Broadcast produces a *delivery-certificate*, such that $n-2f$ honest parties received a *lock-certificate* for this value, and no other value can have a *lock-certificate*. Moreover, the value in the certificate has  *External-Validity*.

The analysis follows directly from the locked broadcast properties: Termination for Write operation follows from the termination of locked broadcast for non-faulty client. Termination for Read operation from waiting for just $n-f$ parties. Validity follows from the fact that write requests are validated and signed by the client. Finally, Correctness follows from the *Unique-Lock-Availability* property and from quorum intersection of any Read operation.


### From set replication to UTXO replication.

A simple example for using set replication is to maintain a *UTXO* set (a set of unspent transactions). For a simple UTXO system, the system maintains a set of tokens where each token is a pair $tok=(id,pk)$: a unique identifier and a public key (here we omit using denominations for simplicity). A valid write value is of the form $Tx=(tok,tok', sig, lock{-}cert)$ where sig is a signature on $(tok,tok')$ that verifies under the public key $tok.pk$ and the $lock{-}cert$ is a proof that $tok$ is a valid token. The identifier $tok.id$ of the token is used to fix the session id of the locked broadcast instance (to avoid double spending). The External validity check of the lock broadcast checks the validity of the signature.

This means that each token is essentially a write-once object. A transaction marks an active token as spent and creates a new active token in the UTXO set.

Real systems also need to implement more efficient read operations via indexing and times tamping, add check-pointing and garbage collection. Reads can also be made linearizable by adding an additional round. It is also possible to carefully *combine* log replication with set replication to get the best of both worlds (fulfilling Lamport’s vision). We plan to cover this in future posts.


### Set Replication and Data Availability

Set replication is a formal way to define some of the requirements that are often informally called **data availability** in the blockchain space.

> Data availability is the guarantee that the block proposer published all transaction data for a block and that the transaction data is available to other network participants.  --[ethereum](https://ethereum.org/en/developers/docs/data-availability/)

In later posts, we will discuss how to obtain better guarantees for set replication. In particular, how lightweight clients can efficiently **audit** a set of replicas and punish them for misbehaving (claiming to store the set but censoring read requests). See [Al-Bassam, Sonnino, and Buterin, 2019](https://arxiv.org/abs/1809.09044) and stay tuned for future posts.

### Acknowledgments

Many thanks to Adithya Baht and Kartik Nayak for insightful comments.



Your thoughts on [Twitter](https://twitter.com/ittaia/status/1607674657397694465?s=61&t=5e3KM2Kmf3CDaCNUuFLing).