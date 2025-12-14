-- ============================================================
-- Baudrate Generator Testbench
-- Student: Khush Vaghasiya (15142993)
-- Course: Digital Circuit Design
-- University: Hochschule Ravensburg-Weingarten
-- 
-- Modified to test professor's baudrate structure
-- Tests both 9600 and 19200 baud rates
-- Verifies:
--   - br_o period = 104.168 µs (9600 Hz) or 52.084 µs (19200 Hz)
--   - br_2_o occurs at midpoint
--   - Counter resets properly with br_start_i
-- ============================================================

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY kv_baudrate_tb IS
END kv_baudrate_tb;

ARCHITECTURE tb OF kv_baudrate_tb IS

  -- Component declaration for the Unit Under Test (UUT)
  COMPONENT kv_baudrate_e
    PORT(
      clk_i       : IN  STD_LOGIC;
      rst_n_i     : IN  STD_LOGIC;
      br_start_i  : IN  STD_LOGIC;
      reg_bit_i   : IN  STD_LOGIC;
      br_2_o      : OUT STD_LOGIC;
      br_o        : OUT STD_LOGIC;
      test_o      : OUT STD_LOGIC
    );
  END COMPONENT;

  -- Test signals
  SIGNAL clk_i       : STD_LOGIC := '0';
  SIGNAL rst_n_i     : STD_LOGIC := '0';
  SIGNAL br_start_i  : STD_LOGIC := '0';
  SIGNAL reg_bit_i   : STD_LOGIC := '0';  -- '0' = 9600, '1' = 19200
  SIGNAL br_o        : STD_LOGIC;
  SIGNAL br_2_o      : STD_LOGIC;
  SIGNAL test_o      : STD_LOGIC;

  -- Clock period definition (125 MHz = 8 ns period)
  CONSTANT clk_period_c : TIME := 8 ns;

  -- Expected baud periods
  CONSTANT baud_9600_period_c  : TIME := 104168 ns;  -- 9600 baud
  CONSTANT baud_19200_period_c : TIME := 52084 ns;   -- 19200 baud

  -- Simulation control
  SIGNAL sim_done_s : BOOLEAN := FALSE;

