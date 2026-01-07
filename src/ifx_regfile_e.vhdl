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
        ready_o   : OUT STD_LOGIC;
        registers_o : OUT reg_array_t;
        reg0_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg1_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg2_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg3_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg4_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg5_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg6_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg7_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg8_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg9_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg10_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg11_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg12_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg13_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg14_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg15_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg16_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg17_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg18_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg19_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg20_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg21_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg22_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg23_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg24_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg25_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg26_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg27_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg28_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg29_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg30_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        reg31_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0)
    );
END ENTITY ifx_regfile_e;