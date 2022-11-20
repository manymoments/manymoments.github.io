---
title: On PBFT from Locked Broadcast
date: 2022-11-20 04:00:00 -05:00
tags:
- dist101
author: Ittai Abraham
---

We describe a variation of the authenticated version of [PBFT](https://pmg.csail.mit.edu/papers/osdi99.pdf) using [Locked Broadcast](https://decentralizedthoughts.github.io/2022-09-10-provable-broadcast/) that follows a similar path as our previous post on [Paxos using Recoverable Broadcast](https://decentralizedthoughts.github.io/2022-11-04-paxos-via-recoverable-broadcast/). I call this protocol **linear PBFT** and variants of it are used by [SBFT](https://arxiv.org/pdf/1804.01626.pdf) and [Tusk](https://arxiv.org/pdf/2105.11827.pdf). A later post will show how to extend this approach for [Two Round HotStuff](https://arxiv.org/pdf/1803.05069v1.pdf) using [Locked Broadcast](https://decentralizedthoughts.github.io/2022-09-10-provable-broadcast/) and [Three Round HotStuff](https://arxiv.org/pdf/1803.05069.pdf) using [Keyed Broadcast](https://decentralizedthoughts.github.io/2022-09-10-provable-broadcast/).


The model is [Partial Synchrony](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) with $f<n/3$ [Byzantine failures](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) and the goal is *consensus with external validity* (see below for exact details). 

As with Paxos, we approach PBFT by starting with two major simplifications:

1. Use a *simple revolving primary* strategy assuming perfectly synchronized clocks. This approach follows Section 6 of [Two Round HotStuff](https://arxiv.org/pdf/1803.05069v1.pdf).
2. Focus on a *single-shot* consensus while PBFT is designed as a full State Machine Replication system.


## View-based protocol with simple rotating primary

The protocol progresses in **views**. The first view is 1 and view $v+1$ follows view $v$. Each view has a designated **primary** party. For fairness, parties rotate the role of the primary. For simplicity, the primary of view $v$ is party $v \mod n$. 

Clocks are synchronized, and $\Delta$ is known, so set view $v$ to be the time interval $[v(10 \Delta),(v+1)(10 \Delta))$. In other words, each $10\Delta$ clock ticks each party triggers a **view change** and increments the view by one. Since clocks are assumed to be perfectly synchronized, all parties move in and out of each view in complete synchrony.


## Single-shot Consensus with External Validity

There is some *External Validity* Boolean function ($EV_{\text{consensus}}$) that is provided to each party. $EV$ takes as input a value $v$ and a proof $proof$. If $EV(v, proof)=1$ we say that $v$ is *externally valid*. A simple example of external validity is a check that the value is signed by the client that controls the asset. External validity is based on the framework of [Cachin, Kursawe, Petzold, and Shoup, 2001](https://www.iacr.org/archive/crypto2001/21390524.pdf). 

In this setting, each party has some externally valid *input values* and the goal is to *output a single external valid value (and its proof)* with the following three properties:

**Agreement**: all non-faulty parties output the same value. 

**Termination**: all non-faulty parties eventually output a (value, proof) pair and terminate. 

**External Validity**: the output is externally valid. 


Denote by $EV_{\text{consensus}}$ the external validity function that is given as input to the consenesu instance.

Linear PBFT is decomposed to use two building blocks: *Locked Broadcast* and *Recover Max Lock*. The exposition will start top-down: defining the high-level protocol first and detailing the building blocks later. 

# Linear PBFT via Locked Broadcast and Recover Max Lock

Every $10 \Delta$ parties change the view and rotate the primary. Clocks are perfectly synchronized so this change of view is perfectly synchronized as well.

In view 1 the primary does a locked broadcast ($LB$), with its validated input value and the view (which is 1). The delivery-certificate output of the Locked Broadcast is a consensus decision!


```Linear PBFT consensus protocol```: 

For view 1, the primary of view 1 with input $val, val{-}proof$: 
```
LB (1, val, val-proof)
```

Once a primary obtains a delivery-certificate it sends it to all parties so they can also output a value. Recall that a delivery-certificate is valid if it has $n-f$ distinct signatures.

```
Upon delivery-certificate dc for (v,x)
    send (v, x, dc) to all

All parties:

Upon valid delivery-certificate dc for (v,x)
    output x    
```


As in Paxos, what if the first Primary is faulty and only some parties output (but not all)? For agreement to hold later primaries cannot output delivery certificates for other values! For safety in Linear PBFT, later primaries will not even be able to generate lock-certificates for other values. 

Similar to Paxos, the Recover Max Lock protocol ($RML$) will return the highest lock-certificate it sees. Unlike Paxos, $RML$ will also return a ```proof```. We detail what this proof contains later, intuitively it contains a way to validate that the primary did indeed choose the highest lock-certificate it saw out of a set of $n-f$ distinct lock-certificated it received.

For view $v>1$, the primary of view $v$ with input $val, val-proof$:
```
p, p-proof := RML(v)

if p = bot then 
   LB (v, val, val-proof, p-proof)
otherwise 
   LB (v, p, p-proof)

```

In words, the primary first tries to recover the lock-certificate with the maximal view. If no lock-certificate is seen, the primary is free to choose its own externally valid input, but even in that case, it adds the proof from the Recover Max Lock protocol. Otherwise, it proposes the output value from the Recover Max Lock along with its proof.  Note the deep similarity to the Paxos protocol variant of the [previous post](https://decentralizedthoughts.github.io/2022-11-04-paxos-via-recoverable-broadcast/).

Much of the magic of Byzantine Fault tolerance is hidden in the Locked Broadcast abstraction, its external validity $EV_{\text{LB}}$ function definition, and the Recover Max Lock protocol. Let's detail these one after the other:


### Recover Max Lock

The ```RML(v)``` protocol for view $v$ finds the highest lock-certificate and returns not only the associated value but also the $n-f$ responses that allows one to verify that this is indeed the highest lock-certificate among some set of $n-f$ valid responses. 

```
RML(v):

Party i upon start of view v
    send <echoed-max(v, v', p, LC(v',p) )>_i 
        of the highest view v' it has a lock-certificate LC(v',p)
    or send <echoed-max(v, bot)>_i 
        It does not have any lock-certificate

Primary waits for n-f responses <echoed-max(v,*)> 
    if all are bot then output (bot, responses)
    otherwise, output (proposal, responses) 
        where proposal is associated with the highest view in responses
```

### Locked Broadcast 

[Locked broadcast](https://decentralizedthoughts.github.io/2022-09-10-provable-broadcast/) is the application of two provable broadcasts with an *external validity function*, $EV_{\text{LB}}$, which obtains the following properties:

* **Termination**: If the sender is honest and has an *externally valid* input $v$, then after a constant number of rounds the sender will obtain a *delivery-certificate* of $v$. Note that the Termination property requires just the sender to hold the certificate.
* **Uniqueness**: There can be at most one value that obtains a *delivery-certificate*. So there cannot be two *delivery-certificates* with different values.
* **External Validity**: If there is a *delivery-certificate* on value $v$ and proof $proof$ then $v$ is *externally valid*. So $EV_{\text{LB}}(v, proof)=1$.
* **Unique-Lock-Availability**: If a  *delivery-certificate* exists for $v$ then there can only exist a *lock-certificate* for $v$ and there are at least $n-2f\geq f+1$ honest parties that hold this *lock-certificate*.

Note that Locked Broadcast needs to define an external validity function $EV_{\text{LB}}$, which controls what outputs are allowed. $EV_{\text{LB}}$ is different from $EV_{\text{consensus}}$ (the external validity function of the underlying consensus protocol). As you may expect, $EV_{\text{LB}}$ checks the validity of the $RML(v)$ protocol and uses $EV_{\text{consensus}}:

### External Validity for the Locked Broadcast of Linear PBFT

Define $EV_{\text{LB}}$:

For view 1, just use the external validity function of the consensus protocol $EV_{\text{consensus}}$. So $EV_{\text{LB}}(1, val, val-proof)= EV_{\text{consensus}}(val, val-proof)$.

For view $v>1$ there are two cases:

1. Given a 4-tuple $(v, val, val{-}proof, p{-}proof)$, $p{-}proof$ consists of $n-f$ distinct valid $RML(v)$ responses:
    1. All $n-f$ of the $RML(v)$ responses have value $\bot$.
    2. Output true if $EV_{\text{consensus}}(val, val-proof)=1$.
2. Otherwise, given a 3-tuple $(v, p, p{-}proof)$, check that $p{-}proof$ consists of $n-f$ distinct valid $RML(v)$ responses:
    1. An $RML(v)$ message that contains ```<echoed-max(v, v', p, LC(v') )>_i``` is valid if the lock-certificate $LC(v')$ is valid for view $v'$ and the value associated with $LC(v')$ is $p$.
    2. Let $v^+, LC_{v^+}, p^+$ be the valid ```<echoed-max(v, * )>_i``` response with the highest view $v^+$. 
    3. Output true of $p=p^+$.


In words, either check all parties saw no lock-certificate and the new value is externally valid for consensus, or that the primary proposes the value that is associated with the highest lock-certificate in the valid responses set.



This completes the description of the consensus protocol. The protocol is detailed in 4 places: the linear PBFT consensus protocol, the recover max lock protocol, the locked broadcast protocol, and finally the external validity of the locked broadcast. Let's prove that the three properties of consensus hold:


### Agreement (Safety)

**Safety Lemma**: Let $v^{\star}$ be the first view with a lock-certificate on $(v^\star, x)$, then for any view $v \geq v^\star$ if a lock-certificate forms for view $v$, must be with value $x$.

*Exercise: prove the Agreement property follows from Lemma above.*

Let's prove the safety lemma, which is the essence of PBFT.

*Proof of Safety Lemma*: consider the set $S$ (for Sentinels) of **non-faulty** parties among the $n-f$ parties that sent a lock-certificate in the second round of locked broadcast of view $v^\star$. Note that $|S| \geq n-2f \geq f+1$. 

Induction statement: for any view $v\geq v^\star$:
1. If there is a lock-certificate for view $v$ then it has value $x$.
2. For each party in $S$, in view $v$, the lock-certificate with its highest view $v' \leq v$ is such that: 
    1. $v' \geq v^\star$; and
    2. The value of the lock-certificate is $x$.

For the base case, $v=v^\star$ (1.) follows from the *Uniqueness* property of locked broadcast of view $v^*$ and (2.) follows from the *Unique-Lock-Availability* property of locked broadcast.

Now suppose the induction statement holds for all views $v^\star \leq v$ and consider view $v+1$:

Use the *External Validity* property of locked broadcast and the definition of $EV_{\text{LB}}$ above: to form a lock-certificate, the primary needs $n-2f$ non-faulty parties to view its proposal as valid. 

Observe that by definition of $EV_{\text{LB}}$ for view $v+1$: any valid $p{-}proof$ must include a lock-certificate sent by some member of $S$ for view $v+1$. This is true because $p{-}proof$ must include $n-f$ distinct and valid lock-certificates. 

Use the induction hypothesis on views all views $v^\star \leq v$: from (2.) and the above argument, $p{-}proof$ must contain a lock-certificate of view at least $v^* $ and value $x$. From (1.) any lock-certificate in $p{-}proof$ is either of view $< v^*$ or of value $x$. Hence the value associated with the maximal view lock-certificate in $p{-}proof$ must be $x$. This concludes the proof of (1.) for view $v+1$.

Given (1.) for view $v+1$, (2.) follows immediately, the only thing that may happen is that some members is $S$ see a lock-certificate for view $v+1$ and update their highest lock-certificate. The value will remain $x$. This concludes the proof of the Safety Lemma.

### Liveness

Consider the view $v^+$ with the *first* non-faulty Primary that started after GST at time $T$. Due to clock synchronization and being after GST, then on or before time $T+ \Delta$ the primary will receive ```<echoed-max(v+,*)>``` from all non-faulty parties (at least $n-f$ parties). Hence the non-faulty will send a value $LB(v^+, *)$ that (1) will arrive at all non-faulty parties on or before time $T+2\Delta$ and (2) will have a $proof$ that is valid. Hence all non-faulty parties will pass the $EV_{v^+}$ condition (they are still in view $v^+$). So the primary will obtain a delivery-certificate on or before time $T+5\Delta$ (locked broadcast takes at most $4 \Delta$) and all non-faulty will decide on or before time $T+6\Delta$.

This concludes the proof of Liveness.


### Termination


Add the following *termination gadget*:

```
If the consensus protocol outputs x and valid delivery-certificate dc for x
    Send <decide, x, dc> to all
    Terminate
    
Upon receiving a valid <decide, x, dc> 
    Send <decide, x, x-dc> to all
    Terminate
``` 

*Exercise: if a non-faulty party terminates, then eventually all non-faulty parties terminate.*



### External Validity

External validity is proven by induction on the chain of lock-certificates. For a lock-certificate that is formed with an $EV_{\text{LB}}$ check that had no prior lock, external validity is part of the $EV_{\text{LB}}$ function check. For a lock-certificate that is formed with $EV_{\text{LB}}$ check that checks a previous lock-certificate, then this new lock certificate must use the same value as the previous lock-certificate. Hence an induction argument shows that any lock-certificate must have an externally valid value.


### Time and Message Complexity

The time and number of messages before GST can be both unbounded, so we measure the time and message complexity after GST.

**Time complexity**:  since the liveness proof requires waits for the first non-faulty primary after GST this may take an interrupted view, then in the worst case this may require $f$ views of faulty primaries, then a good view in the worst case. So all parties will output a value in at most $(f+2)10 \Delta = O(f \Delta)$ time after GST. This is asymptotically optimal but not optimized.


**Message Complexity**: since each view has a linear message exchange, the total number of messages sent after GST is $O(f \times n) = O(n^2)$. This is asymptotically optimal. 

However, the number of bits in each message is large and not optimal. The size of a lock-certificate or a delivery-certificate is $O(n)$ signatures. More worrisome, the size of a $p{-}proof$ that is sent in the locked broadcast is $O(n^2)$ signatures because it contains $O(n)$ lock-certificates.

Lock-certificates can be reduced to a single signatures by using threshold signatures. Reducing the size of the $p{-}proof$ below $O(n)$ signatures requires either more powerful succinct proofs or a slightly different protocol. We will explore both in future posts.


## Notes


In later posts, we will show the accountability improvements suggested by [Casper FFG](https://arxiv.org/pdf/1710.09437.pdf), simple view synchronization based on Reliable Broadcast, and HotStuff which also provides responsiveness.

