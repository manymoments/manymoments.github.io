---
title: The Lock-Commit Paradigm
date: 2020-11-29 02:02:00 -11:00
tags:
- dist101
author: Ittai Abraham
---

In this post, we explore the Lock-Commit paradigm for consensus protocols. This approach is probably the most celebrated and widely used technique for reaching consensus in a safe manner. This approach is one of the key techniques in [DLS88](https://groups.csail.mit.edu/tds/papers/Lynch/jacm88.pdf) and Lamport's [Paxos](https://lamport.azurewebsites.net/pubs/lamport-paxos.pdf).

We exemplify this paradigm by showing a single shot [synchronous protocol](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) for [uniform consensus](https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/) that is tolerant to $f$ [omission](https://decentralizedthoughts.github.io/2020-09-13-synchronous-consensus-omission-faults/) failures given $2f<n$.

In a [follow up post](...) we extend this paradigm to a multi-shot protocol that can tolerate both $f$ omission failures and $k$ [crash](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) failures given $k\+2f<n$.

Previous related posts:

1. In synchrony, for non-uniform consensus,  [this post](https://decentralizedthoughts.github.io/2019-11-01-primary-backup/) shows how to tolerate $k<n$ *crash* failures. [This post](https://decentralizedthoughts.github.io/2020-09-13-synchronous-consensus-omission-faults/) shows how to tolerate $t<n/2$ *omission* failures (obtaining non-uniform consensus).

2. [This post](https://decentralizedthoughts.github.io/2019-11-02-primary-backup-for-2-servers-and-omission-failures-is-impossible/) shows a lower bound that it is impossible to tolerate $2f\\geq n$ omission failures. It's a nice exercise to extend this lower bound to show it is impossible to tolerate $k\+ft \\geq n$ for $k$ crash failures and $f$ omission failures.

## Lock-Commit

The idea behind the Lock-Commit paradigm: the safety risk in consensus is that you decide but due to failures your decision will no be heard by others. In particular, a new primary may emerge that does not hear about your decision. The Lock-Commit solution is to do two things:

1. Amplify your decision before you take it. Make sure there is a **quorum** of parties that herd you are plan to decide. We say the parties in this set are *locked* on your value.

2. Listen carefully and adopt a value even if you just see just a lock for it. A new Primary must read from a **quorum** and choose the most recent lock value it sees.

This approach obtains safety because *any two quorum sets must have a non-empty intersection*. In this post, we will use quorums that consist of $n-f=f\+1$ parties.

This simple idea is very powerful and can be extended to many settings:

1. Since it's based on *quorum intersection*, this mechanism does not rely on any synchrony for safety!

2. This approach guarantees non-uniform consensus. In essence, you don't commit before you have proof that the system is [committed](https://decentralizedthoughts.github.io/2019-12-15-consensus-model-for-FLP/).

3. This paradigm can be extended to tolerate malicious adversaries. For $n>2f$, by using [signatures and synchrony](https://decentralizedthoughts.github.io/2019-11-10-authenticated-synchronous-bft/). For $n>3f$, by using Byzantine Quorums that intersect by at least $f\+1$ parties.

Let go right away to a Lock-Commit based consensus protocol for a single slot:

## Lock-Commit for omission failures

    // pseudocode for Replica j
    
    state = init // the state of the state machine
    log = []     // a log (of size 1) of committed commands
    view = 0     // view number that indicates the current Primary
    lockcmd = null
    lock = -1     // the highest view a propose was heard
    mycmd = null
    start timer(0) // start timer for first view
    
    
    while true:
    
       // as a primary (you are replica 0 and view is 0)
       on receiving first cmd from client and j == 0 and view == 0:
             send ("propose", cmd, view) to all replicas
       // as a primary (you are replica j and view is j)
       on receiving ("lock", cmd, view) from n-f distinct replicas and view == j:
             // commit (after you know enough have locked)
             log[0] = cmd
             send ("commit", cmd) to all replicas
             terminate
       // as a replica: commit and terminate
       on receiving ("commit", cmd):
             log[0] = cmd
             send ("commit", cmd) to all replicas
             terminate
       // as a backup replica in the same view
       on receiving ("propose", cmd, v) and v==view:
             lock = v
             lockcmd = cmd
             send ("lock", cmd, v) to the primary j

When does a replica move from one view to another? When it see that the current primary is not making progress. This is the **view change trigger** protocol:

      on timer(i) expiring and log[0] == null and view == i; or
      on receiving ("blame", i) from f+1 distinct replicas
             send ("blame", i) to all replicas
      on receiving ("blame", i) from n-f distinct and view <= i:
             // this will trigger a timer and a "highest lock message"
             send ("view change", i+1) to all replicas (including self)

Note that the view change trigger protocol can be simplified and also altered to have a linear communication optimistic path. Assuming synchrony, we could for example, simply trigger a view change after each 6 message delays. The more elaborate option above will give us flexibility in later posts.

What do the next primaries propose? to be safe, they must read from a quorum and use the value with the highest view number. This is the **view change** protocol:

       // send your highest lock
       on receiving ("view change", v) and view < v:
             view = v
             // start timer for 8*(max message delay)
             start timer(v)
             send ("highest lock", lockcmd, lock, v) to replica v
       // as the primary (you are replica j and view is j)
       on receiving ("highest lock", c, v, j) from n-f distinct replicas and view == j:
             if all heard values are null (all heard views are -1):
                 mycmd = any value heard from the clients
             otherwise:
                 mycmd = value with the highest view heard
             send ("propose", mycmd, view) to all replicas

### Argument for Safety

**Claim:** let $v$ be the first view were some party commits to some value $cmd$, then no primary will propose $cmd' \\neq cmd$ at any view $v'\\geq v$.

*Proof:*

By induction on $v' \\geq v$. For view $v'=v$ this follows since the primary sends just one "propose" value per view. Assume the hypothesis holds for all views $\\leq v'$ and consider the view change of primary $v'\+1$ to view $v'\+1$.

Let $W$ be the set of $n-f$ distinct parties that set $lock = v$ and sent $("lock", cmd, v)$ to the primary $v$ in view $v$.

Let $R$ be the $n-f$ parties that party $v'\+1$ received their $("highest lock", lockcmd, lock, v'\+1)$ for view $v'\+1$.

Since $W \\cap R \\neq \\emptyset$ then the primary of $v'\+1$ must hear from a member of $R$ and from the induction hypothesis we know that this member's lock is at least view $v$ and its lock value must be $cmd$. In addition, from the induction hypothesis, we know that no other member of $W$ can have a lock for a value that has a view that is at least $v$ with a value $cmd' \\neq cmd$.

Hence during the view change of view $v'\+1$, the value with the maximum view in $W$ must have the value $cmd$ and be with a view $\\geq v$.

Observe that this argument did not rely on synchrony.

### Argument for Liveness

**Claim:** let $v$ be the first view with a non-faulty primary, then all non-faulty parties will commit by the end of view $v$.

*Proof:*

Observe that in any view $<v$, either some non-faulty commits and hence all non-faulty commit and terminate one message delay later; or otherwise, all non-faulty do not commit, and hence will send a "blame" and hence all non-faulty will send a "view change" and join the next view within one round trip.

Observe that this argument that the timers will explore and all start the next view within one message delay requires synchrony.

If some non-faulty parties have not decided before entering view $v$ then all non-faulty will enter view $v$ within one message delay. In view $v$, the non-faulty primary will gather $n-f$ distinct "lock" messages and will send a commit message that will arrive to all non-faulty parties before their $timer(v)$ expires (assuming the timer is larger than 8 message delays and using the fact that they all started their timer with a gap of at most one message delay). Hence even if all faulty parties send a "blame" message there will not be enough "blame" messages to form a "view change" message.

Again observe the use of synchrony.

Please answer/discuss/comment/ask on [Twitter](...).