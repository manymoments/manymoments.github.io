---
title: Learning in State Machine Replication
date: 2020-09-26 02:30:00 -11:00
published: false
---

A State Machine Replication system needs to do roughly three things (in a fault-tolerant manner): (1) decide on commands; (2) learn about decided commands; (3) execute decided commands. In this post, we provide an overview of the *learning* part of SMR. Most of the ideas of this post appear in [PBFT](https://www.microsoft.com/en-us/research/wp-content/uploads/2017/01/thesis-mcastro.pdf) and are extended here to the case where digital signatures are used.

Let's start by saying that *learning* decisions in distributed computing has many manifestations, sometimes learning is simply called *reading*, and sometimes its referred to as *state transfer*. We will explain these keywords below.

## Learning in a single-shot consensus system

In many situations, a non-faulty replica may have missed the decision. So the consensus algorithm already agreed on a value. Now a replica simply wants to *read* or *learn* the decision value. How can it do this?

- In the Omission failure (non-Byzantine) setting:

1. If we have uniform consensus, it's enough to ask $f+1$ replicas. A replica that is asked returns the decision value it knows about. The asking replica simply uses the first response of a decision value. 

2. If we have non-uniform consensus, then ask $2f+1$ replicas and wait for at least $f+1$ replica to send the same decision value.  

- In the Byzantine failure setting:

1. if the decision has a verifiable certificate, then again its enough to ask $f+1$ replica and use the first response whole certificate is valid.

2. If decisions don't carry a certificate, then like the non-uniform case above, ask $2f+1$ replicas and wait for at least $f+1$ replica to send the same decision value. This is what PBFT does.

## Can you learn?

Note that there is a gap between the time the first replica decides and the time when learning can occur (at least f+1 non-faulty have decided). 


## Learning in a multi-shot consensus system

A State Machine Replication system makes a *sequence* $c_1,c_2,c_3,\dots$ of decisions. In such a multi-shot consensus protocol, we will call the $i$th decision in the sequence: *slot $i$*. In the basic version of such systems, the decision for slot $i+1$ is done only after the decision for slot $i$. More generally, there is often some active window $x$, such that the decision for slot $i+x$ can only be made after the decision for slot $i$ is done. Even more generally, there may be some periodic *checkpoint* that is done every $y<x$ slots (often $y=x/2)$ and the active window is all the $x$ from the latest checkpoint (this is what PBFT does). We will expand on checkpoints in the next section.

For now its enough to assume that each replica maintains the *latest consecutive decided slot*. If this value is $l$ it means that the replica has locally decided on all slots from 1 to $l$ but slot $l+1$ has not been locally decided yet. 

If a replica wants to catch up and *learn* about on all the decided slots, what should it do?

Clearly, it can just try to learn each slot independently but how will it learn which slots are decided and which are not?

- In a uniform consensus setting or a Byzantine failure setting with commit certificates, the learning party can ask $f+1$ other replicas for the *last consecutively decide slot*. The asking party can then take the minimum value $m$ out of the $f+1$ responses. It can know for sure that decisions from 1 to $m$ have been decided by enough replica and learning will succeed.

- In a non-uniform consensus or Byzantine failure setting without certificates, the learning party can ask $2f+1$ other replicas for the *last consecutively decide slot*. The asking party can then take the minimum value $m$ such that at least $f+1$ replicas say that their last consecutively decide slot is *at least* $m$.


Even when certificates are used, if you want your learning (reads) to be linearizable, then in an asynchronous setting you need to read from $2f+1$ replicas and then take the certified value that appears in at least $f+1$ replicas, also see [section 5.1.3 in PBFT](https://www.microsoft.com/en-us/research/wp-content/uploads/2017/01/thesis-mcastro.pdf).

## Learning with Checkpoints

When a Replicated State Machine creates periodic checkpoints it allows a replica to catchup by comparing its state to the latest checkpoint and then add only the latest updates. This is similar to the restore from snapshot backup vs restore from an incremental backup.

A learning replica can now (1) learn the lastest checkpoint; then (2) update to the latest checkpoint; then (3) update the decisions in the active window.

Step (1) is a learning query, and step (3) is similar to the learning described in the previous section. For step (2), we can use a specialized protocol for state transfer. For example, one can use anti-entropy via a Merkle tree to learn the missing pieces of the latest checkpoint. See [section 5.3 in PBFT](https://www.microsoft.com/en-us/research/wp-content/uploads/2017/01/thesis-mcastro.pdf) and also [Bessani etal](https://www.usenix.org/system/files/conference/atc13/atc13-bessani.pdf). 

## Learning complexity, optimization, and denial of service protection

In a naive of learning, each faulty replica can ask each non-faulty replica for the missing decision. This would lead to a  $O(n^2 M)$ total word complexity for a decision of length $M$. Let's cover two important optimizations:

1. Instead of asking the decision from $f+1$ replicas, the asking replica can ask the decision from one replica and ask the [cryptographic hash](https://decentralizedthoughts.github.io/2020-08-28-what-is-a-cryptographic-hash-function/) of the decision from the remaining $f$ replicas. Modeling the size of the hash as a word, this reduces the total word complexity to $O(n^2 + n M)$. The problem with this approach is that a malicious asker can ask for the decision value from more than one replica. So the worst-case word complexity could again reach $O(n^2 M)$.

2. To solve the denial of service attack, instead of sending the decision, we can use [error correction codes](https://users.ece.cmu.edu/~jwylie/pubs/CMU-PDL-03-104.pdf) to split the decision value to $O(m/n)$ shares. Each non-faulty party will send its share to all parties. So the total word complexity is just $O(M/n)$ times $O(n^2)$ which is $O(n M)$ (where the leading constant is at least 3).



