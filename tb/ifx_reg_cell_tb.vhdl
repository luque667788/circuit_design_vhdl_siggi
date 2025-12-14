LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.env.ALL;
USE work.project_pkg.ALL;

ENTITY ifx_reg_cell_tb IS
END ENTITY ifx_reg_cell_tb;

ARCHITECTURE tb OF ifx_reg_cell_tb IS
    CONSTANT width_c : POSITIVE := reg_width_c;
    CONSTANT clk_period_c : TIME := 10 ns;
    CONSTANT pat_a5_c : STD_LOGIC_VECTOR(width_c - 1 DOWNTO 0) := x"A5";
    CONSTANT pat_3c_c : STD_LOGIC_VECTOR(width_c - 1 DOWNTO 0) := x"3C";
    CONSTANT zero_c : STD_LOGIC_VECTOR(width_c - 1 DOWNTO 0) :=
    (OTHERS => '0');

    SIGNAL clk_i : STD_LOGIC := '0';
    SIGNAL rst_n_i : STD_LOGIC := '0';
    SIGNAL load_i : STD_LOGIC := '0';
    SIGNAL data_i : STD_LOGIC_VECTOR(width_c - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data_o : STD_LOGIC_VECTOR(width_c - 1 DOWNTO 0);
BEGIN
    clk_p : PROCESS
    BEGIN
        clk_i <= '0';
        WAIT FOR clk_period_c / 2;
        clk_i <= '1';
        WAIT FOR clk_period_c / 2;
    END PROCESS clk_p;

    dut : ENTITY work.ifx_reg_cell_e
        GENERIC MAP(
            width_g => width_c
        )
        PORT MAP(
            clk_i => clk_i,
            rst_n_i => rst_n_i,
            load_i => load_i,
            data_i => data_i,
            data_o => data_o
        );

    stim_p : PROCESS
    BEGIN
        rst_n_i <= '0';
        load_i <= '0';
        data_i <= (OTHERS => '0');
        WAIT FOR 3 * clk_period_c;
        rst_n_i <= '1';

        WAIT UNTIL rising_edge(clk_i);
        ASSERT data_o = zero_c
        REPORT "ifx_reg_cell_tb: reset mismatch"
            SEVERITY error;

        data_i <= pat_a5_c;
        load_i <= '1';
        WAIT UNTIL rising_edge(clk_i);
        load_i <= '0';
        WAIT FOR clk_period_c;
        ASSERT data_o = pat_a5_c
        REPORT "ifx_reg_cell_tb: first load mismatch"
            SEVERITY error;

        WAIT UNTIL rising_edge(clk_i);

        data_i <= pat_3c_c;
        load_i <= '1';
        WAIT UNTIL rising_edge(clk_i);
        load_i <= '0';
        WAIT FOR clk_period_c;
        ASSERT data_o = pat_3c_c
        REPORT "ifx_reg_cell_tb: second load mismatch"
            SEVERITY error;
        ASSERT data_o = pat_3c_c
        REPORT "ifx_reg_cell_tb: value not held"
            SEVERITY error;

        WAIT UNTIL rising_edge(clk_i);

        data_i <= pat_a5_c;
        load_i <= '1';
        WAIT UNTIL rising_edge(clk_i);
        load_i <= '0';
        WAIT FOR clk_period_c;
        ASSERT data_o = pat_a5_c
        REPORT "ifx_reg_cell_tb: first load mismatch"
            SEVERITY error;

        WAIT FOR 5 * clk_period_c;

        REPORT "ifx_reg_cell_tb completed" SEVERITY note;
        stop;
        WAIT;
    END PROCESS stim_p;
END ARCHITECTURE tb;