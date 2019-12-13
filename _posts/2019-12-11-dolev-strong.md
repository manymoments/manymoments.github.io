---
title: Dolev Strong Broadcast
date: 2019-12-11 09:05:00 -08:00
published: false
tags:
- dist101
author: 
---

In this post to show a classic result on Authenticated Broadcast against a Byzantine adversary:

**Theorem ([Dolev Strong \[1983\]](https://www.cse.huji.ac.il/~dolev/pubs/authenticated.pdf)):** *there exists an authenticated protocol for solving [broadcast](https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/), against any adversary controlling $t<n$ out of $n$ parties, in $t+1$ rounds, using $O(nt^2)$ words*


Recall that in the Broadcast Problem there is a designated party, often called the leader (or dealer) that has some input $v$ from a domain $V$. A protocol that solves Broadcast must have the following properties.

**(agreement):** no two honest parties *decide* on different values.

**(validity):** if the leader is honest then $v$ must be the decision value.

**(termination):** all honest nodes must eventually *decide* on a value in $V$ and terminate.


Lets assume there are $n$ parties, and party $i$ is allows to sign a message $m$ as $sign(m,1)$. Any party can verify this signature is valid and no party $j \neq i$ can forge such a signature.

We now define the notion of a *k-signature chain* recursively:

A *1-signature chain* on $v$ is a pair $(v, sign(v,1))$. For $k>1$, a *k-signature chain* on $v$ is a pair $(m, sign (m,j))$ where $m$ is a $(k-1)$-signature chain on $v$ that *does not* contain a signature from $j$.



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
