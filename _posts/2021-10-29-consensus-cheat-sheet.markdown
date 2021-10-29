---
title: Consensus cheat sheet
date: 2021-10-29 08:18:00 -04:00
tags:
- dist101
author: Ittai Abraham
---



| | Crash | Omission | Byzantine |
| --- | --- | ---- | --- |
| Synchrony |  :eight_spoked_asterisk: $f<n$ [is possible](https://decentralizedthoughts.github.io/2019-11-01-primary-backup/) <br /> :turtle: $f+1$ round executions [must exist](https://decentralizedthoughts.github.io/2019-12-15-synchrony-uncommitted-lower-bound/)| ![](https://github.githubassets.com/images/icons/emoji/unicode/1f62d.png?v8) $f \geq n/2$ [is impossible](https://decentralizedthoughts.github.io/2019-11-02-primary-backup-for-2-servers-and-omission-failures-is-impossible/)| :eight_spoked_asterisk: $f<n/2$ [possible with PKI](https://decentralizedthoughts.github.io/2019-11-11-authenticated-synchronous-bft/) / [PoW](https://decentralizedthoughts.github.io/2021-10-15-Nakamoto-Consensus/) <br /> ![](https://github.githubassets.com/images/icons/emoji/unicode/1f62d.png?v8) $f \geq n/3$ [impossible without PKI/PoW](https://decentralizedthoughts.github.io/2019-08-02-byzantine-agreement-is-impossible-for-$n-slash-leq-3-f$-is-the-adversary-can-easily-simulate/)|
| Partial Synchrony | ![](https://github.githubassets.com/images/icons/emoji/unicode/1f62d.png?v8) $f \geq n/2$ [is impossible](https://decentralizedthoughts.github.io/2019-06-25-on-the-impossibility-of-byzantine-agreement-for-n-equals-3f-in-partial-synchrony/) | :eight_spoked_asterisk: $f<n/2$ [is possible](https://lamport.azurewebsites.net/pubs/lamport-paxos.pdf)|  :eight_spoked_asterisk: $f<n/3$ [is possible](http://pmg.csail.mit.edu/papers/osdi99.pdf) <br /> ![](https://github.githubassets.com/images/icons/emoji/unicode/1f62d.png?v8) $f \geq n/3$ [is impossble](https://decentralizedthoughts.github.io/2019-06-25-on-the-impossibility-of-byzantine-agreement-for-n-equals-3f-in-partial-synchrony/)|
| Asynchrony |  :turtle: non terminating executions [must exist](https://decentralizedthoughts.github.io/2019-12-15-asynchrony-uncommitted-lower-bound/)| :eight_spoked_asterisk: $f<n/2$ possible in $O(1)$ expected| :eight_spoked_asterisk: $f<n/3$ [possible](https://dspace.mit.edu/bitstream/handle/1721.1/14368/20051076-MIT.pdf;jsessionid=2A5CC7AF0CEF95E05450CD863B94A394?sequence=2) in $O(1)$ expected|
