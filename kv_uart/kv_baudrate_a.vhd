-- ============================================================
-- UART Baud Rate Generator Architecture - CORRECTED
-- Student: Khush Vaghasiya (15142993)
-- Implementation: 3-State FSM with Registered Outputs
-- Compliant with Prof. Dr.-Ing. A. Siggelkow Design Guideline
-- Version: 2.0 (Design Guideline Compliant)
-- ============================================================

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.ma_p.ALL;

ARCHITECTURE kv_baudrate_a OF kv_baudrate_e IS

  -- -------------------------------------------------------
  -- Signal declarations
  -- -------------------------------------------------------
  SIGNAL cnt_i_s      : integer RANGE br_max_cnt_i_c DOWNTO 0;
  SIGNAL cnt_end_s    : integer RANGE br_max_cnt_i_c DOWNTO 0;
  SIGNAL cnt_mid_s    : integer RANGE br_max_cnt_i_c DOWNTO 0;

BEGIN

  -- -------------------------------------------------------
  -- Select the baud rate based on reg_bit_i
  -- -------------------------------------------------------
  cnt_end_s <= br_9600i_c   WHEN (reg_bit_i = '0') ELSE br_19200_c;
  cnt_mid_s <= br_9600i_2_c WHEN (reg_bit_i = '0') ELSE br_19200_2_c;

  -- ========================================================================
  -- Counter Logic (Sequential)
  -- ========================================================================

  PROCESS(clk_i, rst_n_i)
  BEGIN
    IF (rst_n_i = '0') THEN
      cnt_i_s <= 0;
    ELSIF (clk_i'event AND clk_i = '1') THEN
      IF (cnt_i_s >= cnt_end_s-1 OR br_start_i = '1') THEN
        cnt_i_s <= 0;
      ELSE
        cnt_i_s <= cnt_i_s + 1;
      END IF;
    END IF;
  END PROCESS;



  br_2_o <= '1' WHEN(cnt_i_s = cnt_mid_s)ELSE '0';   
  br_o   <= '1' WHEN(cnt_i_s = 0)        ELSE '0';
  test_o <= '1' WHEN(cnt_i_s = 1)        ELSE '0';

END kv_baudrate_a;