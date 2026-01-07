-- ============================================================
-- UART Receiver Entity
-- Student: Khush Vaghasiya (15142993)
-- Institution: Hochschule Ravensburg-Weingarten
-- Date: 14 December 2025
-- ============================================================

LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.ma_p.ALL;

ENTITY kv_uart_rx_e IS
  PORT(
    clk_i           : IN  std_logic;                    -- System clock (125 MHz)
    rst_n_i         : IN  std_logic;                    -- Asynchronous reset (active-low)
    br_i            : IN  std_logic;                    -- Baud rate pulse (start of bit period)
    br_2_i          : IN  std_logic;                    -- Half baud rate pulse (mid-bit sampling)
    rx_i            : IN  std_logic;                    -- UART RX input line
    ascii_o         : OUT std_logic_vector(7 DOWNTO 0); -- Received 8-bit data output
    rx_ready_o      : OUT std_logic;                    -- Data ready flag (pulse)
    start_br_cnt_o  : OUT std_logic                     -- Start baud rate counter signal
  );
END kv_uart_rx_e;
