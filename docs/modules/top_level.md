# `top_level_e` / `_a` Data Sheet

Purpose
- Structural wrapper that connects the UART command core to the register file.
- Provides a simple external read port while writes come from UART.

Ports
- `clk_i` (in): system clock, rising-edge.
- `rst_n_i` (in): active-low async reset for all sub-blocks.
- `ascii_rx_i` (in): UART byte stream from receiver.
- `rx_ready_i` (in): pulse indicating `ascii_rx_i` is valid.
- `reg_addr_i` (in): external read address.
- `reg_data_o` (out): external read data from regfile.
- `reg_ready_o` (out): regfile ready flag (low only during a write cycle).

Internal Signals
- `reg_wr_en_s`: write enable from UART core to regfile.
- `reg_wr_addr_s`: write address from UART core to regfile.
- `reg_data_in_s`: write data from UART core to regfile.

Instances
- `integration_uart_core_e`: decodes UART bytes to produce write addr/data/en.
- `ifx_regfile_e`: stores registers; handles external read and UART-driven writes.

Operation
- UART core watches `ascii_rx_i`/`rx_ready_i` for a command + data byte and asserts `reg_wr_en_s` with address/data.
- Regfile writes on that strobe; `reg_ready_o` drops for that cycle.
- External logic reads by driving `reg_addr_i`; `reg_data_o` updates combinationally.
