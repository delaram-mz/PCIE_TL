LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Interface_PCHtoNB_DataPath IS

	PORT
	(
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;

		-- Northbridge interface:
		data_out  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		start_pch : OUT STD_LOGIC;
		pop : IN STD_LOGIC;

		-- PCH interface:

		ready3 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

		-- Controller (inside):

		full : OUT STD_LOGIC

	);

END Interface_PCHtoNB_DataPath;

ARCHITECTURE Behavioral OF Interface_PCHtoNB_DataPath IS

	SIGNAL rdy : STD_LOGIC;
	SIGNAL empty: STD_LOGIC;
	SIGNAL fifo_top_dataout : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

BEGIN
	data_out <= fifo_top_dataout;
	start_pch <= NOT empty;

	-- FIFO
	FIFO1 : ENTITY work.FIFO
		GENERIC MAP(
			log2size => 3
		)
		PORT MAP
		(
			clk => clk,
			rst => rst,
			push => rdy,
			pop => pop,
			data_in => data_in,
			data_top => fifo_top_dataout,
			full => full,
			empty => empty
		);

	-- ORing3
	ORing3_1 : ENTITY work.ORing3
		PORT MAP
		(
			a => ready3(0),
			b => ready3(1),
			c => ready3(2),
			y => rdy
		);
			
END Behavioral;