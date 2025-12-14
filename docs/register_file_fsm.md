# FSM State Diagram


```mermaid
stateDiagram-v2
    [*] --> ST_IDLE
    state ST_IDLE {
        ready_high: ready_o high
    }www
    state ST_WRITE {
        write_action: store data_in at wr_addr_i of register file
    }
    state ST_DONE {
        ready_high: ready_o high, data_out still holds valid data
    }

    ST_IDLE --> ST_WRITE : wr_en_i
    ST_WRITE --> ST_DONE
    ST_DONE --> ST_IDLE
```

Reads bypass the FSM entirely—they are simple combinational muxing from `rd_addr_i` to `data_out`.