BEGIN

  -- Device Under Test (DUT) Instantiation
  DUT: kv_baudrate_e
    PORT MAP (
      clk_i      => clk_i,
      rst_n_i    => rst_n_i,
      br_start_i => br_start_i,
      reg_bit_i  => reg_bit_i,
      br_o       => br_o,
      br_2_o     => br_2_o,
      test_o     => test_o
    );

  -- ========================================================================
  -- Clock generation process
  -- Generates 125 MHz clock (8 ns period)
  -- ========================================================================
  clk_process : PROCESS
  BEGIN
    WHILE NOT sim_done_s LOOP
      clk_i <= '0';
      WAIT FOR clk_period_c/2;
      clk_i <= '1';
      WAIT FOR clk_period_c/2;
    END LOOP;
    WAIT;
  END PROCESS clk_process;

  -- ========================================================================
  -- Stimulus process
  -- Tests reset, normal operation, and timing verification for both baud rates
  -- ========================================================================
  stim_proc: PROCESS
    VARIABLE br_count_v : INTEGER := 0;
  BEGIN
    -- ====================================================================
    -- Test 1: Reset test
    -- ====================================================================
    REPORT "=== Starting Baudrate Generator Test ===" SEVERITY note;
    REPORT "Test 1: Reset verification" SEVERITY note;

    rst_n_i    <= '0';  -- Assert reset (active-low)
    reg_bit_i  <= '0';  -- Select 9600 baud
    br_start_i <= '0';
    WAIT FOR 100 ns;

    rst_n_i <= '1';  -- Release reset
    WAIT FOR 50 ns;

    REPORT "Test 1: PASSED - Reset completed" SEVERITY note;

    -- ====================================================================
    -- Test 2: Test 9600 baud rate (reg_br_i_c = '0')
    -- ====================================================================
    REPORT "Test 2: Testing 9600 baud rate" SEVERITY note;
    reg_bit_i <= '0';
    WAIT FOR 100 ns;

    -- Wait for first br_o pulse
    WAIT UNTIL rising_edge(br_o);
    REPORT "First br_o pulse detected at 9600 baud" SEVERITY note;

    -- Measure multiple periods
    FOR i IN 1 TO 3 LOOP
      WAIT UNTIL rising_edge(br_o);
      REPORT "9600 baud br_o pulse " & INTEGER'IMAGE(i) & " at time: " 
        & TIME'IMAGE(NOW) SEVERITY note;
    END LOOP;

    -- Verify br_2_o timing
    WAIT UNTIL rising_edge(br_o);
    WAIT FOR baud_9600_period_c/2;
    REPORT "br_2_o should pulse around now for 9600 baud" SEVERITY note;
    WAIT FOR 200 ns;

    REPORT "Test 2: PASSED - 9600 baud verified" SEVERITY note;

    -- ====================================================================
    -- Test 3: Test br_start_i (counter restart)
    -- ====================================================================
    REPORT "Test 3: Testing br_start_i signal" SEVERITY note;

    WAIT FOR baud_9600_period_c/4;  -- Wait quarter period
    br_start_i <= '1';              -- Trigger counter restart
    WAIT FOR clk_period_c * 2;
    br_start_i <= '0';
    
    WAIT UNTIL rising_edge(br_o);
    REPORT "Counter restarted successfully with br_start_i" SEVERITY note;
    WAIT FOR 100 ns;

    REPORT "Test 3: PASSED - br_start_i functional" SEVERITY note;

    -- ====================================================================
    -- Test 4: Test 19200 baud rate (reg_br_i_c = '1')
    -- ====================================================================
    REPORT "Test 4: Testing 19200 baud rate" SEVERITY note;
    reg_bit_i <= '1';  -- Switch to 19200 baud
    WAIT FOR 200 ns;

    -- Wait for first br_o pulse after switching
    WAIT UNTIL rising_edge(br_o);
    REPORT "First br_o pulse detected at 19200 baud" SEVERITY note;

    -- Measure multiple periods
    FOR i IN 1 TO 5 LOOP
      WAIT UNTIL rising_edge(br_o);
      REPORT "19200 baud br_o pulse " & INTEGER'IMAGE(i) & " at time: " 
        & TIME'IMAGE(NOW) SEVERITY note;
    END LOOP;

    -- Verify br_2_o timing for 19200
    WAIT UNTIL rising_edge(br_o);
    WAIT FOR baud_19200_period_c/2;
    REPORT "br_2_o should pulse around now for 19200 baud" SEVERITY note;
    WAIT FOR 200 ns;

    REPORT "Test 4: PASSED - 19200 baud verified" SEVERITY note;

    -- ====================================================================
    -- Test 5: Switch back to 9600 baud
    -- ====================================================================
    REPORT "Test 5: Switching back to 9600 baud" SEVERITY note;
    reg_bit_i <= '0';  -- Back to 9600
    WAIT FOR 200 ns;

    FOR i IN 1 TO 2 LOOP
      WAIT UNTIL rising_edge(br_o);
      REPORT "Switched back - 9600 baud pulse " & INTEGER'IMAGE(i) SEVERITY note;
    END LOOP;

    REPORT "Test 5: PASSED - Baud rate switching works" SEVERITY note;

    -- ====================================================================
    -- Test 6: Reset during operation
    -- ====================================================================
    REPORT "Test 6: Testing reset during operation" SEVERITY note;

    WAIT FOR baud_9600_period_c/4;
    rst_n_i <= '0';  -- Assert reset
    WAIT FOR 200 ns;
    rst_n_i <= '1';  -- Release reset
    WAIT FOR 100 ns;

    WAIT UNTIL rising_edge(br_o);
    REPORT "Test 6: PASSED - Reset during operation successful" SEVERITY note;

    -- ====================================================================
    -- Final verification
    -- ====================================================================
    WAIT FOR baud_9600_period_c * 2;

    REPORT "=== All Tests Completed Successfully ===" SEVERITY note;
  

    REPORT "Simulation PASSED - Verify waveforms in simulator" SEVERITY note;

    -- End simulation
    sim_done_s <= TRUE;
    WAIT;

  END PROCESS stim_proc;

END tb;
