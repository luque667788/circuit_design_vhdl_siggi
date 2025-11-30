# FSM Register File Usage Guide

## Overview
- Entity: `fsm_3block_regfile`
- Purpose: Single-port register file with synchronous read/write and one-cycle `ready_o` completion pulse.
- Generics:
  - `width_g`: data width per register (default 8).
  - `count_g`: number of registers (default 8).

## FSM States
- `ST_IDLE`: wait for a request; `ready_o` held low.
- `ST_WRITE`: capture write request and commit `data_in` to `wr_addr_i` on the same clock.
- `ST_READ`: capture read request and place the addressed register into `data_out`.
- `ST_DONE`: signal completion with `ready_o = '1'` for one clock, then return to idle.

## Implementation Notes
- Each storage element is an instance of `ifx_reg_cell_e`, a parametrised flip-flop with load enable and explicit feedback path for academic clarity.

## Port Summary
- `clk_i`: rising-edge clock.
- `rst_i`: synchronous active-high reset; clears state, memory, and output buffer.
- `en_i`: global enable. Requests are ignored when low.
- `we_i`: write request. Sampled in `ST_IDLE`.
- `re_i`: read request. Sampled in `ST_IDLE`.
- `wr_addr_i`: write address (3 bits for default generics).
- `rd_addr_i`: read address.
- `data_in`: data to be written.
- `data_out`: registered read data, valid during and after the `ST_DONE` state.
- `ready_o`: pulses high for one clock in `ST_DONE`, signalling completion of the most recent request.

## Handshake Timing
1. Drive `en_i = '1'` and assert either `we_i` or `re_i` (not both) while presenting addresses/data.
2. Hold the request for at least one rising clock edge so the FSM can capture it in `ST_IDLE`.
3. After the edge, deassert the request; the FSM advances to `ST_WRITE` or `ST_READ` and then `ST_DONE`.
4. On the next clock, observe `ready_o = '1'`. If the request was a read, sample `data_out` on this cycle.
5. The FSM automatically returns to `ST_IDLE`, ready for the next transaction.

## Simulation Workflow
- Run `./run_ifx_regfile_tb.sh --clean --gui` from the project root to rebuild, simulate with GHDL, and optionally open GTKWave.
- The provided testbench exercises reset, read-after-write, and the `ready_o` handshake using helper procedures that wait for completion.

## Customisation Tips
- For deeper register files, increase `count_g` and expand address widths accordingly.
- Add wait states by extending the FSM if downstream logic requires multi-cycle operations.
- Expose additional status (e.g., error flags) by augmenting the `ST_DONE` logic.
