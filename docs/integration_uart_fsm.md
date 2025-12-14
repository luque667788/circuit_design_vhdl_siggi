# Integration UART FSM


Top-level `integration_uart_e` is structural only. All behavior lives in
`integration_uart_core_e` / `_a`, which receives UART bytes and outputs register write signals.
A leading nibble `1111` marks an address byte; the next byte is written as data.
The interface is:

- `reg_wr_addr_o`: latched address (from address byte lower bits)
- `reg_data_in_o`: data byte (from payload)
- `reg_wr_en_o`: asserted for one cycle to trigger write

All widths and prefix constants are in `project_pkg.vhdl`.

```mermaid
stateDiagram-v2
    [*] --> idle_st
    idle_st --> addr_st: rx_ready_i && ascii_rx_i[7:4] == "1111"
    addr_st --> wait_data_st
    wait_data_st --> data_st: rx_ready_i
    data_st --> idle_st

    state idle_st {
        note right: waiting for address prefix
    }
    state addr_st {
        note right: latch reg_wr_addr_o = ascii_rx_i[3:0]
    }
    state wait_data_st {
        note right: hold address, wait for payload byte
    }
    state data_st {
        note right: assert reg_wr_en_o for one cycle, reg_data_in_o = ascii_rx_i
    }
```

Outputs:
- `reg_wr_en_o` is asserted for one cycle in `data_st` to trigger a register write.
- `reg_wr_addr_o` holds the latched address (from the address byte lower bits).
- `reg_data_in_o` is the data byte (from the payload byte).
- Reset is active-low (`rst_n_i`). All widths and prefix constants are in `project_pkg.vhdl`.