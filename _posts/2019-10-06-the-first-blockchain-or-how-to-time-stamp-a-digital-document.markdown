---
title: The First Blockchain or How to Time-Stamp a Digital Document
date: 2019-10-06 19:58:00 -07:00
published: false
tags:
- blockchain101
---

This post is about the work of Stuart Haber and W. Scott Stornetta from 1991 [How to Time-Stamp a Digital Document](https://www.anf.es/pdf/Haber_Stornetta.pdf) and their followup paper [Improving the Efficiency and Reliability of Digital Time-Stamping](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.71.4891&rep=rep1&type=pdf). These are two of the eight papers cited by the [bitcoin whitepaper](https://bitcoin.org/bitcoin.pdf). 

> Who watches the watchmen?
>
> Quis custodiet ipsos custodes?
> -- <cite> [Juvenal](https://en.wikipedia.org/wiki/Juvenal) </cite>


The ideas of this paper have been in use from 1995 by [Surety](http://www.surety.com/solutions/intellectual-property-protection/sign-seal). This makes it the longest-running blockchain! Here is a photo from 2018 of Stuart Haber with the hash circled in red on the NYT.

<p align="center">
    <img src="/uploads/Haber1" width="600" title="The first blockchain">
</p>

<p align="center">
    <img src="/uploads/Haber2" width="600" title="The first blockchain">
</p>

## How to Time-Stamp a Digital Document?
In 1991, Haber and Stornetta asked this very basic question. Today, after 30 years of exponential growth in digital documents, this question is even more revenant! Let's describe their basic scheme:

1. The system is composed of users, a Time-Stamp Service (TSS), and a repository. 

2. At some regular interval, the TSS publishes an "internal hash" to the "widely available repository".

3. Users 