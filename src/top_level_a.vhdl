LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.project_pkg.ALL;

ARCHITECTURE top_level_a OF top_level_e IS
  -- Internal signals just to map in between UART core and register file
  SIGNAL reg_wr_en_s : STD_LOGIC;
  SIGNAL reg_wr_addr_s : STD_LOGIC_VECTOR(reg_addr_width_c - 1 DOWNTO 0);
  SIGNAL reg_data_in_s : STD_LOGIC_VECTOR(reg_width_c - 1 DOWNTO 0);
  SIGNAL reg_registers_s : reg_array_t(0 TO reg_count_c - 1);

BEGIN

  u_regfile : ifx_regfile_e
  GENERIC MAP(
    width_g => reg_width_c,
    count_g => reg_count_c,
    addr_width_g => reg_addr_width_c
  )
  PORT MAP(
    clk_i => clk_i,
    rst_n_i => rst_n_i,
    wr_en_i => reg_wr_en_s,
    wr_addr_i => reg_wr_addr_s,
    data_in => reg_data_in_s,
    rd_addr_i => reg_addr_i,
    data_out => reg_data_o,
    ready_o => reg_ready_o,
    registers_o => reg_registers_s,
    reg0_o => reg0_o,
    reg1_o => reg1_o,
    reg2_o => reg2_o,
    reg3_o => reg3_o,
    reg4_o => reg4_o,
    reg5_o => reg5_o,
    reg6_o => reg6_o,
    reg7_o => reg7_o,
    reg8_o => reg8_o,
    reg9_o => reg9_o,
    reg10_o => reg10_o,
    reg11_o => reg11_o,
    reg12_o => reg12_o,
    reg13_o => reg13_o,
    reg14_o => reg14_o,
    reg15_o => reg15_o,
    reg16_o => reg16_o,
    reg17_o => reg17_o,
    reg18_o => reg18_o,
    reg19_o => reg19_o,
    reg20_o => reg20_o,
    reg21_o => reg21_o,
    reg22_o => reg22_o,
    reg23_o => reg23_o,
    reg24_o => reg24_o,
    reg25_o => reg25_o,
    reg26_o => reg26_o,
    reg27_o => reg27_o,
    reg28_o => reg28_o,
    reg29_o => reg29_o,
    reg30_o => reg30_o,
    reg31_o => reg31_o
  );

  u_integration_uart_core : integration_uart_core_e
  PORT MAP(
    clk_i => clk_i,
    rst_n_i => rst_n_i,
    ascii_rx_i => ascii_rx_i,
    rx_ready_i => rx_ready_i,
    reg_wr_addr_o => reg_wr_addr_s,
    reg_data_in_o => reg_data_in_s,
    reg_wr_en_o => reg_wr_en_s
  );
END ARCHITECTURE top_level_a;