-- ============================================================
-- TOP LEVEL UART TESTBENCH 
-- Student: Khush Vaghasiya (15142993)
-- Institution: Hochschule Ravensburg-Weingarten
-- Date: 07 December 2024
-- ============================================================

LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.ma_p.ALL;

ENTITY kv_toplevel_tb IS
END kv_toplevel_tb;

ARCHITECTURE kv_toplevel_tb_a OF kv_toplevel_tb IS

  -- ========================================================================
  -- Component Declaration (Top Level)
  -- ========================================================================
  COMPONENT kv_toplevel_e IS
    PORT (
      clk_i              : IN  std_logic;
      rst_n_i            : IN  std_logic;
      reg_bit_i          : IN  std_logic;
      rx_i               : IN  std_logic;
      rx_data_o          : OUT std_logic_vector(7 DOWNTO 0);
      rx_ready_o         : OUT std_logic;
      tx_o               : OUT std_logic;
      tx_ready_o         : OUT std_logic;
      test_br_o          : OUT std_logic;
      test_br_2_o        : OUT std_logic;
      test_reg_o         : OUT std_logic_vector(7 DOWNTO 0);
      test_tx_data_o     : OUT std_logic_vector(7 DOWNTO 0);   
      test_tx_valid_o    : OUT std_logic                       
    );
  END COMPONENT;

  -- ========================================================================
  -- Test Signal Declarations
  -- ========================================================================
  SIGNAL clk_s               : std_logic := '0';
  SIGNAL rst_n_s             : std_logic := '0';
  SIGNAL reg_bit_s           : std_logic := '0';  -- 9600 baud
  
  -- RX Interface
  SIGNAL rx_i_s              : std_logic := '1';  -- Default idle (high)
  SIGNAL rx_data_s           : std_logic_vector(7 DOWNTO 0);
  SIGNAL rx_ready_s          : std_logic;
  
  -- TX Interface
  SIGNAL tx_o_s              : std_logic;
  SIGNAL tx_ready_s          : std_logic;
  
  -- Debug/Test Signals
  SIGNAL test_br_s           : std_logic;
  SIGNAL test_br_2_s         : std_logic;
  SIGNAL test_reg_s          : std_logic_vector(7 DOWNTO 0);  -- REGISTER CONTENTS
  SIGNAL tx_data_s           : std_logic_vector(7 DOWNTO 0);
  SIGNAL tx_valid_s          : std_logic;


  
  -- ========== Timing Constants ==========
  CONSTANT clk_period_c      : time := 8 ns;           -- 125 MHz
  CONSTANT br_9600_cycles_c  : integer := 13021;       -- 125MHz / 9600
  CONSTANT br_9600_period_c  : time := br_9600_cycles_c * clk_period_c;

