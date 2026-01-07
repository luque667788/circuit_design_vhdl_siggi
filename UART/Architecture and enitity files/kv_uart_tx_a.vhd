-- ============================================================
-- UART Transmitter Architecture 
-- Student: Khush Vaghasiya (15142993)
-- Institution: Hochschule Ravensburg-Weingarten
-- Date: 14 December 2025
-- ============================================================

LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.ma_p.ALL;

ARCHITECTURE kv_uart_tx_a OF kv_uart_tx_e IS

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

  -- Data storage signals
  SIGNAL shift_reg_s           : std_logic_vector(7 DOWNTO 0);
  -- ========================================================================
  -- Output synchronization signals (registered flip-flops)
  -- ========================================================================
  SIGNAL tx_ready_s_reg        : std_logic;
  SIGNAL tx_line_s_reg         : std_logic;
  SIGNAL start_cnt_s_reg       : std_logic;

BEGIN

  -- ========================================================================
  --! PROCESS 1: FSM - Combinatorial next state logic
  -- ========================================================================
  proc_tx : PROCESS(state_s, br_i, tx_valid_i)
  BEGIN
    nextstate_s <= state_s;

    CASE state_s IS

      WHEN reset_state_st =>
        nextstate_s <= idle_state_st;

      WHEN idle_state_st =>
        IF (tx_valid_i = '1') THEN
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
        IF (br_i = '1') THEN
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
  --! Sequential - Data storage
  -- ========================================================================
  data_store : PROCESS(clk_i, rst_n_i)
  BEGIN
    IF (rst_n_i = '0') THEN
      shift_reg_s <= (others => '0');
    ELSIF (clk_i'event AND clk_i = '1') THEN
      IF (state_s = idle_state_st AND tx_valid_i = '1') THEN
        shift_reg_s <= tx_data_i;
      END IF;
    END IF;
  END PROCESS;


  -- ========================================================================
  --! PROCESS 3: Sequential - Output Generation (REGISTERED OUTPUTS)
  -- ========================================================================
  
  output_register_proc : PROCESS(clk_i, rst_n_i)
  BEGIN
    IF (rst_n_i = '0') THEN
      -- Reset all output registers to default values
      tx_ready_s_reg   <= '0';
      tx_line_s_reg    <= '1';
      start_cnt_s_reg  <= '0';

    ELSIF (clk_i'event AND clk_i = '1') THEN
      -- Register all outputs (synchronize to clock)
      -- Default assignments every clock edge
      tx_ready_s_reg   <= '0';
      start_cnt_s_reg  <= '0';

      -- tx_ready: high only in idle state
      CASE state_s IS

      	WHEN reset_state_st =>
        	tx_line_s_reg <= '1';

      	WHEN idle_state_st =>
        	tx_line_s_reg <= '1';
        	-- TX is ready only in idle
        	tx_ready_s_reg <= '1';
        	-- Start counter if a new frame is requested
        	IF tx_valid_i = '1' THEN
          		start_cnt_s_reg <= '1';
        	END IF;

      	WHEN startbit_state_st =>
        	tx_line_s_reg <= '0';

      	WHEN bit0_state_st =>
        	tx_line_s_reg <= shift_reg_s(0);

      	WHEN bit1_state_st =>
        	tx_line_s_reg <= shift_reg_s(1);

      	WHEN bit2_state_st =>
        	tx_line_s_reg <= shift_reg_s(2);

      	WHEN bit3_state_st =>
        	tx_line_s_reg <= shift_reg_s(3);

      	WHEN bit4_state_st =>
        	tx_line_s_reg <= shift_reg_s(4);

      	WHEN bit5_state_st =>
        	tx_line_s_reg <= shift_reg_s(5);

      	WHEN bit6_state_st =>
        	tx_line_s_reg <= shift_reg_s(6);

      	WHEN bit7_state_st =>
        	tx_line_s_reg <= shift_reg_s(7);

      	WHEN stopbit_state_st =>
        	tx_line_s_reg <= '1';

      	WHEN OTHERS =>
        	tx_line_s_reg <= '1';

      END CASE;

    END IF;
  END PROCESS;



  -- ========================================================================
  --! Output assignments 
  -- ========================================================================

  tx_o            <= tx_line_s_reg;   
  start_br_cnt_o  <= start_cnt_s_reg; 
  tx_ready_o      <= tx_ready_s_reg;  

END kv_uart_tx_a;