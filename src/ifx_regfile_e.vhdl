-- ###########################################################################
--  ifx_regfile
-- ###########################################################################

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.project_pkg.ALL;

ENTITY ifx_regfile_e IS
    GENERIC (
        width_g      : NATURAL := reg_width_c;
        count_g      : NATURAL := reg_count_c;
        addr_width_g : NATURAL := reg_addr_width_c
    );
    PORT (
        clk_i     : IN  STD_LOGIC;
        rst_n_i   : IN  STD_LOGIC;
        wr_en_i   : IN  STD_LOGIC;
        wr_addr_i : IN  STD_LOGIC_VECTOR(addr_width_g - 1 DOWNTO 0);
        data_in   : IN  STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        rd_addr_i : IN  STD_LOGIC_VECTOR(addr_width_g - 1 DOWNTO 0);
        data_out  : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        ready_o   : OUT STD_LOGIC
    );
END ENTITY ifx_regfile_e;