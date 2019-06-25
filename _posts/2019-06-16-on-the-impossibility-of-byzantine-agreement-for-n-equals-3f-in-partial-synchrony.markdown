---
title: On the impossibility of Byzantine Agreement for $n \leq 3 f$  in Partial synchrony
date: 2019-06-16 07:06:00 -07:00
published: false
tags:
- dist101
- lowerbound
authors:
- Kartik Nayak
- Ittai Abraham
---

<p align="center">
  co-authored with [Kartik](https://users.cs.duke.edu/~kartik/) [Nayak](https://twitter.com/kartik1507)
</p>



> Its either easy or impossible
> -- <cite>Salvador Dali</cite>

Lower bounds in distributed computing are very important. They prevent you from trying to do impossible things. Even more importantly understanding them well often helps in finding ways to focus on what is optimally possible or ways to circumvent them by altering the assumptions or problem formulation.


In this post we explain an key impossibility result:  **Consensus cannot be solved under partial synchrony[1] against a Byzantine adversary if $f \geq n/3$.**


As described in an earlier [post](https://ittaiab.github.io/2019-06-01-2019-5-31-models/}{partial synchrony), either we have a GST event at an unknown time (or we have an unknown $\Delta$). Thus, the time to decide cannot depend on GST occurring  (or on knowing $\Delta$). 

Seeking a contradiction, let us assume there is a protocol that claims to solve Byzantine Agreement with $f \geq n/3$ Byzantine parties. Divide the $n$ processors into three sets: $A$, $B$, and $C$ each with at least one party and at most $f$ parties in each set. We consider the following three worlds and explain the worlds from the view of $A$, $B$, and $C$. In all three worlds, we will assume that all messages between $A <-> B$ and $B <-> C$ arrive immediately; but all messages between $A$ and $C$ are delayed by the adversary.

For the proof approach we introduce two extremely powerful techniques that have many applications: 

The first is **indistinguishability**, this is where some parties can not tell between two (or more) potential worlds. Their distribution of views looks exactly the same so they must decide the same way in both cases. This leads to the following initial proof approach: imagine that there were two worlds 1 and 2 such that in world 1 the honest must decide 1 and in world 2 the honest must decide 0. If there was some honest party for which world 1 and world 2 are indistinguishable then we would drive a contradiction.  Unfortunately we cannot use such a simple argument for this lower bound.

The second techniques is **hybridization**,  this is where we build intermediate worlds between the two contradicting worlds and use a chain of indistinguishability arguments to create a series of statements that leads to the final contradiction. 

Here we go:

*World 1*: Suppose parties in $A$ and $B$ start with the value 1. Parties in C have crashed. Since $|C| \leq f$, the parties will eventually decide. For agreement to hold, all the parties in A and B will output 1. From the perspective of $A$ (and also $B$), they cannot distinguish between a crashed (or Byzantine) $C$ vs.\ an honest $C$ whose messages are delayed.

*World 2*: This will be a world similar to world 1 where the roles of $A$ and $C$ are interchanged. The parties in $B$ and $C$  start with the value 0.  Parties in $A$ have crashed. Again, $C$ cannot distinguish between a crashed $A$ vs.\ an honest $A$ whose messages are delayed.

*World 3*: We will now create a \emph{hybrid} world where the view of $A$ in this world will be indistinguishable to the view of $A$ in world 1 and the view of $C$ in this world will be indistinguishable to the view of $C$ to world 2. $A$ will start with value 1 and $C$ will start with value 0. The adversary will use it Byzantine power to corrupt $B$ to perform a \emph{split-brain} attack  and to make $A$ and $C$ each believe that they are in their respective worlds. $B$ will equivocate and act as if the starting value is 1 with $A$ and as if it is 0 with $C$. Since messages between A and C are delayed by the adversary, then by an indistinguishability argument, $A$ will commit to 1 and $C$ will commit to 0 (recall the time to decide cannot depend on GST or $\Delta$). This violates the agreement property.

Some important observations:
1. The impossibility holds even if the adversary is static, i.e., we fixed the set $B$ as the adversary to begin with.
    
2. I am not sure how people will relate the secure setup comment. Have a post on setups.. 
    
3. The impossibility above importantly assumes (i) a Byzantine adversary B, and (ii) messages between A and C do not arrive. Even if one of these two conditions do not hold, we can tolerate $f \geq n/3$. If we only have crash faults, then Paxos and many other protocols can tolerate a minority corruption. If messages are guaranteed to arrive within a fixed known time bound (i.e., assuming synchrony), then we can tolerate a minority corruption \textbf{(what is the best known example? our FC paper? sync hotstuff? KK?)}

4. For agreement to hold, it is essential that if one party decides on a value, all other parties decide on the same value. Under partial synchrony, since parties are not even guaranteed to be able to communicate with each other throughout the protocol, they always ensure that a majority of honest parties ``agree'' to a value before deciding (otherwise two minorities can commit to different values). Among 3f+1 parties, f can be Byzantine; thus f+1 honest parties form a majority among the remaining 2f+1. Hence, partially synchronous protocols typically communicate with 2f+1 (out of 3f+1) parties before deciding: f+1 honest majority + (up to) f Byzantine. 
    
5. On the other hand, under synchrony even a single honest party can inform all other honest parties. Thus, synchronous parties typically communicate with f+1 out of 2f+1 parties.
    
6. A similar lower bound holds for crash (or omission) failures if $n \leq 2f$. This is a good exercise to check you understand the arguments above.



\href{https://groups.csail.mit.edu/tds/papers/Lynch/jacm88.pdf}{DLS88 [Theorem 4.4]}.