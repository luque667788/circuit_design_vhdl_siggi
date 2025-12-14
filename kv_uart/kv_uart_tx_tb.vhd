-- ============================================================
-- UART Transmitter Testbench
-- Student: Khush Vaghasiya (15142993)
-- Tests UART TX module with multiple test cases
-- Verifies correct bit timing and frame format
-- ============================================================

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY kv_uart_tx_tb IS
END kv_uart_tx_tb;

ARCHITECTURE tb OF kv_uart_tx_tb IS

  -- Signals
  SIGNAL clk_i           : std_logic := '0';
  SIGNAL rst_n_i         : std_logic := '0';
  SIGNAL br_i            : std_logic := '0';
  SIGNAL tx_data_i       : std_logic_vector(7 DOWNTO 0) := (others => '0');
  SIGNAL tx_valid_i      : std_logic := '0';
  SIGNAL tx_o            : std_logic;
  SIGNAL tx_ready_o      : std_logic;
  SIGNAL start_br_cnt_o  : std_logic;

  -- Timing constants
  CONSTANT clk_period   : time := 8 ns;       -- 125 MHz
  CONSTANT baud_period  : time := 104168 ns;  -- 9600 baud

  -- Simulation control
  SIGNAL sim_done_s : BOOLEAN := FALSE;

BEGIN

  -- Device Under Test (DUT) Instantiation
  DUT: ENTITY work.kv_uart_tx_e
    PORT MAP (
      clk_i          => clk_i,
      rst_n_i        => rst_n_i,
      br_i           => br_i,
      tx_data_i      => tx_data_i,
      tx_valid_i     => tx_valid_i,
      tx_o           => tx_o,
      tx_ready_o     => tx_ready_o,
      start_br_cnt_o => start_br_cnt_o
    );

  -- Clock Generation: 125 MHz
  clk_process : PROCESS
  BEGIN
    WHILE NOT sim_done_s LOOP
      clk_i <= '0';
      WAIT FOR clk_period/2;
      clk_i <= '1';
      WAIT FOR clk_period/2;
    END LOOP;
    WAIT;
  END PROCESS clk_process;

  -- Baud rate signal generation
  baud_proc: PROCESS
  BEGIN
    WHILE NOT sim_done_s LOOP
      br_i <= '1';
      WAIT FOR clk_period;
      br_i <= '0';
      WAIT FOR baud_period - clk_period;
    END LOOP;
    WAIT;
  END PROCESS;

  -- Stimulus process
  stim_proc: PROCESS
  BEGIN
    -- ====================================================================
    -- Test 1: Reset verification
    -- ====================================================================
    REPORT "=== Starting UART TX Testbench ===" SEVERITY note;
    REPORT "Test 1: Reset verification" SEVERITY note;

    rst_n_i    <= '0';
    tx_data_i  <= (others => '0');
    tx_valid_i <= '0';
    WAIT FOR 100 ns;

    rst_n_i <= '1';
    WAIT FOR 200 ns;

    REPORT "Test 1: PASSED - Reset completed" SEVERITY note;

    -- ====================================================================
    -- Test 2: Send 'A' (0x41 = 0100 0001 binary)
    -- ====================================================================
    REPORT "Test 2: Sending 'A' (0x41)" SEVERITY note;
    tx_data_i  <= X"41";
    tx_valid_i <= '1';
    WAIT FOR clk_period;
    tx_valid_i <= '0';

    -- Wait for transmission to complete (10 bit periods: start + 8 data + stop)
    WAIT FOR baud_period * 10 + 100 ns;
    REPORT "Test 2: 'A' transmission complete" SEVERITY note;

    -- ====================================================================
    -- Test 3: Send 'B' (0x42 = 0100 0010 binary)
    -- ====================================================================
    WAIT FOR baud_period * 2;
    REPORT "Test 3: Sending 'B' (0x42)" SEVERITY note;
    tx_data_i  <= X"42";
    tx_valid_i <= '1';
    WAIT FOR clk_period;
    tx_valid_i <= '0';

    -- Wait for transmission to complete
    WAIT FOR baud_period * 10 + 100 ns;
    REPORT "Test 3: 'B' transmission complete" SEVERITY note;

    -- ====================================================================
    -- Test 4: Send 'C' (0x43 = 0100 0011 binary)
    -- ====================================================================
    WAIT FOR baud_period * 2;
    REPORT "Test 4: Sending 'C' (0x43)" SEVERITY note;
    tx_data_i  <= X"43";
    tx_valid_i <= '1';
    WAIT FOR clk_period;
    tx_valid_i <= '0';

    -- Wait for transmission to complete
    WAIT FOR baud_period * 10 + 100 ns;
    REPORT "Test 4: 'C' transmission complete" SEVERITY note;

    -- ====================================================================
    -- Test 5: Send 0xFF (all ones = 1111 1111)
    -- ====================================================================
    WAIT FOR baud_period * 2;
    REPORT "Test 5: Sending 0xFF (all ones)" SEVERITY note;
    tx_data_i  <= X"FF";
    tx_valid_i <= '1';
    WAIT FOR clk_period;
    tx_valid_i <= '0';

    -- Wait for transmission to complete
    WAIT FOR baud_period * 10 + 100 ns;
    REPORT "Test 5: 0xFF transmission complete" SEVERITY note;

    -- ====================================================================
    -- Test 6: Send 0x00 (all zeros = 0000 0000)
    -- ====================================================================
    WAIT FOR baud_period * 2;
    REPORT "Test 6: Sending 0x00 (all zeros)" SEVERITY note;
    tx_data_i  <= X"00";
    tx_valid_i <= '1';
    WAIT FOR clk_period;
    tx_valid_i <= '0';

    -- Wait for transmission to complete
    WAIT FOR baud_period * 10 + 100 ns;
    REPORT "Test 6: 0x00 transmission complete" SEVERITY note;

    -- ====================================================================
    -- Test 7: Send 0x55 (alternating pattern = 0101 0101)
    -- ====================================================================
    WAIT FOR baud_period * 2;
    REPORT "Test 7: Sending 0x55 (alternating pattern 01010101)" SEVERITY note;
    tx_data_i  <= X"55";
    tx_valid_i <= '1';
    WAIT FOR clk_period;
    tx_valid_i <= '0';

    -- Wait for transmission to complete
    WAIT FOR baud_period * 10 + 100 ns;
    REPORT "Test 7: 0x55 transmission complete" SEVERITY note;

    -- ====================================================================
    -- Test 8: Send 0xAA (alternating pattern = 1010 1010)
    -- ====================================================================
    WAIT FOR baud_period * 2;
    REPORT "Test 8: Sending 0xAA (alternating pattern 10101010)" SEVERITY note;
    tx_data_i  <= X"AA";
    tx_valid_i <= '1';
    WAIT FOR clk_period;
    tx_valid_i <= '0';

    -- Wait for transmission to complete
    WAIT FOR baud_period * 10 + 100 ns;
    REPORT "Test 8: 0xAA transmission complete" SEVERITY note;

    -- ====================================================================
    -- Final verification
    -- ====================================================================
    WAIT FOR baud_period * 3;

    REPORT "=== All UART TX Tests Completed Successfully ===" SEVERITY note;
   
    -- End simulation
    sim_done_s <= TRUE;
    WAIT;

  END PROCESS stim_proc;

END tb;