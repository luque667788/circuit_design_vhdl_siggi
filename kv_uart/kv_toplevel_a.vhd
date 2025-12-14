-- ============================================================
-- TOP LEVEL UART ARCHITECTURE 
-- Student: Khush Vaghasiya (15142993)
-- Institution: Hochschule Ravensburg-Weingarten
-- Date: 07 December 2024
-- ============================================================

LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.ma_p.ALL;

ARCHITECTURE kv_toplevel_a OF kv_toplevel_e IS

  -- ========================================================================
  -- Component Declarations (from package or explicit here)
  -- ========================================================================
  
  COMPONENT kv_baudrate_e IS
    PORT (
      clk_i        : IN  std_logic;
      rst_n_i      : IN  std_logic;
      br_start_i   : IN  std_logic;
      reg_bit_i    : IN  std_logic;
      br_o         : OUT std_logic;
      br_2_o       : OUT std_logic;
      test_o       : OUT std_logic
    );
  END COMPONENT;

  COMPONENT kv_uart_rx_e IS
    PORT (
      clk_i          : IN  std_logic;
      rst_n_i        : IN  std_logic;
      br_i           : IN  std_logic;
      br_2_i         : IN  std_logic;
      rx_i           : IN  std_logic;
      ascii_o        : OUT std_logic_vector(7 DOWNTO 0);
      rx_ready_o     : OUT std_logic;
      start_br_cnt_o : OUT std_logic
    );
  END COMPONENT;

  COMPONENT kv_uart_tx_e IS
    PORT (
      clk_i          : IN  std_logic;
      rst_n_i        : IN  std_logic;
      br_i           : IN  std_logic;
      tx_data_i      : IN  std_logic_vector(7 DOWNTO 0);
      tx_valid_i     : IN  std_logic;
      tx_o           : OUT std_logic;
      tx_ready_o     : OUT std_logic;
      start_br_cnt_o : OUT std_logic
    );
  END COMPONENT;

  COMPONENT kv_register_e IS
    PORT (
      clk_i           : IN  std_logic;
      rst_n_i         : IN  std_logic;
      rx_data_i       : IN  std_logic_vector(7 DOWNTO 0);
      rx_ready_i      : IN  std_logic;
      tx_data_o       : OUT std_logic_vector(7 DOWNTO 0);
      tx_valid_o      : OUT std_logic;
      tx_ready_i      : IN  std_logic;
      register_o      : OUT std_logic_vector(7 DOWNTO 0)
    );
  END COMPONENT;

  -- ========================================================================
  -- Internal Signal Declarations (for interconnection)
  -- ========================================================================
  
  -- Baud Rate Generator Signals
  SIGNAL br_s                : std_logic;
  SIGNAL br_2_s              : std_logic;
  SIGNAL test_br_s           : std_logic;
  
  -- RX Signals
  SIGNAL rx_data_s           : std_logic_vector(7 DOWNTO 0);
  SIGNAL rx_ready_s          : std_logic;
  SIGNAL rx_start_br_cnt_s   : std_logic;
  
  -- TX Signals
  SIGNAL tx_data_s           : std_logic_vector(7 DOWNTO 0);
  SIGNAL tx_valid_s          : std_logic;
  SIGNAL tx_ready_s          : std_logic;
  SIGNAL tx_start_br_cnt_s   : std_logic;
  
  -- Baud Rate Start Arbitration
  SIGNAL br_start_s          : std_logic;
  
  -- Register Debug Signal
  SIGNAL register_contents_s : std_logic_vector(7 DOWNTO 0);

BEGIN

  -- ========================================================================
  --! COMPONENT INSTANTIATION 1: Baud Rate Generator
  -- ========================================================================
  baudrate_inst : kv_baudrate_e
    PORT MAP (
      clk_i        => clk_i,
      rst_n_i      => rst_n_i,
      br_start_i   => br_start_s,
      reg_bit_i    => reg_bit_i,
      br_o         => br_s,
      br_2_o       => br_2_s,
      test_o       => test_br_s
    );

  -- ========================================================================
  --! COMPONENT INSTANTIATION 2: UART Receiver
  -- ========================================================================
  uart_rx_inst : kv_uart_rx_e
    PORT MAP (
      clk_i          => clk_i,
      rst_n_i        => rst_n_i,
      br_i           => br_s,
      br_2_i         => br_2_s,
      rx_i           => rx_i,
      ascii_o        => rx_data_s,
      rx_ready_o     => rx_ready_s,
      start_br_cnt_o => rx_start_br_cnt_s
    );

  -- ========================================================================
  --! COMPONENT INSTANTIATION 3: Register + Control FSM
  -- ========================================================================
  register_inst : kv_register_e
    PORT MAP (
      clk_i           => clk_i,
      rst_n_i         => rst_n_i,
      rx_data_i       => rx_data_s,
      rx_ready_i      => rx_ready_s,
      tx_data_o       => tx_data_s,
      tx_valid_o      => tx_valid_s,
      tx_ready_i      => tx_ready_s,
      register_o      => register_contents_s
    );

  -- ========================================================================
  --! COMPONENT INSTANTIATION 4: UART Transmitter
  -- ========================================================================
  uart_tx_inst : kv_uart_tx_e
    PORT MAP (
      clk_i          => clk_i,
      rst_n_i        => rst_n_i,
      br_i           => br_s,
      tx_data_i      => tx_data_s,
      tx_valid_i     => tx_valid_s,
      tx_o           => tx_o,
      tx_ready_o     => tx_ready_s,
      start_br_cnt_o => tx_start_br_cnt_s
    );

  -- ========================================================================
  --! WIRING LOGIC (Pure Combinatorial Signal Routing)
  -- ========================================================================
  -- Baud Rate Counter Start: Either RX or TX can request
  br_start_s <= rx_start_br_cnt_s OR tx_start_br_cnt_s;

  -- ========================================================================
  --! OUTPUT ASSIGNMENTS (Debug/Test Signals)
  -- ========================================================================
  rx_data_o   <= rx_data_s;              -- Show what RX received
  rx_ready_o  <= rx_ready_s;             -- Show when RX has data
  tx_ready_o  <= tx_ready_s;             -- Show when TX is ready
  test_br_o   <= test_br_s;              -- Show baud rate clock
  test_br_2_o <= br_2_s;                 -- Show half-baud rate
  test_reg_o  <= register_contents_s;    -- Show register contents
  test_tx_data_o <= tx_data_s;           -- Show TX data
  test_tx_valid_o <= tx_valid_s;         -- Show TX valid signal

END kv_toplevel_a;
