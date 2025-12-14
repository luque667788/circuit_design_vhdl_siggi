LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ARCHITECTURE integration_uart_a OF integration_uart_e IS
	TYPE state_t IS (ST_IDLE, ST_ADDR, ST_WAIT_DATA, ST_DATA);

	SIGNAL state : state_t;
	SIGNAL next_state : state_t;

	SIGNAL ADDRESS : STD_LOGIC_VECTOR(3 DOWNTO 0);

	-- Signals for regfile instance
	SIGNAL reg_wr_en : STD_LOGIC;
	SIGNAL reg_wr_addr : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL reg_rd_addr : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL reg_data_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL reg_data_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL reg_ready : STD_LOGIC;
BEGIN
	-- FSM Process move to next state
	fsm_regfile : PROCESS (clk_i, rst_i)
	BEGIN
		IF rst_i = '1' THEN
			state   <= ST_IDLE;
			ADDRESS <= (OTHERS => '0');
		ELSIF rising_edge(clk_i) THEN
			state <= next_state;
			IF rx_ready_i = '1' AND ascii_rx_i(7 DOWNTO 4) = "1111" THEN
				ADDRESS <= ascii_rx_i(3 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;

	-- Next state logic
	next_state_logic : PROCESS (state, rx_ready_i, ascii_rx_i)
	BEGIN
		next_state <= state;
		CASE state IS
			WHEN ST_IDLE =>
				IF rx_ready_i = '1' AND ascii_rx_i(7 DOWNTO 4) = "1111" THEN
					next_state <= ST_ADDR;
				END IF;
			WHEN ST_ADDR =>
				next_state <= ST_WAIT_DATA;
			WHEN ST_WAIT_DATA =>
				IF rx_ready_i = '1' THEN
					next_state <= ST_DATA;
				END IF;
			WHEN ST_DATA =>
				next_state <= ST_IDLE;
		END CASE;
	END PROCESS;

	-- Output logic (boilerplate)
	output_logic : PROCESS (state, rx_ready_i)
	BEGIN
		reg_wr_en <= '0';
		CASE state IS
			WHEN ST_IDLE =>
				NULL;
			WHEN ST_ADDR =>
				NULL;
			WHEN ST_WAIT_DATA =>
				reg_wr_en <= rx_ready_i;
			WHEN ST_DATA =>
				NULL;
		END CASE;
	END PROCESS;

	reg_data_in <= ascii_rx_i;

	reg_wr_addr <= ADDRESS; -- write address latched from UART
	reg_rd_addr <= reg_addr_i; -- read address comes from top-level port
	reg_data_o  <= reg_data_out; -- expose read data (regfile)
		reg_ready_o <= reg_ready; -- expose ready signal (regfile)

	-- Instance of regfile
	u_regfile : ENTITY work.fsm_3block_regfile
		GENERIC MAP(
			width_g => 8,
			count_g => 16,
			addr_width_g => 4
		)
		PORT MAP(
			clk_i => clk_i,
			rst_i => rst_i,
			wr_en_i => reg_wr_en,
			wr_addr_i => reg_wr_addr,
			data_in => reg_data_in,
			rd_addr_i => reg_rd_addr,
			data_out => reg_data_out,
			ready_o => reg_ready
		);
END ARCHITECTURE integration_uart_a;