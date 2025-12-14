-- ============================================================
-- UART Receiver Testbench 
-- Student: Khush Vaghasiya (15142993)
-- Tests UART TX module with multiple test cases
-- ============================================================

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY kv_uart_rx_tb IS
END kv_uart_rx_tb;

ARCHITECTURE tb OF kv_uart_rx_tb IS

  -- Signals
  SIGNAL clk_i           : std_logic := '0';
  SIGNAL rst_n_i         : std_logic := '0';
  SIGNAL br_i            : std_logic := '0';
  SIGNAL br_2_i          : std_logic := '0';
  SIGNAL rx_i            : std_logic := '1';
  SIGNAL ascii_o         : std_logic_vector(7 DOWNTO 0);
  SIGNAL rx_ready_o      : std_logic;
  SIGNAL start_br_cnt_o  : std_logic;

  -- Timing constants
  CONSTANT clk_period   : time := 8 ns;       -- 125 MHz
  CONSTANT baud_period  : time := 104168 ns;  -- 9600 baud
  
  -- ========================================================================
  -- Hex Conversion Function
  -- ========================================================================
  FUNCTION to_hex(vec : std_logic_vector(7 DOWNTO 0)) RETURN string IS
    CONSTANT hex : string := "0123456789ABCDEF";
    VARIABLE u : integer;
    VARIABLE l : integer;
  BEGIN
    u := to_integer(unsigned(vec(7 DOWNTO 4)));
    l := to_integer(unsigned(vec(3 DOWNTO 0)));
    RETURN hex(u+1) & hex(l+1);
  END FUNCTION;

BEGIN

  -- Device Under Test (DUT) Instantiation
  DUT: ENTITY work.kv_uart_rx_e
    PORT MAP (
      clk_i          => clk_i,
      rst_n_i        => rst_n_i,
      br_i           => br_i,
      br_2_i         => br_2_i,
      rx_i           => rx_i,
      ascii_o        => ascii_o,
      rx_ready_o     => rx_ready_o,
      start_br_cnt_o => start_br_cnt_o
    );

  -- Clock Generation: 125 MHz
  clk_proc: PROCESS
  BEGIN
    WHILE true LOOP
      clk_i <= '0'; WAIT FOR clk_period/2;
      clk_i <= '1'; WAIT FOR clk_period/2;
    END LOOP;
  END PROCESS;

  -- Baud Rate Signal Generation
  baud_proc: PROCESS
  BEGIN
    WHILE true LOOP
      -- START of bit period: br_i pulse
      br_i   <= '1'; 
      br_2_i <= '0'; 
      WAIT FOR clk_period;
      
      -- Wait until middle
      br_i   <= '0'; 
      br_2_i <= '0'; 
      WAIT FOR (baud_period/2) - clk_period;
      
      -- MIDDLE of bit period: br_2_i pulse (sampling point)
      br_i   <= '0'; 
      br_2_i <= '1'; 
      WAIT FOR clk_period;
      
      -- Wait until end
      br_i   <= '0'; 
      br_2_i <= '0'; 
      WAIT FOR (baud_period/2) - clk_period;
    END LOOP;
  END PROCESS;

  -- Stimulus Process
  stim_proc: PROCESS
  BEGIN
    -- Reset
    rst_n_i <= '0'; WAIT FOR 100 ns;
    rst_n_i <= '1'; WAIT FOR 200 ns;

    REPORT "=== UART RX Testbench Started ===" SEVERITY note;

    -- Send 'A' (0x41)
    REPORT "Sending: 'A' (0x41)" SEVERITY note;
    rx_i <= '0'; WAIT FOR baud_period;  -- Start bit
    rx_i <= '1'; WAIT FOR baud_period;  -- bit 0
    rx_i <= '0'; WAIT FOR baud_period;  -- bit 1
    rx_i <= '0'; WAIT FOR baud_period;  -- bit 2
    rx_i <= '0'; WAIT FOR baud_period;  -- bit 3
    rx_i <= '0'; WAIT FOR baud_period;  -- bit 4
    rx_i <= '0'; WAIT FOR baud_period;  -- bit 5
    rx_i <= '1'; WAIT FOR baud_period;  -- bit 6
    rx_i <= '0'; WAIT FOR baud_period;  -- bit 7
    rx_i <= '1'; WAIT FOR baud_period;  -- Stop bit
    WAIT FOR baud_period * 2;
    REPORT "Received: 0x" & to_hex(ascii_o) SEVERITY note;


    -- Send 'B' (0x42)
    REPORT "Sending: 'B' (0x42)" SEVERITY note;
    rx_i <= '0'; WAIT FOR baud_period;  -- Start bit
    rx_i <= '0'; WAIT FOR baud_period;  -- bit 0
    rx_i <= '1'; WAIT FOR baud_period;  -- bit 1
    rx_i <= '0'; WAIT FOR baud_period;  -- bit 2
    rx_i <= '0'; WAIT FOR baud_period;  -- bit 3
    rx_i <= '0'; WAIT FOR baud_period;  -- bit 4
    rx_i <= '0'; WAIT FOR baud_period;  -- bit 5
    rx_i <= '1'; WAIT FOR baud_period;  -- bit 6
    rx_i <= '0'; WAIT FOR baud_period;  -- bit 7
    rx_i <= '1'; WAIT FOR baud_period;  -- Stop bit
    WAIT FOR baud_period * 2;
    REPORT "Received: 0x" & to_hex(ascii_o) SEVERITY note;

    -- Send 'C' (0x43)
    REPORT "Sending: 'C' (0x43)" SEVERITY note;
    rx_i <= '0'; WAIT FOR baud_period;  -- Start bit
    rx_i <= '1'; WAIT FOR baud_period;  -- bit 0
    rx_i <= '1'; WAIT FOR baud_period;  -- bit 1
    rx_i <= '0'; WAIT FOR baud_period;  -- bit 2
    rx_i <= '0'; WAIT FOR baud_period;  -- bit 3
    rx_i <= '0'; WAIT FOR baud_period;  -- bit 4
    rx_i <= '0'; WAIT FOR baud_period;  -- bit 5
    rx_i <= '1'; WAIT FOR baud_period;  -- bit 6
    rx_i <= '0'; WAIT FOR baud_period;  -- bit 7
    rx_i <= '1'; WAIT FOR baud_period;  -- Stop bit
    WAIT FOR baud_period * 2;
    REPORT "Received: 0x" & to_hex(ascii_o) SEVERITY note;


    WAIT FOR baud_period * 5;
    REPORT "=== All tests completed ===" SEVERITY note;
    WAIT;
  END PROCESS;

END tb;
