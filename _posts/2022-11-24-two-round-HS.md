---
title: Two Round HotStuff
date: 2022-11-24 05:00:00 -04:00
tags:
- dist101
author: Ittai Abraham
---

In the first part of this post we describe a single-shot variation of Two Round HotStuff (see the [HotStuff v1 paper](https://arxiv.org/pdf/1803.05069v1.pdf)) using [Locked Broadcast](https://decentralizedthoughts.github.io/2022-09-10-provable-broadcast/) that follows a similar path as our previous post on [Paxos](https://decentralizedthoughts.github.io/2022-11-04-paxos-via-recoverable-broadcast/) and [Linear PBFT](https://decentralizedthoughts.github.io/2022-11-20-pbft-via-locked-braodcast/). In the second part, we describe a fully pipelined multi-shot State Machine Replication version of Two Round HotStuff that is similar to [Casper FFG](https://arxiv.org/abs/1710.09437) and [Streamlet](https://decentralizedthoughts.github.io/2020-05-14-streamlet/).


The simplified single-shot Two Round HotStuff variation captures the essence of the [Tendermint](https://tendermint.com/static/docs/tendermint.pdf) view change protocol (also see more recent [Tendermint paper](https://arxiv.org/pdf/1807.04938.pdf)) which reduces the size of the view change messages relative PBFT.

The model is [Partial Synchrony](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) with $f<n/3$ [Byzantine failures](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/).


# Part one: single shot with rotating leaders.

Here we use the same view based framework as in the [PBFT post](https://decentralizedthoughts.github.io/2022-11-20-pbft-via-locked-braodcast/):

1. The goal in this part is Single-shot Consensus with External Validity.
2. We use a view based protocol where view $v$ is the time interval $[v(10 \Delta),(v+1)(10 \Delta))$.
3. The protocol uses [Locked broadcast](https://decentralizedthoughts.github.io/2022-09-10-provable-broadcast/).

Here is the pseudocode which is (almost) the same as the [PBFT post](https://decentralizedthoughts.github.io/2022-11-20-pbft-via-locked-braodcast/):



```
Two Round HotStuff single-shot consensus protocol

View 1 primary:
    LB(1, val, val-proof)

View v>1 primary:
    (p, p-proof) := RML(v)

    if p = bot then 
        LB(v, val, val-proof)
    otherwise 
        LB(v, p, p-proof)
        

Upon delivery-certificate dc for (v,x)
    send (v, x, dc) to all

All parties:

Upon valid delivery-certificate dc for (v,x)
    output x    
```

A minor difference is that when $p= \bot$ then $p{-}proof$ is not sent.


Two major differences in the sub-protocols $RML$ and external validity of $LB$:
1. *Recover Max Lock* protocol: Instead of using ```PBFT-RML(v)``` which returns a set of $n-f$ lock-certificates, we use ```TNDRMNT-RML(v)``` which returns only **one** lock-certificate. This is where Tendermint based protocols (like Two Round HotStuff) save on message size.
2. The *external validity* of the *Locked broadcast* $EV_{\text{LB}}$ is changed from $EV_{\text{LB-PBFT}}$ to $EV_{\text{LB-TNDRMNT}}$ to work with the change above in the Recover Max Lock protocol.

We go over these changes in more detail:


### Recover Max Lock for Tendermint based protocols

The ```TNDRMNT-RML(v)``` protocol for view $v$ finds the lock-certificate with the highest view and simply returns the associated value and the lock-certificate. 

The other major change in ```TNDRMNT-RML(v)``` is the additional wait of $\Delta$ at the primary (in addition to waiting for at least $n-f$). This is required for the liveness proof.

```
TNDRMNT-RML(v):

Party i upon start of view v:
    send <echoed-max(v, v', p, LC(v',p) )>_i 
        of the highest view v' it has a lock-certificate LC(v',p)
    or send <echoed-max(v, bot)>_i 
        it does not have any lock-certificate

Primary waits for its least n-f responses <echoed-max(v,*)> and Delta time:
    if all are bot then output (bot, bot)
    otherwise, output (proposal, LC(v',proposal)) 
        where proposal is associated with the highest view in responses
        and LC(v',proposal) is the associated lock-certificate
```

 
### External Validity for the Locked Broadcast of Linear PBFT


$EV_{\text{LB-TNDRMNT}}$ checks the validity relative to the ```TNDRMNT-RML(v)``` protocol. Unlike the $EV_{\text{LB-PBFT}}$ check, the $EV_{\text{LB-TNDRMNT}}$ verification is *stateful*, the check compares the input to the highest lock-certificate that the party has seen.

To be explicit about this, each part maintains state  ```my-lock``` that contains the lock-certificate with the highest view it saw. Denote by ```view(my-lock)``` the view number of this block-certificate. Initially ```my-lock := bot``` and ```view(my-lock) := 0```.

Now define $EV_{\text{LB-TNDRMNT}}$:

For view 1, nothing changes, just check external validity of the consensus protocol: $EV_{\text{LB-TNDRMNT}}(1, val, val-proof)= EV_{\text{consensus}}(val, val-proof)$.

For view $v>1$ there are two cases:

1. Given a 3-tuple $(v, val, val{-}proof$:
    1. Check that $view(my{-}lock) = 0$.
    2. Output true if $EV_{\text{consensus}}(val, val{-}proof)=1$.
2. Otherwise, given a 3-tuple $(v, p, p{-}proof)$:
    1. Check that $p{-}proof$ is a valid lock-certificate $LC(v',p)$ for view $v'$ and value $p'$.
    2. Check that $view(my{-}lock) \leq v'$ 
    3. Output true of $p=p'$.

    
In words: the check makes sure that the proposed value has a valid lock-certificate that has a view that is at least as high as the view of the lock-certificate this server has.
 
 
Now that ```TNDRMNT-RML(v)```  and $EV_{\text{LB-TNDRMNT}}$ are defined this fully defines the single-shot consensus protocol. Let's prove Agreement and Liveness (the Validity argument is the same as in PBFT).

### Agreement (Safety)

**Safety Lemma**: Let $v^{\star}$ be the first view with a commit-certificate on $(v^\star, x)$, then for any view $v\geq v^\star$, if a lock-certificate forms for view $v$ then it must be with value $x$.

*Exercise: prove the Agreement property follows from Lemma above.*

We now prove the safety Lemma, which is the essence of Tendermint based view change protocols.

*Proof of Safety Lemma*: Let $S$ (for Sentinels) be the set of non-faulty parties among the $n-f$ parties that sent lock-certificate in the second round of locked broadcast of view $v^\star$. Note that $|S| \geq n-2f \geq f+1$. 

Induction statement: for any view $v\geq v^\star$:
1. If there is a lock-certificate for view $v$ then it has value $x$.
2. For each party in $S$, in view $v$, the lock-certificate with the highest view has view $v' \leq v$ such that: 
    1. $v' \geq v^\star$; and
    2. The value of the lock-certificate is $x$.

For the base case, $v=v^\star$ (1.) follows from the *Uniqueness* property of locked broadcast of view $v^*$ and (2.) follows from the *Unique-Lock-Availability* property of locked broadcast.

Now suppose the induction statement holds for all views $v^\star \leq v$ and consider view $v+1$:

Here we will use the *External Validity* of Locked Broadcast. To form a lock-certificate, the primary needs $n{-}f$ parties to view its proposal as valid. This set of validators must intersect with at least one party from $S$ (because $S$ is of size at least $f+1$).

Consider this honest party $s \in S$ and the fact that $EV_{\text{LB-TNDRMNT}}$ requires a proposal with a lock-certificate of a view that is at least as high as $s$'s highest lock-certificate. From (2.) this must be with a view of at least $v^*$. From (1.) we have that any proposal that will be valid for $s$ must have the value $x$. This concludes the proof of part (1.) for view $v+1$.

For part (2.), since the only lock-certificate that can form in view $v+1$ must have value $x$, then each party in $S$ either stays with its previous lock-certificate (from $(1.)$ of the induction hypothesis for view $\leq v$) or it updates it to the higher view lock-certificate for view $v+1$. In both cases, we proved that part $(2.)$ of the induction hypothesis holds for view $v+1$.

This concludes the proof of Safety Lemma.

### Liveness

The only difference relative the Liveness proof for [PBFT](https://decentralizedthoughts.github.io/2022-11-20-pbft-via-locked-braodcast/) is that we need to show that all non-faulty parties will verify $EV_{\text{LB-TNDRMNT}}$ on the honest primary proposal. This is where the additional wait for $\Delta$ time in the gathering phase of ```TNDRMNT-RML(v)``` is required - it guarantees that after GST, by waiting for $\Delta$ time, the primary will hear from all non-faulty parties, hence is guaranteed to choose the lock-certificate that is high enough to verify $EV_{\text{LB-TNDRMNT}}$ for all non-faulty parties. 

This concludes the proof of Liveness.


### Time and Message Complexity

Like PBFT, the time complexity is $O(f \Delta)$.

Unlike PBFT, the size of a proposal message is just one lock-certificate instead of $n-f$ lock-certificates. With a threshold signature setup, the size of a lock-certificate can also be a constant (in the security parameter). So the total number of messages is $O(n^2)$ and the size of each message can be just $O(1)$ words - where a word constants a constant number of values and cryptographic signatures.



# Part two: pipelined multi-shot State Machine Replication version of Two Round HotStuff

The protocol revolves around a data structure which is a chain of blocks and 2-3 certificates (each certificate is a set of $n-f$ signatures on the block). Lets define:

A ```block``` $B$ contains a triplet $B=(cmd, view, pointer)$ where *cmd* is an externally valid client command, *view* is the view this block was proposed in, and *pointer* is a link to a previous block (that has a smaller view).

A ```blockchain``` is just a chain of ```block```s that starts with an empty ```genesis block``` of view 0 and empty pointer.

The last block which also has the highest view in a chain is called the ```tip```.

A ```block-cert``` for a block $B$ is a set of $n-f$ distinct signatures on $B$. We assume the ```genesis block``` implicitly has a block-certificate.

A ```valid blockchain``` is a blockchain with a ```commit-cert``` and a ```lock-cert```. Both are defined below:

A ```commit-cert``` for a block $B=(cmd, view, pointer)$ on a ```valid blockchain``` that is not the genesis is a ```block-cert``` for $B$, and a second block $B'=(cmd, view+1, pointer{-}to{-}B)$  with a ```block-cert``` for $B'$. Importantly, $B'$ does not have to be part of the ```valid blockchain``` but its view must be exactly one more than $B$'s view. By default, if there is no explicit pair of block-certificates, we say that the ```valid blockchain``` has a ```commit-cert``` on the  ```genesis block```. We call the chain from $B$ to the ```genesis block``` the ```committed blockchain```.

The ```lock-cert``` is a ```block-cert``` for a block $L$ that is on the ```valid blockchain``` but not part of the ```committed blockchain```.
 
Note that the ```lock-cert``` can be the ```block-certificate``` on the second block of the ```commit-cert```. In this case, this second block must be part of the ```valid blockchain```. By default, if there is no explicit block-certificates, we say that the ```valid blockchain``` has a ```lock-cert``` on the  ```genesis block```.

Each party stores a ```valid blockchain``` in a variable called  ```my-blockchain``` which stores the valid blockchain with the lock-certificate of highest view.


Protocol for view $v$:


On the start of view $v$, each party sends its signature on its valid blockchain to the primary:

```
Party i:

On start view v
    Send <"start view", v, my-blockchain>_i to view v primary
```

The primary of view $v$ waits for both $\Delta$ time and at least $n-f$ valid responses. There are two cases:
1. If $n-f$ parties send the *same* valid blockchain, and its tip is from view $v-1$ then:
    1. The primary creates a new lock-certificate for the tip and updates the lock-certificate to be this new block-certificate.
    2. If there is new commit-certificate (because both the block in view $v-1$ and the block in $v-2$ now have block-certificates) then update the commit-certificate to be this new pair.
    3. Finally the primary appends its new block as the new tip.
2. Otherwise the primary chooses the valid blockchain with the lock-certificate of the highest view and appends its new block to it as the new tip.

Finally the primary sends this as the proposal for view $v$ to all parties.


```    
Primary of view v:

On at least n-f valid <"start view", v, *> and waiting Delta time
    If n-f <"start view", v, blockchain> are the same and tip(blockchain).view = v-1
        blockchain.updateLockCert(block-cert(tip))
        If a new commit-cert created
            blockchain.updateCommitCert()
        my-blockchain := blockchain.addBlock(cmd, v, pointer-to-tip)
    
    Otherwise
        Let h-blockchain be the valid blockchain 
            with the lock-cert of highest view in <"start view", v, *> messages
        my-blockchain := h-blockchain.addBlock(cmd, v, pointer-to-tip)
        
    Send <"propose", v, my-blockchain> to all
```

When a party sees a proposal blockchain from the view $v$ primary it checks:
1. That its view is still $v$;
2. That this is the first such message from the primary;
3. That the proposal is a valid blockchain with a valid lock-certificate and a valid commit-certificate;
4. That all the blocks after the lock-certificate of the proposed blockchain contain externally valid commands;
5. That the lock-certificate of the proposed blockchain has a view that is at least as high as the view of the lock-certificate of ```my-blockchain```.
6. If all these checks pass, then:
    1. If the proposed blockchain has a commit-certificate for a higher view than that of  ```my-blockchain``` then execute the blocks in between the previous commit-certificate and the new commit-certificate.
    2. Update ```my-blockchain``` to the new proposed blockchain so it will be signed at part of the start view of view $v+1$.

```   
Party i:

    Upon <"propose", v, blockchain> from primary
        Check your view is v
        Check this is the first view v proposal
        Check that blockchain is valid (has valid lock-cert and commit-cert)
        Check that all blocks after blockchain.lock-cert are externally valid
        Check that blockchain.lock-cert.view >= my-blockchain.lock-cert.view
        
        If blockchain.commit-cert.view > my-blockchain.commit-cert.view
            execute commands between the two commit-certs
        my-blockcain := blockchain 
        
        
    If the view v timer expires then start view v+1
        
```


***Safety***: 



Given a commit-certificate that consists of two block-certificates on two consecutive blocks $B$ and $B'$ of views $v^* $ and $v^* +1$. Let set $S$ be the set of honest parties that signed a blockchain for view $v^* +1$ that included the block-certificate for $B$.

**Claim**: for any view $v \geq v^*$,
1. Any valid blockchain that has a lock-certificate of view $v$ includes block $B$.
2. The ```my-blockchain``` of any member of $S$ at the beginning of view $v+1$ includes block $B$ and its lock-certificate is at least of view $v^*$.

Base case (when $v=v^* $): follows the uniqueness of block-certificate $B$ (because it contains $n-f$ signatures in view $v^* $ and honest parties sign just one message per view). The fact that at least $f+1$ parties out of the $n-f$ parties in the block-certificate for $B'$ are honest defines the set $S$. Indeed members of $S$ at the beginning of view $v^* +1$ have $B$ as their lock-certificate. 

Induction argument, assuming $v\leq v^* $ and proving for $v+1$: The only way to create a lock-certificate in view $v+1$ is if a member of $S$ signs in the start view $v+1$ a blockchain with a tip in view $v$, which that in view $v$ it passed the check that the lock-certificate proposed by the primary had a view that is at least as high as the view of its lock-certificate.

Using the induction hypothesis (2.), the members of $S$ have a lock-certificate of view at least $v^* $ hence in order for them to approve the proposal must be of a view of at least $v^*$. We can now apply the induction hypothesis (1.) to say that such a proposal must include the block $B$. Hence the only valid blockchain that has a lock-certificate of view $v+1$ must also include block $B$. This concludes (1.).

For (2.) this follows since in view $v+1$ we can only create a new lock-certificate that extends $B$. So at the beginning of view $v+2$ parties in $S$ either maintain their previous blockchain or update to one which has a higher lock-certificate but in that case from (1.) this new blockchain must still include $B$. This concludes (2.) and the proof.


***Liveness***: 

Highlights:

1. Assuming perfect clock synchronization to obtain view synchronization.
2. The primary waits for $\Delta$ time so it hears the valid blockchain with the lock-certificate go highest view among all non-faulty parties.
3. Need 3 consecutive honest parties so everyone learns the commit-certificate.


## Using an authenticated data structure

The way the protocol is described, parties send back and forth the whole blockchain. This is not bandwidth efficient. Instead, we could view the blockchain as an authenticated data structure. For example, the hash of the tip can be used as a digest of a simple hash chain authenticated structure.

The protocol can send the digest of the blockchain instead of the blockchain. Any data this is missing for validation can be requested in a separate mechanism along with a proof that this is the correct data relative to the digest.