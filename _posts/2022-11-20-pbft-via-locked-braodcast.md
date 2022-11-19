---
title: On PBFT from Locked Broadcast
date: 2022-11-20 04:00:00 -05:00
published: false
tags:
- dist101
author: Ittai Abraham
---

We describe a variation of the authenticated version of [PBFT](https://pmg.csail.mit.edu/papers/osdi99.pdf) using [Locked Broadcast](https://decentralizedthoughts.github.io/2022-09-10-provable-broadcast/) that follows a similar path as our previous post on [Paxos using Recoverable Broadcast](https://decentralizedthoughts.github.io/2022-11-04-paxos-via-recoverable-broadcast/). I call this protocol **linear PBFT** and variants of it are used in [SBFT](https://arxiv.org/pdf/1804.01626.pdf) and in [Tusk](https://arxiv.org/pdf/2105.11827.pdf). A later post will show how to extend this approach for [Two Round HotStuff](https://arxiv.org/pdf/1803.05069v1.pdf)) using [Locked Broadcast](https://decentralizedthoughts.github.io/2022-09-10-provable-broadcast/) and [Three Round HotStuff](https://arxiv.org/pdf/1803.05069.pdf) using [Keyed Broadcast](https://decentralizedthoughts.github.io/2022-09-10-provable-broadcast/).


The model is [Partial Synchrony](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) with $f<n/3$ [Byzantine failures](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) and the goal is [consensus](https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/) (see below for exact details). 

As we did with Paxos, we approach PBFT by starting with two major simplifications:

1. Use a *simple revolving primary* strategy based on the assumptions of perfectly synchronized clocks. This approach follows Section 6 of [Two Round HotStuff](https://arxiv.org/pdf/1803.05069v1.pdf) that then suggests an additional way of doing view synchronization for a total $O(n^2)$ message complexity without clock synchronization.
2. Focus on a *single-shot* consensus while PBFT is designed as a full State Machine Replication system.


## View based protocol with simple rotating primary

The protocol progresses in **views**. The first view is 1 and view $v+1$ follows view $v$. Each view has a designated **primary** party. For fairness, parties rotate the role of the primary. For simplicity, the primary of view $v$ is party $v \mod n$. 

Clocks are synchronized, and $\Delta$ is known, so set view $v$ is set to be the time interval $[v(10 \Delta),(v+1)(10 \Delta))$. In other words, each $10\Delta$ clock ticks each party triggers a **view change** and increments the view by one. Since clocks are assumed to be perfectly synchronized, all parties move in and out of each view in complete synchrony.


## Single-shot Consensus with External Validity

We assume there is some *External Validity* ($EV_{\text{consensus}}$) Boolean predicate that is provided to each party. $EV$ takes as input a value $v$ and a proof $proof$. If $EV(v,proof)=1$ we say that $v$ is *externally valid*. A simple example of external validity is a check that the value is signed by the by the client that controls the asset. External validity is based on the framework of [Cachin, Kursawe, Petzold, and Shoup, 2001](https://www.iacr.org/archive/crypto2001/21390524.pdf). 

In this setting each party has some *input value with external validity* and the goal is to *output a single value with a proof* with the following three properties:

**Agreement**: all non-faulty parties output the same value. 

**Termination**: all non-faulty parties eventually output a value proof pair and terminate. 

**External Validity**: the output is externally valid. 


We denote by $EV_{\text{consensus}}$ the external validity function that is given.


We will use two building blocks: Locked Broadcast and Recover Max Lock. However our exposition will start top down defining first the high level protocol and then the building blocks. 

# Linear PBFT via Locked Broadcast and Recover Max

Every $10 \Delta$ parties change view and rotate the primary. Clocks are perfectly synchronized so this change of view is perfectly synchronized as well.

In view 1 the primary does a locked broadcast ($LB$), with its validated input value and the view (which is 1). The delivery certificate output of the Locked Broadcast is a consensus decision!


```Linear PBFT consensus protocol```: 

For view 1, the primary of view 1 with input $val,proof$: 
```
LB (1, val, val-proof)
```

Once a primary gets a delivery certificate it sends it to all parties to commit. Recall that a delivery certificate is valid if it has $n-f$ distinct signatures.

```
Upon delivery-certificate dc for (v,x)
    send (x, dc) to all

All parties:

Upon valid (x,dc)  
    commit x    
```


As in Paxos, what if the first Primary is faulty and only some parties decide (but not all)? For agreement to hold later primaries cannot commit other values! In fact we will show that later primaries cannot even generate lock-certificates for other values! 

Similar to Paxos, the Recover Max Lock ($RML$) will return the highest lock certificate. Unlike Paxos, $RML$ will also return a ```proof```. We will explain what this proof contains later, intuitively it contains a proof that the primary did indeed chooses the highest lock certificate it saw.

For view $v>1$, the primary of view $v$ with input $val,val-proof$:
```
p,p-proof := RML(v)

if p = bot then 
   LB (v, val, val-proof, p-proof)
otherwise 
   LB (v, p, p-proof)

```

In words, the primary will first try to recover the lock certificate with maximal view. If no lock certificate is seen, the primary is free to choose its own externally valid input, but even in that cases it adds the proof from the ecover max lock pprotocol. Otherwise, it proposes the output from the recover max lock along with its proof.  Note the deep similarity to the Paxos protocol variant of the [previous post](https://decentralizedthoughts.github.io/2022-11-04-paxos-via-recoverable-broadcast/).

Much of the magic of Byzantine Fault tolerance is hidden in the Lock Broadcast abstraction, its $EV$ function definition, and the recover max lock protocol. Let's details them one after the other:


### Recover Max Lock

```Recover-Max-Lock (v)``` protocol for view $v$ finds the highest lock and returns not only the associated value, but a proof that the primary chose the highest lock among some set of $n-f$ valid responses. 

```
RML(v):

Party i upon start of view v
    send <echoed-max(v, v', p, LC(v') )>_i of the highest view v' in which you have a lock certificate LC for (v',p)
    or send <echoed-max(v, bot)>_i if you don't have any lock certificate

Primary waits for n-f responses <echoed-max(v,*)> 
    if all are bot then output (bot, responses)
    otherwise output the proposal associated with the highest view v' and responses
```

So the primary not only outputs the value associated with the highest lock certificate it also has to send all the $n-f$ lock certificate responses it saw!

### Locked Broadcast 

Recall that [Locked broadcast](https://decentralizedthoughts.github.io/2022-09-10-provable-broadcast/) is the application of two provable broadcasts with an *external validity function*, which has the following properties:

* **Termination**: If the sender is honest and has an *externally valid* input $v$, then after a constant number of rounds the sender will obtain a *delivery-certificate* of $v$. Note that the Termination property requires just the sender to hold the certificate.
* **Uniqueness**: There can be at most one value that obtains a *delivery-certificate*. So there cannot be two *delivery-certificates* with different values.
* **External Validity**: If there is a *delivery-certificate* on value $v$ and proof $proof$ then $v$ is *externally valid*. So $EV(v,proof)=1$.
* **Unique-Lock-Availability**: If a  *delivery-certificate* exists for $v$ then there can only exist a *lock-certificate* for $v$ and there are at least $n-2f\geq f+1$ honest parties that hold this *lock-certificate*.

Note that Locked Broadcast needs to define an external validity function $EV_{\text{LB}}$, this defines what messages are allowed to proceed. Note that this is different from the external validity function of the consensus protocol $EV_{\text{consensus}}$. As you may expect, the $EV_{\text{LB}}$ will check the the validity of the $RML(v)$ protocol!

### External Validity for the Locked Broadcast of Linear PBFT

We now define $EV_{\text{LB}}$,

For view 1, we just use the external validity function of the consensus protocol $EV_{\text{consensus}}$. So $EV_{\text{LB}}(1, val, val-proof)= EV_{\text{consensus}}(val, val-proof)$.

For view $v>1$ there are two cases:

1. We are given a 4-tuple $(v, val, val-proof, p-proof)$, if $p-proof$ consists of $n-f$ distinct $RML(v)$ responses and all have value $\bot$, then output $EV_{\text{consensus}}(val, val-proof)$.
2. Otherwise, We are given a 3-tuple $(v, p, p-proof)$, check that $p-proof$ consists of $n-f$ distinct valid $RML(v)$ responses:
    1. An $RML(v)$ message that contains ```<echoed-max(v, v', p, LC(v') )>_i``` is valid if the lock certificate is valid for view $v'$ and the value associated with this lock is $p$.
    2. Let $v^+, LC_{v^+}, p^+$ be the valid ```<echoed-max(v, * )>_i``` response with the highest view $v^+$. 
    3. Output true of $p=p^+$.


In words, we either check all parties saw no lock certificate and the new value is valid, or that the primary proposes the value that is associated with the highest lock certificate.



This completes the description of the protocol. Note that we described the protocol in 4 places: the high level consensus, the recover max lock protocol, the locked broadcast protocol and finally the external validity of the locked broadcast. Let's prove that the three properties of consensus hold when we combine all of this together!


### Agreement (Safety)

**Safety Lemma**: Let $v^{\star}$ be the first view with a lock certificate on $(v^\star, x)$, then for any view $v>v^\star$ if a lock certificate forms for view $v$ must be with value $x$.

*Exercise: prove the Agreement property follows from Lemma above.*

We now prove the safety Lemma, which is the essence of Tendermint.

*Proof of Safety Lemma*: consider the set $S$ (for Sentinels) of non-faulty parties among the $n-f$ parties that sent ```<??? (v*,x)>``` in view $v^\star$. We will call them the *Sentinels*, because they guard safety. Note that $|S| \geq n-2f \geq f+1$. For simplicity assume $|S|=f+1$.

We will prove by induction, that for any view $v\geq v^\star$:
1. If there is a lock certificate for view $v$ it has value $x$.
2. For each party $P_i$ in $S$, the lock certificate with its highest view $v'$ is such that: (1) $v' \geq v^\star$; (2) and the value of the lock certificate is $x$.

For the base case, $v=v^\star$ (1.) follows from the *Uniqueness* property of locked broadcast and (2.) follows from the *Unique-Lock-Availability* property of locked broadcast.

Now suppose the induction statement holds for all views $v^\star \leq v$ and consider view $v+1$:

Here we will use the *External Validity* of locked broadcast. To form a lock certificate, the primary needs $n-f$ parties to view its proposal as valid. This set of validators must intersect with the set $S$ which is also of size at least $f+1$ by at least one party.

Consider this honest party $s \in S$ and the fact that $EV_{v+1}$ requires a proposal with a lock certificate of a view that is at least $v^*$. Hence from (2.) we have that the only such proposal that will be valid for $s$ must have the value $x$. This concludes the proof of part (1.) for view $v+1$.

For party (1.), since the only lock certificate that can form in view $v+1$ must have value $x$, then each party in $S$ either stays with its previous highest lock certificate (from $(1.)$ of the induction hypothesis for view $\leq v$) or it updates it to the higher lock certificate for view $v+1$. Clearly, in both cases we proved that part $(2.)$ of the induction hypothesis holds for view $v+1$.

This concludes the proof of Lemma 2.

### Liveness

We proved Agreement, now let's prove that eventually all *non-faulty* parties output a value. Naturally we will rely on the *Termination* property of locked broadcast.

Consider the view $v^+$ with the *first* non-faulty Primary that started after GST at time $T$. Since we are after GST, then on or before time $T+ \Delta$ the primary will receive ```<echoed-max(v+,*)>``` from all non-faulty parties (at least $n-f$). Hence will send a a value in $LB(v^+)$ that (1) will arrive at all non-faulty parties on or before time $T+2\Delta$ and (2) will have a lock certificate that is at least as high as the highest lock certificate held by any non-faulty party (here we used the fact that we wait $\Delta$ in $RM(v^+)$. Hence all non-faulty parties will pass the $EV_{v^+}$ condition (because they are still in view $v^+$, the lock certificate is high enough and the value is valid). So the primary will obtain a delivery certifiacte on or before time $T+3\Delta$. So all non-faulty will decide on or before time $T+4\Delta$

This concludes the proof of Liveness.


### Termination


We proved that all non-faulty parties output a value, but our protocol never terminates! For that we can add the following *termination gadget*:

```
If the consensus protocol outputs x and delivery certificate x-dc,
    Send <decide, x, x-dc> to all
    Terminate
    
Upon receiving <decide, x, x-dc>
    Send <decide, x, x-dc> to all
    Terminate
``` 

Clearly if a non-faulty party terminates, then eventually all non-faulty parties terminate. 



### External Validity

External validity can be proven by induction on the chain of lock certificates. For a lock certificate with no prior lock, external validity is part of the $EV$ function check. Observe that any lock certificate that points a previous lock certificate must use the same value. Hence a simple induction shows that any lock certificate must have an externally valid value.


### Time and Message Complexity

Note that the time and number of messages before GST can be both unbounded, so we measure the time and message complexity after GST.

**Time complexity**:  since the Liveness proof waits for the first non-faulty primary after GST this may take an interrupted view, then $f$ views of faulty primaries, then a good view in the worst case. So all parties will output a value in at most $(f+2)10 \Delta = O(f \Delta)$ time after GST. This is asymptotically optimal.


**Message Complexity**: since each round has a linear message exchange, the total number of message sent after GST is $O(f \times n) = O(n^2)$. This is asymptotically optimal.


## notes


In later posts we will show the accountability improvements suggested by [Casper FFG](https://arxiv.org/pdf/1710.09437.pdf), simple view synchronization based on Reliable Broadcast, and HotStuff that also provides responsiveness.

