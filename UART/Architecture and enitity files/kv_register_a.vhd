-- ============================================================
-- FSM Control ARCHITECTURE - 3-STATE FSM
-- Student: Khush Vaghasiya (15142993)
-- Institution: Hochschule Ravensburg-Weingarten
-- Date: 14 December 2025
-- ============================================================

LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.ma_p.ALL;

ARCHITECTURE kv_register_a OF kv_register_e IS

  -- FSM State Type Definition (3 states)
  TYPE state_type IS (idle_st, wait_st, send_st);
  
  -- Internal Signal Declarations
  SIGNAL state_s : state_type;                         -- Current state
  SIGNAL next_state_s : state_type;                    -- Next state
  SIGNAL register_s : std_logic_vector(7 DOWNTO 0);    -- Data register

BEGIN

-- ============================================================
-- PROCESS 1: Combinatorial Next-State Logic (Moore FSM)
-- ============================================================
  
  fsm_next_state : PROCESS (state_s, rx_ready_i, tx_ready_i)
  BEGIN
    next_state_s <= state_s;  -- Default: stay in current state
    
    CASE state_s IS
      
      -- IDLE STATE: Waiting for RX data to arrive
      WHEN idle_st =>
        IF rx_ready_i = '1' THEN
          next_state_s <= send_st;  -- RX has data, go send it
        ELSE
          next_state_s <= wait_st;  -- Wait for RX
        END IF;
      
      -- WAIT STATE: Waiting for RX to complete decoding
      WHEN wait_st =>
        IF rx_ready_i = '1' THEN
          next_state_s <= send_st;  -- RX ready now, go send!
        ELSE
          next_state_s <= wait_st;  -- Keep waiting for RX
        END IF;
      
      -- SEND STATE: Transmitting data via TX
      WHEN send_st =>
        next_state_s <= idle_st;    -- Done, return to idle
    
    END CASE;
  END PROCESS fsm_next_state;

  -- ============================================================
  -- PROCESS 2: Sequential State Register (Synchronous State Update)
  -- ============================================================
  
  fsm_state_register : PROCESS (clk_i, rst_n_i)
  BEGIN
    IF rst_n_i = '0' THEN
      -- Asynchronous reset active-low
      state_s <= idle_st;
    ELSIF rising_edge(clk_i) THEN
      -- Synchronous state transition on rising clock edge
      state_s <= next_state_s;
    END IF;
  END PROCESS fsm_state_register;

  -- ============================================================
  -- PROCESS 3: Sequential Output Logic and Register Updates (Moore Machine)
  -- ============================================================
  
  fsm_output_logic : PROCESS (clk_i, rst_n_i)
  BEGIN
    IF rst_n_i = '0' THEN
      -- Asynchronous reset all outputs and register to default values
      register_s <= (others => '0');
      tx_data_o <= (others => '0');
      tx_valid_o <= '0';
    
    ELSIF rising_edge(clk_i) THEN
      -- DEFAULT: All outputs inactive (Moore machine)
      tx_valid_o <= '0';
      
      -- STATE-DEPENDENT OUTPUT LOGIC
      CASE state_s IS
        
        -- ─────────────────────────────────────────────────────────────
        WHEN idle_st =>
          -- IDLE STATE: Nothing active, just waiting
          tx_valid_o <= '0';
        
        -- ─────────────────────────────────────────────────────────────
        WHEN wait_st =>
          -- WAIT STATE: Store RX data when it arrives
          -- KEY ACTION: Data flows from RX to Register
          IF rx_ready_i = '1' THEN
            register_s <= rx_data_i;  -- STORE RX DATA
            tx_valid_o <= '0';
          ELSE
            tx_valid_o <= '0';
          END IF;
        
        -- ─────────────────────────────────────────────────────────────
        WHEN send_st =>
          -- SEND STATE: Send register data to TX
          -- KEY ACTION: Data flows from Register to TX
          IF tx_ready_i = '1' THEN
            tx_data_o <= register_s;  -- SEND REGISTER TO TX
            tx_valid_o <= '1';        -- VALID STROBE PULSE!
          ELSE
            tx_valid_o <= '0';
          END IF;
        
        -- ─────────────────────────────────────────────────────────────
        WHEN OTHERS =>
          -- Default: Should never reach here
          tx_valid_o <= '0';
      
      END CASE;
    
    END IF;
  END PROCESS fsm_output_logic;

  -- ============================================================
  -- OUTPUT ASSIGNMENTS
  -- ============================================================
  
  -- Export register contents for waveform observation
  register_o <= register_s;

END kv_register_a;

