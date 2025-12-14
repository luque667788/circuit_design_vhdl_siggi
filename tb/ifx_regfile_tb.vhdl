-- ###########################################################################
--  ifx_regfile_tb
-- ###########################################################################

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.env.ALL;
USE work.project_pkg.ALL;

ENTITY ifx_regfile_tb IS
END ENTITY ifx_regfile_tb;

ARCHITECTURE tb OF ifx_regfile_tb IS
    CONSTANT register_count_c : POSITIVE := 8;
    CONSTANT data_width_c : POSITIVE := 8;
    CONSTANT addr_width_c : POSITIVE := 3;
    CONSTANT clk_period_c : TIME := 8 ns;
    CONSTANT pat_a5_c : STD_LOGIC_VECTOR(data_width_c - 1 DOWNTO 0) := x"A5";

    SIGNAL clk_i : STD_LOGIC := '0';
    SIGNAL rst_n_i : STD_LOGIC := '0';
    SIGNAL wr_en_i : STD_LOGIC := '0';
    SIGNAL wr_addr_i : STD_LOGIC_VECTOR(addr_width_c - 1 DOWNTO 0) :=
    (OTHERS => '0');
    SIGNAL rd_addr_i : STD_LOGIC_VECTOR(addr_width_c - 1 DOWNTO 0) :=
    (OTHERS => '0');
    SIGNAL data_in : STD_LOGIC_VECTOR(data_width_c - 1 DOWNTO 0) :=
    (OTHERS => '0');
    SIGNAL data_out : STD_LOGIC_VECTOR(data_width_c - 1 DOWNTO 0);
    SIGNAL ready_o : STD_LOGIC := '0';
BEGIN
    clk_gen : PROCESS
    BEGIN
        clk_i <= '0';
        WAIT FOR clk_period_c / 2;
        clk_i <= '1';
        WAIT FOR clk_period_c / 2;
    END PROCESS clk_gen;

    dut : ENTITY work.ifx_regfile_e
        GENERIC MAP(
            count_g => register_count_c,
            width_g => data_width_c,
            addr_width_g => addr_width_c
        )
        PORT MAP(
            clk_i => clk_i,
            rst_n_i => rst_n_i,
            wr_en_i => wr_en_i,
            wr_addr_i => wr_addr_i,
            data_in => data_in,
            rd_addr_i => rd_addr_i,
            data_out => data_out,
            ready_o => ready_o
        );

    stimulus : PROCESS
    BEGIN
        rst_n_i <= '0';
        wr_en_i <= '0';
        wr_addr_i <= (OTHERS => '0');
        rd_addr_i <= (OTHERS => '0');
        data_in <= (OTHERS => '0');
        WAIT FOR 4 * clk_period_c;
        rst_n_i <= '1';

        wr_addr_i <= STD_LOGIC_VECTOR(to_unsigned(2, addr_width_c));
        data_in <= pat_a5_c;
        wr_en_i <= '1';
        WAIT UNTIL rising_edge(clk_i);
        wr_en_i <= '0';

        WAIT UNTIL ready_o = '0';
        WAIT UNTIL ready_o = '1';
        WAIT UNTIL rising_edge(clk_i);
        rd_addr_i <= STD_LOGIC_VECTOR(to_unsigned(2, addr_width_c));
        WAIT FOR clk_period_c;

        ASSERT data_out = pat_a5_c
        REPORT "Register 2 read-back mismatch"
            SEVERITY error;

        REPORT "ifx_regfile_tb completed successfully" SEVERITY note;
        stop;
        WAIT;
    END PROCESS stimulus;
END ARCHITECTURE tb;