-- ============================================================
-- REGISTER ARCHITECTURE (3-state Moore FSM)
-- Student: Khush Vaghasiya (15142993)
-- Institution: Hochschule Ravensburg-Weingarten
-- Date: 07 December 2024
-- ============================================================


LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.ma_p.ALL;

ARCHITECTURE kv_register_a OF kv_register_e IS

  -- ========================================================================
  -- FSM State Type Definition
  -- ========================================================================
  TYPE state_type IS (IDLE_ST, RX_WAIT_ST, RX_STORE_ST, TX_WAIT_ST, TX_SEND_ST);
  
  -- ========================================================================
  -- Internal Signal Declarations
  -- ========================================================================
  SIGNAL state_s         : state_type;  -- Current state
  SIGNAL next_state_s    : state_type;  -- Next state (combinatorial logic)
  SIGNAL register_s      : std_logic_vector(7 DOWNTO 0);  -- Data register

BEGIN

  -- ========================================================================
  --! PROCESS 1: Combinatorial Next-State Logic (Moore FSM)
  -- ========================================================================

  fsm_next_state : PROCESS (state_s, rx_ready_i, tx_ready_i)
  BEGIN
    CASE state_s IS
      
      -- ===== IDLE_ST: Waiting for RX data to arrive =====
      WHEN IDLE_ST =>
        IF (rx_ready_i = '1') THEN
          next_state_s <= RX_STORE_ST;  -- RX has data, store it immediately
        ELSE
          next_state_s <= RX_WAIT_ST;   -- Wait for RX data
        END IF;
      
      -- ===== RX_WAIT_ST: Waiting for RX to complete decoding =====
      WHEN RX_WAIT_ST =>
        IF (rx_ready_i = '1') THEN
          next_state_s <= RX_STORE_ST;  -- RX decoded, store data now
        ELSE
          next_state_s <= RX_WAIT_ST;   -- Still waiting for RX
        END IF;
      
      -- ===== RX_STORE_ST: RX data received, move to TX wait =====
      WHEN RX_STORE_ST =>
        next_state_s <= TX_WAIT_ST;     -- Data stored, now wait for TX ready
      
      -- ===== TX_WAIT_ST: Waiting for TX to be ready =====
      WHEN TX_WAIT_ST =>
        IF (tx_ready_i = '1') THEN
          next_state_s <= TX_SEND_ST;   -- TX ready, send data
        ELSE
          next_state_s <= TX_WAIT_ST;   -- TX not ready yet
        END IF;
      
      -- ===== TX_SEND_ST: TX ready, send register data, return to idle =====
      WHEN TX_SEND_ST =>
        next_state_s <= IDLE_ST;        -- TX has data, return to idle
      
      -- ===== Default: Should never reach here =====
      WHEN OTHERS =>
        next_state_s <= IDLE_ST;
    END CASE;
  END PROCESS fsm_next_state;


  -- ========================================================================
  --! PROCESS 2: Sequential State Register (Synchronous State Update)
  -- ========================================================================
  
  fsm_state_register : PROCESS (clk_i, rst_n_i)
  BEGIN
    IF (rst_n_i = '0') THEN
      -- Asynchronous reset (active-low)
      state_s <= IDLE_ST;
    ELSIF (rising_edge(clk_i)) THEN
      -- Synchronous state transition on rising clock edge
      state_s <= next_state_s;
    END IF;
  END PROCESS fsm_state_register;


  -- ========================================================================
  --! PROCESS 3: Sequential Output Logic and Register Updates
  -- ========================================================================

  fsm_output_logic : PROCESS (clk_i, rst_n_i)
  BEGIN
    IF (rst_n_i = '0') THEN
      -- Asynchronous reset all outputs and register
      register_s <= (others => '0');
      tx_data_o  <= (others => '0');
      tx_valid_o <= '0';
    
    ELSIF (rising_edge(clk_i)) THEN
      -- ===== DEFAULT: All outputs inactive (Moore machine) =====
      tx_valid_o <= '0';  -- Default: TX not valid
      
      -- ===== STATE-DEPENDENT OUTPUT LOGIC =====
      CASE state_s IS
        
        -- ----- IDLE_ST: Idle, nothing active -----
        WHEN IDLE_ST =>
          tx_valid_o <= '0';  -- TX not valid in idle
        
        -- ----- RX_WAIT_ST: Waiting for RX, nothing active -----
        WHEN RX_WAIT_ST =>
          tx_valid_o <= '0';  -- TX not valid while waiting for RX
        
        -- ----- RX_STORE_ST: Store RX data into register -----
        --  KEY ACTION: DATA FLOWS FROM RX TO REGISTER 
        WHEN RX_STORE_ST =>
          register_s <= rx_data_i;
          tx_valid_o <= '0';  -- TX not valid while storing RX
        
        -- ----- TX_WAIT_ST: Waiting for TX ready, nothing active -----
        WHEN TX_WAIT_ST =>
          tx_valid_o <= '0';  -- TX not valid while waiting
        
        -- ----- TX_SEND_ST: Send register data to TX -----
        -- KEY ACTION: DATA FLOWS FROM REGISTER TO TX
        WHEN TX_SEND_ST =>
          -- When TX is ready, feed register contents to TX output
          tx_data_o  <= register_s;  -- Register => TX data
          tx_valid_o <= '1';         -- Signal TX that data is valid
        
        -- ----- Default: Should never reach here -----
        WHEN OTHERS =>
          tx_valid_o <= '0';
      END CASE;
    END IF;
  END PROCESS fsm_output_logic;

  -- ========================================================================
  --! OUTPUT ASSIGNMENT
  -- ========================================================================
  -- Export register contents for waveform observation
  register_o <= register_s;

END kv_register_a;
