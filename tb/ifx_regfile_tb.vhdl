-- ###########################################################################
--  ifx_regfile_tb
-- ###########################################################################

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.env.ALL;


ENTITY ifx_regfile_tb IS
END ENTITY ifx_regfile_tb;

ARCHITECTURE tb OF ifx_regfile_tb IS
-- testbench parameters
    CONSTANT c_register_count : POSITIVE := 8;
    CONSTANT c_data_width : POSITIVE := 8;
    CONSTANT c_addr_width : POSITIVE := 3;
    CONSTANT c_clk_period : TIME := 8 ns; -- 125 MHz clock period
    CONSTANT c_zero : STD_LOGIC_VECTOR(c_data_width - 1 DOWNTO 0) := (OTHERS => '0');
    CONSTANT c_pat_a5 : STD_LOGIC_VECTOR(c_data_width - 1 DOWNTO 0) := x"A5";
    CONSTANT c_pat_3c : STD_LOGIC_VECTOR(c_data_width - 1 DOWNTO 0) := x"3C";
    CONSTANT c_pat_55 : STD_LOGIC_VECTOR(c_data_width - 1 DOWNTO 0) := x"55";

    -- Stimulus signals.
    SIGNAL clk_i : STD_LOGIC := '0';
    SIGNAL rst_i : STD_LOGIC := '0';
    SIGNAL en_i : STD_LOGIC := '0';
    SIGNAL we_i : STD_LOGIC := '0';
    SIGNAL re_i : STD_LOGIC := '0';
    SIGNAL wr_addr_i : STD_LOGIC_VECTOR(c_addr_width - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rd_addr_i : STD_LOGIC_VECTOR(c_addr_width - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data_in : STD_LOGIC_VECTOR(c_data_width - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data_out : STD_LOGIC_VECTOR(c_data_width - 1 DOWNTO 0);
    SIGNAL ready_o : STD_LOGIC := '0';

-- helper to wait a clock cycle
    PROCEDURE wait_clk IS
    BEGIN
        WAIT UNTIL rising_edge(clk_i);
        WAIT FOR c_clk_period / 10;
    END PROCEDURE;

    PROCEDURE write_reg(
        SIGNAL wr_addr : OUT STD_LOGIC_VECTOR;
        SIGNAL data_in_s : OUT STD_LOGIC_VECTOR;
        SIGNAL we_s : OUT STD_LOGIC;
        SIGNAL re_s : OUT STD_LOGIC;
        SIGNAL ready_s : IN STD_LOGIC;
        CONSTANT addr : NATURAL;
        CONSTANT value : STD_LOGIC_VECTOR
    ) IS
    BEGIN
        wr_addr <= STD_LOGIC_VECTOR(to_unsigned(addr, c_addr_width));
        data_in_s <= value;
        we_s <= '1';
        re_s <= '0';
        wait_clk;
        we_s <= '0';
        WAIT UNTIL ready_s = '1';
        wait_clk;
    END PROCEDURE;

    PROCEDURE read_reg(
        SIGNAL rd_addr : OUT STD_LOGIC_VECTOR;
        SIGNAL we_s : OUT STD_LOGIC;
        SIGNAL re_s : OUT STD_LOGIC;
        SIGNAL ready_s : IN STD_LOGIC;
        CONSTANT addr : NATURAL
    ) IS
    BEGIN
        rd_addr <= STD_LOGIC_VECTOR(to_unsigned(addr, c_addr_width));
        re_s <= '1';
        we_s <= '0';
        wait_clk;
        re_s <= '0';
        WAIT UNTIL ready_s = '1';
        wait_clk;
    END PROCEDURE;

BEGIN

    -- Clock generator
    clk_gen : PROCESS
    BEGIN
        clk_i <= '0';
        WAIT FOR c_clk_period / 2;
        clk_i <= '1';
        WAIT FOR c_clk_period / 2;
    END PROCESS;

-- create the entity to test
    dut : ENTITY work.fsm_3block_regfile
        GENERIC MAP(
            count_g => c_register_count,
            width_g => c_data_width
        )
        PORT MAP(
            clk_i => clk_i,
            rst_i => rst_i,
            en_i => en_i,
            we_i => we_i,
            re_i => re_i,
            wr_addr_i => wr_addr_i,
            rd_addr_i => rd_addr_i,
            data_in => data_in,
            data_out => data_out,
            ready_o => ready_o
        );


    -- simulation some use like reads and writes
    stimulus : PROCESS
    BEGIN
        rst_i <= '1';
        en_i <= '0';
        we_i <= '0';
        re_i <= '0';
        wr_addr_i <= (OTHERS => '0');
        rd_addr_i <= (OTHERS => '0');
        data_in <= (OTHERS => '0');
        wait_clk;
        wait_clk;
        rst_i <= '0';
        en_i <= '1';
        read_reg(rd_addr_i, we_i, re_i, ready_o, 5);
        ASSERT data_out = c_zero REPORT "Register 5 not reset to zero" SEVERITY error;

        write_reg(wr_addr_i, data_in, we_i, re_i, ready_o, 5, c_pat_a5);
        wait_clk;
        read_reg(rd_addr_i, we_i, re_i, ready_o, 5);
        ASSERT data_out = c_pat_a5 REPORT "Register 5 read-back mismatch" SEVERITY error;

        write_reg(wr_addr_i, data_in, we_i, re_i, ready_o, 3, c_pat_3c);
        wait_clk;
        read_reg(rd_addr_i, we_i, re_i, ready_o, 3);
        ASSERT data_out = c_pat_3c REPORT "Register 3 read-back mismatch" SEVERITY error;

        read_reg(rd_addr_i, we_i, re_i, ready_o, 5);
        ASSERT data_out = c_pat_a5 REPORT "Register 5 corrupted" SEVERITY error;

        en_i <= '0';
        re_i <= '1';
        rd_addr_i <= STD_LOGIC_VECTOR(to_unsigned(2, c_addr_width));
        wait_clk;
        re_i <= '0';
        ASSERT data_out = c_pat_a5 REPORT "Data output changed while enable low" SEVERITY error;
        en_i <= '1';
        wait_clk;

        write_reg(wr_addr_i, data_in, we_i, re_i, ready_o, 7, c_pat_55);
        wait_clk;
        read_reg(rd_addr_i, we_i, re_i, ready_o, 7);
        ASSERT data_out = c_pat_55 REPORT "Register 7 write/read mismatch" SEVERITY error;
        wait_clk;
        REPORT "ifx_regfile_tb completed successfully" SEVERITY note;
        STOP;
    END PROCESS;

END ARCHITECTURE tb;