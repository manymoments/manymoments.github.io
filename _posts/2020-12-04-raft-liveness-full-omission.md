---
title: Raft does not Guarantee Liveness in the face of Omission Faults.
date: 2020-12-04 09:01:00 -05:00
published: false
---

Last week, [Cloudflare published a postmortem](https://blog.cloudflare.com/a-byzantine-failure-in-the-real-world/) of a recent 6-hour outage caused by a partial switch failure which left [etcd](https://etcd.io) unavailable as it was unable to establish a stable leader. This outage has understandably led to [discussion online](https://twitter.com/heidiann360/status/1332711011451867139) about exactly what liveness guarantees are provided by the [Raft](https://raft.github.io) consensus algorithm in the face of network failures.

The [original Raft paper](https://raft.github.io/raft.pdf) makes the following claim:
*“[Consensus algorithms] are fully functional (available) as long as any majority of the servers are operational and can communicate with each other and with clients.”*

This statement implies that consensus algorithms such as Raft should tolerate message delay or loss (also known as [omission faults](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/)) as long as it does not impact communication between the majority of servers.

In this post, however, we will show the following claim:

*Claim:* Raft does not guarantee liveness if one link between servers can arbitrarily delay or drop messages.

*Proof:*

At the high level, we can show this by demonstrating that leadership can bounce between the servers at either end of the broken link such that a stable leader is not established.

Specifically, consider the following scenario...

We have three servers: server 1, server 2, and server 3. All servers are up and available. The three servers are executing the Raft algorithm, as described in the [Raft paper](https://raft.github.io/raft.pdf) and there are no [Byzantine failures](https://decentralizedthoughts.github.io/2019-06-07-modeling-the-adversary/). Servers 1 and 2, as well as servers 2 and 3, are connected by perfect links, where all messages sent between these servers are reliably delivered in a timely manner. The link between server 1 and server 3 however is broken and may drop or delay some messages. This is the partial network failure which [caused the Cloudflare outage](https://blog.cloudflare.com/a-byzantine-failure-in-the-real-world/).

To begin with, all servers are in term 1, server 3 is the leader and servers 1 and 2 are followers. All three servers have identical logs.

We expect that this system would be fully available as we have a clear leader (server 3) and a follower (server 2) which are connected by perfect links. But this is not always the case. Here’s why:

1. The broken link between server 1 and 3 could delay/drop the AppendEntries RPC heartbeats from server 3. Server 1’s election timeout could elapse without hearing from the leader (server 3).
Server 1 increases its term from term 1 to term 2 and sends RequestVote RPCs to servers 2 and 3.
2. Server 3 ends up stepping down as leader of term 1. This could occur because either:
  * server 3 receives the RequestVote RPC from server 1 and steps down directly or,
  * server 2 receives the RequestVote RPC from server 1, updates its own term to term 2, and informs server 3 that it is now term 2 in the next AppendEntries RPC response.
3. Server 1 will receive a vote from server 2 (and maybe also from server 3). Server 1 will therefore become the leader of term 2 as it has received at least two votes. Server 1 can begin appending log entries to servers 2 and 3. If the broken link between server 1 and 3 delivers the AppendEntries RPC to server 3 then we can reach a state where all logs are the same.
4. This is now the same situation we started with, except that we are in term 2 instead of term 1, and server 1 and 3 have swapped roles. This sequence of events could continue indefinitely.

Note that this case is also not specific to deployments with three servers. We can recreate the same issue with five servers by substituting server 2 with servers 2, 4, and 5. We can do the same for seven servers and so forth.

We have outlined one issue with guaranteeing the liveness of Raft in the presence of partial network failures.  Fundamentally, whilst Raft does guarantee liveness when up to a minority of servers have failed, **Raft does not guarantee liveness in the presence of omission faults** and thus this should be taken into consideration when deciding to depend upon the availability of Raft in production.

## Bonus: Patching

Naturally, the question arises of whether we can patch Raft such that it able to guarantee liveness in the presence of omission faults, provided that at least a majority of servers are up and the links between them are perfect. In our example, a leader (server 3) with a majority quorum (itself and server 2) is forced to step down by another server (server 1). This is not desirable behaviour but this issue can be fixed, for example, by either:
1. requiring servers to ignore RequestVote RPCs if they have received an AppendEntries RPC from the leader within the election timeout. This was suggested in section 6 in the [Raft paper](https://raft.github.io/raft.pdf) as mitigation for liveness issues during reconfiguration, or
2. by using PreVote, which requires potential candidates to run a trial election before incrementing their term and executing a normal election. A server only votes for a potential candidate during the trial election if it would vote for it during a normal election and importantly, if has not received an AppendEntries RPC from the leader with in the election timeout. This is described in section 9.6 of [Diego Ongaro’s thesis](https://web.stanford.edu/~ouster/cgi-bin/papers/OngaroPhD.pdf).

We will now look more closely at the later patch and show that it does in fact fix our issue.

*Claim:* Raft with PreVote guarantees that a leader with the support of a majority quorum of followers, all up and connected by perfect links, will not be forced to step down.

*Proof:*

A leader will only step down if it receives an RPC (except PreVote) with a greater term, therefore if no server has a greater term than the leader then the leader cannot be forced to step down.
We will assume that initially all servers have a term equal to or less than the leader and show that no server can increase its term to more than the leader's term.

The first server to increase its term to more than the leader's must have first completed the PreVote phase with a majority of servers. Since the leader has perfect links to a majority quorum of followers, none of the majority will pre vote and thus the cannot receive sufficient pre votes to update its term.


However, such a protocol changes simply create new liveness issues in different scenarios.
