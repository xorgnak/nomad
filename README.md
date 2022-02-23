```mermaid!
flowchart TB
    box-->cluster
    box-0-->cluster
    sub-1-->box
    sub-2-->box
    subgraph cluster
    
    end
    subgraph box-0
    
    end
    subgraph sub-0
    
    end
    subgraph sub-1
    
    end
    subgraph box
      db [(redis)]
      pubsub ((mqtt))
      comms ([mumble])
      server [nomad]
      client >nomad]
    end
```
