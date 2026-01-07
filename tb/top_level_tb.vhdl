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
    SIGNAL reg_outputs_s : reg_array_t(0 TO reg_count_c - 1);

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
            reg_addr_i  => reg_addr_i,
            reg0_o => reg_outputs_s(0),
            reg1_o => reg_outputs_s(1),
            reg2_o => reg_outputs_s(2),
            reg3_o => reg_outputs_s(3),
            reg4_o => reg_outputs_s(4),
            reg5_o => reg_outputs_s(5),
            reg6_o => reg_outputs_s(6),
            reg7_o => reg_outputs_s(7),
            reg8_o => reg_outputs_s(8),
            reg9_o => reg_outputs_s(9),
            reg10_o => reg_outputs_s(10),
            reg11_o => reg_outputs_s(11),
            reg12_o => reg_outputs_s(12),
            reg13_o => reg_outputs_s(13),
            reg14_o => reg_outputs_s(14),
            reg15_o => reg_outputs_s(15),
            reg16_o => reg_outputs_s(16),
            reg17_o => reg_outputs_s(17),
            reg18_o => reg_outputs_s(18),
            reg19_o => reg_outputs_s(19),
            reg20_o => reg_outputs_s(20),
            reg21_o => reg_outputs_s(21),
            reg22_o => reg_outputs_s(22),
            reg23_o => reg_outputs_s(23),
            reg24_o => reg_outputs_s(24),
            reg25_o => reg_outputs_s(25),
            reg26_o => reg_outputs_s(26),
            reg27_o => reg_outputs_s(27),
            reg28_o => reg_outputs_s(28),
            reg29_o => reg_outputs_s(29),
            reg30_o => reg_outputs_s(30),
            reg31_o => reg_outputs_s(31)
        );

    stimulus : PROCESS
    BEGIN
        rst_n_i <= '0';
        WAIT FOR 5 * clk_period_c;
        rst_n_i <= '1';

        WAIT FOR 5 * clk_period_c;
        push_byte(
            ascii_rx_i,
            rx_ready_i,
            prefix_cmd_c & STD_LOGIC_VECTOR(to_unsigned(2, reg_addr_width_c))
        );
        WAIT FOR 8 * clk_period_c;
        push_byte(ascii_rx_i, rx_ready_i, x"3C");

        WAIT FOR 20 * clk_period_c;
        reg_addr_i <= STD_LOGIC_VECTOR(to_unsigned(2, reg_addr_width_c));
        WAIT FOR 5 * clk_period_c;
        ASSERT reg_data_o = x"3C"
            REPORT "Integration regfile readback mismatch"
            SEVERITY error;

        ASSERT reg_outputs_s(2) = x"3C"
            REPORT "Top-level exported register output mismatch for register 2"
            SEVERITY error;

        REPORT "top_level_tb completed" SEVERITY note;
        WAIT FOR 20 * clk_period_c;

        stop;
    END PROCESS stimulus;
END ARCHITECTURE tb;