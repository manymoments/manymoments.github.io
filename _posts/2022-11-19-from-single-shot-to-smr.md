---
title: From Single-Shot Consensus to State Machine Replication
date: 2022-11-19 04:00:00 -05:00
tags:
- dist101
author: Ittai Abraham
---

In this post we explore the path from *Single-Shot Consensus*, via *Write-Once Registers*, to *Log Replication*, and finally to *State Machine Replication*. We begin by defining all four problems assuming *minority omission failures* and *partial synchrony*. This post continues our previous post [on Paxos from Recoverable Broadcast](https://decentralizedthoughts.github.io/2022-11-04-paxos-via-recoverable-broadcast/). 

### (Single-Shot) Consensus

In *Consensus* there are $n$ parties that each have an input value, and the goal is to output a value such that:

**Uniform Agreement**: All parties that output a value, output the same value. 

**Termination**: All non-faulty parties eventually output a value and terminate.

**Validity**: The output is an input of one of the parties.

We interchangeably call this problem Consensus and Agreement. Note that [Agreement and Broadcast](https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/) are [deeply connected](https://decentralizedthoughts.github.io/2020-09-14-broadcast-from-agreement-and-agreement-from-broadcast/) in this setting.

### Write-Once Register State Machine Replication

Instead of just $n$ parties, there are two types of entities: some *clients* and $n$ *servers* (sometimes also called *replicas*). A minority of the servers and *any* number of clients may have omission failures.

Each client has a *local* component called a **client library**. The client interacts with the client library and the library interacts with the servers. Essentially, the client library provides the client with the illusion of talking to a single (ideal) entity. 

The clients have inputs and they can send *requests* to their client library. Clients are sequential and will send a new request only after the client library sends back a *response* to the existing request. 

For a Write-Once Register there are two types of requests: ```write(v)``` which gets an input value and returns a value; and ```read``` which returns a response with either an output value or a special value $\bot$, with the following properties:

**Termination**: If a non-faulty client issues a *request* then it eventually gets a *response*.

**Write-Once Agreement**: If two requests return $x$ and $x'$ then $\|x \cup x' \setminus \{\bot \}\| \leq 1$, so if $x$ and $x'$ are both not $\bot$ then $x=x'$.

**Write-Once Validity**: If a request returns a non-$\bot$ value then there was some client write request with this value.

To make the problem non-trivial, we also require the system to return a non-$\bot$ value after any write. Moreover, if there was just one write, this must be the returned value:

**Write-Once Correctness**: If there is a write request with the value $v$ that gets a response at time $t$, then any request $R$ that starts after $t$ returns a non-$\bot$ value. Moreover, if no other write request started before $t$, the value returned from $R$ is $v$.

*Exercise 1: show how to implement a fault-tolerant Write-Once Register given a consensus protocol. You will need to implement the client library.*

An alternative way to define a Write-Once Register is that it abstracts an *ideal functionality* that writes down the first value it hears (literally a register that only writes once).

### Log Replication

The setting is the same as above: some clients and $n$ servers. Clients can make two types of requests: ```read``` which now returns a **log of values** (or $\bot$ for the empty log)  as a response; and ```write(v)``` which gets an input value and also returns a response that is a log of values.

Clients can have multiple input values at different times. 

**Termination**: If a non-faulty client issues a *request* then it eventually gets a *response*.

**Log Agreement**: Any two requests return logs then one is a prefix of the other.

**Log Validity**: Each value in the log can be uniquely mapped to a write request.

**Log Correctness**: If there is a write request with the value $v$ that gets a response at time $t$, then any request that starts after $t$ returns a log of values that includes $v$.

The ```read``` request may not scale well because the log may have an unbounded size. A more refined read request can ask for parts of the log. We choose this generic interface for simplicity.

An alternative way to define Log Replication is that it abstracts an *ideal functionality* that adds write commands to a log.


### State Machine Replication

There is a state machine which is a function that takes input and current state and returns the output and the next state:
$$SM(cmd, S)=(out,S')$$
The state machine has some *genesis state* $S_0$.
Note that this is a very general definition. Clients can submit requests  ```cmd``` (can define ```read``` and ```write``` commands via the state machine).  Given a log $L=c_1,\dots,c_k$, naturally define $SM(L)=(out,S)$ as the sequential application of the log of commands $L$ on $SM$ starting with $S_0$. 

The core difference (in terms of what the client sees) between Log replication and SMR replication is that instead of returning a log of values $L$, the client library returns the output of $SM(L)$. So the servers (or the client library) need to execute state machine transactions based on the command log.

The properties of Termination, Agreement, Validity, and Correctness are all as in Log replication but on the induced log:


**Termination**: If a non-faulty client issues a *request* then it eventually gets a *response*.


**SMR Agreement**: If two requests return outputs $out_1$ and $out_2$ then there are two logs $L_1$ and $L_2$ such that one is a prefix of the,  $out_1$ is the output of $SM(L_1)$, and $out_2$ is the output of $SM(L_2)$.

**SMR Validity**:  The request returns $out$ which is the output of some $SM(L)$ and each value in $L$ can be mapped uniquely to a client request.

**SMR Correctness**: If there is a request with the value $cmd$ that gets a response at time $t$, then any request that starts after time $t$ returns the output of some $SM(L)$ such that $L$ includes $cmd$.

Note that SMR replication can implement *any* state machine. In particular, it can also (trivially) implement Log Replication. 

*Exercise 2: show how to implement SMR Replication given Log replication. In particular, using a bounded amount of space at the client library.*



## From Write-Once Registers to Log Replication

There are two main ways to obtain Log Replication from Write-Once Registers:

- **Array**: servers maintain an array consisting of separate write-once register instances for each position in the array. While each instance is independent, the view number of each instance is global and common to all instances. Once the write-once register instance at position $j$ in the array reaches consensus, the servers start the write-once register instance in the array at position $j+1$. This approach can be extended to use a sliding window of $c \geq 1$ pending write-once register instances. If all write-once register instances for positions  1 up to $x$ in the array are all committed, parties participate (in parallel) in write-once register instances for positions $x+1,\dots,x+c$ of the array. This allows running multiple write-once register instances in parallel. It also makes the reduction to SMR more delicate: must use the largest *consecutive* sequence in the array that is committed to define the actual committed log. As an example, this is the path PBFT takes.


- **Linked list**: servers participate in a perpetual single instance of a write-once register. Each server stores its currently committed log as a linked list $L = c_j \rightarrow ... \rightarrow c_{1}$. Each server then sets its input (proposal) to be a new linked whose head is an uncommitted client command $cmd$ that points to the committed log:  $L' = cmd \rightarrow c_j \rightarrow ... \rightarrow c_{1}$. Consensus is done on the whole log and each time a new log is committed the servers continue to propose a larger log. While this does not allow parallel consensus instances, it does allow to *pipeline* consecutive consensus instances and also allows for optimistic execution in the SMR setting. For some underlying consensus protocols, pipelining and optimism can provide performance benefits. As an example, this is the path HotStuff takes. 


## Responsiveness: Good case efficiency in the multi-shot setting


As we have seen, in the worst case, even one single-shot consensus can take $O(f \Delta)$ time. But what about the good case when the system is in synchrony and the primary is non-faulty? The following definition captures the best-case guarantees that we would like to obtain:

**Single-Shot Responsiveness**: if the systems is in synchrony, the primary is non-faulty and each message arrives after $\delta << \Delta$ time then the time to terminate is $O(\delta)$.

What about multi-shot? The obvious path is to do one consensus per view. With this approach, using our $10\Delta$ timeout to switch views, to do $k$ consensus instances, even if the system is in synchrony, and even if all the primaries are non-faulty, would take $O(\Delta k)$. A natural goal would be to try to obtain a better bound:

**Multi-Shot Responsiveness**: if the system is in synchrony, the primaries for the $k$ next agreements are non-faulty and each message arrives after $\delta << \Delta$ time then the time to reach $k$ consecutive agreements is  $O(\delta k)$.

Does it matter if we get $(k \Delta)$ or $O(k \delta)$? The answer is that it depends. If the gap between $\delta$ and $\Delta$ is not large, then it does not matter much. In some systems, there is no need to move faster than one decision per $O(\Delta)$ time, while in other systems obtaining better best-case performance is critical. In any case, in the worst case, even one decision may take $O(\Delta f)$ time, so this measure is only measuring the good case.


### Obtaining Multi-Shot responsiveness via a Stable Leader

Instead of replacing leaders every $10 \Delta$ time, let's keep the same leader and replace it only when it fails. This way the same stable leader can consecutively commit commands using recoverable broadcast without any additional waiting and without calling recover-max in between commands. This change obtains Multi-Shot Responsiveness in the array and linked list paradigms. Many deployed SMR systems use the stable leader paradigm due to the performance advantages of multi-shot responsiveness.

There is no safety concern: each consensus instance has its independent safety properties maintained. 

But what about liveness? There is a new challenge: we cannot use a fixed time to change views, so we need some new mechanism to decide when to move to a new view and to make sure this move is synchronized between all parties. Here is how this is done:

For a view $v$, a party can be in one of three states:
1. start-view-$v$; 
2. blame-$v$; 
3. stop-view-$v$. 

Let's go over each transition:

* From start-view-$v$ to blame-$v$: this is when a party is not seeing progress in the current view. The first reason to blame is if a heartbeat or message from the current primary does not arrive in $2 \Delta$ from the previous one. The second reason to blame is if a client request arrives but the primary does not reach a decision on it in the required time. In either case, when moving to blame-$v$, the party sends a ```<blame v>``` message to all parties.
* From blame-$v$ to stop-$v$: should a party in blame-$v$ stop processing messages in view $v$?  Not so fast, maybe the party is faulty not the primary. To overcome this ambiguity, a party waits for $f+1$ distinct ```<blame v>``` messages before moving to stop-view-$v$. When moving to stop-view-$v$ the party sends a ```<stop-view v>``` message to all parties. At this point, the party stops responding to view $v$ messages (in partial does not echo messages for view $v$).
* From stop-$v$ to start-$v+1$: should the party move to view $v+1$ when it reaches stop-view $v$? Not so fast, maybe the party is the only non-faulty party that reached stop-$v$? To synchronize, we make stop-$v$ contagious! If a party hears a ```<stop-view v>``` message and it did not send it yet then it sends ```<stop-view v>``` to all parties.
* Parties start-view-$v+1$ (start recover max for view $v+1$) when they hear $f+1$ stop-view-$v$ messages.


**Lemma**: If a party starts view $v+1$ in time $t$, then all non-faulty parties will start view $v+1$ in at most $t+2\Delta$ time.

*Proof*: a party starts view $v+1$ at time $T$ if it heard $f+1$ ```<stop-view v>``` messages. At least one of them is from a non-faulty party. So all non-faulty will receive at least one ```<stop-view v>``` by time $T+\Delta$, and hence all non-faulty parties will send ```<stop-view v>```  by time $T+\Delta$. So all non-faulty parties will receive at least $f+1$ ```<stop-view v>``` by time $T+2\Delta$.



With this three-state technique parties can make sure that a non-faulty primary after GST will not be removed (incorrectly blamed), while in any case of a view change, all parties will be moving in sync (up to $2\Delta$). The first property is critical for the responsiveness property of the stable leader and the second property is critical for the liveness property.

For multi-shot responsiveness, do we have to use a stable leader? Can we do the same for a sequence of non-faulty rotating leaders?

### Obtaining Multi-Shot Responsiveness with rotating leaders

With a stable leader, we could keep the same view for multiple consecutive commands from the same stable leader. For rotating leaders, we need to change views each time we change primaries. The idea is to use the $n-f$ echoes as both a commit message and also an implicit report max message for the next view! So once the primary for view $v+1$ sees $n-f$ echo messages for view $v$ it can immediately propose the next value for view $v+1$. 

For safety, why is recoverability okay even though we did not explicitly send ```<echoed-max>``` between views? Recover max for view $v+1$ only needs the highest echo, and we have an echo in view $v$ which is the highest possible (at the beginning of view $v+1$). So safety is maintained. Moreover, we obtain the required multi-shot responsiveness. What about liveness?

We again use the three states: (1) start-view-$v$; (2) blame-$v$; (3) stop-view-$v$. The only difference is that this time we can simply use a $10 \Delta$ timer for moving into blame $v$ (or cancel the timer if we change to the next view).

So a primary of view $v+1$ can skip doing recover max for view $v+1$ if it hears $n-f$ echos from view $v$,  otherwise, it runs the regular protocol.

### Note on Strong Responsiveness

**Single Shot Strong Responsiveness**: assuming all parties are non-faulty, the time after GST to decide is $O(\delta)$. 

This property is strictly stronger than Single Shot Responsiveness as it covers any full partial synchrony, not just executions that are fully synchronous.


