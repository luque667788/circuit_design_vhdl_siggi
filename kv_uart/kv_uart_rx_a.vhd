-- ============================================================
-- UART Receiver Architecture 
-- Student: Khush Vaghasiya (15142993)
-- Implementation: 3-State FSM with Registered Outputs
-- Compliant with Prof. Dr.-Ing. A. Siggelkow Design Guideline
-- ============================================================

LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.ma_p.ALL;

ARCHITECTURE kv_uart_rx_a OF kv_uart_rx_e IS

  -- -------------------------------------------------------
  -- Type definitions
  -- -------------------------------------------------------
  TYPE state_type_t IS (reset_state_st, idle_state_st,
                        startbrcnt_state_st,
                        startbit_state_st, wait_state_st,
                        bit0_state_st, bit1_state_st,
                        bit2_state_st, bit3_state_st,
                        bit4_state_st, bit5_state_st,
                        bit6_state_st, bit7_state_st,
                        stopbit_state_st);

  -- -------------------------------------------------------
  -- Signal declarations
  -- -------------------------------------------------------
  SIGNAL state_s, nextstate_s  : state_type_t;

  -- Edge detection signals for rx_i
  SIGNAL delay_rx_s            : std_logic_vector(1 DOWNTO 0);
  SIGNAL fall_edge_s            : std_logic;

  -- Edge detection signals for finish
  SIGNAL finish_s              : std_logic;
  SIGNAL rise_edgefin_s        : std_logic;
  SIGNAL fall_edgefin_s        : std_logic;
  SIGNAL delay_fin_s           : std_logic_vector(1 DOWNTO 0);

  -- Data capture signals
  SIGNAL ascii_sx              : std_logic_vector(7 DOWNTO 0);
  SIGNAL oscil_sx              : std_logic_vector(7 DOWNTO 0);

  -- ========================================================================
  -- Output synchronization signals
  -- ========================================================================
  SIGNAL rx_ready_s_reg        : std_logic;
  SIGNAL ascii_s_reg           : std_logic_vector(7 DOWNTO 0);
  SIGNAL start_cnt_s_reg       : std_logic;

