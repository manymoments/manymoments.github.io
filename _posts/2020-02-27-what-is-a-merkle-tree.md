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

_Merkle Hash Trees (MHTs)_[^Merkle87] is a way to sign many documents using just one digital signature.

** An Example
Suppose that Alice has 1000 documents that she wants to shre with Bob and decides to use [Dropbox](https://dropbox.com).
Alice has no guarantee that the file(s) that Bob will download  are the same files that Alice uploaded.
What if a disgruntled Dropbox employee modified one of Alice's pictures or changed one of her PowerPoint presentations?

The simplest thing Alice can do is sign each  of her 1000 documents signed using a digital signature.  She then just needs to give Bob per public key. After verifying all the signatures, Dropbox just needs to send with each document, also Alice's signature on the document.

The good thing about this solution is that Dropbox needs to send very little additional information (just one signature)

The problem with this solution is twofold: Alice needs to sign a lot of document (this can take a lot of time) and Dropbox has to store a lot of signature (this can take a lot of space).


** A more frugal solution using Merkle Hash Trees
If Alice has billions of very small documents this solution is not good.  

A Merkle Hash Tree is data structure that provides a much better trade-off in this case.

1. Instead of signing each document, Alice builds a Merkle Hash Tree of the documents and  signs just the *Root Hash* of the Merkle Hash Tree.

2. Alice then uploads the Root Hash to Dropbox.

3. Dropbox also builds a Merkle Hash Tree of the documents and verifies Alice's signature of the Root Hash that dropbox computed.

3. Now when Bob asks for a document $D$, Dropbox can serve the document and also a cryptographic proof that Alice singed this document. This cryptographic proof consists of two parts:
  1. Alice's a signature of the Root Hash.
  2. A *Merkle Branch Proof* that essentially transforms the signature on the Root Hash to a signature on the document $D$.

  4. When Bob receives $D$ and the two parts of the proof, it can verify that together they form a signature of Alice on $D$.


The good things about this solution:
1. Alice needs to sign just one value.
2. Alice needs to upload just one signature to Dropbox.

The slight drawback of this solution is that the data that Dropbox needs to send to Bob is more than one signature, its also the Merkle Branch Proof.



---


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
