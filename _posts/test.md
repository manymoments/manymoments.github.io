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

Messages in the protocol are signature chains and have the form $(v, p_1, \sigma_{p_1}, p_2, \sigma_{p_2}, \ldots, p_j, \sigma_{p_j})$. This means that the original message is $v$. It was signed by $p_1$ and the resulting signature is $\sigma_{p_1}$. The message $(v, p_1, \sigma_{p_1})$ was signed by $p_2$ and the resulting signature is $\sigma_{p_2}$. And so on.

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
