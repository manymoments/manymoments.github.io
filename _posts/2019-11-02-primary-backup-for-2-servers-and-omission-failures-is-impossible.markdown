---
title: Primary-Backup for Two Servers and One Omission Failure is Impossible
date: 2019-11-02 11:12:00 -07:00
tags:
- lowerbound
- SMR
- dist101
---

In the [previous post](https://decentralizedthoughts.github.io/2019-11-01-primary-backup/), we show that State Machine Replication for $n<f$ failures is possible in the synchronous model when the adversary can only cause parties to *crash*. In this post, we show that *omission* failures are more challenging.

**Theorem:** *It is impossible to implement State Machine Replication with two replicas and an adversary that can cause omission failures to one replica even in a lock-step model.* 

As in our previous [lower bounds](https://decentralizedthoughts.github.io/2019-06-25-on-the-impossibility-of-byzantine-agreement-for-n-equals-3f-in-partial-synchrony/), we assume a solution that is safe and live exists and reach a contradiction. For the contradiction, we define multiple worlds and use an indistinguishability argument. In each world, there are two clients called client $1$ and client $2$ and two servers called server $1$ and server $2$.

### World A:
In this world, client $1$ wants to send command $C1$, and the adversary blocks all communication to and from server $2$. Since the protocol is safe and live, any correct solution must notify client $1$ that command $C1$ is the only committed command.

### World B:
In this world, client $2$ wants to send command $C2$, and the adversary blocks all communication to and from server $1$. Since the protocol is safe and live, any correct solution must notify client $2$ that command $C2$ is the only committed command.

### World C:
In this world, client $1$ wants to send command $C1$, and client $2$ wants to send command $C2$. The adversary causes both clients to fail by omission as follows: it blocks all communication between client $1$ and server $2$ and all communication between client $2$ and server $1$. Finally, without loss of generality, the adversary also causes server 2 to have omission failures by blocking all communication between server $1$ and server $2$.


Observe that the view of server 1 in world A and world C is indistinguishable. Since in worlds A and C, client $1$ only communicates with server $1$, it also has indistinguishable views.

Similarly, the view of server 2 in world B and world C is indistinguishable. Since in worlds B and C, client $2$ only communicates with server $2$, it also has indistinguishable views.

So in world C, the two clients will see conflicting states and this is a violation of safety.


Notes:
1. This lower bound can be generalized to $n$ replicas and $f$ omission failures for any $n\leq 2f$.
2. This lower bound holds even if there is a setup and a PKI.

Please leave comments on [Twitter]()
