---
title: Consensus cheat sheet
date: 2021-10-29 08:18:00 -04:00
tags:
- dist101
author: Ittai Abraham
---

| | Crash | Omission | Byzantine |
| --- | --- | ---- | --- |
| Synchrony |  ![](https://github.githubassets.com/images/icons/emoji/unicode/2714.png?v8) $f<n$ [is possible](https://decentralizedthoughts.github.io/2019-11-01-primary-backup/) <br /> ![](https://github.githubassets.com/images/icons/emoji/unicode/1f422.png?v8) $f+1$ round executions [must exist](https://decentralizedthoughts.github.io/2019-12-15-synchrony-uncommitted-lower-bound/)| ![](https://github.githubassets.com/images/icons/emoji/unicode/1f62d.png?v8) $f \geq n/2$ [is impossible](https://decentralizedthoughts.github.io/2019-11-02-primary-backup-for-2-servers-and-omission-failures-is-impossible/)| ![](https://github.githubassets.com/images/icons/emoji/unicode/2714.png?v8) $f<n/2$ [possible with PKI](https://decentralizedthoughts.github.io/2019-11-11-authenticated-synchronous-bft/) / [PoW](https://decentralizedthoughts.github.io/2021-10-15-Nakamoto-Consensus/) <br /> ![](https://github.githubassets.com/images/icons/emoji/unicode/1f62d.png?v8) $f \geq n/3$ [impossible without PKI/PoW](https://decentralizedthoughts.github.io/2019-08-02-byzantine-agreement-is-impossible-for-$n-slash-leq-3-f$-is-the-adversary-can-easily-simulate/)|
| Partial Synchrony | ![](https://github.githubassets.com/images/icons/emoji/unicode/1f62d.png?v8) $f \geq n/2$ [is impossible](https://decentralizedthoughts.github.io/2019-06-25-on-the-impossibility-of-byzantine-agreement-for-n-equals-3f-in-partial-synchrony/) | ![](https://github.githubassets.com/images/icons/emoji/unicode/2714.png?v8) $f<n/2$ [is possible](https://lamport.azurewebsites.net/pubs/lamport-paxos.pdf)|  ![](https://github.githubassets.com/images/icons/emoji/unicode/2714.png?v8) $f<n/3$ [is possible](http://pmg.csail.mit.edu/papers/osdi99.pdf) <br /> ![](https://github.githubassets.com/images/icons/emoji/unicode/1f62d.png?v8) $f \geq n/3$ [is impossible](https://decentralizedthoughts.github.io/2019-06-25-on-the-impossibility-of-byzantine-agreement-for-n-equals-3f-in-partial-synchrony/)|
| Asynchrony |  ![](https://github.githubassets.com/images/icons/emoji/unicode/1f422.png?v8) non terminating executions [must exist](https://decentralizedthoughts.github.io/2019-12-15-asynchrony-uncommitted-lower-bound/)| ![](https://github.githubassets.com/images/icons/emoji/unicode/2714.png?v8) $f<n/2$ possible in $O(1)$ expected| ![](https://github.githubassets.com/images/icons/emoji/unicode/2714.png?v8) $f<n/3$ [possible](https://dspace.mit.edu/bitstream/handle/1721.1/14368/20051076-MIT.pdf;jsessionid=2A5CC7AF0CEF95E05450CD863B94A394?sequence=2) in $O(1)$ expected|


Here $n$ is the number of parties, and $f$ is the number of parties that the [adversarial threshold](https://decentralizedthoughts.github.io/2019-06-17-the-threshold-adversary/). Recall [that](https://decentralizedthoughts.github.io/2019-06-01-2019-5-31-models/) **Synchrony** $\subseteq$ **Partial Synchrony** $\subseteq$ **Asynchrony**. Similarly [that](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/) **Crash**  $\subseteq$ **Omission** $\subseteq$ **Byzantine**. Therefore,
1. Any upper bound holds if we go down and/or to the left. e.g., the $O(1)$ expected round upper bounds under asynchrony also hold in partial synchrony and synchrony.
2. Any lower bound holds if we go up and/or to the right. e.g., the impossibility of $f \geq n/3$ carries with Byzantine adversaries in partial synchrony carries over to asynchrony and the $t+1$ round lower bound carries over from crash to omission and Byzantine.


Acknowledgments: many thanks to Kartik Nayak for help with this post!

Your thoughts on [twitter](https://twitter.com/ittaia/status/1454065908415090696?s=20). 
