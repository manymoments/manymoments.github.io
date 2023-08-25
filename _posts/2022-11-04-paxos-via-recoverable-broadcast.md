---
title: On Paxos from Recoverable Broadcast
date: 2022-11-04 05:00:00 -04:00
tags:
- dist101
- omission
author: Ittai Abraham
---

There are so many ways to learn about the [Paxos](https://lamport.azurewebsites.net/pubs/lamport-paxos.pdf) protocol (see [Lampson](https://www.microsoft.com/en-us/research/publication/the-abcds-of-paxos/), [Cachin](https://cachin.com/cc/papers/pax.pdf), [Howard](https://www.youtube.com/watch?v=0K6kt39wyH0) [Howard 2](https://www.youtube.com/watch?v=s8JqcZtvnsM), [Guerraoui](https://www.youtube.com/watch?v=WX4gjowx45E), [Kladov](https://matklad.github.io/2020/11/01/notes-on-paxos.html), [Krzyzanowski](https://people.cs.rutgers.edu/~pxk/417/notes/paxos.html), [Lamport](https://www.youtube.com/watch?v=tw3gsBms-f8), [Wikipedia](https://en.wikipedia.org/wiki/Paxos_(computer_science)) and many more). The emphasis of this post is on a **decomposition** of Paxos for *omission failures* that will later help when we do a similar decomposition for *Byzantine failures* (for [PBFT](https://decentralizedthoughts.github.io/2022-11-20-pbft-via-locked-braodcast/) and [HotStuff](https://decentralizedthoughts.github.io/2022-11-24-two-round-HS/)).

This post has a few simple exercises - try to go over them and [post your answers](https://twitter.com/ittaia/status/1599150007697182720?s=20&t=JiegXa5IVUUcfNM6ZietBA).

The model is [partial synchrony](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) with $f<n/2$ [omission failures](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) and the goal is [consensus](https://decentralizedthoughts.github.io/2019-06-27-defining-consensus/) (see below for exact details). 

> The Paxon parliament’s protocol provides a new way of implementing the state-machine approach to the design of distributed systems. [Lamport, The Part-Time Parliament](https://lamport.azurewebsites.net/pubs/lamport-paxos.pdf).

We approach Paxos by starting with two major simplifications:

1. Use a *simple revolving primary* strategy based on the assumptions of perfectly synchronized clocks. A later post shows how to extend to a *stable leader*, how to rotate leaders with *responsiveness*, and how not to rely on clock synchronization.
2. Focus on a *single-shot* consensus. A [later post](https://decentralizedthoughts.github.io/2022-11-19-from-single-shot-to-smr/) shows how to extend to *multi-shot* consensus and *state machine replication*.

## View-based protocol with simple revolving primary

The protocol progresses in **views**, each view has a designated **primary** party. The role of the primary is rotated. For simplicity, the primary of view $v$ is party $v \bmod n$. 

Clocks are perfectly synchronized, and $\Delta$ (the maximum message delay after GST) is known. View $v$ is set to be the time interval $[v(10 \Delta),(v+1)(10 \Delta))$. In other words, each $10\Delta$ clock ticks each party triggers a **view change** and increments the view by one. Clocks are assumed to be perfectly synchronized, so all parties move in and out of each view in complete synchrony (lock step).
## Single-shot consensus

In this setting, each party has some *input value* and the goal is to *output a single value* with the following three properties:

**Uniform Agreement**: if any two parties output $v$ and $v'$ then $v=v'$. Note that this is a strictly stronger property than **Agreement** which just requires that all *non-faulty* parties that output a value, output the same value.

**Termination**: all non-faulty parties eventually output a value and terminate. Note that this is a strictly stronger property than **Liveness** which just requires that all non-faulty parties eventually output a value.

**Validity**: the output is an input of one of the parties. Note that this is a strictly stronger property than **Weak Validity** which just requires that if *all* parties have the same input value then this is the output value.

## What is the core problem of view-based consensus protocols?

The core problem that all view-based consensus protocols need to solve is the risk of an agreement violation (safety) from a case where one primary causes some parties to commit $X$, but some later primary misses this event and causes other parties to commit to $Y \neq X$.

To avoid this despite both asynchrony and minority omission corruptions, Paxos type protocols do two very important things:

1. The primary broadcasts its value via a **recoverable broadcast protocol** that guarantees that if some party commits to the primary's value in view $v$, then there is sufficient evidence to recover that value in a later view.
2. The primary of any view (except the first) tries to recover a previously committed value via a **recoverable broadcast protocol** that guarantees that if some previous primary caused some party to commit, then the recover protocol will return this value. The primary will then **adopt** this recovered value, instead of using its own input value, as the value it tries to broadcast for committing. 

In this post we *decompose* Paxos into an inner *recoverable broadcast protocol* that fixes this problem and the outer view-based protocol.

## Recoverable Broadcast protocol for $f<n/2$ omission corruptions

Recoverable Broadcast is a pair of protocols: ```Broadcast``` and ```Recover```. 

### Broadcast protocol


```Broadcast``` has a designated *leader* party with *input value* ```p``` (we use the term *leader* to indicate it does nor have to be the *primary*, but in our case it will be): 

```
Leader sends <p> to all

Upon receiving <p> from leader, 
 send <echo, p> to all

Upon receiving n-f <echo, p>, 
 output p
```


For simplicity, the leader also acts as a regular party. So it also sends ```<p>``` to itself and upon seeing its own message, it sends an ```<echo, p>``` message to all parties (again including sending it to itself). 

### Broadcast properties

**Validity**: If a party outputs a value in Broadcast then it's the leader's input value.

**Weak Termination of Broadcast**: If the leader is non-faulty then all non-faulty parties output a value and terminate.

**Recoverability**: If some party outputs $p$ then at least $n-f$ parties received '''<echo, p>'''

*Exercise 1: prove these properties. Explain where you used the assumption that there are at most $f$ omission failures.*

### Recover protocol

The goal of the ```Recover``` protocol is to output either a broadcast value or a special $\bot$ value (which we write as ```bot``` in pseudo-code):

```
upon start,
 if you sent <echo, p> in Broadcast,
 then send <recover, p> to all
 if you did not send <echo, p> in Broadcast yet,
 then send <recover, bot> to all
Upon receiving n-f <recover, *>,
 if one is <recover, p> then output p
 otherwise (all are <recover, bot>) then output bot

```

We will later detail what triggers starting the Recover protocol. Note that given ```<echo, p>```, sending ```<recover, p>``` could be made redundant. We keep both for clarity for now.

### Recover properties:

**Validity**: If a party outputs a value in Recover then it is either the leader's input value or $\bot$.

**Termination of Recover**: If all parties start Recover, then all non-faulty parties output a value and terminate.

**Recover after Broadcast**: If all parties start Recover *after* some party outputs a value from Broadcast then all parties will output this value in the Recover.

*Exercise 2: Prove these properties and explain where you use (1) the assumption that $f<n/2$; (2) the [Pigeonhole principle](https://en.wikipedia.org/wiki/Pigeonhole_principle); (3) and where exactly you use the fact that the Recover is started after some party outputs a value from Broadcast.*

*Exercise 3: give examples executions to the following cases (given $n=3$ and $f=1$ omission failures), assuming that broadcast starts at time 0 and all parties start the recover protocol at time 1:*

1. No party outputs a value from Broadcast (does not terminate), and some party outputs a non-$\bot$ value in recover.
2. Some party outputs a value from broadcast, and some party outputs $\bot$ in recover.

## Paxos via Recoverable Broadcast

We now show how to decompose Paxos into an outer shell and an inner protocol that is based on  ```Broadcast``` and ```Recover```. To be more exact we will use variations that we call ```Broadcast-in view``` and ```Recover-max``` that we now motivate and detail these variations.

Every $10 \Delta$ the parties change view and rotate the primary. Since clocks are perfectly synchronized this change of view is perfectly synchronized as well.

Here is a natural path: in view 1 the primary ```Broadcast``` is input value. The output of ```Broadcast``` is a consensus decision!

But what if the first Primary is faulty and only some parties decide? For agreement to hold we must make sure that later primaries use the same value.

*Exercise 4: If all that each primary does in its view is ```Broadcast``` its input value - show an execution that has a violation of the Agreement property.*

The (obviously) missing step that a primary of view >1 should do is call ```Recover```. In particular, if there was a decision in view 1 by some party, then ```Recover``` will notify the new primary. 

Recall that **Recover after Broadcast** needs the output of ```Broadcast``` to happen **before** the ```Recover``` starts! Solution: change ```Broadcast``` to ```Broadcast-in-view``` so it stops when view $v$ ends:

```Broadcast-in-view(v,p)``` has both a view $v$ and a proposal value $p$:

```
Primary of view v sends <propose(v,p)> to all

Upon receiving <propose(v,p)> from primary,
 if myview = v then send <echo(v,p)> to all

Upon receiving n-f <echo(v,p)>,
 if myview = v then output p

```

Since ```Broadcast-in-view(v,p)``` stops at the end of view $v$, we can run ```Recover``` when we enter view $v+1$ and thus guarantee **Recover after Broadcast** property.

There is one final challenge: what if ```Recover``` returns **multiple values** from multiple previous views, which one should the primary use? For example, suppose that at view 10, we recover both a proposal $p'$ from view 4 and a proposal $p''$ from view 6. Which one should the primary choose?

**The main Paxos algorithmic insight is that for guaranteeing agreement the primary must:**
> **Choose the recovered value associated with the most recent view you hear!**

To highlight this important insight we modify ```Recover``` to ```Recover-Max```.

Just like ```Broadcast-in-view``` has a view number as input, ```Recover-Max``` also have a view number $v$ as input:

```
upon start of view v
 send <echoed-max(v,bot)> if you never sent echo yet
 otherwise, 
 let v'<v be the highest view in which you sent an echo message
 let p be the proposal that you echoed in view v'
 send <echoed-max(v,v',p)>
 
Primary waits for n-f responses <echoed-max(v,*)>
 if all are bot then output bot
 // primary is free to use any value, say its input value
 otherwise, output the proposal p associated with the highest view v'
 // primary must propose p for safety
```

This protocol needs only send messages to the primary. Here is the core property:

**Lemma 1**: let $p$ be a value output by ```Broadcast``` in some view $v$, then any ```Recover-Max``` invocation in any view $>v$ will output some value $p'$ such that $p'$ was proposed at view $\geq v$.

*Exercise 5: Prove Lemma 1.*

So all that remains is to combine the two protocols to make sure the primary uses the result of ```Recover-Max``` if its output is not $\bot$. This is the outer shell ```Paxos``` protocol: 

For view 1, the primary of view 1 with input $val$: 

```
Broadcast-in-view (1,val)
```

For view $v>1$, the primary of view $v$ with input $val$:

```
p := Recover-Max(v)

if p = bot then 
 Broadcast-in-view (v,val)
otherwise 
 Broadcast-in-view (v,p)
```

In words: the primary will first try to recover the maximal echo. If no echo is seen, the primary is free to choose its own input. Otherwise, it must propose the value associated with the highest view in which it heard there was an echo.

This completes the description of Paxos. Let's prove that the three properties of consensus hold.

### Agreement (Safety)

**Lemma 2**: Let $v^{\star}$ be the first view with $n-f$ echos of $ (v^\star, x)$, then for any view $v>v^\star$ the proposal value of ```Broadcast-in-view (v,x)``` must be $x$.

*Exercise 7: Prove the Agreement property follows from Lemma 2.* Hint: Assume two parties decide on different values. Prove they could not have decided in the same view, so ... apply Lemma 2.

We now prove Lemma 2, which is the essence of Paxos.

*Proof of Lemma 2*: consider the set $S$ (for Sentinels) consisting of the $n-f$ parties that sent ```<echo(v*,x)>``` in view $v^\star$. We will call them the *Sentinels*, because they guard safety.

We will prove by induction, that for any view $v\geq v^\star$:
1. The output of ```Recover-Max(v)``` is $x$.
2. For each party $P_i$ in $S$, the highest view $v'$ of ```<echoed-max(v,v',x)>``` it sends in ```Recover-Max(v)``` is such that: (1) $v' \geq v^\star$; (2) and the value is $x$.

For the base case, $v=v^\star$, this follows from the definition of $S$. Now suppose the induction statement holds for all views $v^\star \leq v$ and consider view $v+1$:

```Recover-Max(v+1)``` must get a response from $n-f$ parties, and that set must intersect with the set $S$ which is also of size $n-f$ by at least $n-2f>0$ one party. From $(2.)$ of the induction hypothesis on views $\leq v$ it follows that at least this one response will be of view $\geq v^\star $ and its value is $x$. From $(1.)$ it follows that any response from view $\geq v^\star$ will be of value $x$. Since ```Recover-Max(v+1)``` takes the value associated with the highest view, it must output $x$. This proves part $(1.)$ of the induction hypothesis for view $v+1$.

Observe that this is exactly the point in the proof where we used the main Paxos algorithmic insight:
> **Choose the recovered value associated with the most recent view you hear!**

The remainder of the proof is to show that given the above, part $(2.)$ of the induction claim also holds:

Since the primary of view $v+1$ must propose $x$, then each party in $S$ either stays with its previous highest view echo (from $(1.)$ of the induction hypothesis for view $\leq v$) or it updates it to the higher view $(v+1,x)$. Clearly, in both cases, we proved that part $(2.)$ of the induction hypothesis holds for view $v+1$.

This concludes the proof of Lemma 2.

### Liveness

We proved Agreement, now let's prove that eventually, after GST, all *non-faulty* parties output a value.

Consider the view $v^+$ with the *first* non-faulty primary that started after GST at time $T$. Since we are after GST, then on or before time $T+ \Delta$ the primary will receive ```<echoed-max(v+,*)>``` from all non-faulty parties (at least $n-f$). Hence will send a ```<propose(v+,p)>``` that will arrive at all non-faulty parties on or before time $T+2\Delta$. Hence all non-faulty parties will send ```<echo(v+,p)>``` (because they are still in view $v^+$). So all non-faulty parties will hear $n-f$ ```<echo(v+,p)>``` on or before time $T+3\Delta$. So all non-faulty will decide $p$ because they are still in view $v^+$.

This concludes the liveness proof.

*Exercise 8: Show that there is no liveness (via an infinite execution) if view $v$ is set to be the time interval $[v(2 \Delta),(v+1)(2 \Delta))$. In other words, each $2\Delta$ clock ticks each party triggers an increment of the view by one.*

*Exercise 9: What is the minimal $\alpha$ such that the liveness property holds if view $v$ is set to be the time interval $[v(\alpha \Delta),(v+1)(\alpha \Delta))$. In other words, each $\alpha \Delta$ clock ticks each party triggers increments the view by one. What is the best time complexity you can get (see below)?*

### Termination


We proved that all non-faulty parties output a value, but our protocol never terminates! For that, we add the following *termination gadget*:

```
If the consensus protocol outputs p,
 then send <decide, p> to all

Upon receiving <decide, p>
 If you did not output yet,
 Then output p and send <decide, p> to all

Upon receiving n-f <decide, p>
 Terminate

``` 

*Exercise 10: Prove termination - that the termination gadget causes all non-faulty parties to eventually terminate.*

### Validity

Observe that Validity is trivial in these protocols. By induction, the only values used are the inputs of the parties.

What if a party has several different values (for example it received several different values from several different clients)? This is an example of how the standard validity of consensus does not address the challenges of MEV. More on that in later posts. 

d Message Complexity

Note that the time and number of messages before GST can be both unbounded. So for this post, we will measure the time and message complexity after GST.

**Time complexity**: since the Liveness proof waits for the first non-faulty primary that starts after GST this may take in the worst case: almost one "interrupted" view, then $f$ views of faulty primaries, then a view of a non-faulty party. So all parties will output a value in at most $(f+2)10 \Delta$ time after GST. A more careful analysis can improve the first and the last durations. We show [here](https://decentralizedthoughts.github.io/2019-12-15-synchrony-uncommitted-lower-bound/) that $(f+1) \Delta$ is a worst case that cannot be avoided (but can have a small probability when using randomization).

**Message Complexity**: since each round has an all-to-all message exchange, the total number of messages sent after GST is $O((f+1) \times n^2) = O(n^3)$. We show [here](https://decentralizedthoughts.github.io/2019-08-16-byzantine-agreement-needs-quadratic-messages/) that $O(n^2)$ is the best you can hope for (for deterministic protocols or against strongly adaptive adversaries).

*Exercise 11: Modify the protocol above to use just $O(n)$ messages per view (so total of $O(n^2)$ after GST). Explain why the proof still works, in particular, detail the Liveness proof and the Time complexity. Can you get the same bound as in Exercise 9?*

## Acknowledgments
Many thanks to Kartik Nayak for insightful comments.


Your comments on [Twitter](https://twitter.com/ittaia/status/1599150005432250368?s=20&t=JiegXa5IVUUcfNM6ZietBA).