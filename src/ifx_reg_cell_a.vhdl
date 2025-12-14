LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ARCHITECTURE ifx_reg_cell_a OF ifx_reg_cell_e IS
    SIGNAL q_reg : STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
BEGIN
    PROCESS (clk_i)
    BEGIN
        IF rising_edge(clk_i) THEN
            IF rst_i = '1' THEN
                q_reg <= (OTHERS => '0');
            ELSIF load_i = '1' THEN
                q_reg <= data_i;
            END IF; -- when load_i = '0' data recirculates automatically data_0 <= q_reg (feedback loop)
        END IF;
    END PROCESS;

    data_o <= q_reg; -- Feed output (feedback loop when load_i = '0')
END ARCHITECTURE ifx_reg_cell_a;
