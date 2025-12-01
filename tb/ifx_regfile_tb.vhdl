-- ###########################################################################
--  ifx_regfile_tb
-- ###########################################################################

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.env.All;

ENTITY ifx_regfile_tb IS
END ENTITY ifx_regfile_tb;

ARCHITECTURE tb OF ifx_regfile_tb IS
-- testbench parameters
    CONSTANT c_register_count : POSITIVE := 8;
    CONSTANT c_data_width : POSITIVE := 8;
    CONSTANT c_addr_width : POSITIVE := 3;
    CONSTANT c_clk_period : TIME := 8 ns; -- 125 MHz clock period
    CONSTANT c_pat_a5 : STD_LOGIC_VECTOR(c_data_width - 1 DOWNTO 0) := x"A5";

    -- Stimulus signals.
    SIGNAL clk_i : STD_LOGIC := '0';
    SIGNAL rst_i : STD_LOGIC := '0';
    SIGNAL en_i : STD_LOGIC := '0';
    SIGNAL we_i : STD_LOGIC := '0';
    SIGNAL re_i : STD_LOGIC := '0';
    SIGNAL wr_addr_i : STD_LOGIC_VECTOR(c_addr_width - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rd_addr_i : STD_LOGIC_VECTOR(c_addr_width - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data_in : STD_LOGIC_VECTOR(c_data_width - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data_out : STD_LOGIC_VECTOR(c_data_width - 1 DOWNTO 0);
    SIGNAL ready_o : STD_LOGIC := '0';

BEGIN

    -- Clock generator
    clk_gen : PROCESS
    BEGIN
        clk_i <= '0';
        WAIT FOR c_clk_period / 2;
        clk_i <= '1';
        WAIT FOR c_clk_period / 2;
    END PROCESS;

-- create the entity to test
    dut : ENTITY work.fsm_3block_regfile
        GENERIC MAP(
            count_g => c_register_count,
            width_g => c_data_width
        )
        PORT MAP(
            clk_i => clk_i,
            rst_i => rst_i,
            en_i => en_i,
            we_i => we_i,
            re_i => re_i,
            wr_addr_i => wr_addr_i,
            rd_addr_i => rd_addr_i,
            data_in => data_in,
            data_out => data_out,
            ready_o => ready_o
        );


    -- simulation some use like reads and writes
    stimulus : PROCESS
        VARIABLE cycles : INTEGER := 0;
        VARIABLE ready_seen_1 : BOOLEAN := FALSE;
        VARIABLE ready_seen_2 : BOOLEAN := FALSE;
    BEGIN
        -- initial reset/defaults
        rst_i     <= '1';
        en_i      <= '0';
        we_i      <= '0';
        re_i      <= '0';
        wr_addr_i <= (OTHERS => '0');
        rd_addr_i <= (OTHERS => '0');
        data_in   <= (OTHERS => '0');

        -- run for a bounded number of clock cycles
        FOR i IN 0 TO 50 LOOP
            WAIT UNTIL rising_edge(clk_i);
            cycles := cycles + 1;

            CASE cycles IS
                WHEN 1 | 2 =>
                    -- still in reset

                WHEN 3 =>
                    -- release reset, enable DUT
                    rst_i <= '0';
                    en_i  <= '1';

                    -- request write to register 2 with pattern A5
                    wr_addr_i <= STD_LOGIC_VECTOR(to_unsigned(2, c_addr_width));
                    data_in   <= c_pat_a5;
                    we_i      <= '1';
                    re_i      <= '0';

                WHEN 4 =>
                    -- de-assert write
                    we_i <= '0';

                WHEN OTHERS =>
                    NULL;
            END CASE;

            -- react to ready_o edges in the same clock
            IF ready_o = '1' THEN
                IF NOT ready_seen_1 THEN
                    -- first ready: schedule read
                    ready_seen_1 := TRUE;
                    rd_addr_i    <= STD_LOGIC_VECTOR(to_unsigned(2, c_addr_width));
                    re_i         <= '1';

                ELSIF NOT ready_seen_2 THEN
                    -- second ready: complete read & check data
                    ready_seen_2 := TRUE;
                    re_i         <= '0';

                    ASSERT data_out = c_pat_a5
                        REPORT "Register 2 read-back mismatch"
                        SEVERITY error;

                    REPORT "ifx_regfile_tb completed successfully" SEVERITY note;
                    stop;
                    WAIT;
                END IF;
            END IF;
        END LOOP;

        -- safety fallback if we exit the loop without finishing
    END PROCESS;

END ARCHITECTURE tb;