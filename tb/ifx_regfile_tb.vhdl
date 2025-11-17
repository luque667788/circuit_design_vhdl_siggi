-- ###########################################################################
--  ifx_regfile_tb
-- ###########################################################################

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.env.ALL;


ENTITY ifx_regfile_tb IS
END ENTITY ifx_regfile_tb;

ARCHITECTURE tb OF ifx_regfile_tb IS
-- testbench parameters
    CONSTANT c_register_count : POSITIVE := 64;
    CONSTANT c_data_width : POSITIVE := 8;
    CONSTANT c_addr_width : POSITIVE := 6;
    CONSTANT c_clk_period : TIME := 8 ns; -- 125 MHz clock period
    CONSTANT c_zero : STD_LOGIC_VECTOR(c_data_width - 1 DOWNTO 0) := (OTHERS => '0');
    CONSTANT c_pat_a5 : STD_LOGIC_VECTOR(c_data_width - 1 DOWNTO 0) := x"A5";
    CONSTANT c_pat_3c : STD_LOGIC_VECTOR(c_data_width - 1 DOWNTO 0) := x"3C";
    CONSTANT c_pat_55 : STD_LOGIC_VECTOR(c_data_width - 1 DOWNTO 0) := x"55";

    -- Stimulus signals.
    SIGNAL clk_i : STD_LOGIC := '0';
    SIGNAL rst_i : STD_LOGIC := '0';
    SIGNAL en_i : STD_LOGIC := '0';
    SIGNAL wr_en_i : STD_LOGIC := '0';
    SIGNAL wr_addr_i : STD_LOGIC_VECTOR(c_addr_width - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL wr_data_i : STD_LOGIC_VECTOR(c_data_width - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rd_addr_i : STD_LOGIC_VECTOR(c_addr_width - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rd_data_o : STD_LOGIC_VECTOR(c_data_width - 1 DOWNTO 0);

-- helper to wait a clock cycle
    PROCEDURE wait_clk IS
    BEGIN
        WAIT UNTIL rising_edge(clk_i);
        WAIT FOR c_clk_period / 10;
    END PROCEDURE;

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
    dut : ENTITY work.ifx_regfile_e
        GENERIC MAP(
            register_count_g => c_register_count,
            data_width_g => c_data_width,
            addr_width_g => c_addr_width
        )
        PORT MAP(
            clk_i => clk_i,
            rst_i => rst_i,
            en_i => en_i,
            wr_en_i => wr_en_i,
            wr_addr_i => wr_addr_i,
            wr_data_i => wr_data_i,
            rd_addr_i => rd_addr_i,
            rd_data_o => rd_data_o
        );


    -- simulation some use like reads and writes
    stimulus : PROCESS
    BEGIN
        rst_i <= '1';
        en_i <= '0';
        wr_en_i <= '0';
        wr_addr_i <= (OTHERS => '0');
        wr_data_i <= (OTHERS => '0');
        rd_addr_i <= (OTHERS => '0');
        wait_clk;
        wait_clk;
        rst_i <= '0';
        en_i <= '1';
        rd_addr_i <= STD_LOGIC_VECTOR(to_unsigned(5, c_addr_width));
        wait_clk;
        ASSERT rd_data_o = c_zero REPORT "Register 5 not reset to zero" SEVERITY error;
        wr_en_i <= '1';
        wr_addr_i <= rd_addr_i;
        wr_data_i <= c_pat_a5;
        wait_clk;
        ASSERT rd_data_o = c_pat_a5 REPORT "Bypass path failed for register 5 (observed )" SEVERITY error;
        wr_en_i <= '0';
        wait_clk;
        ASSERT rd_data_o = c_pat_a5 REPORT "Register 5 lost stored data (observed)" SEVERITY error;
        wr_en_i <= '1';
        wr_addr_i <= STD_LOGIC_VECTOR(to_unsigned(8, c_addr_width));
        wr_data_i <= c_pat_3c;
        rd_addr_i <= STD_LOGIC_VECTOR(to_unsigned(8, c_addr_width));
        wait_clk;
        ASSERT rd_data_o = c_pat_3c REPORT "Register 8 write/read mismatch (observed )" SEVERITY error;
        wr_en_i <= '0';
        rd_addr_i <= STD_LOGIC_VECTOR(to_unsigned(5, c_addr_width));
        wait_clk;
        ASSERT rd_data_o = c_pat_a5 REPORT "Register 5 corrupted (observed)" SEVERITY error;
        en_i <= '0';
        rd_addr_i <= STD_LOGIC_VECTOR(to_unsigned(9, c_addr_width));
        wait_clk;
        ASSERT rd_data_o = c_pat_a5 REPORT "Read output changed while enable low (observed )" SEVERITY error;
        en_i <= '1';
        wr_en_i <= '1';
        wr_addr_i <= STD_LOGIC_VECTOR(to_unsigned(9, c_addr_width));
        wr_data_i <= c_pat_55;
        rd_addr_i <= STD_LOGIC_VECTOR(to_unsigned(9, c_addr_width));
        wait_clk;
        ASSERT rd_data_o = c_pat_55 REPORT "Register 9 write failed (observed )" SEVERITY error;
        wr_en_i <= '0';
        REPORT "ifx_regfile_tb completed successfully" SEVERITY note;
        STOP;
    END PROCESS;

END ARCHITECTURE tb;