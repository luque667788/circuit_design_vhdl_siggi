-- ###########################################################################
--  ifx_regfile_tb
-- ###########################################################################

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.env.ALL;
USE work.project_pkg.ALL;

ENTITY top_level_tb IS
END ENTITY top_level_tb;

ARCHITECTURE tb OF top_level_tb IS
    CONSTANT clk_period_c : TIME := 10 ns;

    SIGNAL clk_i       : STD_LOGIC := '0';
    SIGNAL rst_n_i     : STD_LOGIC := '0';
    SIGNAL ascii_rx_i  : STD_LOGIC_VECTOR(reg_width_c - 1 DOWNTO 0) :=
        (OTHERS => '0');
    SIGNAL rx_ready_i  : STD_LOGIC := '0';
    SIGNAL reg_data_o  : STD_LOGIC_VECTOR(reg_width_c - 1 DOWNTO 0);
    SIGNAL reg_ready_o : STD_LOGIC;
    SIGNAL reg_addr_i  : STD_LOGIC_VECTOR(reg_addr_width_c - 1 DOWNTO 0) :=
        (OTHERS => '0');

    PROCEDURE push_byte(
        SIGNAL ascii_rx : OUT STD_LOGIC_VECTOR(reg_width_c - 1 DOWNTO 0);
        SIGNAL rx_ready : OUT STD_LOGIC;
        CONSTANT value  : STD_LOGIC_VECTOR(reg_width_c - 1 DOWNTO 0)) IS
    BEGIN
        ascii_rx <= value;
        rx_ready <= '1';
        WAIT FOR clk_period_c;
        rx_ready <= '0';
        WAIT FOR clk_period_c;
    END PROCEDURE;
BEGIN
    clk_process : PROCESS
    BEGIN
        clk_i <= '0';
        WAIT FOR clk_period_c / 2;
        clk_i <= '1';
        WAIT FOR clk_period_c / 2;
    END PROCESS clk_process;

    dut : ENTITY work.top_level_e
        PORT MAP(
            clk_i       => clk_i,
            rst_n_i     => rst_n_i,
            ascii_rx_i  => ascii_rx_i,
            rx_ready_i  => rx_ready_i,
            reg_data_o  => reg_data_o,
            reg_ready_o => reg_ready_o,
            reg_addr_i  => reg_addr_i
        );

    stimulus : PROCESS
    BEGIN
        rst_n_i <= '0';
        WAIT FOR 5 * clk_period_c;
        rst_n_i <= '1';

        WAIT FOR 5 * clk_period_c;
        push_byte(ascii_rx_i, rx_ready_i, x"F2");
        WAIT FOR 8 * clk_period_c;
        push_byte(ascii_rx_i, rx_ready_i, x"3C");

        WAIT FOR 20 * clk_period_c;
        reg_addr_i <= "0010";
        WAIT FOR 5 * clk_period_c;
        ASSERT reg_data_o = x"3C"
            REPORT "Integration regfile readback mismatch"
            SEVERITY error;

        REPORT "top_level_tb completed" SEVERITY note;
        WAIT FOR 20 * clk_period_c;

        stop;
    END PROCESS stimulus;
END ARCHITECTURE tb;