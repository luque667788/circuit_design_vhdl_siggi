LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE project_pkg IS
    CONSTANT reg_width_c : NATURAL := 8;
    CONSTANT reg_count_c : NATURAL := 32;
    CONSTANT reg_addr_width_c : NATURAL := 5;
    CONSTANT prefix_width_c : NATURAL := reg_width_c - reg_addr_width_c;
    CONSTANT prefix_cmd_c :
    STD_LOGIC_VECTOR(prefix_width_c - 1 DOWNTO 0) := (OTHERS => '1');

    TYPE integration_uart_state_t IS
    (idle_st, addr_st, wait_data_st, data_st);

    -- element type for a single register (fixed width from package constant)
    SUBTYPE reg_vector_t IS STD_LOGIC_VECTOR(reg_width_c - 1 DOWNTO 0);
    -- unconstrained array of registers: allows instances to use different counts via generics
    TYPE reg_array_t IS ARRAY (NATURAL RANGE <>) OF reg_vector_t;

    
    COMPONENT ifx_reg_cell_e IS
        GENERIC (
            width_g : POSITIVE := reg_width_c
        );
        PORT (
            clk_i : IN STD_LOGIC;
            rst_n_i : IN STD_LOGIC;
            load_i : IN STD_LOGIC;
            data_i : IN STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
            data_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0)
        );
    END COMPONENT ifx_reg_cell_e;

    COMPONENT ifx_regfile_e IS
        GENERIC (
            width_g : NATURAL := reg_width_c;
            count_g : NATURAL := reg_count_c;
            addr_width_g : NATURAL := reg_addr_width_c
        );
        PORT (
            clk_i : IN STD_LOGIC;
            rst_n_i : IN STD_LOGIC;
            wr_en_i : IN STD_LOGIC;
            wr_addr_i : IN STD_LOGIC_VECTOR(addr_width_g - 1 DOWNTO 0);
            data_in : IN STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
            rd_addr_i : IN STD_LOGIC_VECTOR(addr_width_g - 1 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
            ready_o : OUT STD_LOGIC;
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
    END COMPONENT ifx_regfile_e;

    COMPONENT integration_uart_core_e IS
        PORT (
            clk_i : IN STD_LOGIC;
            rst_n_i : IN STD_LOGIC;
            ascii_rx_i : IN STD_LOGIC_VECTOR(reg_width_c - 1 DOWNTO 0);
            rx_ready_i : IN STD_LOGIC;
            reg_wr_addr_o : OUT STD_LOGIC_VECTOR(reg_addr_width_c - 1 DOWNTO 0);
            reg_data_in_o : OUT STD_LOGIC_VECTOR(reg_width_c - 1 DOWNTO 0);
            reg_wr_en_o : OUT STD_LOGIC
        );
    END COMPONENT integration_uart_core_e;

    COMPONENT integration_uart_e IS
        PORT (
            clk_i : IN STD_LOGIC;
            rst_n_i : IN STD_LOGIC;
            ascii_rx_i : IN STD_LOGIC_VECTOR(reg_width_c - 1 DOWNTO 0);
            rx_ready_i : IN STD_LOGIC;
            reg_addr_i : IN STD_LOGIC_VECTOR(reg_addr_width_c - 1 DOWNTO 0);
            reg_data_o : OUT STD_LOGIC_VECTOR(reg_width_c - 1 DOWNTO 0);
            reg_ready_o : OUT STD_LOGIC
        );
    END COMPONENT integration_uart_e;
END PACKAGE project_pkg;