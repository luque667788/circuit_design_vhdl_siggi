-- ###########################################################################
--  ifx_regfile_tb
-- ###########################################################################

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.env.ALL;
USE work.project_pkg.ALL;

ENTITY ifx_regfile_tb IS
END ENTITY ifx_regfile_tb;

ARCHITECTURE tb OF ifx_regfile_tb IS
    CONSTANT register_count_c : POSITIVE := reg_count_c;
    CONSTANT data_width_c : POSITIVE := reg_width_c;
    CONSTANT addr_width_c : POSITIVE := reg_addr_width_c;
    CONSTANT clk_period_c : TIME := 8 ns;
    CONSTANT pat_a5_c : STD_LOGIC_VECTOR(data_width_c - 1 DOWNTO 0) := x"A5";

    SIGNAL clk_i : STD_LOGIC := '0';
    SIGNAL rst_n_i : STD_LOGIC := '0';
    SIGNAL wr_en_i : STD_LOGIC := '0';
    SIGNAL wr_addr_i : STD_LOGIC_VECTOR(addr_width_c - 1 DOWNTO 0) :=
    (OTHERS => '0');
    SIGNAL rd_addr_i : STD_LOGIC_VECTOR(addr_width_c - 1 DOWNTO 0) :=
    (OTHERS => '0');
    SIGNAL data_in : STD_LOGIC_VECTOR(data_width_c - 1 DOWNTO 0) :=
    (OTHERS => '0');
    SIGNAL data_out : STD_LOGIC_VECTOR(data_width_c - 1 DOWNTO 0);
    SIGNAL ready_o : STD_LOGIC := '0';
    SIGNAL registers_s_tb : reg_array_t(0 TO register_count_c - 1);
    SIGNAL reg_outputs_s : reg_array_t(0 TO register_count_c - 1);
BEGIN
    clk_gen : PROCESS
    BEGIN
        clk_i <= '0';
        WAIT FOR clk_period_c / 2;
        clk_i <= '1';
        WAIT FOR clk_period_c / 2;
    END PROCESS clk_gen;

    dut : ENTITY work.ifx_regfile_e
        GENERIC MAP(
            count_g => register_count_c,
            width_g => data_width_c,
            addr_width_g => addr_width_c
        )
        PORT MAP(
            clk_i => clk_i,
            rst_n_i => rst_n_i,
            wr_en_i => wr_en_i,
            wr_addr_i => wr_addr_i,
            data_in => data_in,
            rd_addr_i => rd_addr_i,
            data_out => data_out,
            ready_o => ready_o,
            registers_o => registers_s_tb,
            reg0_o => reg_outputs_s(0),
            reg1_o => reg_outputs_s(1),
            reg2_o => reg_outputs_s(2),
            reg3_o => reg_outputs_s(3),
            reg4_o => reg_outputs_s(4),
            reg5_o => reg_outputs_s(5),
            reg6_o => reg_outputs_s(6),
            reg7_o => reg_outputs_s(7),
            reg8_o => reg_outputs_s(8),
            reg9_o => reg_outputs_s(9),
            reg10_o => reg_outputs_s(10),
            reg11_o => reg_outputs_s(11),
            reg12_o => reg_outputs_s(12),
            reg13_o => reg_outputs_s(13),
            reg14_o => reg_outputs_s(14),
            reg15_o => reg_outputs_s(15),
            reg16_o => reg_outputs_s(16),
            reg17_o => reg_outputs_s(17),
            reg18_o => reg_outputs_s(18),
            reg19_o => reg_outputs_s(19),
            reg20_o => reg_outputs_s(20),
            reg21_o => reg_outputs_s(21),
            reg22_o => reg_outputs_s(22),
            reg23_o => reg_outputs_s(23),
            reg24_o => reg_outputs_s(24),
            reg25_o => reg_outputs_s(25),
            reg26_o => reg_outputs_s(26),
            reg27_o => reg_outputs_s(27),
            reg28_o => reg_outputs_s(28),
            reg29_o => reg_outputs_s(29),
            reg30_o => reg_outputs_s(30),
            reg31_o => reg_outputs_s(31)
        );

    stimulus : PROCESS
    BEGIN
        rst_n_i <= '0';
        wr_en_i <= '0';
        wr_addr_i <= (OTHERS => '0');
        rd_addr_i <= (OTHERS => '0');
        data_in <= (OTHERS => '0');
        WAIT FOR 4 * clk_period_c;
        rst_n_i <= '1';

        wr_addr_i <= STD_LOGIC_VECTOR(to_unsigned(2, addr_width_c));
        data_in <= pat_a5_c;
        wr_en_i <= '1';
        WAIT UNTIL rising_edge(clk_i);
        wr_en_i <= '0';

        WAIT UNTIL ready_o = '0';
        WAIT UNTIL ready_o = '1';
        WAIT UNTIL rising_edge(clk_i);
        rd_addr_i <= STD_LOGIC_VECTOR(to_unsigned(2, addr_width_c));
        WAIT FOR clk_period_c;

        ASSERT data_out = pat_a5_c
        REPORT "Register 2 read-back mismatch"
            SEVERITY error;

        ASSERT registers_s_tb(2) = pat_a5_c
        REPORT "Register array export mismatch for register 2"
            SEVERITY error;

        ASSERT reg_outputs_s(2) = pat_a5_c
        REPORT "Per-register output mismatch for register 2"
            SEVERITY error;

        REPORT "ifx_regfile_tb completed successfully" SEVERITY note;
        stop;
        WAIT;
    END PROCESS stimulus;
END ARCHITECTURE tb;