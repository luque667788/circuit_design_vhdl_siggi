LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ARCHITECTURE ifx_regfile_a OF fsm_3block_regfile IS
    TYPE reg_array_t IS ARRAY (0 TO count_g - 1) OF STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
    SIGNAL registers : reg_array_t;
    SIGNAL reg_load  : STD_LOGIC_VECTOR(0 TO count_g - 1);
    SIGNAL busy_q    : STD_LOGIC;

    -- read is not dependant on clock or state
    -- just decodes the address to an index in the array and then outputs it.
    FUNCTION mux_read(
        addr : STD_LOGIC_VECTOR(addr_width_g - 1 DOWNTO 0);
        regs : reg_array_t) RETURN STD_LOGIC_VECTOR IS
        VARIABLE out_val : STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        VARIABLE idx     : INTEGER;
    BEGIN
        idx := to_integer(unsigned(addr));
        IF idx >= 0 AND idx < count_g THEN
            out_val := regs(idx);
        ELSE
            out_val := (OTHERS => '0');
        END IF;
        RETURN out_val;
    END FUNCTION mux_read;
    BEGIN
    -- Instantiate one flip-flop register per storage element
    gen_registers : FOR i IN 0 TO count_g - 1 GENERATE
        reg_cell : ENTITY work.ifx_reg_cell_e
            GENERIC MAP(
                width_g => width_g
            )
            PORT MAP(
                clk_i  => clk_i,
                rst_i  => rst_i,
                load_i => reg_load(i),
                data_i => data_in,
                data_o => registers(i)
            );
    END GENERATE gen_registers;

    -- Decode write enable per register for a given address
    -- we only decode when write enable is asserted
    reg_load_decode : PROCESS (wr_en_i, wr_addr_i)
        VARIABLE tmp : STD_LOGIC_VECTOR(0 TO count_g - 1); -- we can only edit signals once per process so we use a temporary variable
        VARIABLE idx : INTEGER;
    BEGIN
        tmp := (OTHERS => '0');
        IF wr_en_i = '1' THEN
            idx := to_integer(unsigned(wr_addr_i));
            IF idx >= 0 AND idx < count_g THEN
                tmp(idx) := '1'; -- here we are "decoding" the address and enabling the corresponding register 
            END IF;
        END IF;
        reg_load <= tmp; -- Assign the temporary variable to the signal 

        
        -- TAKE CARE: we should only have one 1 in the reg_load signal (write one signal at a time)
    END PROCESS reg_load_decode;

    data_out <= mux_read(rd_addr_i, registers);

    -- ready drops for one cycle when a write strobe is seen
    busy_ff : PROCESS (clk_i)
    BEGIN
        IF rising_edge(clk_i) THEN
            IF rst_i = '1' THEN
                busy_q <= '0';
            ELSIF wr_en_i = '1' THEN
                busy_q <= '1';
            ELSE
                busy_q <= '0';
            END IF;
        END IF;
    END PROCESS busy_ff;

    ready_o <= NOT busy_q;

END ifx_regfile_a;