---
title: The round complexity of Reliable Broadcast
date: 2021-09-29 06:05:00 -04:00
tags:
- dist101
- research
- lowerbound
author: Ittai Abraham, Zhuolun Xiang, Ling Ren
---

[Reliable Broadcast](https://decentralizedthoughts.github.io/2020-09-19-living-with-asynchrony-brachas-reliable-broadcast/) is an important building block of many [Asynchronous](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) protocols. There is a broadcaster that has some *input value*, $v$, and a non-faulty party that *terminates* needs to *output* a value. Reliable Broadcast is defined via two properties: 

**Validity**: If the broadcaster is non-faulty then *eventually* all non-faulty parties will output the broadcaster's input.

**Agreement**: If some non-faulty party outputs a value then *eventually* all non-faulty parties will output the same value.

In this post we try to better understand and optimize this notion of *eventually*. There are many reasons to outright [stop using the term "eventually"](https://twitter.com/heidiann360/status/1315608969470189568?s=20). Can we be more precise? Instead of eventually, can we provide a concrete measure of the worst case round complexity? 


## The round complexity of a synchronous protocol

In the synchronous model there is an upper bound $\Delta$ on the message delay between any two non-faulty parties. In this model, let $roundComplexity(e)$ of an execution $e$ be the *total time divided by $\Delta$*, and $roundComplexity(P)$ of a protocol $P$ the maximum round complexity overall executions and adversary strategies.

## The round complexity of an asynchronous protocol

Let's adopt the synchronous definition to the asynchronous model. In the asynchronous model the message delay between any two non-faulty is unbounded. We will use the longest delay, by looking at the execution in hindsight, once it's fixed. 

Imagine having an external clock that can provide an ideal clock time for each event. Consider a protocol $P$.

1. For a message $m$ that is sent and received between two non-faulty parties, define $messageDelay(m)$ as the time elapsed between the send and receive time points.
2. For an execution $e$, define  $totalTime(e)$ as the elapsed time between the earliest time a non-faulty sends a message and the latest time a non-faulty party terminates. 
3. For an execution $e$, define $roundComplexity(e)$ as 
$$
\frac{ totalTime(e) }{ \max_{m \in M} messageDelay(m) } .
$$
5. For the protocol $P$, define $roundComplexity(P)$ as the maximum $roundComplexity(e)$ over all executions and adversary strategies.  In later posts, we will generalize this definition to randomized protocols and expected round complexity.



Note that the round complexity of an execution does not need to be an integer, but the round complexity of a protocol is often manifested when an asynchronous protocol is executed in a *lock step* schedule (and hence is an integer).


## Reliable Broadcast and round complexity

We can now replace the word "eventually" with a more precise notion of round complexity:

**Validity**: If the broadcaster is non-faulty then, *after at most $R_g$ rounds*, all non-faulty parties will output the broadcaster's input.

**Agreement**: If some non-faulty party outputs a value then, *after at most $R_{ex}$ round*, all non-faulty parties will output the same value.

We call $R_g$ the *good-case latency*, and define $R_b=R_g+R_{ex}$ to be the *bad-case latency*. We say a Reliable Broadcast protocol is $(R_g,R_b)$-round if it has good-case $R_g$ rounds and bad-case $R_b$ rounds.

> *Exercise 1*: Go back to the post on [Reliable Broadcast](https://decentralizedthoughts.github.io/2020-09-19-living-with-asynchrony-brachas-reliable-broadcast/) and verify that indeed it takes three rounds when the broadcaster is non-faulty and at most one more round to reach agreement. In other words, it is $(3,4)$-round. 
<!-- Roughly speaking, it's because in the first round the broadcaster *sends*, then the parties *echo*, then they *vote*.  -->


Now that we have a concrete measure of complexity, is three rounds the best we can do?

## Can Reliable Broadcast take 2 rounds?

We will show two protocols for Reliable Broadcast that take just 2 rounds under a non-faulty broadcaster, or in other words, have good-case latency of 2 rounds. The first assumes a Public Key Infrastructure (PKI) and the second assumes no authentication.

### 2-round Reliable Broadcast given a PKI:

This protocol for $n>3f$ appears in section 3 of our recent paper on [good-case latency categorization](https://arxiv.org/pdf/2102.07240.pdf).

       // broadcaster s with input v
       send <v>_s to all parties

       // Party j
       on receiving the first proposal <v>_s from broadcaster s:
          send <echo, v>_j to all parties

       on receiving <echo, v>_* signed by n-f distinct parties:
          send the <echo, v>_* signed by n-f distinct parties to all parties
          deliver v and termiante

The main insight: a party that delivers a value has a proof that it can transfer to other parties.


> *Exercise 2*: Prove that for $n\geq 3f$, Agreement and Validity hold assuming the adversary is computationally bounded (cannot forge signatures), and the protocol is $(2,3)$-round.



### 2-round Reliable Broadcast without PKI:

Do we have to assume a PKI to get to 2 rounds? The next protocol shows that this is not the case. This protocol decides in 2 rounds when the broadcaster is honest and requires $n\geq 4f$.



       // broadcaster with input v
       send <v> to all parties

       // Party j 
       on receiving the first proposal <v> from broadcaster:
          send <echo 0, v> to all parties

       on receiving <echo 0, v>  by n-f-1 distinct non-broadcaster parties:
          deliver v, send <echo 1, v> and <echo 2, v> to all parties and terminate

       on receiving <echo 0, v>  by n-2f distinct non-broadcaster parties:
          send <echo 1, v> (if not sent yet) to all parties
          
       on receiving <echo 1, v>  by n-f-1 distinct non-broadcaster parties:
          send <echo 2, v> (if not sent yet) to all parties

       on receiving <echo 2, v>  by n-f-1 distinct non-broadcaster parties:
          deliver v and terminate

       on receiving <echo 2, v>  by f+1 distinct non-broadcaster parties:
          send <echo 2, v> (if not sent yet) to all parties


<!-- *Validity claim: When the broadcaster is honest, all honest parties decide broadcaster's value in 2 rounds.* -->


*Agreement claim: If an honest sees n-f-1 <echo 0, v> and commits v, then no honest will see n-2f <echo 0, v'>, or send <echo 1, v'> or <echo 2, v'>. Moreover, eventually all honest will see n-2f <echo 0, v>, so eventually send <echo 1, v>.*

Proof: For honest broadcaster - trivial. For faulty broadcaster - there are at most f-1 Byzantine non-broadcaster parties. If some honest send <echo 1, v'>, then n-2f honest send <echo 0, v> and n-3f+1 send <echo 0, v'>. Since there are n-f honest nodes, there must be at least (n-2f)+(n-3f+1)-(n-f)>=1 honest in the intersection that equivocates, contradiction. Also, the threshold for sending echo 2 is > f, so no honest will send <echo 2, v'>. Since n-2f honest send <echo 0, v> and no honest send <echo 1, v'>, all honest will eventually send <echo 1, v>.

> *Exercise 3*: Verify that the above protocol satisfies validity and agreement, and has $(2,4)$-round.

### $n\geq 4f$ is optimal for 2-round unauthenticated Reliable Broadcast

The previous 2-round reliable broadcast protocol that assumes no authentication requires $n\geq 4f$, worse than the $n\geq 3f+1$ of 2-round reliable broadcast with PKI. Can we do better?

It turns out $n\geq 4f$ is the best we can do without signatures, as we formally prove a *lower bound* result in our [new paper](https://arxiv.org/pdf/2109.12454.pdf) showing that *any unauthenticated reliable broadcast under $n\leq 4n-1$ cannot achieve good-case 2 rounds*.

## How many rounds does Reliable Broadcast need when the broadcaster is bad?

In the *good case* when the broadcaster is non-faulty, we know that we can do Reliable Broadcast in 2 rounds, either under $n\geq 3f+1$ with PKI, or under $n\geq 4f$ without PKI. Now, what if the broadcaster is faulty?

Of course, if the faulty broadcaster sends no message, Reliable Broadcast allows non-faulty parties to never output. The tricky case is when the faulty broadcaster together with other faulty parties intentionally make only some non-faulty party output, but not the others. To satisfy agreement, the protocol needs to take extra rounds to have all non-faulty parties output the same value. An interesting question is, how many extra rounds do we need for this *bad case*? The previous 2-round protocol without PKI has bad case 4 rounds, can we do better?

In our [new paper](https://arxiv.org/pdf/2109.12454.pdf), we give a complete categorization of how many extra rounds we need for solving 2-round unauthenticated Reliable Broadcast in the bad case. We show that for $f\geq 3$, it is impossible to achieve the following three conditions simultaneously: (1) output in 2 rounds under non-faulty broadcaster (2) one extra round for all non-faulty parties to output once any non-faulty party outputs (3) have resilience $n\leq 5f-2$ assuming no authentication. 

We then present four Reliable Broadcast protocols in our [new paper](https://arxiv.org/pdf/2109.12454.pdf), and all protocols have good-case latency 2 rounds, and are optimal with respect to the above impossibility result. For $f=1$, we give a $(2,2)$-round protocol under $n\geq 4f$; For $f=2$, we give a $(2,3)$-round protocol under $n\geq 4f$; For $f\geq 3$, we show two protocols, one presented earlier that has $(2,4)$-round and needs $n\geq 4f$, another one that has $(2,3)$-round and needs $n\geq 5f-1$. Below we present the $(2,3)$-round Reliable Broadcast under $n\geq 5f-1$ as an example.


<!-- 
### (2,3) Reliable Broadcast for $n=8,f=2$ and (2,4) for $n\ge 4f$


These protocols decide in two rounds when the broadcaster is honest.



       // broadcaster with input v
       send <v> to all parties

       on receiving <v> from broadcaster:
          if first mesage form broadcaster:
             send <echo, v> to all parties

       on receiving <echo, v>  by n-f-1 distinct non-broadcaster parties:
          deliver v and terminate

       on receiving <echo, v>  from j ( and j is not you and not the broadcaster):
          if first mesage form j:
             send <vote, j, v> to all parties
          
       on receiving <vote,j,v> by n-f-1 distinct non-broadcaster and non-j parties:
          resolve j to v

       on resolving n-f-1 non-broadcaster parties to v:
          deliver v and terminate


For the case of $f\ge 3$ and $n\ge 4f-2$ we add two more rules and get (2,4):



       on resolving n-2f+1 non-broadcaster parties to v:
          send <echo 2 ,v> (if not sent yet) to all parties

       on receiving <echo 2, v>  by n-f-1 distinct non-broadcaster parties:
          deliver v and terminate
    

This works because for a bad $j$, if an honest sees $n-f-1$ votes then all honest will see $n-f-1 -(f-2)=n-2f+1$ and when $n \ge 4f-1$ we have that $n-2f+1$ is a strict majority out of $n-1$.

 -->
### $(2,3)$-round Reliable Broadcast without PKI for $n \geq 5f-1$
A similar protocol was shown by  [Imbs and Raynal](https://www.worldscientific.com/doi/abs/10.1142/S0129626416500171?journalCode=ppl) for $n\geq 5f+1$, and we improve the resilience of their protocol by distinguishing the messages from broadcaster and non-broadcasters.


       // broadcaster with input v
       send <v> to all parties

       // Party j
       on receiving the first proposal <v> from broadcaster:
          send <echo, v> to all parties

       on receiving <echo, v>  by n-2f distinct non-broadcaster parties:
         if not yet sent echo for v:
             send <echo, v> to all parties

       on receiving <echo, v>  by n-f-1 distinct non-broadcaster parties:
         deliver v and terminate


Validity in two rounds follows since all $n-f$ non-faulty parties will echo the non-faulty broadcaster's value in the end of the second round.

For Agreement, when the broadcaster is faulty, if a non-faulty party decides $v$, there there are at least $n-2f$ non-faulty non-broadcasters that echo $v$. So from quorum intersection, no value $v' \neq v$ can receive $n-2f$ echoes. Hence all non-faulty will hear $n-2f$ echo $v$ and after at most one more round will send echo $v$. By the end of this round, all non-faulty parties will hear $n-f$ echoes and terminate.


For more results, please refer to our [good-case and bad-case latency paper](https://arxiv.org/pdf/2109.12454.pdf).


Your comments and decentralized thoughts on [Twitter](https://twitter.com/ittaia/status/1443160799665610758?s=20).  

