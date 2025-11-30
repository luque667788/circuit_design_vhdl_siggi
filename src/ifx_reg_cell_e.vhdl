LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ifx_reg_cell_e IS
    GENERIC (
        width_g : POSITIVE := 8
    );
    PORT (
        clk_i  : IN  STD_LOGIC;
        rst_i  : IN  STD_LOGIC;
        load_i : IN  STD_LOGIC;
        data_i : IN  STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        data_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0)
    );
END ENTITY ifx_reg_cell_e;
