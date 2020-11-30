---
title: The Lock-Commit Paradigm
date: 2020-11-29 02:02:00 -11:00
published: false
---

In this post, we explore the Lock-Commit paradigm for consensus protocols. This approach is probably the most celebrated and widely used technique for reaching consensus in a safe manner.

We exemplify this paradigm by showing a single shot [synchronous protocol](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) for [uniform consensus](https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/) that can $t$ [omission](https://decentralizedthoughts.github.io/2020-09-13-synchronous-consensus-omission-faults/) failures.

In the follow up post we will extend this paradigm to a multi-shot protocol that can tolerate both $t$ omission failures and $k$ [crash](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) failures.

Previous related posts:

1. In synchrony, for non-uniform consensus,  [this post](https://decentralizedthoughts.github.io/2019-11-01-primary-backup/) shows we can tolerate $k<n$ *crash* failures and [this post](https://decentralizedthoughts.github.io/2020-09-13-synchronous-consensus-omission-faults/) shows we can tolerate $t<n/2$ *omission* failures.

2. [This post](https://decentralizedthoughts.github.io/2019-11-02-primary-backup-for-2-servers-and-omission-failures-is-impossible/) has a lower bound that shows we cannot tolerate $2t\\geq n$ omission failures. It's a good exercise to extend this lower bound to show we cannot tolerate $k\+2t \\geq n$ for $k$ crash failures and $t$ omission failures.

## Lock-Commit

The idea behind the Lock-Commit paradigm is simple: the safety risk in consensus is that you decide but due to failures your decision will no be heard. In particular, a new primary may emerge that does not hear about your decision. The solution is to do two things:

1. Amplify your decision before you take it. Make sure there is a **quorum** of parties that herd you are plan to decide. We say the parties in this set are *locked* on your value.

2. Listen carefully and adopt a value even if you just see just a lock for it. A new Primary must read from a **quorum** and choose the most recent lock value it sees.

This approach works because of the simple fact that any two quorum sets must have a non-empty intersection. In this post we will use quorums that consist of $n-f=f\+1$ parties.

This simple idea is very powerful and carries over to many settings:

1. Since it's based on *quorum intersection*, this mechanism does not rely on any synchrony!

2. This approach guarantees non-uniform consensus. In essence, you don't commit before you have proof that the system is [committed](https://decentralizedthoughts.github.io/2019-12-15-consensus-model-for-FLP/).

3. This paradigm can be extended to tolerate malicious adversaries. For $n>2f$ by using [signatures and synchrony](https://decentralizedthoughts.github.io/2019-11-10-authenticated-synchronous-bft/). For $n>3f$ by using Byzantine Quorums that intersect by at least $f\+1$ parties.

## Lock-Commit for omission failures

    // Replica j
    
    state = init // the state of the state machine
    log = []     // a log (of size 1) of committed commands
    view = 0     // view number that indicates the current Primary
    lockcmd = null
    lock = 0
    highestView = view
    mycmd = null
    
    while true:
    
       // as a primary
       on receiving first cmd from client and j == 0 and view == 0:
            send ("propose", cmd, view) to all replicas
       on receiving ("lock", cmd, view) from n-f distinct replicas and view == j:
             // commit
             log[0] = cmd
             state, output = apply(cmd, state)
             send output to the client library
             send ("commit", cmd) to all replicas
       // as a replica: execute and terminate
       on receiving ("commit", cmd):
             log[0] = cmd
             state, output = apply(cmd, state)
             send ("commit", cmd) to all replicas
             terminate
       // as a backup replica in the same view
       on receiving ("propose", cmd, v) and v==view:
          lock = v
          lockcmd = cmd
          send ("lock", cmd, v) to the primary j

What do the next primaries propose? they must read from a quorum and use the value with the highest view number. This is the **view change** protocol:

       // send your highest lock
       on receiving ("view change", i) and view < i:
            view = i
            start timer(i)
            send ("highest lock", lockcmd, lock, i) to replica i
       // as the primary
       on receiving ("highest lock", c, v, j) from n-f distinct replicas and view == j:
            if all values are null (from view 0):
                 mycmd = any value heard from the clients
            otherwise:
                 mycmd = value with the highest view heard
            send ("propose", mycmd, view) to all replicas

When does a replica move from one view to another? When it see that the current primary is not making progress. This is the **view change trigger** protocol:

      on timer(i) expiring and log[0] == null and view == i; or
      on receiving ("blame", i) from f+1 distinct replicas
            send ("blame", i) to all replicas
      on receiving ("blame", i) from n-f distinct and view <= i:
            // this will trigger a timer and a "highest lock message"
            send ("view change", i+1) to all replicas (including self)

Note that the view change trigger protocol can be altered to have a linear communication optimistic path.

### Argument for Safety

**Claim:** let $v$ be the first view were a party commits to value $cmd$ then no primary will propose $cmd' \\neq cmd$ at any view $v'\\geq v$

*Proof:* by induction on $v' \\geq v$. For $v'=v$ this follows since the primary sends just one "propose" value per view. Assume the hypothesis holds for all view $\\leq v'$ and consider the view change of primary $v'\+1$.

Let $W$ be the $n-f$ parties that set $lock = v$ and sent $("lock", cmd, v)$ to the primary $v$ in view $v$.

Let $R$ be the $n-f$ parties that party $v'\+1$ received their $("highest lock", lockcmd, lock, v'\+1)$ for view $v'\+1$.

Since $W \\cap R \\neq \\emptyset$ then the primary of $v'\+1$ must hear from a member of $R$ and from the induction hypothesis we know that this member's lock is at least $v$ and its value must be $cmd$. In addition, from the induction hypothesis, we know that no other member of $W$ can have a lock for a value that is at least $v$ with a value $cmd' \\neq cmd$.

Hence during the view change of view $v'\+1$, the value with the maximum view in $W$ must be $cmd$ with a view $\\geq v$.

### Argument for Liveness

**Claim:** let $v$ be the first view with a non-faulty primary, then all non-faulty parties will commit by the end of view $v$.

*Proof:*

Observe that in any view $<v$, either some non-fualty commits and hence all non-fualty commit and terminate one round later; or otherwise, all non-fualty do not commit, and hence will send a "blame" and later a "view change".

If some non-faulty parties have not decided before entering view $v$ then in view $v$ the non-faulty primary will gather $n-f$ distinct "lock" messages and will send a commit message that will arrive to all non-faulty parties before their $timer(v)$ expires. Hence even of all faulty send a "blame" message there will not be a "view change" message.