---
title: From Single-Shot Consensus to State Machine Replication
date: 2022-11-19 04:00:00 -05:00
tags:
- dist101
author: Ittai Abraham
---

In this post we explore the path from *Single-Shot Consensus*, via *Write-Once Registers*, to *Log Replication*, and finally to *State Machine Replication*. We begin by defining all four problems assuming *minority omission failures* and *partial synchrony*. This post continues our previous post [On Paxos from Recoverable Broadcast](https://decentralizedthoughts.github.io/2022-11-04-paxos-via-recoverable-broadcast/). 

### (Single-Shot) Consensus

In *Consensus* there are $n$ parties that each have an input value, and the goal is to output a value such that:

**Uniform Agreement**: All parties that output a value, output the same value. 

**Termination**: All non-faulty parties eventually output a value and terminate.

**Validity**: The output is an input of one of the parties.

We interchangeably call this problem Consensus and Agreement. Note that [Agreement and Broadcast](https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/) are [deeply connected](https://decentralizedthoughts.github.io/2020-09-14-broadcast-from-agreement-and-agreement-from-broadcast/) in this setting.

### Write-Once Register State Machine Replication

Instead of $n$ parties, we have some *clients* and $n$ *servers* (sometimes also called *replicas*). A minority of the servers and *any* number of clients may have omission failures.

Each client has a *local* component called a **client library**. The client interacts with the client library and the library interacts with the servers. Essentially, the client library provides the client with the illusion of talking to a single (ideal) entity. 

The clients have inputs and they can send *requests* to their client library. Clients are sequential and will send a new request only after the client library sends back a *response* to the existing request. 

For a Write-Once Register there is one type of request: ```write(v)``` which gets an input value and returns a value; and ```read``` which returns a response with either an output value or a special value $\bot$, with the following properties:

**Termination**: If a non-faulty client issues a *request* then it eventually gets a *response*.

**Write-Once Agreement**: If two requests return $x$ and $x'$ then $|x \cup x' \setminus \{\bot \}| \leq 1$, so if $x$ and $x'$ are both not $\bot$ then $x=x'$.

**Write-Once Validity**: If a request returns a non-$\bot$ value then there was some client write request with this value.

To make the problem non-trivial, we also force the system to return a non-$\bot$ value after any write and if there was just one write, this must be the returned value:

**Write-Once Correctness**: If there is a write request with the value $v$ that gets a response at time $t$, then any request $R$ that starts after $t$ returns a non-$\bot$ value. Moreover, if no other write request started before $t$, the value returned from $R$ is $v$.

*Exercise 1: show how to implement a fault-tolerant Write-Once Register given a consensus protocol. You will need to implement the client library.*

### Log Replication

The setting is the same as above with clients and servers. Clients have two types of requests: ```read``` which now returns a response that is a **log of values** (or $\bot$ for the empty log) and ```write(v)``` which gets an input value and a log of values.

Clients can have multiple inputs at different times. 

**Termination**: If a non-faulty client issues a *request* then it eventually gets a *response*.

**Log Agreement**: Any two requests return logs then one is a prefix of the other.

**Log Validity**: Each value in the log can be uniquely mapped to a write request.

**Log Correctness**: If there is a write request with the value $v$ that gets a response at time $t$, then any request that starts after $t$ returns a log of values that includes $v$.

The ```read``` may not scale well because the log may have an unbounded size. We could have defined a more refined read request that just asks for parts of the log. We choose this generic interface for simplicity.


### State Machine Replication

There is a state machine which is a function that takes input and current state and returns the output and the next state
$$SM(cmd, S)=(out,S')$$
Note that this is a very general definition. Clients can submit requests  ```cmd``` (you can easily define ```read``` and ```write``` commands via the state machine). The state machine has some genesis state $S_0$. Given a log $L=c_1,\dots,c_k$, naturally define $SM(L)=(out,S)$ as the sequential application of $L$ on $SM$ starting with $S_0$. 

The core difference (in terms of what the client sees) between Log replication and SMR replication is that instead of returning a log of values $L$, the client library returns the output of $SM(L)$. So the servers (or the client library) need to execute the command log on the state machine.

The properties of Termination, Agreement, Validity, and Correctness are all as in Log replication but on the induced log:


**Termination**: If a non-faulty client issues a *request* then it eventually gets a *response*.


**SMR Agreement**: If two requests return outputs $out_1$ and $out_2$ then there are two logs $L_1$ and $L_2$ such that one is a prefix of the othe,  $out_1$ is the output of $SM(L_1)$, and $out_2$ is the output of $SM(L_2)$.

**SMR Validity**:  The output $out$ is the output of some $SM(L)$ and each value in $L$ can be mapped uniquely to a client request.

**SMR Correctness**: If there is a request with the value $cmd$ that gets a response at time $t$, then any request that starts after $t$ returns the output of some $SM(L)$ such that $L$ includes $cmd$.

Note that SMR replication can implement *any* state machine. In particular, it can also (trivially) implement Log replication. 

*Exercise 2: show how to implement SMR Replication given Log replication. In particular, using a bounded amount of space at the client library.*



## From Write-Once Registers to Log Replication

There are two main natural ways to obtain Log replication from Write-Once Registers:

- **Array**: view each entry in the log as a separate write-once register instance. Once sequence number $j$ in the log terminates then start sequence number $j+1$. This approach can be extended to use a sliding window of $c$ commands. So if sequence numbers up to $x$ are all committed, the parties participate in sequence numbers $x+1,\dots,x+c$. This allows running several write-once register instances in parallel but this also makes the reduction to SMR more delicate: must use the largest *consecutive* sequence in the array that is committed. As an example, this is the path PBFT takes.


- **Linked list**: servers participate in a perpetual instance of a write-once register. Each server stores the current committed log $c_j \rightarrow ... \rightarrow c_{1}$ (initially empty). Each server then sets its input to be a linked whose head is an uncommitted client command $cmd$ and the rest is committed: $cmd \rightarrow c_j \rightarrow ... \rightarrow c_{1}$. This way agreement is always done on the whole log and each time a log is committed the servers continue to propose a larger log. While this does not allow parallel consensus instances, it does allow to *pipeline* consecutive consensus instances and also allows for optimistic execution in the SMR setting. For some underlying consensus protocols, pipelining can provide performance benefits. As an example, this is the path HotStuff takes.



## Responsiveness: Good case efficiency in the multi-shot setting


As we have seen in the worst case even a single-shot consensus can take $O(f \Delta)$ time. But what about the good case when the system is in synchrony and the primary is non-faulty? The following definition captures the best-case guarantees that we can obtain:

**Single-Shot Responsiveness**: if the systems is in synchrony, the primary is non-faulty and each message arrives after $\delta << \Delta$ time then to time to terminate is $O(\delta)$.


What about multi-shot? The obvious path is to do one consensus per view. With this approach to do $k$ consensus, even if the system is in synchrony, and even if all the primaries are non-faulty, would take $O(\Delta k)$. A natural goal would be to try to obtain a better bound:

**Multi-Shot Responsiveness**: if the system is in synchrony, the primaries for the $k$ next agreements are non-faulty and each message arrives after $\delta << \Delta$ time then to time to reach $k$ consecutive agreements is  $O(\delta k)$.

Does it matter if we get $(k \Delta)$ or $O(k \delta)$? The answer is that it depends. First of all, it does not matter that much if the gap between $\delta$ and $\Delta$ is not large. In some systems, there is no need to move faster than one decision per $O(\Delta)$ time, while in other systems obtaining even better best-case performance is critical. In any case remember: in the worst case, even one decision may take $O(\Delta f)$ time.


### Obtaining Multi-Shot responsiveness via a Stable Leader

Instead of replacing leaders, let's keep the same leader and replace it only when it fails. Now the same leader can consecutively use recoverable broadcast without any additional waiting. This change obtains Multi-Shot Responsiveness. Many deployed SMR systems use this stable leader paradigm due to this optimization.

Note that there is no safety concern, but what about liveness? There is a new hard challenge: we cannot use a fixed time to change views, so we need some new mechanism to decide when to move to a new view and to make sure this move is synchronized.

At a high level, for a specific view $v$ a party can have 3 states: (1) start-view $v$; (2) blame $v$; (3) stop-view $v$. Let's go over each transition:

* From start-view $v$ to blame $v$: this is when a party is not seeing progress in the current view. The first reason to blame is if a heartbeat or message from the current primary does not arrive in $2 \Delta$ from the previous one. The second reason to blame is if a client request arrives but the primary does not reach a decision on it. In any case, when moving to blame $v$, the party sends a ```<blame v>``` message to all parties.
* Should a party stop processing messages in view $v$ and move to view $v+1$ if you are in blame $v$? Not so fast, maybe you are faulty. To overcome this, wait for $f+1$ distinct ```<blame v>``` before moving to stop-view $v$. When moving to stop-view $v$ the party sends a ```<stop-view v>``` message to all parties. At this point, the party stops responding to view $v$ messages.
* Should you move to view $v+1$ when you stop-view $v$? Not so fast, maybe you are the only non-faulty that does a stop-view? So we make stop-view contagious! If you hear a ```<stop-view v>``` and you did not sent it yet then send ```<stop-view v>``` to all parties.
* Now we can trigger start-view $v+1$ (start recover max) when you hear $f+1$ stop-view $v$ messages:


**Lemma**: If a party starts view $v+1$, then all non-faulty parties will start $v+1$ in at most $2\Delta$.

With this technique parties can make sure that a non-faulty primary after GST will not be removed, while in case to view change, all parties will be moving in sync. The first property is critical for responsiveness and the second property is critical for the liveness proof.

For multi-shot responsiveness, do we have to use a stable leader? Can we do the same for a sequence of non-faulty rotating leaders?

### Obtaining Multi-Shot Responsiveness with rotating leaders

The idea is to use the $n-f$ echoes as both a commit message and also an implicit report max message for the next view! So once the new primary sees $n-f$ echo messages it can immediately propose the next value. 


Why is recoverability okay even though we did not explicitly send ```<echoed-max>```? Because we only need the highest echo, and we are at view $v$ so this is the highest possible (at the beginning of view $v+1$). This shows that we are safe and that we can obtain Multi-Shot responsiveness. What about liveness?

We again use the three states: (1) start-view $v$; (2) blame $v$; (3) stop-view $v$. The only difference is that this time we can simply use a $10 \Delta$ timer for moving into blame $v$.

So in the end, a primary of view $v+1$ can skip doing revere max for $v+1$ if it hears $n-f$ echo from view $v$,  otherwise, it runs the regular protocol.

### Note on Strong Responsiveness

A stronger property one could ask for: assuming all parties are non-faulty, the time after GST to decide is $O(\delta)$. This property is strictly stronger as it covers the full partial synchrony case.


