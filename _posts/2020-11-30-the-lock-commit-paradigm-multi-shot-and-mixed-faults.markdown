---
title: 'The Lock-Commit Paradigm: Multi-shot and Mixed Faults'
date: 2020-11-30 03:01:00 -11:00
published: false
---

In this follow up post, show a multi-shot [synchronous protocol](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) for [uniform consensus](https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/) that can $f$ [omission](https://decentralizedthoughts.github.io/2020-09-13-synchronous-consensus-omission-faults/) failures given $2f<n$ and then extend to one that  tolerate both $f$ omission failures and $k$ [crash](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) failures given $k\+2f<n$.

## Multi-shot Lock-Commit

Instead of reaching agreement on a single entry, we will have an ever growing \*\*commitLog \*\*that we will extend by **appending** commands to it.

# Multi-shot Lock-Commit for omission failures

The main change is that this protocol never terminates, it just appends more commands to the commitLog. Another change is that each time the commitLog is sent, the receiver may update its commitLog and **learn** about committed commands it missed.

    // pseudocode for Replica j
    
    state = init // the state of the state machine
    commitLog = []     // a log of committed commands
    view = 1     // view number that indicates the current Primary
    lockcmd = null
    lock = 0     // the highest view a propose was heard
    mycmd = null
    start timer(1) // start timer for first view
    
    
    while true:
    
       // as a primary (you are replica j)
       on receiving first cmd from client and j == 0 and view == 0:
            send ("propose", commitLog, cmd, view) to all replicas
       on receiving ("lock", CL, cmd, view) from n-f distinct replicas and view == j:
             // append to log
             commitLog.append(cmd)
             send ("commit", commitLog, cmd, view) to all replicas
       // as a replica: execute and terminate
       on receiving ("commit", CL, cmd, v):
             // learn if needed
             if CL > commitLog then commitLog = CV
             // append to log
             commitLog.append(cmd)
             restart timer(v)
       // as a backup replica in the same view
       on receiving ("propose", CL, cmd, v) and v==view:
             // learn if needed
             if CL > commitLog then commitLog = CV
             lock = v
             lockcmd = cmd
             send ("lock", commitLog, cmd, v) to the primary j

The **view change trigger** protocol is same, but since timer(i) is restarted each time a replica appends to commitLog then this variant implements a stable leader approach where a primary can commit many entries in the log and is replaced only when there are $f\+1$ "blame" messages. An alternative approach that replaces the primary every round will be explored in later posts.

      on timer(i) expiring and view == i; or
      on receiving ("blame", i) from f+1 distinct replicas
            send ("blame", i) to all replicas
      on receiving ("blame", i) from n-f distinct and view <= i:
            // this will trigger a timer and a "highest lock message"
            send ("view change", i+1) to all replicas (including self)

The **view change** protocol is modified so the new primary learns about commands it has missed (this variant is different than Raft). This means that the new primary must choose the value of the highest lock that related to the largest commit log it has seen

       // send your highest lock
       on receiving ("view change", v) and view < v:
            view = v
            start timer(v)
            send ("highest lock", commitLog, lockcmd, lock, v) to replica v
       // as the primary (you are replica j)
       on receiving ("highest lock", CL, c, v, j) from n-f distinct replicas and view == j:
            // learn if needed
            if any CL > commitLog then commitLog = CV
            Let H be the set of "highest lock" with CL == commitLog
            if all heard values in H are null (or H is empty):
                 mycmd = any value heard from the clients
            otherwise:
                 mycmd = value in H with the highest view heard
            send ("propose", mycmd, view) to all replicas

# Multi-shot Lock-Commit tolerating mixed failures

When you have both $t$ omission failures and $k$ crash failures the primary needs to guarantee that all non-crashed replicas receive a  "propose" message and lock. Just waiting for $n-(k-t)$ "lock" messages is not safe because it may be that the primary is omission faulty and these $n-(k-t)=t\+1$ parties all crash. The primary does not know if its omission faulty!

Instead, the primary asks the replicas to "help" spread the propose. Each helper sends the propose to everyone and then sends a "help done". This way, the primary can wait for $n-(k\+t)$ parties to acknowledge "help done" and know that at least one of the helpers was non-omission  faulty!

    // pseudocode for Replica j
    
    state = init // the state of the state machine
    commitLog = []     // a log of committed commands
    view = 1     // view number that indicates the current Primary
    lockcmd = null
    lock = 0     // the highest view a propose was heard
    mycmd = null
    start timer(1) // start timer for first view
    
    
    while true:
    
       // as a primary (you are replica j)
       on receiving first cmd from client and j == 0 and view == 0:
            send ("help", commitLog, cmd, view) to all replicas
       on receiving ("help", CL, cmd, v) and v==view:
             // learn if needed
             if CL > commitLog then commitLog = CV
             send ("propose", commitLog, cmd, v) to all replicas
             send ("help done", commitLog, cmd, v) to the primary j
       on receiving ("help done", CL, cmd, view) from f+1 distinct replicas and view == j:
             // append to log
             commitLog.append(cmd)
             send ("commit", commitLog, cmd, view) to all replicas
       // as a replica: execute and terminate
       on receiving ("commit", CL, cmd, v):
             // learn if needed
             if CL > commitLog then commitLog = CV
             // append to log
             commitLog.append(cmd)
             restart timer(v)
       // as a backup replica in the same view
       on receiving ("propose", CL, cmd, v) and v==view:
             // learn if needed
             if CL > commitLog then commitLog = CV
             lock = v
             lockcmd = cmd
             send ("lock", commitLog, cmd, v) to the primary j

### Argument for Safety

**Claim:** let $v$ be the first view were a party commits to value $cmd$ then no primary will propose $cmd' \\neq cmd$ at any view $v'\\geq v$

*Proof:*

By induction on $v' \\geq v$. For $v'=v$ this follows since the primary sends just one "propose" value per view. Assume the hypothesis holds for all view $\\leq v'$ and consider the view change of primary $v'\+1$.

Let $W$ be the $n-f$ parties that set $lock = v$ in view $v$. Since primary $v$ had at least $t\+1$ helpers that did not crash, then at least one of them must have sent the proposal to all non-faulty parties.

Let $R$ be the set of at least $n-(t\+k)$ parties that party $v'\+1$ received their $("highest lock", lockcmd, lock, v'\+1)$ for view $v'\+1$. 

