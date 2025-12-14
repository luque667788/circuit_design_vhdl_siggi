# Register File (`ifx_regfile_e`)

This repository provides a small synchronous register file you can drop into
your own VHDL design. The main thing you will use is the entity
`ifx_regfile_e` from `src/ifx_regfile_e.vhdl` with defaults in
`src/project_pkg.vhdl`.

You do **not** need to understand the internal FSM; you only need the ports and the basic request/ready handshake. For a short, step-by-step usage guide, see `docs/register_file_usage.md`.

---

## Entity Overview (Reference)

```vhdl
ENTITY ifx_regfile_e IS
  GENERIC (
    width_g      : NATURAL := reg_width_c;
    count_g      : NATURAL := reg_count_c;
    addr_width_g : NATURAL := reg_addr_width_c
  );
  PORT (
    clk_i     : IN  STD_LOGIC;
    rst_n_i   : IN  STD_LOGIC;
    wr_en_i   : IN  STD_LOGIC;
    wr_addr_i : IN  STD_LOGIC_VECTOR(addr_width_g - 1 DOWNTO 0);
    data_in   : IN  STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
    rd_addr_i : IN  STD_LOGIC_VECTOR(addr_width_g - 1 DOWNTO 0);
    data_out  : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
    ready_o   : OUT STD_LOGIC
  );
END ENTITY ifx_regfile_e;
```

- `reg_width_c`, `reg_count_c`, `reg_addr_width_c` live in `project_pkg.vhdl`.
- Active-low asynchronous reset `rst_n_i` applies to all flip-flops.

For a quick, practical usage sequence (write/read handshakes and example timing), see `docs/register_file_usage.md`.

---

## Instantiating in Your Design

Minimal example (after `USE work.project_pkg.ALL;`):

```vhdl
u_regfile : ifx_regfile_e
  GENERIC MAP (
    width_g      => reg_width_c,
    count_g      => reg_count_c,
    addr_width_g => reg_addr_width_c
  )
  PORT MAP (
    clk_i     => clk,
    rst_n_i   => rst_n,
    wr_en_i   => reg_wr_en,
    wr_addr_i => reg_wr_addr,
    rd_addr_i => reg_rd_addr,
    data_in   => reg_data_in,
    data_out  => reg_data_out,
    ready_o   => reg_ready
  );
```

Drive `wr_en_i` for one clock to store `data_in` at `wr_addr_i`; `ready_o` stays low only while the internal FSM performs the write. Reads are purely combinational—just set `rd_addr_i` and observe `data_out`.

---

## Running the Testbench and Using Vivado

Simulation helper scripts (all use GHDL + optional GTKWave):

- `./run_ifx_reg_cell_tb.sh [--clean] [--gui]`
  - Unit test for the single register cell (`ifx_reg_cell_e/a`).
- `./run_ifx_regfile_tb.sh [--clean] [--gui]`
  - Unit test for the register file (`ifx_regfile_e`).
- `./run_integration_uart_core_tb.sh [--clean] [--gui]`
  - Unit test for the UART integration core FSM (`integration_uart_core`).
- `./run_ifx_regfile_integration_1_tb.sh [--clean] [--gui]`
  - Integration test: UART core writes to the regfile, then reads back via
    external address.

ATTENTION: scripts expect a Linux environment with `ghdl` and `gtkwave` on PATH.

```sh
./run_ifx_regfile_tb.sh --clean --gui
```

Each testbench is self-checking and reports mismatches via ASSERTs.

### Note for Vivado users

The testbench, as written, uses `std.env.stop` to end the simulation. Some Vivado flows do not support this import or the `stop` call directly.

If you run the testbench inside Vivado and hit issues, make these two changes in `tb/ifx_regfile_tb.vhdl`:

- **Remove the library import**:
  - Delete the line `USE std.env.ALL;`
- **Remove the explicit stop call**:
  - Delete the line `stop;` inside the stimulus process.

Vivado can then control the end of simulation itself (e.g. via a run time or TCL commands), while the testbench still performs the same write/read checks. If you just want to use the register file in your own project, you only need to instantiate `fsm_3block_regfile` as shown above and follow the usage described in `docs/register_file_usage.md`.

