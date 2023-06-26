---
title: "$3f+1$ is needed in Partial Synchrony even against a Rollback adversary"
date: 2023-06-26 07:00:00 -04:00
tags:
- lowerbound
- dist101
author: Ittai Abraham
---

We covered the classic [DLS88 split brain](https://decentralizedthoughts.github.io/2019-06-25-on-the-impossibility-of-byzantine-agreement-for-n-equals-3f-in-partial-synchrony/) impossibility result against a Byzantine adversary in a previous post:

**[DLS88](https://groups.csail.mit.edu/tds/papers/Lynch/jacm88.pdf):** (Theorem 4.4) It is impossible to solve  [Agreement](https://ittaiab.github.io/2019-06-27-defining-consensus/) under partial synchrony against a ***Byzantine adversary*** if $f \geq n/3$.

In a follow up, we discussed how [CJKR12](https://decentralizedthoughts.github.io/2021-06-14-neither-non-equivocation-nor-transferability-alone-is-enough-for-tolerating-minority-corruptions-in-asynchrony/) strengthen this result by observing that it holds even if the adversary is weaker in that it must faithfully transfer messages. 
In this post we strengthen this result yet again by observing that it holds even against a much weaker **Rollback adversary**  suggested by [Matetic, Kostiainen,  Dhar,  Sommer, Gervais, Juels, Capkun 2017](https://www.usenix.org/system/files/conference/usenixsecurity17/sec17-matetic.pdf):

**DLS88:** (modern version) It is impossible to solve Agreement under partial synchrony against a ***Rollback adversary*** if $f \geq n/3$.
### The Rollback Adversary
Recall that an *omission adversary* can block any message sent to or from a corrupted party, but it must run the correct protocol, from its correct beginning state, in an honest manner even on a corrupted party. In contrast, a *Byzantine adversary* can run any protocol on a corrupted party. 
A **Rollback adversary** has slightly more power than an omission adversary: 
1. Can block any message sent to or from a corrupted party.
2. Only run the correct protocol, from its correct beginning state, even on a corrupted party.
3. On a corrupted party, can rollback the protocol to its beginning state and re-run it again.

In particular, the Rollback adversary models an adversary that cannot corrupt the execution, but since the execution is stateless, it can rollback the execution and feed it different versions and inputs. See [Matetic etal 2017](https://www.usenix.org/system/files/conference/usenixsecurity17/sec17-matetic.pdf) for more discussion on this adversary.


### The proof

We observe that in order execute the lower bound of [DLS88](https://decentralizedthoughts.github.io/2019-06-25-on-the-impossibility-of-byzantine-agreement-for-n-equals-3f-in-partial-synchrony/), all the adversary needs to do is to run two "split brains". This can be done if the adversary is allowed to run two instances in parallel, or as in the case of the rollback adversary, run one instance and then rollback to run the other.
Here is the relevant part of the proof in [our blog post on DLS](https://decentralizedthoughts.github.io/2019-06-25-on-the-impossibility-of-byzantine-agreement-for-n-equals-3f-in-partial-synchrony/):

> The adversary will use its Byzantine power to corrupt $B$ to perform a **split-brain** attack  and make $A$ and $C$ each believe that they are in their respective worlds. $B$ will equivocate and act as if its starting value is 1 when communicating with $A$ and as if its 0 when communicating with $C$. If the adversary delays messages between $A$ and $C$ for longer than the time it takes for $A$ and $C$ to decide in their respective worlds, then by an indistinguishability argument, $A$ will commit to 1 and $C$ will commit to 0 (recall the time to decide cannot depend on GST or $\Delta$). This violates the agreement property.

Given a Rollback adversary, it will "act as if its starting value is 1 when communicating with $A$", then wait for $A$ to commit and then rollback and "act as if its starting value is 0 when communicating with $C$". Note that due to partial synchrony, $C$ cannot detect any problem with this delay. 
We need to be able to detect termination of one instance in order to know when to switch back to the second instance. Party $B$ can simply wait for its termination which must occur as we assume the protocol solves Agreement.
We also need to assume the adversary has access to two different inputs, in this case "0" and "1" (and that the input is not part of its "sealed" correct beginning state). In the state machine replication setting, this implies having more than one client.

This concludes the observation that the main "split brain" world can be conducted by a rollback adversary. The reminder of the proof follows exactly as in [our blog post about the DLS88 lower bound](https://decentralizedthoughts.github.io/2019-06-25-on-the-impossibility-of-byzantine-agreement-for-n-equals-3f-in-partial-synchrony/) showing that Agreement is impossible in Partial Synchrony.

### ROTE: Rollback Protection for Trusted Execution
[Matetic etal 2017](https://www.usenix.org/system/files/conference/usenixsecurity17/sec17-matetic.pdf) suggest a system called **Rote** that provides rollback protection. Rote uses $n=f+2u+1$ severs to overcome $f$ malicious servers and to provide liveness when there are $u$ unresponsive servers. With $f$ malicious servers that can also be unresponsive, Rote would need $u=f$ and hence $n=3f+1$ servers to obtain safety and liveness (not circumventing the lower bound). Setting $u$ < $f$ would imply that Rote is not live if $f$ servers are unresponsive and hence any protocol relying on it would not obtain liveness so would not solve Agreement (again not circumventing the lower bound).

### Acknowledgments
Many thanks to Andrew Miller and Guy Gueta for insightful discussions.

Your comments on [Twitter]().