Since  $|N \\setminus W| \\leq t$ and $|R| \\geq t\+1$ it must be that $W \\cap R \\neq \\emptyset$. So the primary of $v'\+1$ must hear from a member of $R$ and from the induction hypothesis we know that this member's lock is at least $v$ and its value must be $cmd$. In addition, from the induction hypothesis, we know that no other member of $W$ can have a lock for a value that is at least $v$ with a value $cmd' \\neq cmd$.

Hence during the view change of view $v'\+1$, the value with the maximum view in $W$ must be $cmd$ with a view $\\geq v$.

### Argument for Liveness

For liveness we need to modify the blame threshold to $t\+1$ and view change threshold to $n-(t\+k)$.

**Claim:** let $v$ be the first view with a non-faulty primary, then all non-faulty parties will commit by the end of view $v$.

*Proof:*

Observe that in any view $<v$, either some non-faulty commits and hence all non-faulty commit and terminate one round later; or otherwise, all non-faulty do not commit, and hence will send a "blame" and hence all non-faulty will send  a "view change".

If some non-faulty parties have not decided before entering view $v$ then all non-faulty will enter view $v$ within one message delay. In view $v$ the non-faulty primary will gather $n-(t\+k)$ distinct "help done" messages and will send a commit message that will arrive to all non-faulty parties before their $timer(v)$ expires (assuming the timer is larger than 6 message delays). Hence even of all omission faulty send a "blame" message there will not be a "view change" message.