-- ###########################################################################
--  ifx_regfile
-- ###########################################################################

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


ENTITY ifx_regfile_e IS
    GENERIC (
        register_count_g : POSITIVE := 64;
        data_width_g : POSITIVE := 8;
        addr_width_g : POSITIVE := 6
    );
    PORT (
        clk_i : IN STD_LOGIC;
        rst_i : IN STD_LOGIC;
        en_i : IN STD_LOGIC;
        wr_en_i : IN STD_LOGIC;
        wr_addr_i : IN STD_LOGIC_VECTOR(addr_width_g - 1 DOWNTO 0);
        wr_data_i : IN STD_LOGIC_VECTOR(data_width_g - 1 DOWNTO 0);
        rd_addr_i : IN STD_LOGIC_VECTOR(addr_width_g - 1 DOWNTO 0);
        rd_data_o : OUT STD_LOGIC_VECTOR(data_width_g - 1 DOWNTO 0)
    );
END ENTITY ifx_regfile_e;