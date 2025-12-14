# `ifx_regfile_e` / `_a` Data Sheet

Purpose
- Small synchronous register file with configurable width and depth.
- Provides a simple write handshake and combinational read.

Ports
- `clk_i` (in): system clock, rising-edge.
- `rst_n_i` (in): active-low async reset; clears internal registers.
- `wr_en_i` (in): write enable pulse; when high on a rising edge, writes `data_in` to `wr_addr_i`.
- `wr_addr_i` (in): write address, `addr_width_g` bits (default `reg_addr_width_c`).
- `data_in` (in): write data, `width_g` bits (default `reg_width_c`).
- `rd_addr_i` (in): read address, `addr_width_g` bits.
- `data_out` (out): combinational read data from `rd_addr_i`.
- `ready_o` (out): write-ready flag; low only while the internal write strobe is active.

Internal Signals / Registers
- Memory array of `count_g` registers, each `width_g` bits.
- Simple ready flag (`ready_o`) that drops for the write cycle.

Processes
- Clocked write process: on rising edge, if `wr_en_i` = '1', write `data_in` to `wr_addr_i` and drop `ready_o` for that cycle.
- Combinational read: `data_out` is a mux of the array at `rd_addr_i`.

Operation
- Write: set `wr_addr_i` and `data_in`, pulse `wr_en_i` high for one clock. `ready_o` goes low for that cycle, then returns high.
- Read: set `rd_addr_i`; `data_out` updates combinationally (no handshake needed).
- Reset: `rst_n_i` low clears all registers and drives `ready_o` high after reset.
