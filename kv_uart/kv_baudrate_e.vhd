-- -------------------------------------------------------
-- Baudrate Generator Entity
-- Generates baud rate clock and half-baud clock
-- Target: 9600 or 19200 baud from 125 MHz system clock
-- Author: Khush Vaghasiya (15142993)
-- Course: Digital Circuit Design
-- University: Hochschule Ravensburg-Weingarten
-- Part: 1 of 6 (UART Module)
-- Modified to match professor's structure
-- -------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.ma_p.ALL;

ENTITY kv_baudrate_e IS
  PORT(
    clk_i       : IN  std_logic;   -- Base clock, e.g. 100MHz clock
    rst_n_i     : IN  std_logic;   -- Reset
    br_start_i  : IN  std_logic;   -- Start the counter
    reg_bit_i   : IN  std_logic;   -- 9600 or 19200
    br_2_o      : OUT std_logic;   -- Half of the bit period
    br_o        : OUT std_logic;   -- Begin of the bit period
    test_o      : OUT std_logic    -- Monitor
  );
END kv_baudrate_e;
