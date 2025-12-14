# Register File Quick Usage

This is a short, practical guide for using `fsm_3block_regfile`. For a full description of ports and behaviour, see the top-level `README.md`.

## What it is

- A small synchronous register file with `width_g` bits per register and `count_g` registers.
- You talk to it with a simple request / ready handshake.

## Basic rules

- Writes are initiated by pulsing `wr_en_i` high for **one** rising edge.
- Keep `wr_addr_i` and `data_in` stable while `wr_en_i` is high.
- `ready_o` is low only while the write FSM is busy; otherwise it is high.
- Reads are **combinational**: set `rd_addr_i` and `data_out` updates immediately (within propagation delay).

## Write sequence

1. Drive `wr_addr_i` and `data_in` with the target register and value.
2. Assert `wr_en_i = '1'` for one rising edge of `clk_i`.
3. Deassert `wr_en_i`.
4. Wait for `ready_o` to return high (it goes low for one clock while the write commits).

## Read behaviour

- Because reads are combinational, you do **not** need a handshake.
- Simply set `rd_addr_i` to the register you want and observe `data_out`.
- If you prefer a registered read, add a flip-flop in your design and sample `data_out` on your own clock enable.

## Example: write then read

- Write `x"A5"` to register 2:
  - `wr_addr_i="010"`, `data_in=x"A5"`, pulse `wr_en_i` high for one clock.
  - `ready_o` drops to `0` for that cycle and returns to `1` when the write is complete.
- Read it back:
  - Drive `rd_addr_i="010"`.
  - After combinational delay, `data_out` reflects `x"A5"` (no handshake needed).

## Simulation

To see this in action, run the provided testbench:

```sh
./run_ifx_regfile_tb.sh --clean --gui
```

The testbench performs a write and a read and checks that the read-back value matches.
