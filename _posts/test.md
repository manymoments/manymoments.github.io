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

In more detail, messages in the protocol are signature chains and have the form $(v, p_1, \sigma_{p_1}, p_2, \sigma_{p_2}, \ldots, p_j, \sigma_{p_j})$. This means that the original message is $v$. It was signed by $p_1$ and the resulting signature is $\sigma_{p_1}$. The message $(v, p_1, \sigma_{p_1})$ was signed by $p_2$ and the resulting signature is $\sigma_{p_2}$. And so on.

A message received by party $p_i$ in round $j$ is said to be valid if
- The first signer of the signature chain is the designated dealer
- All signers are distinct
- $p_i$ is not in the signature chain
- All signatures are valid
- The signature chain has length $j$


The protocol:
```

Round 1: The dealer $p_1$ signs $v$ and sends (v, $p_1$, \sigma_{p_1}) to all parties

Round $j \in \[2, n-1\]$: When a party $p_i$ receives a round $j-1$ valid message $(v, p_1, \sigma_{p_1}, p_2, \sigma_{p_2}, \ldots, p_{j-1}, \sigma_{p_{j-1}})$ at the end of round $j-1$, it signs this message and sends $(v, p_1, \sigma_{p_1}, p_2, \sigma_{p_2}, \ldots, p_{j-1}, \sigma_{p_{j-1}}, p_{j}, \sigma_{p_{j}})$ it to all parties.
```
----------------
```
// Party i decision rule

Decision at the end of round f+1:
  Let V be the set of values that i received some signature chain on.
  If |V|=0 or |V|>1, then decide null
  Otherwise decide v, where V={v}.
```


Termination trivial. For Validity, note that all parties will have a 1-signature chain on $v$ and due to unforgeability, no signature chain on $
\neq v$ will exist.


For agreement...

complexity measures


open: reduce to $O(n^2)$ words against adaptive. Mention trivial to get $O(n \log n)$ for static (with error).
