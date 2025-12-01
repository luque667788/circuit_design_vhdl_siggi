# Register File Quick Usage

This is a short, practical guide for using `fsm_3block_regfile`. For a full description of ports and behaviour, see the top-level `README.md`.

## What it is

- A small synchronous register file with `width_g` bits per register and `count_g` registers.
- You talk to it with a simple request / ready handshake.

## Basic rules

- Only **one request at a time**: either write (`we_i`) or read (`re_i`), not both.
- All signals are sampled on the **rising edge** of `clk_i`.
- `en_i` must be `'1'` or the request is ignored.
- When a request finishes, `ready_o` goes high for **one clock**.

## Write sequence

1. Set `en_i = '1'`.
2. Set `we_i = '1'`, `re_i = '0'`.
3. Drive `wr_addr_i` and `data_in` to the desired values.
4. Wait for one clock edge, then you can drop `we_i`.
5. Wait until `ready_o = '1'` for one clock → write is done.

## Read sequence

1. Set `en_i = '1'`.
2. Set `re_i = '1'`, `we_i = '0'`.
3. Drive `rd_addr_i` to the desired register.
4. Wait for one clock edge, then you can drop `re_i`.
5. Wait until `ready_o = '1'` → on that clock, `data_out` holds the register value.

## Example: write then read

- Write `x"A5"` to register 2:
  - `en_i=1`, `we_i=1`, `re_i=0`, `wr_addr_i="010"`, `data_in=x"A5"` for one clock.
  - Later, when `ready_o` pulses high, the write is complete.
- Read it back:
  - `en_i=1`, `re_i=1`, `we_i=0`, `rd_addr_i="010"` for one clock.
  - When `ready_o` pulses high, sample `data_out` → should be `x"A5"`.

## Simulation

To see this in action, run the provided testbench:

```sh
./run_ifx_regfile_tb.sh --clean --gui
```

The testbench performs a write and a read and checks that the read-back value matches.
