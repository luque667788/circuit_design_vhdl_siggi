-- ###########################################################################
--  ifx_regfile
-- ###########################################################################

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fsm_3block_regfile IS
    GENERIC (
        width_g      : NATURAL := 8; -- Data width
        count_g      : NATURAL := 8; -- Number of registers
        addr_width_g : NATURAL := 3  -- Address width
    );
    PORT (
        clk_i     : IN  STD_LOGIC;
        rst_i     : IN  STD_LOGIC;

        -- Write interface
        wr_en_i   : IN  STD_LOGIC;
        wr_addr_i : IN  STD_LOGIC_VECTOR(addr_width_g - 1 DOWNTO 0);
        data_in   : IN  STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);

        -- Read interface
        rd_addr_i : IN  STD_LOGIC_VECTOR(addr_width_g - 1 DOWNTO 0);
        data_out  : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);

        -- Status
        ready_o   : OUT STD_LOGIC
    );
END ENTITY fsm_3block_regfile;