# Register File (`fsm_3block_regfile`)

This repository provides a small synchronous register file you can drop into your own VHDL design. The main thing you will use is the entity `fsm_3block_regfile` from `src/ifx_regfile_e.vhdl`.

You do **not** need to understand the internal FSM; you only need the ports and the basic request/ready handshake. For a short, step-by-step usage guide, see `docs/register_file_usage.md`.

---

## Entity Overview (Reference)

```vhdl
ENTITY fsm_3block_regfile IS
		GENERIC (
			width_g      : NATURAL := 8; -- bits per register
			count_g      : NATURAL := 8; -- number of registers
			addr_width_g : NATURAL := 3  -- address width
		);
		PORT (
				clk_i     : IN  STD_LOGIC;
			rst_i     : IN  STD_LOGIC; -- async reset

			wr_en_i   : IN  STD_LOGIC; -- write strobe
			wr_addr_i : IN  STD_LOGIC_VECTOR(addr_width_g - 1 DOWNTO 0); -- write address
			rd_addr_i : IN  STD_LOGIC_VECTOR(addr_width_g - 1 DOWNTO 0); -- read address
				data_in   : IN  STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);

				data_out  : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
				ready_o   : OUT STD_LOGIC
		);
END ENTITY fsm_3block_regfile;
```

-- `width_g`: number of bits per register (default 8).
-- `count_g`: number of registers (default 8).
-- `addr_width_g`: address vector width (default 3, matches `count_g = 8`).

For a quick, practical usage sequence (write/read handshakes and example timing), see `docs/register_file_usage.md`.

---

## Instantiating in Your Design

Minimal example:

```vhdl
u_regfile : ENTITY work.fsm_3block_regfile
		GENERIC MAP (
				width_g => 8,  -- adjust as needed
				count_g => 8,
				addr_width_g => 3
		)
		PORT MAP (
				clk_i     => clk,
				rst_i     => rst,

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

The repository includes a self-checking testbench in `tb/ifx_regfile_tb.vhdl` and a helper script:

ATTENTION: this script only works in a properly setup linux machine with ghdl and gtkwave installed.

```sh
./run_ifx_regfile_tb.sh --clean --gui
```

The testbench writes a value to a register, reads it back, and checks that the data matches.

### Note for Vivado users

The testbench, as written, uses `std.env.stop` to end the simulation. Some Vivado flows do not support this import or the `stop` call directly.

If you run the testbench inside Vivado and hit issues, make these two changes in `tb/ifx_regfile_tb.vhdl`:

- **Remove the library import**:
  - Delete the line `USE std.env.ALL;`
- **Remove the explicit stop call**:
  - Delete the line `stop;` inside the stimulus process.

Vivado can then control the end of simulation itself (e.g. via a run time or TCL commands), while the testbench still performs the same write/read checks. If you just want to use the register file in your own project, you only need to instantiate `fsm_3block_regfile` as shown above and follow the usage described in `docs/register_file_usage.md`.

