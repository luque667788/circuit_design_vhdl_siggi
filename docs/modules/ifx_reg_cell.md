# `ifx_reg_cell_e` / `_a` Data Sheet

Purpose
- Single synchronous register with load enable.
- Width is generic (`width_g`, default `reg_width_c`).

Ports
- `clk_i` (in): system clock, rising-edge.
- `rst_n_i` (in): active-low async reset, clears the register to `0`.
- `load_i` (in): when high on a rising edge, captures `data_i`.
- `data_i` (in): data to store, `width_g` bits.
- `data_o` (out): stored data, `width_g` bits.

Internal Signals / Registers
- One register holding `data_o`.

Processes
- Clocked process on `clk_i`, async reset on `rst_n_i`.
  - If reset is low, register <= 0.
  - Else if rising edge and `load_i = '1'`, register <= `data_i`.
  - Else hold last value.

Operation
- Assert `load_i` for one clock with desired `data_i` to update the register.
- `data_o` reflects the stored value after the rising edge.
