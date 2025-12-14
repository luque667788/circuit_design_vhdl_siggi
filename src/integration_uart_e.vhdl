LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY integration_uart_e IS
    PORT (
        clk_i       : IN  STD_LOGIC;
        rst_i       : IN  STD_LOGIC;
        ascii_rx_i  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        rx_ready_i  : IN  STD_LOGIC;
        -- only for testing and simulation
        reg_addr_i  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        reg_data_o  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg_ready_o : OUT STD_LOGIC
    );
END ENTITY integration_uart_e;
