-- ###########################################################################
--  ifx_regfile
-- ###########################################################################

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ARCHITECTURE rtl OF ifx_regfile_e IS
    CONSTANT addr_capacity_c : NATURAL := 2 ** addr_width_g;
    SUBTYPE reg_index_t IS NATURAL RANGE 0 TO register_count_g - 1; -- the number of registers but with 0-based index
    TYPE reg_array_t IS ARRAY (reg_index_t) OF STD_LOGIC_VECTOR(data_width_g - 1 DOWNTO 0); -- each register is data_width_g wide (example 8 bits)
    SIGNAL storage_r : reg_array_t := (OTHERS => (OTHERS => '0')); -- we have an array of arrays (like multiple registers each 8 bits wide) so it is basically a 2D array
    SIGNAL read_r : STD_LOGIC_VECTOR(data_width_g - 1 DOWNTO 0) := (OTHERS => '0');

BEGIN

    ASSERT register_count_g <= addr_capacity_c
    REPORT "Address width does not cover register count" SEVERITY failure;


    -- State machine: Reset, Idle, Active (Read/Write/Bypass)
    -- State Machine Inputs:
    -- rst_i, en_i, wr_en_i

    -- Address Inputs: wr_addr_i, rd_addr_i

    -- Outputs: rd_data_o

    PROCESS (clk_i)
        VARIABLE wr_idx_v : reg_index_t;
        VARIABLE rd_idx_v : reg_index_t;
    BEGIN
        IF rising_edge(clk_i) THEN
            IF rst_i = '1' THEN -- RESET STATE
                storage_r <= (OTHERS => (OTHERS => '0'));
                read_r <= (OTHERS => '0');
            ELSIF en_i = '1' THEN -- ENABLED
                rd_idx_v := reg_index_t(to_integer(unsigned(rd_addr_i))); -- Always able to read if it is enabled
                read_r <= storage_r(rd_idx_v);
                IF wr_en_i = '1' THEN -- If write is enabled we can also modify the register file
                    wr_idx_v := reg_index_t(to_integer(unsigned(wr_addr_i)));
                    storage_r(wr_idx_v) <= wr_data_i; -- actually write
                    IF wr_idx_v = rd_idx_v THEN -- If we are writing to the same address we are reading, update read_r with newly written data
                        read_r <= wr_data_i;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    rd_data_o <= read_r; -- OUTPUT read data output

END ARCHITECTURE rtl;