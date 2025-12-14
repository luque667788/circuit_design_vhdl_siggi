-- -------------------------------------------------------
-- Constants Package for UART Module
-- Defines baud rate constants for 125 MHz system clock
-- Author: Khush Vaghasiya (15142993)
-- University: Hochschule Ravensburg-Weingarten
-- -------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE ma_p IS

  -- ============================================================
  -- Baud Rate Constants for 125 MHz Clock
  -- ============================================================
  
  -- Maximum counter value (for signal range declaration)
  CONSTANT br_max_cnt_i_c   : integer := 16383;
  
  -- Baud rate divisor constants
  -- Formula: Counter = Clock_Freq / Baud_Rate - 1
  
  -- For 9600 baud: 125,000,000 / 9,600 = 13,020.833 ≈ 13,021
  CONSTANT br_9600i_c      : integer := 13021;
  
  -- For 19200 baud: 125,000,000 / 19,200 = 6,510.417 ≈ 6,511
  CONSTANT br_19200_c     : integer := 6511;
  
  -- Midpoint constants (half of baud period for sampling)
  -- Used for br_2_o signal generation
  
  -- Midpoint for 9600 baud: 13,021 / 2 = 6,511
  CONSTANT br_9600i_2_c     : integer := 6511;
  
  -- Midpoint for 19200 baud: 6,511 / 2 = 3,255.5
  CONSTANT br_19200_2_c    : integer := 3256;
  
 -- ============================================================
  -- UART RX Constants
  -- ============================================================
  
  -- Data bits configuration
  CONSTANT data_bits_c      : integer := 8;  -- 8-bit data frame
  
  -- Stop bits configuration  
  CONSTANT stop_bits_c      : integer := 1;  -- 1 stop bit
  
  -- Parity configuration
  CONSTANT parity_bits_c    : integer := 0;  -- No parity (N in 8-N-1)

END ma_p;

PACKAGE BODY ma_p IS
  -- Package body (empty for constants-only package)
END ma_p;
