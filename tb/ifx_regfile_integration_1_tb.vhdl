-- ###########################################################################
--  ifx_regfile_tb
-- ###########################################################################

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.env.ALL;

ENTITY ifx_regfile_integration_1_tb IS
END ENTITY ifx_regfile_integration_1_tb;

ARCHITECTURE tb OF ifx_regfile_integration_1_tb IS
    CONSTANT c_clk_period : TIME := 10 ns;

    SIGNAL clk_i : STD_LOGIC := '0';
    SIGNAL rst_i : STD_LOGIC := '0';
    SIGNAL ascii_rx_i : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rx_ready_i : STD_LOGIC := '0';
    SIGNAL reg_data_o : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL reg_ready_o : STD_LOGIC;
    SIGNAL reg_addr_i : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');

    PROCEDURE push_byte(
        SIGNAL ascii_rx : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL rx_ready : OUT STD_LOGIC;

        CONSTANT value : STD_LOGIC_VECTOR(7 DOWNTO 0)) IS
    BEGIN
        ascii_rx <= value;
        rx_ready <= '1';
        WAIT FOR c_clk_period;
        rx_ready <= '0';
        WAIT FOR c_clk_period;
    END PROCEDURE;
BEGIN
    -- clock generation
    clk_process : PROCESS
    BEGIN
        clk_i <= '0';
        WAIT FOR c_clk_period / 2;
        clk_i <= '1';
        WAIT FOR c_clk_period / 2;
    END PROCESS;

    -- device under test
    dut : ENTITY work.integration_uart_e
        PORT MAP(
            clk_i => clk_i,
            rst_i => rst_i,
            ascii_rx_i => ascii_rx_i,
            rx_ready_i => rx_ready_i,
            reg_data_o => reg_data_o,
            reg_ready_o => reg_ready_o,
            reg_addr_i => reg_addr_i
        );

    -- simple stimulus: send address nibble followed by data
    stimulus : PROCESS
    BEGIN
        rst_i <= '1';
        WAIT FOR 5 * c_clk_period;
        rst_i <= '0';

        WAIT FOR 5 * c_clk_period;
        push_byte(ascii_rx_i, rx_ready_i, x"F2"); -- indicates start + address nibble
        WAIT FOR 8 * c_clk_period;
        push_byte(ascii_rx_i, rx_ready_i, x"3C"); -- example data payload

        WAIT FOR 20 * c_clk_period;
        reg_addr_i <= "0010"; -- read back address 2
        WAIT FOR 5 * c_clk_period;
        ASSERT reg_data_o = x"3C"
        REPORT "Integration regfile readback mismatch"
            SEVERITY error;

        REPORT "ifx_regfile_integration_1_tb completed" SEVERITY note;
        WAIT FOR 20 * c_clk_period;

        stop;
    END PROCESS;
END ARCHITECTURE tb;