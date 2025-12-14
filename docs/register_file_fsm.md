# FSM State Diagram

```mermaid
stateDiagram-v2
    [*] --> ready_st
    ready_st --> busy_st: wr_en_i
    busy_st --> ready_st

    state ready_st {
        note right: ready_o='1'
    }
    state busy_st {
        note right: write strobed, ready_o drops for 1 clk
    }
```

Reads bypass the FSM entirely—they are combinational muxing from `rd_addr_i`
to `data_out`.

Reset is active-low (`rst_n_i`); default widths and counts are defined in
`project_pkg.vhdl`.
