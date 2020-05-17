---
---

### Generalized Primary-Backup

When there are $n>2$ replicas the new primary must do some more work to continue to maintain the invariant: **send the command to all the backups before responding back to the client**. 

Each ```replica j``` maintains a *resend* variable that stores the last command it received from the primary. If $j$ becomes the new primary it resends the last command to all replicas when it does a view change. Assume $n$ replicas with identifiers $\{0,1,2,\dots,n-1\}$.



```
// Replica j

state = init
log = []
resend = []
view = 0
while true:
   // as a Backup
   on receiving cmd from replica[view]:
      log.append(cmd)
      state, output = apply(cmd, state)
      resend = cmd        
   // as a Primary
   on receiving cmd from a client library (and view == j):
      send cmd to all replicas
      log.append(cmd)
      state, output = apply(cmd, state)
      send output to the client library
   // View change
   on missing "heartbeat" from replica[view] in the last t + $\Delta$ time units:
      view = view + 1
      if view == j
         send ("view change", j) to all client libraries
         send resend to all replicas (in order)
   // Heartbeat from primary
   if no client message for some predetermined time t: 
      send "heartbeat" to all replicas (in order)
```
