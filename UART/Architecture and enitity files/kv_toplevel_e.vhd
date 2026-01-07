-- ============================================================
-- TOP LEVEL UART ENTITY 
-- Student: Khush Vaghasiya (15142993)
-- Institution: Hochschule Ravensburg-Weingarten
-- Date: 14 December 2025
-- ============================================================

LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.ma_p.ALL;

ENTITY kv_toplevel_e IS
  PORT (
    -- ========== System Control Signals ==========
    clk_i              : IN  std_logic;                      -- System clock (125 MHz)
    rst_n_i            : IN  std_logic;                      -- Asynchronous reset (active-low)
    
    -- ========== Baud Rate Configuration ==========
    reg_bit_i          : IN  std_logic;                      -- Baud rate select (0=9600, 1=19200)
    
    -- ========== UART RX Interface ==========
    rx_i               : IN  std_logic;                      -- RX serial input
    rx_data_o          : OUT std_logic_vector(7 DOWNTO 0);   -- RX data output (debug)
    rx_ready_o         : OUT std_logic;                      -- RX ready flag (debug)
    
    -- ========== UART TX Interface ==========
    tx_o               : OUT std_logic;                      -- TX serial output
    tx_ready_o         : OUT std_logic;                      -- TX ready flag (debug)
    
    -- ========== Debug/Test Signals ==========
    test_br_o          : OUT std_logic;                      -- Baud rate pulse
    test_br_2_o        : OUT std_logic;                      -- Half-baud rate pulse
    test_reg_o         : OUT std_logic_vector(7 DOWNTO 0);   -- Register contents 
    test_tx_data_o     : OUT std_logic_vector(7 DOWNTO 0);   -- TX data output (debug)
    test_tx_valid_o    : OUT std_logic                       

  );
END kv_toplevel_e;

