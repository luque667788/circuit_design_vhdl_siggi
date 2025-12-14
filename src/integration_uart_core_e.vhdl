LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.project_pkg.ALL;

ENTITY integration_uart_core_e IS
    PORT (
        clk_i : IN STD_LOGIC;
        rst_n_i : IN STD_LOGIC;
        ascii_rx_i : IN STD_LOGIC_VECTOR(reg_width_c - 1 DOWNTO 0);
        rx_ready_i : IN STD_LOGIC;
        reg_wr_addr_o : OUT STD_LOGIC_VECTOR(reg_addr_width_c - 1 DOWNTO 0);
        reg_data_in_o : OUT STD_LOGIC_VECTOR(reg_width_c - 1 DOWNTO 0);
        reg_wr_en_o : OUT STD_LOGIC

    );
END ENTITY integration_uart_core_e;