BEGIN

  -- ========================================================================
  --! Falling edge detection on rx_i (Combinatorial)
  -- ========================================================================
  fall_edge_proc : PROCESS(clk_i, rst_n_i)
  BEGIN
    IF (rst_n_i = '0') THEN
      delay_rx_s <= (others => '0');
    ELSIF (clk_i'event AND clk_i = '1') THEN
      delay_rx_s(1) <= delay_rx_s(0);
      delay_rx_s(0) <= rx_i;
    END IF;
  END PROCESS;

  fall_edge_s <= (not delay_rx_s(0)) and delay_rx_s(1);
  

  -- ========================================================================
  --! PROCESS 1: FSM - Combinatorial next state logic
  -- ========================================================================
  proc_rx : PROCESS(state_s, fall_edge_s, br_i, br_2_i, rx_i)
  BEGIN
    nextstate_s <= state_s;
    CASE state_s IS

      WHEN reset_state_st =>
        nextstate_s <= idle_state_st;

      WHEN idle_state_st =>
        IF (fall_edge_s = '1') THEN
          nextstate_s <= startbrcnt_state_st;
        END IF;

      WHEN startbrcnt_state_st =>
        nextstate_s <= wait_state_st;

      WHEN wait_state_st =>
        IF (br_i = '1') THEN
          nextstate_s <= startbit_state_st;
        END IF;

      WHEN startbit_state_st =>
        IF (br_i = '1') THEN
          nextstate_s <= bit0_state_st;
        END IF;

      WHEN bit0_state_st =>
        IF (br_i = '1') THEN
          nextstate_s <= bit1_state_st;
        END IF;

      WHEN bit1_state_st =>
        IF (br_i = '1') THEN
          nextstate_s <= bit2_state_st;
        END IF;

      WHEN bit2_state_st =>
        IF (br_i = '1') THEN
          nextstate_s <= bit3_state_st;
        END IF;

      WHEN bit3_state_st =>
        IF (br_i = '1') THEN
          nextstate_s <= bit4_state_st;
        END IF;

      WHEN bit4_state_st =>
        IF (br_i = '1') THEN
          nextstate_s <= bit5_state_st;
        END IF;

      WHEN bit5_state_st =>
        IF (br_i = '1') THEN
          nextstate_s <= bit6_state_st;
        END IF;

      WHEN bit6_state_st =>
        IF (br_i = '1') THEN
          nextstate_s <= bit7_state_st;
        END IF;

      WHEN bit7_state_st =>
        IF (br_i = '1') THEN
          nextstate_s <= stopbit_state_st;
        END IF;

      WHEN stopbit_state_st =>
        IF (br_2_i = '1') THEN
          nextstate_s <= idle_state_st;
        END IF;

      WHEN OTHERS =>
        nextstate_s <= reset_state_st;

    END CASE;
  END PROCESS;
  

  -- ========================================================================
  --! PROCESS 2: Sequential - State register (State Update)
  -- ========================================================================
  proc_delay : PROCESS(clk_i, rst_n_i)
  BEGIN
    IF (rst_n_i = '0') THEN
      state_s <= reset_state_st;
    ELSIF (clk_i'event AND clk_i = '1') THEN
      state_s <= nextstate_s;
    END IF;
  END PROCESS;
  
  -- ========================================================================
  --! Edge detection for finish signal (Sequential)
  -- ========================================================================
  ris_edge_proc : PROCESS(clk_i, rst_n_i)
  BEGIN
    IF (rst_n_i = '0') THEN
      delay_fin_s <= (OTHERS => '0');
    ELSIF (clk_i'event AND clk_i = '1') THEN
      delay_fin_s(1) <= delay_fin_s(0);
      delay_fin_s(0) <= finish_s;
    END IF;
  END PROCESS;

  rise_edgefin_s <= (NOT delay_fin_s(1)) AND delay_fin_s(0);
  fall_edgefin_s <= (NOT delay_fin_s(0)) AND delay_fin_s(1);

  finish_s <= '1' WHEN (state_s = stopbit_state_st) ELSE '0';
  

  -- ========================================================================
  --! Sequential - Bit sampling and capture
  -- ========================================================================
  PROCESS(clk_i, rst_n_i)
  BEGIN
    IF (rst_n_i = '0') THEN
      oscil_sx <= (others => '0');
    ELSIF (clk_i'event AND clk_i = '1') THEN
      IF (state_s = bit0_state_st AND br_2_i = '1') THEN
        oscil_sx(0) <= rx_i;
      END IF;
      IF (state_s = bit1_state_st AND br_2_i = '1') THEN
        oscil_sx(1) <= rx_i;
      END IF;
      IF (state_s = bit2_state_st AND br_2_i = '1') THEN
        oscil_sx(2) <= rx_i;
      END IF;
      IF (state_s = bit3_state_st AND br_2_i = '1') THEN
        oscil_sx(3) <= rx_i;
      END IF;
      IF (state_s = bit4_state_st AND br_2_i = '1') THEN
        oscil_sx(4) <= rx_i;
      END IF;
      IF (state_s = bit5_state_st AND br_2_i = '1') THEN
        oscil_sx(5) <= rx_i;
      END IF;
      IF (state_s = bit6_state_st AND br_2_i = '1') THEN
        oscil_sx(6) <= rx_i;
      END IF;
      IF (state_s = bit7_state_st AND br_2_i = '1') THEN
        oscil_sx(7) <= rx_i;
      END IF;
    END IF;
  END PROCESS;
  

  -- ========================================================================
  --! PROCESS 3: Sequential - Output generation (REGISTERED OUTPUTS)
  -- ========================================================================

  output_register_proc : PROCESS(clk_i, rst_n_i)
  BEGIN
    IF (rst_n_i = '0') THEN
      -- Reset all output registers to default values
      rx_ready_s_reg   <= '0';
      ascii_s_reg      <= (others => '0');
      start_cnt_s_reg  <= '0';
    ELSIF (clk_i'event AND clk_i = '1') THEN
      -- Register all outputs (synchronize to clock)
      -- This creates flip-flops, NOT latches

      -- rx_ready: pulse on fall_edgefin_s
      rx_ready_s_reg <= fall_edgefin_s;

      -- ascii: latch oscil_sx only on rising edge of finish
      IF (rise_edgefin_s = '1') THEN
        ascii_s_reg <= oscil_sx;
      END IF;

      -- start_br_cnt: '1' only in startbrcnt_state_st
      IF (state_s = startbrcnt_state_st) THEN
        start_cnt_s_reg <= '1';
      ELSE
        start_cnt_s_reg <= '0';
      END IF;

    END IF;
  END PROCESS;
  

  -- ========================================================================
  --! Output assignments
  -- ========================================================================

  rx_ready_o      <= rx_ready_s_reg;   
  ascii_o         <= ascii_s_reg;      
  start_br_cnt_o  <= start_cnt_s_reg;   

END kv_uart_rx_a;