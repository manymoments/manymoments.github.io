---
title: 'The Lock-Commit Paradigm: Multi-shot and Mixed Faults'
date: 2020-11-30 09:01:00 -05:00
tags:
- dist101
author: ittai abraham, Kartik Nayak
---

In this follow up post, we show a multi-shot [synchronous protocol](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) for [uniform consensus](https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/) that can tolerate $f$ [omission](https://decentralizedthoughts.github.io/2020-09-13-synchronous-consensus-omission-faults/) failures, given $2f < n$.
We then extend it to one that tolerates both $f$ omission failures and $k$ [crash](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) failures given $k\+2f < n$.

## Multi-shot Lock-Commit

Instead of solving consensus on a [single command](https://decentralizedthoughts.github.io/2020-11-29-the-lock-commit-paradigm/), we implement an ever-growing **commitLog** of decisions that is extended by **appending** commands to it. Similar to the previous post, we do not talk about executing the commands as well as how clients can learn about consensus.

# Multi-shot Lock-Commit for omission failures

Unlike the single-shot protocol, this protocol never terminates, it just appends commands to an ever-increasing log of committed commands called *commitLog*. Another change is that each time the commitLog is sent, the recipient checks if its commitLog is behind (missing commands) and then updates its log (**learn** about committed commands it missed).

Once the primary commits a command, we use the boolean *readyToPropose* to indicate that the primary can send a new proposal to append to the log. 


    // pseudocode for Replica j
    
    state = init // the state of the state machine
    commitLog = []     // a log of committed commands
    view = 1     // view number that indicates the current Primary
    lockcmd = null
    lock = 0     // the highest view a propose was heard
    mycmd = null
    start timer(1) // start timer for first view
    readyToPropose = true // primary can send another propose
    
    while true:
    
       // as a primary (you are replica j)
       on receiving cmd from client, view == j, readyToPropose == true:
             readyToPropose = false
             send ("propose", commitLog, cmd, view) to all replicas
             
       // as a backup replica in the same view
       on receiving ("propose", CL, cmd, v) and v==view:
             // learn if needed
             if CL >= commitLog then 
                 commitLog = CV
                 lock = v
                 lockcmd = cmd
                 send ("lock", commitLog, cmd, v) to the primary j

       on receiving ("lock", CL, cmd, view) from n-f distinct replicas and view == j:
             // append to log
             commitLog.append(cmd)
             send ("commit", commitLog, cmd, view) to all replicas
             readyToPropose = true
             
       // as a replica: execute and terminate
       on receiving ("commit", CL, cmd, v):
             // learn if needed
             if CL >= commitLog then
                 commitLog = CV
                 // append to log
                 commitLog.append(cmd)
                 restart timer(v)

Note that as an optimization, we could have piggybacked the "commit" message with the next "propose" message.

The **view change trigger** protocol is similar to the single-shot, except that timer(i) is restarted each time a replica appends to commitLog (see "restart timer" above). This implements a *stable leader* variant where a primary can commit many entries and is replaced only when there are $f\+1$ "blame" messages. An alternative variant that replaces the primary every round will be explored in later posts.

      on timer(i) expiring and view == i; or
      on receiving ("blame", i) from f+1 distinct replicas
            send ("blame", i) to all replicas
      on receiving ("blame", i) from n-f distinct and view <= i:
            // this will trigger a timer and a "highest lock message"
            send ("view change", i+1) to all replicas (including self)

The **view change** protocol is modified so the new primary learns about commands it has missed (this variant is different than Raft where the new primary cannot learn). This means that the new primary must choose the value of the highest lock for the proposals that are related to the largest commitLog it has seen. Here is the view change for replica $j$:

       // send your commit log and your highest lock
       on receiving ("view change", v) and view < v:
            view = v
            start timer(v)
            send ("highest lock", commitLog, lockcmd, lock, v) to replica v
            
       // as the primary (you are replica j)
       on receiving messages M={("highest lock", CL, cmd, v, j)} from n-f distinct replicas and view == j:
            Let CL be the longest commit log in M.CL
            // learn if needed
            If CL > commitLog then commitLog = CV
            Let H be the set of messages in M where M.CL == commitLog
            if H is empty or all H.v == 0:
                 mycmd = any value heard from the clients
            otherwise:
                 // use the value of the message in H with highest view
                 let m in H be a message with maximum H.v 
                 mycmd = m.cmd
            readyToPropose = false
            send ("propose", mycmd, view) to all replicas

Observe that when a primary proposes a message, as well as when replicas send their highest lock to the next primary, the entire commit log is sent in the message. This ensures that, at any time, whenever a replica is locked on value, all the previous log positions are committed. While sending the entire log each time brings in conceptual simplicity, it is expensive to send the entire log. In a future post, we will discuss how this can be optimized (for example one can just send the digest of the log).

# Multi-shot Lock-Commit tolerating both omission and crash failures

When you have both $f$ omission failures and $k$ crash failures the primary needs to guarantee that all non-crashed replicas receive a  "propose" message and lock. Just waiting for $n-(k\+f)$ "lock" messages is not safe because it may be that the primary is omission faulty and these $n-(k\+f)=f\+1$ parties all crash. The primary does not know if it is omission faulty!

Instead, the primary asks the replicas to "help" spread the "propose" message. Each helper sends the "propose" to everyone and then sends a "help done". This way, the primary can wait for $n-(k\+f)$ parties to acknowledge "help done" and know that at least one of the helpers was non-omission faulty. Since it received a "help done", then this non-omission faulty did not crash before sending the message to everyone!
Here is the pseudocode for Replica $j$:
    
    state = init // the state of the state machine
    commitLog = []     // a log of committed commands
    view = 1     // view number that indicates the current Primary
    lockcmd = null
    lock = 0     // the highest view a propose was heard
    mycmd = null
    start timer(1) // start timer for first view
    readyToPropose = true // primary can send another propose
    
    
    while true:
    
       // as a primary (you are replica j)
       on receiving cmd from client, view == j, readyToPropose == true:
             send ("help", commitLog, cmd, view) to all replicas
             readyToPropose = false
       on receiving ("help", CL, cmd, v) and v==view:
             // learn if needed
             if CL >= commitLog then
                commitLog = CV
                send ("propose", commitLog, cmd, v) to all replicas
                send ("help done", commitLog, cmd, v) to the primary j
       on receiving ("help done", CL, cmd, view) from f+1 distinct replicas and view == j:
             // append to log
             commitLog.append(cmd)
             send ("commit", commitLog, cmd, view) to all replicas
             readyToPropose = true
       // as a replica: execute and terminate
       on receiving ("commit", CL, cmd, v):
             // learn if needed
             if CL >= commitLog then
                commitLog = CV
                // append to log
                commitLog.append(cmd)
                restart timer(v)
       // as a backup replica in the same view
       on receiving ("propose", CL, cmd, v) and v==view:
             // learn if needed
             if CL >= commitLog then
                commitLog = CV
                lock = v
                lockcmd = cmd
           

Note that as an optimization, we could have piggybacked the "commit" message with the next "propose" message.

### Remarks

Just like the previous post, we did not fully specify how the clients send commands to the replicas and we do not talk about executing the commands. We here on the consensus protocol and defer execution and clients to later posts.

### Argument for Safety

**Claim:** Fix any log position $j$, let $v$ be the first view where a party commits to value $cmd$.
Then, no primary will propose $cmd' \\neq cmd$ at any view $v'\\geq v$ for the log position $j$.

*Proof:*

By induction on $v' \\geq v$. For $v'=v$, this follows since the primary sends just one "propose" value per view on a given log position. Assume the hypothesis holds for all view $\\leq v'$ and consider the view change of primary $v'\+1$.

Let $W$ be the parties that set $lock = v$ in view $v$ for log position $j$. Since primary $v$ had at least $f\+1$ helpers that did not crash, then at least one of them must have sent the proposal to all non-faulty parties.

Let $R$ be the set of at least $n-(f\+k)$ parties that party $v'\+1$ received their $("highest lock", lockcmd, lock, v'\+1)$ for view $v'\+1$ on log position $j$. 

Since  $\vert N \\setminus W\vert  \\leq f$ and $\vert R\vert  \\geq f\+1$ it must be that $W \\cap R \\neq \\emptyset$. So the primary of $v'\+1$ must hear from a member of $R$ and, from the induction hypothesis, we know that this member's lock is at least $v$ and its value must be $cmd$. In addition, from the induction hypothesis, we know that no other member of $W$ can have a lock for a value that has a view of at least $v$ with a value $cmd' \\neq cmd$.

Hence, during the view change of view $v'\+1$, the value with the maximum view in $W$ must be $cmd$ with a view $\\geq v$.

### Argument for Liveness

For liveness, we need to modify the blame threshold to $f\+1$ and the view change threshold to $n-(f\+k) \geq f+1$.

**Claim:** Fix some log position $j$. Let $v$ be the first view with a non-faulty primary.
Then, all non-faulty parties will commit to the log position $j$ by the end of view $v$.

*Proof:*

Observe that in any view $<v$, either some non-faulty replica commits and hence all non-faulty replicas commit and terminate one round later; or otherwise, all non-faulty do not commit, and hence will send a "blame" and hence all non-faulty will send a "view change".

If some non-faulty parties have not decided before entering view $v$, then all non-faulty will enter view $v$ within one message delay. In view $v$, the non-faulty primary will gather $n-(f\+k)$ distinct "help done" messages and will send a commit message that will arrive to all the non-faulty parties before their $timer(v)$ expires (assuming the timer is larger than 6 message delays). Hence, even if all omission faulty send a "blame" message, there will not be a "view change" message.

Hence the non-faulty leader of view $v$ will continue to append messages to the log and will eventually reach position $j$.

Please answer/discuss/comment/ask on [Twitter](...).

