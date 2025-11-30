LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ARCHITECTURE ifx_regfile_a OF ifx_regfile_e IS
    TYPE state_t IS (ST_IDLE, ST_WRITE, ST_READ, ST_DONE);
    SIGNAL current_state : state_t := ST_IDLE;
    SIGNAL next_state    : state_t := ST_IDLE;

    TYPE reg_array_t IS ARRAY (0 TO count_g - 1) OF STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
    SIGNAL registers : reg_array_t;
    SIGNAL out_buf   : STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL reg_load  : STD_LOGIC_VECTOR(0 TO count_g - 1) := (OTHERS => '0');
BEGIN
    -- State register with synchronous reset
    state_reg : PROCESS (clk_i)
    BEGIN
        IF rising_edge(clk_i) THEN
            IF rst_i = '1' THEN
                current_state <= ST_IDLE;
            ELSE
                current_state <= next_state;
            END IF;
        END IF;
    END PROCESS state_reg;

    -- Next-state logic driven by control requests
    next_state_logic : PROCESS (current_state, en_i, we_i, re_i)
    BEGIN
        next_state <= current_state;

        CASE current_state IS
            WHEN ST_IDLE =>
                IF en_i = '1' THEN
                    IF we_i = '1' THEN
                        next_state <= ST_WRITE;
                    ELSIF re_i = '1' THEN
                        next_state <= ST_READ;
                    ELSE
                        next_state <= ST_IDLE;
                    END IF;
                ELSE
                    next_state <= ST_IDLE;
                END IF;

            WHEN ST_WRITE =>
                next_state <= ST_DONE;

            WHEN ST_READ =>
                next_state <= ST_DONE;

            WHEN ST_DONE =>
                next_state <= ST_IDLE;

            WHEN OTHERS =>
                next_state <= ST_IDLE;
        END CASE;
    END PROCESS next_state_logic;

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

    -- Decode write enable per register
    reg_load_decode : PROCESS (current_state, wr_addr_i)
        VARIABLE tmp : STD_LOGIC_VECTOR(0 TO count_g - 1);
        VARIABLE idx : INTEGER;
    BEGIN
        tmp := (OTHERS => '0');
        IF current_state = ST_WRITE THEN
            idx := to_integer(unsigned(wr_addr_i));
            IF idx >= 0 AND idx < count_g THEN
                tmp(idx) := '1';
            END IF;
        END IF;
        reg_load <= tmp;
    END PROCESS reg_load_decode;

    -- Capture read data into output buffer
    read_buffer : PROCESS (clk_i)
        VARIABLE idx : INTEGER;
    BEGIN
        IF rising_edge(clk_i) THEN
            IF rst_i = '1' THEN
                out_buf <= (OTHERS => '0');
            ELSIF current_state = ST_READ THEN
                idx := to_integer(unsigned(rd_addr_i));
                IF idx >= 0 AND idx < count_g THEN
                    out_buf <= registers(idx);
                END IF;
            END IF;
        END IF;
    END PROCESS read_buffer;

    data_out <= out_buf;
    ready_o  <= '1' WHEN current_state = ST_DONE ELSE '0';

END ifx_regfile_a;