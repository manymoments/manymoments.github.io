---
title: 'Phase-King through the lens of Gradecast: A simple unauthenticated synchronous
  Byzantine Agreement protocol'
date: 2022-06-09 07:11:00 -04:00
tags:
- dist101
author: Ittai Abraham and Andrew Lewis-Pye
---

In this post we overview a **simple** unauthenticated synchronous Byzantine Agreement protocol that is based on the Phase-King protocol of [Berman, Garay, and Perry 1989-92](http://plan9.bell-labs.co/who/garay/bit.ps). We refer also to [Jonathan Katz's excellent write-up](https://www.cs.umd.edu/~jkatz/gradcrypto2/f13/BA.pdf) on this same protocol from 2013. We offer a modern approach that decomposes the Phase-King protocol into a Gradecast building block.

Phase-King has optimal resilience of $n=3t+1$, runs in asymptotically optimal $3(t+1)$ rounds (recall that $t+1$ rounds is [optimal](https://decentralizedthoughts.github.io/2019-12-15-synchrony-uncommitted-lower-bound/)) and each message contains just a few bits for a total of $O(n^3)$ messages (recall that $\Omega(n^2)$ messages are [needed](https://decentralizedthoughts.github.io/2019-08-16-byzantine-agreement-needs-quadratic-messages/) and we will show how to get it in later posts).

Each party has an input $v \in \{V\}$ and parties are ordered $P_1,\dots, P_n$. For simplicity we describe the protocol in the lock step model.

### Gradecast 

Gradecast is a key building block where each party has an input $v \in \{V\}$ and needs to output a  $value \in \{V\}$ and a $grade \in \{0, 1,2\}$ with the following properties:

**(Validity):** If all honest parties have the same input value, then all of them output this value with grade 2.
**(Knowledge of Agreement):** If an honest party outputs a value with grade 2, then all honest parties output this value.


Consider the following simple 2 round protocol: 

```
input v

Round 1: send v to all parties
Round 2: if n-t distinct parties sent b in round 1, 
                then send b to all parties
End of round 2:
    If n-t distinct parties sent b in round 2,
                then output b with grade 2
    Otherwise, if t+1 distinct parties sent b in round 2,
                then output b with grade 1
    Otherwise, output v with grade 0
```

*Proof of Validity:* At least $n-t$ parties will send the same value $v$ in round 1, hence at least $n-t$ parties will send $v$ in round 2, hence all honest parties output value $v$ with grade 2.

To prove the Knowledge of Agreement property, we first prove a Weak Agreement property:

**(Weak Agreement):** No two honest parties send conflicting round 2 messages.
*Proof of Weak Agreement:* It cannot be the case that one honest party sees $n-t$ round 1 messages for $v$ and another honest party sees $n-t$ messages for $v' \neq v$ because any two sets of $n-t$ parties have least $t+1$ parties in the intersection. At least one of those must be honest, but honest parties send only one value in round 1. 

*Proof of Knowledge of Agreement:* If an honest party has grade 2, then it sees at least $n-t$ round 2 messages, hence all honest parties see at least $n-2t=t+1$ round 2 messages. Moreover, from the Weak Agreement property, we know that there cannot be $t+1$ round 2 messages for any other value.


### The Phase-King protocol in the lens of Gradecast

In this protocol each party has an input $v \in \{V\}$ and needs to decide on a value such that:
**(Validity):** If all honest parties have the same input value, then all of them decide this value.
**(Agreement):** All honest decide on the same value.

Using Gradecast the Phase-King protocol is rather simple. We consider $t+1$ phases, each of which consists of three rounds. In the first two rounds of each phase $i$, we run an instance of Gradecast. In the last round of phase $i$, we consider $P_i$ to be 'king'. The role of the king is to establish agreement in the case that honest parties are split between different values. The king sends their value to all parties, who change their value to $P_i$ unless their grade is 2: 


```
input v[0]

For i=1 to t+1:
    rounds 3i-2,3i-1:
        (v[i], grade[i]) := gradecast(v[i-1])
    round 3i:
        party P_i: send v[i] to all parties
        if grade[i] < 2 then v[i] := party P_i's reported value
        
End of round 3(t+1):
    Decide v[t+1]
```

*Proof of Validity:* This follows from the Validity property of Gradecast and the fact that, in each phase, the grade will be 2, meaning that the king's value will be ignored.

*Proof of Agreement:* Consider the first phase with an honest king. From the Knowledge of Agreement property, all honest parties will either switch to the king's value, or already have that value with grade 2.

This concludes the proof for the Phase-King protocol. In the next post, we will show how to use it recursively to reduce the bit complexity to the optimal $O(n^2)$.


Your thoughts/comments on [Twitter](...).