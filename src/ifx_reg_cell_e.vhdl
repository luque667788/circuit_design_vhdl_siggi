LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ifx_reg_cell_e IS
    GENERIC (
        width_g : POSITIVE := 8
    );
    PORT (
        clk_i  : IN  STD_LOGIC;
        rst_i  : IN  STD_LOGIC;
        load_i : IN  STD_LOGIC;
        data_i : IN  STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0);
        data_o : OUT STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0)
    );
END ENTITY ifx_reg_cell_e;

ARCHITECTURE ifx_reg_cell_a OF ifx_reg_cell_e IS
    SIGNAL q_reg : STD_LOGIC_VECTOR(width_g - 1 DOWNTO 0) := (OTHERS => '0');
BEGIN
    PROCESS (clk_i)
    BEGIN
        IF rising_edge(clk_i) THEN
            IF rst_i = '1' THEN
                q_reg <= (OTHERS => '0');
            ELSIF load_i = '1' THEN
                q_reg <= data_i;
            END IF;
        END IF;
    END PROCESS;

    data_o <= q_reg;
END ARCHITECTURE ifx_reg_cell_a;
