```mermaid
flowchart TB
    box-->cluster
    box-0-->cluster
    sub-1-->box
    sub-2-->box
    subgraph box
      db [(redis)]
      pubsub ((mqtt))
      comms ([mumble])
      nomad [nomad]<--comms <--pubsub<--redis
      nomad >nomad]-|terminal|->nomad
    end
```
