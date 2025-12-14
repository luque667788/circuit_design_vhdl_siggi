LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.env.ALL;
USE work.project_pkg.ALL;

ENTITY integration_uart_core_tb IS
END ENTITY integration_uart_core_tb;

ARCHITECTURE tb OF integration_uart_core_tb IS
  CONSTANT clk_period_c : TIME := 10 ns;

  SIGNAL clk_i         : STD_LOGIC := '0';
  SIGNAL rst_n_i       : STD_LOGIC := '0';
  SIGNAL ascii_rx_i    : STD_LOGIC_VECTOR(reg_width_c - 1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL rx_ready_i    : STD_LOGIC := '0';
  SIGNAL reg_wr_addr_o : STD_LOGIC_VECTOR(reg_addr_width_c - 1 DOWNTO 0);
  SIGNAL reg_data_in_o : STD_LOGIC_VECTOR(reg_width_c - 1 DOWNTO 0);
  SIGNAL reg_wr_en_o   : STD_LOGIC;

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
  clk_p : PROCESS
  BEGIN
    clk_i <= '0';
    WAIT FOR clk_period_c / 2;
    clk_i <= '1';
    WAIT FOR clk_period_c / 2;
  END PROCESS clk_p;

  dut : ENTITY work.integration_uart_core_e
    PORT MAP(
      clk_i         => clk_i,
      rst_n_i       => rst_n_i,
      ascii_rx_i    => ascii_rx_i,
      rx_ready_i    => rx_ready_i,
      reg_wr_addr_o => reg_wr_addr_o,
      reg_data_in_o => reg_data_in_o,
      reg_wr_en_o   => reg_wr_en_o
    );

  stim_p : PROCESS
  BEGIN
    rst_n_i <= '0';
    WAIT FOR 5 * clk_period_c;
    rst_n_i <= '1';

    -- Wait for reset to propagate
    WAIT FOR 2 * clk_period_c;

    -- Send address command (prefix + address)
    push_byte(ascii_rx_i, rx_ready_i, prefix_cmd_c & "0010");
    WAIT FOR clk_period_c*5;

    -- Send data byte
    push_byte(ascii_rx_i, rx_ready_i, x"3C");

    ASSERT reg_wr_addr_o = "0010" REPORT "reg_wr_addr_o mismatch" SEVERITY error;
    ASSERT reg_data_in_o = x"3C" REPORT "reg_data_in_o mismatch" SEVERITY error;


    REPORT "integration_uart_core_tb completed" SEVERITY note;
    stop;
    WAIT;
  END PROCESS stim_p;
END ARCHITECTURE tb;
