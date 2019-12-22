---
title: Dolev Strong Authenticated Broadcast
date: 2019-12-22 09:05:00 -08:00
tags:
- dist101
author: Ittai Abraham, Kartik Nayak
---

This post is about the classic result from 1983 on authenticated broadcast against a Byzantine adversary:

**Theorem ([Dolev Strong \[1983\]](https://www.cse.huji.ac.il/~dolev/pubs/authenticated.pdf)):** *there exists an authenticated protocol for solving broadcast, against any adversary controlling $t<n$ out of $n$ parties, in $t+1$ rounds, using $O(n^2t)$ words*


Recall [Broadcast properties](https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/): (1) *Termination* -  all honest decide and terminate; (2) *Validity* - if the leader is honest, its value is the decision value; and (3) *Agreement* - all honest decide the same value.


The Dolev Strong protocol works in the synchronous and *authentiacted* setting. In this setting we assume a PKI infrastructure. We denote the signature of message $m$ by party $i$ as $sign(m,i)$. We assume signature unforgeability.

Lets try to obtain the following: if a value sent by the leader is received by some honest party, it will be received by all honest parties. Thus, at the end of the protocol, all honest parties would receive the same set of values and deterministically agree on the same value.

Here is an attempt to put the above intuition in a protocol that can handle one malicious party:

```
// Attempt 1:

Round 1: Leader (party 1) sends message <v, sign(v,1)> to all parties
Round 2: If Party i receives <v, sign(v,1)> from leader, then
          sends <v, sign(v,1)> to all.
Round 3: If party i receives only a single signed value $v$, output $v$
          If it receives more than one value, output a default value $\bot$
```

Observe: If the leader is honest then all parties will see the leader value. If the leader is Byzantine and sends its value so some honest by the end of round 1 then  all honest parties will receive it at the beginning of round 3. So does this protocol work?

No! the problem is that a malicious non-leader can invent a value that the honest leader did not send. The solution is to build a chain of signatures:


```
// Attempt 2:

Round 1: Leader (party 1) sends message <v, sign(v,1)> to all parties
Round 2: If Party i receives m=<v, sign(v,1)> from leader, then
          sends <m, sign(v,i)> to all.
Round 3: If party i receives only a single signed value $v$, output $v$
          If it receives more than one value, output a default value $\bot$
```

This protocol is indeed a Broadcast protocol resilient to 1 Byzantine failure (where "signed value" is either a signature from the leader or a signature from $i$ on a signature of the leader).

The Dolev-Strong protocol extends this approach and uses *signatures chains*. Signature chains have two essential properties that allows honest parties to agree on a value at the end of $t+1$ rounds.
- A signature chain consists of signatures from *distinct* parties. So, if we have a signature chain of length $t+1$, it will certainly contain an honest signature. This honest party can send the value to everyone.
- A round $i$ signature chain will be of length $i$. This is to disallow a Byzantine party from  creating a Byzantine-only chain of length $< t$ and send it to honest parties at round $t+1$.

In more detail, messages in the protocol are signature chains where a *k-signature chain* is defined recursively as follows:

A **1-signature chain** on $v$ is a pair $(v, sign(v,1))$.

For $k>1$, a **k-signature chain** on $v$ is a pair $(m, sign (m,j))$ where $m$ is a $(k-1)$-signature chain on $v$ that *does not* contain a signature from $j$. In other words, a message (signature chain) received by party $j$ in round $k$ is said to be valid if
- The first signer of the signature chain is the leader
- All signers in the chain are distinct
- Party $j$ is not in the signature chain
- All signatures are valid
- The signature chain has length $k$


The protocol:
```
// Leader (Party 1) with input v

Round 1: send <v, sign(v,1)> to all
```

Party $i$ does the following:
```
// Party i in round j

For a message m arriving at round j:
  if party i has sent less than two messages; and
    if m is a valid (j-1)-signature chain on $v$,
      that does not contain a signature from i, then
        send <m, sign(m,i)> to all
```



```
// Party i decision rule

Decision at the end of round t+1:
  Let V be the set of values that i received some signature chain on.
  If |V|=0 or |V|>1, then decide null
  Otherwise decide v, where V={v}.
```

Now, let us argue how the protocol satisfies agreement, validity, and termination.

**Termination.** The protocol is deterministic and terminates in $t+1$ rounds.

**Validity.** For validity, observe that the (honest) leader will only sign one value and this value will be sent to all honest parties in the next round. Due to unforgeability of digital signatures, no other signature chain can exist.

**Agreement.** Observe that if an honest party receives a $k$-signature chain in round $k$, then it will send it to all honest parties in round $k+1$. This holds for all rounds except the last round, round $t+1$. But since the honest party can only receive a $t+1$-sized chain in round $t+1$ and a $t+1$-sized chain contains at least one honest party $h$, $h$ must have sent this value to all other honest parties. Thus, every value received by one honest party will be received by all other parties. (This does not hold in the case where the leader has sent more than 2 values. But the protocol ensures that all honest parties receive at least $2$ values and hence they will agree on a default value)

#### Complexity measures and Notes
Every party sends at most two values, and each value may contain $O(t)$ signatures. The total communication is $O(n^2t)$ signatures.

Here is an open question: for $t<n$, reduce communication to $o(n^3)$ against some type of adaptive adversary or perhaps show that $O(n^3)$ is required is some conditions.

Note that this protocol relies heavily on synchrony and [does not work](https://decentralizedthoughts.github.io/2019-11-02-primary-backup-for-2-servers-and-omission-failures-is-impossible/) in client-server model where the clients are passive or may be offline.

In the blockchain space, the Dolev Strong protocol is mentioned by [Spacemesh](https://spacemesh.io/byzantine-agreement-algorithms-and-dolev-strong/).

Please leave comments on [Twitter]()
