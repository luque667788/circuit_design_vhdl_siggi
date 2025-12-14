-- ============================================================
-- REGISTER ENTITY (3-Process FSM per Design Guideline 4.2)
-- Student: Khush Vaghasiya (15142993)
-- Institution: Hochschule Ravensburg-Weingarten
-- Date: 07 December 2024
-- ============================================================


LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.ma_p.ALL;

ENTITY kv_register_e IS
  PORT (
    -- System Control Signals
    clk_i           : IN  std_logic;                      -- System clock (125 MHz)
    rst_n_i         : IN  std_logic;                      -- Asynchronous reset (active-low)
    
    -- RX Input Signals
    rx_data_i       : IN  std_logic_vector(7 DOWNTO 0);   -- RX data input
    rx_ready_i      : IN  std_logic;                      -- RX data ready signal
    
    -- TX Output Signals
    tx_data_o       : OUT std_logic_vector(7 DOWNTO 0);   -- TX data output
    tx_valid_o      : OUT std_logic;                      -- TX valid strobe
    tx_ready_i      : IN  std_logic;                      -- TX ready signal
    
    -- Debug/Test Signals
    register_o      : OUT std_logic_vector(7 DOWNTO 0)    -- Register contents for waveform
  );
END kv_register_e;