BEGIN

  -- Device Under Test (DUT) Instantiation
  DUT: kv_toplevel_e
    PORT MAP (
      clk_i       => clk_s,
      rst_n_i     => rst_n_s,
      reg_bit_i   => reg_bit_s,
      rx_i        => rx_i_s,
      rx_data_o   => rx_data_s,
      rx_ready_o  => rx_ready_s,
      tx_o        => tx_o_s,
      tx_ready_o  => tx_ready_s,
      test_br_o   => test_br_s,
      test_br_2_o => test_br_2_s,
      test_reg_o  => test_reg_s,
      test_tx_data_o => tx_data_s,     
      test_tx_valid_o => tx_valid_s   
    );

  -- ========================================================================
  --! PROCESS 1: Clock Generation (125 MHz = 8 ns period)
  -- ========================================================================
  clk_gen : PROCESS
  BEGIN
    LOOP
      clk_s <= '0';
      WAIT FOR clk_period_c / 2;
      clk_s <= '1';
      WAIT FOR clk_period_c / 2;
    END LOOP;
  END PROCESS clk_gen;

  -- ========================================================================
  --! PROCESS 2: Simulate UART RX Serial Input (3 frames)
  -- ========================================================================
  uart_rx_gen : PROCESS
    
    -- ===== Helper Procedure: Send UART Frame =====
    PROCEDURE send_uart_frame(data : std_logic_vector(7 DOWNTO 0)) IS
    BEGIN
      -- START BIT (0)
      rx_i_s <= '0';
      WAIT FOR br_9600_period_c;
      
      -- 8 DATA BITS (LSB first)
      FOR bit_idx IN 0 TO 7 LOOP
        rx_i_s <= data(bit_idx);
        WAIT FOR br_9600_period_c;
      END LOOP;
      
      -- STOP BIT (1)
      rx_i_s <= '1';
      WAIT FOR br_9600_period_c;
      
      -- Return to idle (high)
      rx_i_s <= '1';
    END PROCEDURE send_uart_frame;
  
  BEGIN
    -- ====================================================================
    -- PHASE 1: RESET SEQUENCE
    -- ====================================================================
    REPORT "===========================================" SEVERITY NOTE;
    REPORT "PHASE 1: System Reset" SEVERITY NOTE;
    REPORT "===========================================" SEVERITY NOTE;
    
    rst_n_s <= '0';
    rx_i_s  <= '1';  -- Keep RX line idle (high)
    WAIT FOR 200 ns;
    
    rst_n_s <= '1';
    WAIT FOR 500 ns;
    REPORT "Reset complete - system ready" SEVERITY NOTE;
    
    -- ====================================================================
    -- PHASE 2: TRANSMIT FIRST UART FRAME (0xA5)
    -- ====================================================================
    REPORT "" SEVERITY NOTE;
    REPORT "===========================================" SEVERITY NOTE;
    REPORT "PHASE 2: RX receives 0xA5" SEVERITY NOTE;
    REPORT "===========================================" SEVERITY NOTE;
    
    WAIT FOR 2 us;
    send_uart_frame(x"A5");
    
    REPORT "Frame complete: 0xA5 transmitted on rx_i" SEVERITY NOTE;
    REPORT "  In Vivado waveform:" SEVERITY NOTE;
    REPORT "    rx_data_o = 0xA5" SEVERITY NOTE;
    REPORT "    test_reg_o = 0xA5 (register stores it)" SEVERITY NOTE;
    
    WAIT FOR 3 ms;
    
    -- ====================================================================
    -- PHASE 3: TRANSMIT SECOND UART FRAME (0x55)
    -- ====================================================================
    REPORT "" SEVERITY NOTE;
    REPORT "===========================================" SEVERITY NOTE;
    REPORT "PHASE 3: RX receives 0x55" SEVERITY NOTE;
    REPORT "===========================================" SEVERITY NOTE;
    
    send_uart_frame(x"55");
    
    REPORT "Frame complete: 0x55 transmitted on rx_i" SEVERITY NOTE;
    REPORT "  In Vivado waveform:" SEVERITY NOTE;
    REPORT "    rx_data_o = 0x55" SEVERITY NOTE;
    REPORT "    test_reg_o = 0x55 (register updated)" SEVERITY NOTE;
    
    WAIT FOR 3 ms;
    
    -- ====================================================================
    -- PHASE 4: TRANSMIT THIRD UART FRAME (0xFF)
    -- ====================================================================
    REPORT "" SEVERITY NOTE;
    REPORT "===========================================" SEVERITY NOTE;
    REPORT "PHASE 4: RX receives 0xFF" SEVERITY NOTE;
    REPORT "===========================================" SEVERITY NOTE;
    
    send_uart_frame(x"FF");
    
    REPORT "Frame complete: 0xFF transmitted on rx_i" SEVERITY NOTE;
    REPORT "  In Vivado waveform:" SEVERITY NOTE;
    REPORT "    rx_data_o = 0xFF" SEVERITY NOTE;
    REPORT "    test_reg_o = 0xFF (register updated)" SEVERITY NOTE;
    
    WAIT FOR 3 ms;
    
    -- ====================================================================
    -- TEST COMPLETE
    -- ====================================================================
    REPORT "" SEVERITY NOTE;
    REPORT "===========================================" SEVERITY NOTE;
    REPORT "TEST COMPLETE!" SEVERITY NOTE;
    REPORT "===========================================" SEVERITY NOTE;
    REPORT "" SEVERITY NOTE;

    
    WAIT FOR 2 ms;
    
    REPORT "Simulation finished." SEVERITY NOTE;
    WAIT;
    
  END PROCESS uart_rx_gen;

END kv_toplevel_tb_a;

