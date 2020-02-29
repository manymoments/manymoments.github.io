---
title: What is a Merkle Tree?
date: 2020-02-27 09:05:00 -08:00
published: false
tags:
- cryptography
- merkle-hash-tree
- collision-resistant-hash-function
- integrity
author: Alin Tomescu
---

_Merkle Hash Trees (MHTs)_[^Merkle87] allow for _secure data outsourcing_.
For example, you upload all of your files on [Dropbox](https://dropbox.com).
Still, you have no guarantee that the file(s) you download back are the same files you uploaded.
What if a disgruntled Dropbox employee modified one of your pictures or changed one of your PowerPoint presentations?
Well, MHTs will allow you to immediately detect any such unauthorized changes to your outsourced files.

You might say, _"but I'll notice anyway when I download the file, open it and manually inspect it."_
Sure, but when you have many files and/or the files are large, detecting subtle changes can be very cumbersome to say the least.
(e.g., imagine detecting a small change in a large number in your huge Excel spreadsheet)

More formally, MHTs enable a _verifier_ to outsource a dataset $D$ to an untrusted _prover_ so that whenever the verifier wants to download $D$ back, they can be convinced by the prover that their dataset was not modified.
In particular, $D$ can be a set, a vector or a key-value store.
Furthermore, the verifier might download part of $D$ rather than the entire $D$ (e.g., a picture on Dropbox rather than all of your Dropbox files).
Nonetheless, the verifier can still be convinced that the prover is sending the correct data. 

## Other applications of Merkle trees

 - Transforming one-time signature schemes to many-time schemes
 - Batch signing

## References

[^Merkle87]: **A Digital Signature Based on a Conventional Encryption Function**, by Merkle, Ralph C., *in CRYPTO '87*, 1988
[^CLRS09]: **Introduction to Algorithms, Third Edition**, by Cormen, Thomas H. and Leiserson, Charles E. and Rivest, Ronald L. and Stein, Clifford, 2009
