---
title: The Lock-Commit Paradigm
date: 2020-11-29 08:02:00 -05:00
tags:
- dist101
author: Ittai Abraham, Kartik Nayak
---

In this post, we explore the Lock-Commit paradigm for consensus protocols. This approach is probably the most celebrated and widely used technique for reaching consensus in a safe manner. This approach is one of the key techniques in [DLS88](https://groups.csail.mit.edu/tds/papers/Lynch/jacm88.pdf) and Lamport's [Paxos](https://lamport.azurewebsites.net/pubs/lamport-paxos.pdf).

We exemplify this paradigm by showing a single-shot [synchronous protocol](/2019-06-01-2019-5-31-models/) (with message delay at most $\Delta$) for [uniform consensus](/2019-06-27-defining-consensus/) that is tolerant to $f$ [omission](/2020-09-13-synchronous-consensus-omission-faults/) failures, given $2f<n$.

Related posts:

1. In synchrony, for non-uniform consensus,  this related [post](/2019-10-31-primary-backup/) shows how to tolerate $k<n$ *crash* failures. A different [post](/2020-09-13-synchronous-consensus-omission-faults/) shows how to tolerate $t<n/2$ *omission* failures (recall that for omision failures, non-uniform consensus means that faulty replicas may commit on incorrect values).

2. This related [post](/2019-11-02-primary-backup-for-2-servers-and-omission-failures-is-impossible/) shows that it is impossible to tolerate $2f\\geq n$ omission failures. As an exercise, you can extend this lower bound to show it is impossible to tolerate $k\+ft \\geq n$ for $k$ crash failures and $f$ omission failures.

3. In a [follow-up post](/2020-11-30-the-lock-commit-paradigm-multi-shot-and-mixed-faults/), we extend this paradigm to a multi-shot protocol that can tolerate both $f$ omission failures and $k$ [crash](/2019-06-07-modeling-the-adversary/) failures given $k\+2f<n$.

## Lock-Commit

Recall that our goal is solving consensus in a system with *clients* and $n$ *replicas*. We are in the Primary-Backup paradigm where the protocol progresses in *views*. In each view $v$, one designated replica (whose id is $v$) is the *primary* of this view and the others are the *backups* of this view. There is a *view change trigger* protocol that decides when to globally execute a *view change* protocol that increments the view (in a single shot synchronous model, it is enough to have $n$ views, but more generally you could have a round-robin or randomized leader election matching of Primaries to views).

The safety risk in consensus is that a replica *commits* to a value but this decision is not known to other replicas. In particular, a new primary in a new view may emerge that does not know about the committed value. The **Lock-Commit paradigm** introduces a *Lock* step before the *Commit* decision and entails the following two important parts:

1. *Lock before you Commit*. To commit a value $cmd$, the primary of view $v$ first makes sure there is a **quorum** of replicas that store a lock that consists of a **lock-value** $cmd$ and a **lock-view** $v$.

2. *As a new Primary: Read and Adopt*. When a new primary starts, it runs a *view change* protocol. In this protocol, the new primary of view $v$ needs to decide which value to try to lock (and eventually commit) in view $v$. A new Primary must read the locks of previous views from a **quorum** of replicas and must adopt the *lock-value* with the highest *lock-view* it sees.

Intuitively, this approach is safe is because *any two quorum sets must have a non-empty intersection, and choosing the lock-value with the highest lock-view will guarantee seeing the committed value* (see the proof below). In this post, we will use quorums that consist of $n-f=f\+1$ replicas.

This Lock-Commit paradigm is very powerful and can be extended to many settings:

1. Since Commit-Lock is based on *quorum intersection*, safety does not rely on any synchrony. Indeed unlike the [Commit-Notify](https://decentralizedthoughts.github.io/2020-09-13-synchronous-consensus-omission-faults/) approach, Commit-Lock can be extended to an asynchronous (or partially synchronous) model.

2. This approach guarantees [uniform consensus](/2019-06-27-defining-consensus/) (so even omission-faulty replicas commit on the same value). In essence, you do not commit before you have proof that the system is [committed](/2019-12-15-consensus-model-for-FLP/).

3. This paradigm can be extended to tolerate malicious adversaries. For $n>2f$, by using [signatures and synchrony](/2019-11-10-authenticated-synchronous-bft/); and for $n>3f$, by using Byzantine Quorums that intersect by at least $f\+1$ replicas.

Here is a Lock-Commit based (uniform) consensus protocol tolerating $f<n/2$ omission faults for a single slot:

## Lock-Commit for omission failures

    // pseudocode for Replica j
    
    log = []     // a log (of size 1) of committed values
    view = 1     // view number that indicates the current Primary
    lock-view = 0     // the highest view a propose was heard
    lock-value = null // the value associated with the highest lock
    start timer(1) // start timer for view 1 (for duration 8 Delta)
    
    
    while true:
       // as primary 1: replica 1 and view is 1
       on receiving first cmd from client and j == 1 and view == 1:
             send ("propose", cmd, view) to all replicas
       
       // as a backup replica 
       on receiving ("propose", cmd, v) and v == view:
             lock-view = v
             lock-value = cmd
             send ("lock", cmd, v) to the primary j
       
       // as a primary: replica j and view is j
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

When does a replica move from one view to another? When it sees that the current primary is not making progress. This is the **view change trigger** protocol:

      on timer(i) expiring and log[0] == null and view == i; or
      on receiving ("blame", i) from f+1 distinct replicas
             send ("blame", i) to all replicas
      on receiving ("blame", i) from n-f distinct and view <= i:
             // this will trigger a timer and a "highest lock message"
             send ("view change", i+1) to all replicas (including self)

Note that the view change trigger protocol can be simplified and also altered to have a linear communication optimistic path. Assuming synchrony, we could for example, simply trigger a view change after each 8 message delays. The more elaborate option described above will allow us to generalize in later posts.

What do the next primaries propose? To maintain safety, they must read from a quorum and use the lock-value with the highest lock-view. This is the essence of the **view change** protocol:

       // send your highest lock
       on receiving ("view change", v) and view < v:
             view = v
             // start timer for 8 Delta
             start timer(v)
             send ("highest lock", lock-value, lock-view, v) to replica v
             
       // as the primary (you are replica j and view is j)
       on receiving ("highest lock", l-val, l-view, j) from n-f distinct replicas and view == j:
             if all l-val are null (all l-view are 0):
                 my-val = any value heard from the clients
             otherwise:
                 my-val = l-val with the highest l-view
             send ("propose", my-val, view) to all replicas


### Argument for Safety

The key intuition for safety is a quorum intersection argument between two quorums:
$W$: A set of replicas who sent a lock message on the committed value (and are hence locked on it).
$R$: A set of replicas who send their highest locks to a primary in any higher view.

If $\|W \cap R\| \geq 1$ replica, then the committed value is always passed on to the next leader as a lock-value whose lock-view is maximial. This argument thus holds for all subsequent views and is formalized using induction in the following claim.

**Claim:** Let $v$ be the first view where some replica commits to some value $cmd$.
Then, no primary will propose $cmd' \\neq cmd$ at any view $v'\\geq v$.

*Proof:*

By induction on $v' \\geq v$. For view $v'=v$, this follows since the primary sends just one "propose" value per view. Assume the hypothesis holds for all views $\\leq v'$ and consider the view change of primary $v'\+1$ to view $v'\+1$.

Let $W$ be the set of $n-f$ distinct replicas that set $lock-view = v$ and sent $("lock", cmd, v)$ to the primary $v$ in view $v$.

Let $R$ be the $n-f$ replicas that the primary $v'\+1$ received their $("highest$ $lock", lock$-$val, lock$-$view, v'\+1)$ for view $v'\+1$.

Since $W \\cap R \\neq \\emptyset$, then the primary of $v'\+1$ must hear from a member of $R$. 
Fix some $a \in W \\cap R$.
By the definition of $R$ and from the induction hypothesis we know that for the view change to view $v'+1$, replica $a$'s lock-view is at least view $v$ and its lock-value must remain $cmd$. In addition, from the induction hypothesis, we know that no other member of $W$ can have a lock that has a lock-view that is at least $v$ with a lock-value $cmd' \\neq cmd$.

Hence, during the view change of view $v'\+1$, the value with the maximum view in $W$ must have the value $cmd$ and be with a view $\\geq v$.

Observe that this argument did not rely on synchrony.

### Argument for Liveness

**Claim:** Let $v$ be the first view with a non-faulty primary. 
Then, all non-faulty replicas will commit by the end of view $v$.

*Proof:*

Observe that in any view $<v$, either some non-faulty commits and hence all non-faulty commit and terminate one message delay later; or otherwise, all non-faulty do not commit, and hence will send a "blame" and hence all non-faulty will send a "view change" and join the next view within one round trip.

Observe that this argument requires synchrony: it uses the fact that the timers will expire and all start the next view within one message delay.

If some non-faulty replicas have not decided before entering view $v$, then all non-faulty will enter view $v$ within one message delay. In view $v$, the non-faulty primary will gather $n-f$ distinct "lock" messages and will send a commit message that will arrive to all non-faulty replicas before their $timer(v)$ expires (assuming the timer is larger than 8 message delays and using the fact that they all started their timer with a gap of at most one message delay). Hence, even if all faulty replicas send a "blame" message, there will not be enough "blame" messages to form a "view change" message.

Again observe the use of synchrony.


### Remarks
1. We did not fully specify how the clients send commands to the replicas. For simplicity, we can assume that clients broadcast their requests to all replicas. In practice, one can add a mechanism to track the primary and resend commands to the new primary when there is a view change.

2. In this post, we do not talk about executing the commands (as required in a [state machine replication protocol](/2019-10-15-consensus-for-state-machine-replication/)) nor about how clients can [learn](...) about consensus. The protocol can be easily modified to handle these aspects.

3. Observe that the only requirement is that $\|W \cap R\| \geq 1$ (honest) replica. Thus, while we consider using quorums of size $n-f = f+1$, the sizes are flexible and do not have to be symmetric. This is the idea behind [Flexible Paxos](https://arxiv.org/pdf/1608.06696v1.pdf).

### Acknolegments
Many thanks to [Alin Tomescu](https://alinush.github.io/) for valuable comments and insights!

Please answer/discuss/comment/ask on [Twitter](...).
