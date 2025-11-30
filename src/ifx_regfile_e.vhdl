-- ###########################################################################
--  ifx_regfile
-- ###########################################################################

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fsm_3block_regfile IS
    GENERIC (
        width_g : NATURAL := 8; -- Data width
        count_g : NATURAL := 8  -- Number of registers
    );
    PORT (
        clk_i     : IN  STD_LOGIC;
        rst_i     : IN  STD_LOGIC; -- Asynchronous Reset
        
        -- User Inputs
        en_i      : IN  STD_LOGIC; -- Global Enable
        we_i      : IN  STD_LOGIC; -- Write Request
        re_i      : IN  STD_LOGIC; -- Read Request
        
        -- Datapath Inputs
        wr_addr_i : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        rd_addr_i : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        data_in   : IN  STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        
        -- System Output
        data_out  : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        ready_o   : OUT STD_LOGIC
    );
END ENTITY fsm_3block_regfile;