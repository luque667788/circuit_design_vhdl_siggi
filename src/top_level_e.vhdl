LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.project_pkg.ALL;

ENTITY top_level_e IS
    PORT (
        clk_i       : IN  STD_LOGIC;
        rst_n_i     : IN  STD_LOGIC;
        ascii_rx_i  : IN  STD_LOGIC_VECTOR(reg_width_c - 1 DOWNTO 0);
        rx_ready_i  : IN  STD_LOGIC;
        reg_addr_i  : IN  STD_LOGIC_VECTOR(reg_addr_width_c - 1 DOWNTO 0);
        reg_data_o  : OUT STD_LOGIC_VECTOR(reg_width_c - 1 DOWNTO 0);
        reg_ready_o : OUT STD_LOGIC
    );
END ENTITY top_level_e;
