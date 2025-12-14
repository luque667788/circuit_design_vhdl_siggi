LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.project_pkg.ALL;

ARCHITECTURE ifx_reg_cell_a OF ifx_reg_cell_e IS
    SIGNAL q_reg_s : STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
BEGIN 
    PROCESS (clk_i, rst_n_i)
    BEGIN -- every register is basically a flip-flop with load enable
        IF rst_n_i = '0' THEN
            q_reg_s <= (OTHERS => '0');
        ELSIF rising_edge(clk_i) THEN
            IF load_i = '1' THEN
                q_reg_s <= data_i; -- when load=1 we break the feedback loop and load new data
            END IF;
        END IF;
    END PROCESS;

    data_o <= q_reg_s; -- default feedback loop to keep the same value 
END ARCHITECTURE ifx_reg_cell_a;
