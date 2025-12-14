LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE project_pkg IS
    CONSTANT reg_width_c : NATURAL := 8;
    CONSTANT reg_count_c : NATURAL := 16;
    CONSTANT reg_addr_width_c : NATURAL := 4;
    CONSTANT prefix_cmd_c :
    STD_LOGIC_VECTOR(reg_addr_width_c - 1 DOWNTO 0) := "1111";

    TYPE integration_uart_state_t IS
    (idle_st, addr_st, wait_data_st, data_st);

    TYPE reg_array_t IS ARRAY (0 TO reg_count_c - 1) OF STD_LOGIC_VECTOR(reg_width_c - 1 DOWNTO 0);

    
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
            ready_o : OUT STD_LOGIC
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