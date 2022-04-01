---
title: 'Asynchronous Agreement Part One: Defining the problem'
date: 2022-03-30 07:11:00 -04:00
tags:
- asynchrony
- dist101
author: 'Ittai Abraham, Naama Ben-David, Sravya Yandamuri '
---

In this series of posts, we explore the marvelous world of consensus in the [Asynchronous model](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/). In this post, we start with simply defining the problem. Recall the  [FLP theorem](https://decentralizedthoughts.github.io/2019-12-15-asynchrony-uncommitted-lower-bound/):


**[FLP theorem 1985](https://groups.csail.mit.edu/tds/papers/Lynch/jacm85.pdf):** Any protocol where no two non-faulty parties decide different values in the asynchronous model that is resilient to even just one crash failure must have an infinite execution.

A naive interpretation would be that consensus is impossible, and indeed only weaker primitives like [Reliable Broadcast](https://decentralizedthoughts.github.io/2020-09-19-living-with-asynchrony-brachas-reliable-broadcast/) and [Gather](https://decentralizedthoughts.github.io/2021-03-26-living-with-asynchrony-the-gather-protocol/) are possible, so what's the point of this post?

Since FLP shows we cannot get always agreement and always termination, maybe we can get something that is weaker but essentially good enough? This leads to the following natural definition of **Asynchronous Agreement:**
* **(Weak Validity):** If all parties are non-faulty and have the same input value, then all parties must decide that value.
* **(Agreement):** No two non-parties decide on different values.
* **(Finite Expected Termination:)** The expected number of rounds till all non-faulty parties decide is finite.

While the weak validity and agreement properties are standard, weak validity will be strengthened in the authenticated model (to external validity). The termination property is more subtle. The first question is how do you define the "number of rounds" in the Asynchronous model? the short answer is that the number of rounds of an execution is the total time divided by the longest message delay. For a longer discussion see [our blog post asynchronous round complexity](https://decentralizedthoughts.github.io/2021-09-29-the-round-complexity-of-reliable-broadcast/). The second question is an expectation over what? The answer is:
* For a protocol $P$ with $n$ parties to have *expected termination* $ET(P,n)$, means that for every adversary strategy, we take expectation over runs of $P$ using the random choices of the parties.

$$
ET(P,n)= \max_{\text{ADV strategy}} E_{X \sim runs(P,n,\text{ random coins, ADV strategy})} X 
$$

Where $X$ is a random variable that equals the number of rounds till all non-faulty parties decide.

Note that this definition of termination is still underdefined. We need to carefully define what are the possible [adversary strategies](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/). Can the adversary make *adaptive* decisions based on the protocol execution? If so, what *information* does the adversary have at each stage? 

Assuming the adversary is *static* (also called an [oblivious adversary](https://www.math.ias.edu/~avi/PUBLICATIONS/MYPAPERS/BORODIN/paper.pdf)) and has to decide all its actions ahead of time sounds quite naive. Its very natural to assume your adversary is observing the protocol and *adaptively* reacting to it. Even though we assume the adversary is adaptive, we need to put some limits on its power. In particular that it cannot guess future coins of non-faulty parties (formally, those coins are *unpredictable*). Moreover, in some implementations of *common coins* we will assume a *private channel model*, where the adversary cannot see the content of messages sent between non-corrupted parties.

So in the standard adaptive model, we assume the adversary has control over the network and over corruptions. At any given step it can decide what message to deliver, with a global restriction that each message must be eventually delivered. In addition, it can decide what parties to corrupt, up to a total of $f$ parties (parties corrupted cannot be un-corrupted). Once a party is corrupted, the adversary may have additional power over that party depending on the model (in the omission model, it can decide what message to omit, in the Byzantine model, it has full control). Finally, the adversary can make all these decisions adaptively assuming it can see all the messages sent to all corrupted parties at the time of decision (but in the private channel model cannot see the content of messages sent between non-corrupted parties; only the fact that a message has been sent).

So we can now restate the termination property more formally as follows:
* **(Finite Expected Termination:)** We say a protocol $P$ for $n$ parties has *Finite Expected Termination*, if for any finite $n$ there exists some finite number $t(n)$, such that $ET(p,n)<t(n)$. For any adaptive strategy the adversary chooses, the expected number of rounds it takes to reach a state where all non-faulty parties decide (and terminate) is at most $t(n)$.

This definition obviously leads to the question of efficiency, what values of $t(n)$ are possible? Must $t(n)$ be a function of $n$ or can it be an absolute constant? 

More on that in the next posts. In the second post, we cover [Ben-Or's classic protocol](https://decentralizedthoughts.github.io/2022-03-30-asynchronous-agreement-part-two-ben-ors-protocol/).

### A note on the Byzantine and authenticated model
In the authenticated model where the adversary is computationally bounded there are two main differences:
1. Often a stronger notion of **External Validity** can be obtained (see [Cachin etal](https://www.iacr.org/archive/crypto2001/21390524.pdf)). This property is important for State Machine Replication in the Byzantine model.
2. In addition, we cannot simply go over all adversary strategies (because there may be exponentially many of them). The solution suggested by [Cachin etal](https://www.iacr.org/archive/crypto2001/21390524.pdf) is to assume the probability of breaking the cryptography is negligible and to show that conditioned on some negligible events not happening, the conditional expectation is finite. Another path is to use a [Dolev-Yao type model](https://cseweb.ucsd.edu/classes/sp05/cse208/lec-dolevyao.html) and assume the cryptography implements a perfect functionality. While this model's assumptions don't hold in reality (cryptography is not perfect), it has proven to be quite a good proxy for distributed protocols. 



Link to the second post on [Ben-Or's classic protocol](https://decentralizedthoughts.github.io/2022-03-30-asynchronous-agreement-part-two-ben-ors-protocol/).

Your thoughts/comments on [Twitter](...).
