LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.project_pkg.ALL;

ARCHITECTURE integration_uart_core_a OF integration_uart_core_e IS
    SIGNAL state_q_s : integration_uart_state_t; -- states
    SIGNAL state_d_s : integration_uart_state_t;
    SIGNAL addr_q_s : STD_LOGIC_VECTOR(reg_addr_width_c - 1 DOWNTO 0);-- local signal to hold address

BEGIN
    reg_data_in_o <= ascii_rx_i; -- map data output port directly from uart to registerfile
    reg_wr_addr_o <= addr_q_s; -- map local to output port

    -- state transition block runs every clock cycle
    state_ff_p : PROCESS (clk_i, rst_n_i)
    BEGIN
        IF rst_n_i = '0' THEN -- reset state
            state_q_s <= idle_st;
            addr_q_s <= (OTHERS => '0');
        ELSIF rising_edge(clk_i) THEN
            state_q_s <= state_d_s;
            IF state_q_s = addr_st THEN
                addr_q_s <= ascii_rx_i(reg_addr_width_c - 1 DOWNTO 0);
            END IF;
        END IF;
    END PROCESS state_ff_p;
    --  choose what is the next state.
    next_state_p : PROCESS (state_q_s, rx_ready_i, ascii_rx_i)
    BEGIN
        state_d_s <= state_q_s; -- default case we just stay in the same state
        CASE state_q_s IS
            WHEN idle_st =>
                IF rx_ready_i = '1' AND -- if we receive an address we switch to address state
                    ascii_rx_i(reg_width_c - 1 DOWNTO reg_addr_width_c) =
                    prefix_cmd_c THEN
                    state_d_s <= addr_st;
                END IF;
            WHEN addr_st => -- this state is pretty boring we just setup the address in the regfile and next state is wait for data
                state_d_s <= wait_data_st;
            WHEN wait_data_st => -- wait for the actual data which comes in the next packet
                IF rx_ready_i = '1' THEN
                    state_d_s <= data_st;
                END IF;
            WHEN data_st => -- just reserver this to write data and go back to idle (which means we just enable the wr_en on the the regfile)
                state_d_s <= idle_st;
            WHEN OTHERS =>
                state_d_s <= idle_st;
        END CASE;
    END PROCESS next_state_p;
    -- what to do for each state
    output_logic_p : PROCESS (state_q_s) -- runs when the state changes (which is during rising edge)
    BEGIN
        reg_wr_en_o <= '0';
        CASE state_q_s IS
            WHEN idle_st =>
                reg_wr_en_o <= '0';-- we gotta disable the right enable we previouly enabled
            WHEN addr_st =>
                NULL;
            WHEN wait_data_st =>
                NULL;
            WHEN data_st =>
                reg_wr_en_o <= '1'; -- we are ready to write data so we do that, just enable
                -- the actual data is in ascii_rx_i  and it is already mapped to reg_data_in_o
            WHEN OTHERS =>
                reg_wr_en_o <= '0'; -- if anything weird happens we disable write
        END CASE;
    END PROCESS output_logic_p;
END ARCHITECTURE integration_uart_core_a;