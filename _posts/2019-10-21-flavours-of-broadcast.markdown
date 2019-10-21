---
title: Flavours of Broadcast
date: 2019-10-21 07:44:00 -07:00
published: false
tags:
- dist101
Field name: 
---

What is the difference between broadcast, crusader broadcast, gradecast, weak broadcast and broadcast with abort?


Secure Multi-Party Computation Without Agreement
Shafi Goldwasser
Yehuda Lindell

http://groups.csail.mit.edu/cis/pubs/shafi/2002-disc.pdf
https://eprint.iacr.org/2002/040.pdf


Detectable Byzantine Agreement Secure Against Faulty
Majorities

https://groups.csail.mit.edu/tds/papers/Smith-Adam/fghhs-PODC2002-new-final.pdf


The Weak Byzantine Generals Problem
Lamport 84
https://zoo.cs.yale.edu/classes/cs426/2014/bib/lamport83theweak.pdf

https://groups.csail.mit.edu/tds/papers/Lynch/FischerLynchMerritt-dc.pdf FLM lower bound


Crusader Agreement
Dolev 81
http://infolab.stanford.edu/pub/cstr/reports/cs/tr/81/846/CS-TR-81-846.pdf




A protocol solves the **broadcast with abort** problem:
1. **Weak Agreement**: If an honest party outputs x, then all honest parties output either x or ⊥.
2a. **Weak Validity*: If sender is honest, then all honest parties output either sender's value or ⊥.
2b. **Non-triviality**: If all parties are honest, then all parties output the sender's value.




A protocol solves the **crusader broadcast** problem:
1. **Weak Agreement**: If an honest party outputs x , then all honest parties output either x or ⊥.
2. **Validity*: If sender is honest, then all honest parties output the sender's value.


(Gradecast is even stronger, so call this gradecast)


A protocol solves the **weak broadcast** problem:
1. **Agreement**: If an honest party outputs x, then all honest parties output x.
2a. **Weak Validity*: If sender is honest, then all honest parties output either sender's value or ⊥.
2b. **Non-triviality**: If all parties are honest, then all parties output the sender's value.