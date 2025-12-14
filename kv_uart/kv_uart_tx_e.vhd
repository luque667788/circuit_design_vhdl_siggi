-- ============================================================
-- UART Transmitter Entity
-- Student: Khush Vaghasiya (15142993)
-- Transmits UART frames (8-N-1: 8 data bits, no parity, 1 stop bit)
-- Baud rate: 9600 / 19200 bps (configurable)
-- ============================================================

LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.ma_p.ALL;

ENTITY kv_uart_tx_e IS
  PORT(
    clk_i           : IN  std_logic;                    -- System clock (125 MHz)
    rst_n_i         : IN  std_logic;                    -- Asynchronous reset (active-low)
    br_i            : IN  std_logic;                    -- Baud rate pulse (start of bit period)
    tx_data_i       : IN  std_logic_vector(7 DOWNTO 0); -- 8-bit data to transmit
    tx_valid_i      : IN  std_logic;                    -- Valid strobe for tx_data_i (pulse)
    tx_o            : OUT std_logic;                    -- UART TX output line (serial stream)
    tx_ready_o      : OUT std_logic;                    -- Ready for next data (pulse in idle)
    start_br_cnt_o  : OUT std_logic                     -- Start baud rate counter signal
  );
END kv_uart_tx_e;