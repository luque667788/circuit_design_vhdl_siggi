LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.project_pkg.ALL;

ARCHITECTURE ifx_regfile_a OF ifx_regfile_e IS
    TYPE reg_array_t IS ARRAY (0 TO count_g - 1)
    OF STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
    SIGNAL registers_s : reg_array_t;
    SIGNAL reg_load_s : STD_LOGIC_VECTOR(0 TO count_g - 1);
    SIGNAL busy_q_s : STD_LOGIC;
    -- MUX read function 
    -- this allows to read the correct register based on the address
    -- and no need to synchronize with the clock for the read
    -- this function decodes the address and returns the corresponding register value from the register array
    FUNCTION mux_read(
        addr : STD_LOGIC_VECTOR(addr_width_g - 1 DOWNTO 0);
        regs : reg_array_t) RETURN STD_LOGIC_VECTOR IS
        VARIABLE out_val_v : STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        VARIABLE idx_v : INTEGER;
    BEGIN
        idx_v := to_integer(unsigned(addr));
        IF idx_v >= 0 AND idx_v < count_g THEN -- check if valid index
            out_val_v := regs(idx_v);
        ELSE
            out_val_v := (OTHERS => '0');
        END IF;
        RETURN out_val_v;
    END FUNCTION mux_read;

BEGIN
    --create N number of register according to generate parameters
    gen_registers : FOR i IN 0 TO count_g - 1 GENERATE -- for that we use the reg_cell entity
        reg_cell : ifx_reg_cell_e
        GENERIC MAP(
            width_g => width_g
        )
        PORT MAP(
            clk_i => clk_i,
            rst_n_i => rst_n_i,
            load_i => reg_load_s(i), -- map array element to load signal
            data_i => data_in,
            data_o => registers_s(i) -- map array element to data output
        );
    END GENERATE gen_registers;

    data_out <= mux_read(rd_addr_i, registers_s); -- map read output from mux function

    -- routine to map write enable and address to load signals for each register
    reg_load_decode : PROCESS (wr_en_i, wr_addr_i)
        VARIABLE tmp_v : STD_LOGIC_VECTOR(0 TO count_g - 1); -- we create a new var because we cannont assign twice to same signal
        VARIABLE idx_v : INTEGER;
    BEGIN
        tmp_v := (OTHERS => '0'); -- make it all zero first
        IF wr_en_i = '1' THEN
            idx_v := to_integer(unsigned(wr_addr_i));
            IF idx_v >= 0 AND idx_v < count_g THEN
                tmp_v(idx_v) := '1'; -- make the selected register load high only
            END IF;
        END IF;
        reg_load_s <= tmp_v; -- map temp variable to signal
    END PROCESS reg_load_decode;


    -- this process just indicates when the regfile is busy writing (for safety so we dont read at the same time)
    -- we assume the whole write process takes one clock cycle so we just the ready true again after one clock cycle
    busy_ff : PROCESS (clk_i, rst_n_i)
    BEGIN-- in the end this is very similar to a flip-flop
        IF rst_n_i = '0' THEN
            busy_q_s <= '0';
        ELSIF rising_edge(clk_i) THEN
            IF wr_en_i = '1' THEN
                busy_q_s <= '1';
            ELSE
                busy_q_s <= '0';
            END IF;
        END IF;
    END PROCESS busy_ff;

    ready_o <= NOT busy_q_s; -- assing to the real signal (inverted because busy high means not ready)
END ifx_regfile_a;