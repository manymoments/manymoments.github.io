---
title: Dolev Strong Broadcast
date: 2019-12-11 09:05:00 -08:00
published: false
tags:
- dist101
author: 
---

In this post, we show a classic result on authenticated broadcast against a Byzantine adversary:

**Theorem ([Dolev Strong \[1983\]](https://www.cse.huji.ac.il/~dolev/pubs/authenticated.pdf)):** *there exists an authenticated protocol for solving [broadcast](https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/), against any adversary controlling $t<n$ out of $n$ parties, in $t+1$ rounds, using $O(nt^2)$ words*

The protocol ensures that if a value sent by the leader is received by some honest party, it will be received by all honest parties. Thus, at the end of the protocol, all honest parties would receive the same set of values and deterministically agree on the same value.

Let us try to put the above intuition in a protocol.

```
// Attempt 1:

Round 1: Leader (party 1) sends message $(v, \sigma_1)$ to all parties
Round 2: Every party sends the message received from the leader and sends it to all parties.
Round 3: If party i receives only a single value $v$, output $v$. If it receives more than one value, output a default value $\bot$.
```

Observe that if a single honest party receives a value at the beginning of round 2, all honest parties will receive it at the beginning of round 3. Though, safety will break if a Byzantine party receives a value $v'$ from a (Byzantine) leader at the beginning of rounds 2 and it forwards $v'$ to only a single honest party?

A simple fix to the above protocol is to add one more round of all-to-all exchanges.
```
// Attempt 2:

Round 1: Leader (party 1) sends message $(v, \sigma_1)$ to all parties
Round 2: Every party sends the message received from the leader and sends it to all parties.
Round 3: Every party sends the message received from another party and sends it to all parties. A party sends at most two messages to all other parties.
Round 4: If party i receives only a single value $v$, output $v$. If it receives more than one value, output a default value $\bot$.
```

Observe that the above "fix" does not really fix the problem. The same attack from round 2 can be carried out in round 3. How do we fix this? The Dolev-Strong protocols uses *signatures chains* to fix it. The chains have two essential properties that allows honest parties to agree on a value at the end of $t+1$ rounds.
- A chain consists of signatures from distinct parties. So, if we have a chain of length $t+1$, it will certainly contain an honest signature. This honest party can send the value to everyone.
- A round $i$ chain will be of length $i$. This is to disallow a Byzantine party to create a Byzantine-only chain of length $< t$ and send it to honest parties at round $t+1$. 

In more detail, messages in the protocol are signature chains where a *k-signature chain* is defined recursively as follows:

A *1-signature chain* on $v$ is a pair $(v, sign(v,1))$. For $k>1$, a *k-signature chain* on $v$ is a pair $(m, sign (m,j))$ where $m$ is a $(k-1)$-signature chain on $v$ that *does not* contain a signature from $j$. In other words, a message (signature chain) received by party $j$ in round $k$ is said to be valid if
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
// Party i

For a message m arriving at round j:
  if party i has sent less than two messages; and
    if m is a valid (j-1)-signature chain on $v$ that does not contain a signature from i, then
      send <m,sign(m,i)> to all
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

complexity measures


open: reduce to $O(n^2)$ words against adaptive. Mention trivial to get $O(n \log n)$ for static (with error).
