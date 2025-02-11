--*****************************************************************************/
--	Filename:		Interface_NBtoPCH_Top.vhd
--	Project:		MCI-PCH
--  Version:		2.1
--	History:		-
--	Date:			30 January 2024
--	Authors:	 	Hossein, Alireza, Delaram
--	Fist Author:    Hossein
--	Last Author: 	Delaram
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--
--*****************************************************************************/
--	File content description:
--  Top module of the interface wich is the interface between northbridge and PCH
--  
--  Modifications from 1.0 to 1.1:
--		- based on controller & datapath
--
--	Modifications from 1.1 to 2.0:

--*****************************************************************************/
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Interface_NBtoPCH_DataPath IS
	PORT(
		clk			    	:	IN	std_logic;
		rst			    	:	IN	std_logic;
		-- Northbridge interface:
		data_in         	:	IN std_logic_vector(31 DOWNTO 0); --FIFO 2
		ready_to_NB			:	OUT	std_logic; --ready_pch_FIFO
		push				:	IN std_logic;  -- FIFO 2(Recive for PCH & Send for NB)
		
		-- PCH interface:
		data_out			:	OUT	std_logic_vector(31 DOWNTO 0); --FIFO 2
		ready3          	:   OUT std_logic_vector(2 DOWNTO 0); --Posted , Non-Posted, Comletion
		
		-- Controller (inside):
		pop					:	IN std_logic;  -- FIFO 2(Recive for PCH & Send for NB)
		empty				:	OUT	std_logic; -- Check HDR0(goes to controller) 
        cnt_en          	:   IN std_logic;
		cnt_rst				:   IN std_logic;
		en_ready3_gen 		:   IN std_logic;
		ld_reg          	:   IN std_logic;
		eq          		:   OUT std_logic;
		one_DB_data			:	OUT std_logic;
		contains_data		:	OUT std_logic
        );
END Interface_NBtoPCH_DataPath;

ARCHITECTURE Behavioral OF Interface_NBtoPCH_DataPath IS

	SIGNAL fifo_top_dataout	: std_logic_vector(31 DOWNTO 0) := (OTHERS => '0'); 
	SIGNAL fmt_type			: std_logic_vector(7 DOWNTO 0) := (OTHERS => '0'); 
	SIGNAL cnt_output		: std_logic_vector(9 DOWNTO 0) := (OTHERS => '0'); 
	SIGNAL length_data		: std_logic_vector(9 DOWNTO 0) := (OTHERS => '0'); 
	SIGNAL full				: std_logic; 
	
	BEGIN
	-- Concurrent Assignments:
	data_out <= fifo_top_dataout;
	ready_to_NB <= NOT full;
--	eq <= '1' WHEN  cnt_output = (length_data - 2) ELSE '0';
	eq <= '1' WHEN  cnt_output = (length_data - 1) ELSE '0';
	one_DB_data <= '1' WHEN (length_data = "00000001") ELSE '0';
    contains_data <= '1' WHEN (length_data /= "000000000") ELSE '0';

	-- FIFO
	FIFO1: ENTITY WORK.FIFO
		GENERIC MAP(log2size => 3)
		PORT MAP(
			clk		 => clk,
			rst		 => rst,
			push	 => push,
			pop		 => pop,
			data_in	 => data_in,
			data_top => fifo_top_dataout,
			full	 => full,
			empty	 => empty
		);
	
	Up_Counter: ENTITY WORK.COUNTER
		GENERIC MAP(inputbit => 10)
		PORT MAP(
			clk		   => clk,
			rst		   => cnt_rst,
			en		   => cnt_en,
			cnt_output => cnt_output
		);

   -- ready3 generator
   	ready3_generator1: ENTITY WORK.ready3_generator
		PORT MAP(
			data_in		 	   => fmt_type,
			en_ready3_generator => en_ready3_gen,
			data_out			   => ready3
		);

    Reg_FMT_TYPE: ENTITY WORK.GENERIC_REG
		GENERIC MAP(N => 8)
		PORT MAP(
			clk		=> clk,
			rst     => rst,
			ld		=> ld_reg,
			reg_in  => fifo_top_dataout(31 DOWNTO 24),
			reg_out => fmt_type
		);
	
	Reg_LENGTH: ENTITY WORK.GENERIC_REG
		GENERIC MAP(N => 10)
		PORT MAP(
			clk		=> clk,
			rst     => rst,
			ld		=> ld_reg,
			reg_in  => fifo_top_dataout(9 DOWNTO 0),
			reg_out => length_data
		);
END Behavioral;

-- --------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity PCH_Interface_Controller is

	PORT(
	
		clk			    	:	IN	std_logic;
		rst			    	:	IN	std_logic;
		-- Northbridge interface: 
		-- 		Nothing
		-- PCH interface:
		ready_to_IF   		:	IN	 std_logic; 
		sop					:	OUT  std_logic;	-- start of packet to PCH
        eop		    		:	OUT  std_logic;	-- end of packet to PCH	
		-- Controller (inside):
		pop					:	OUT std_logic;  -- FIFO 2(Recive for PCH & Send for NB)
        cnt_en          	:   OUT std_logic;
		en_ready3_gen 		:   OUT std_logic;	-- issue ready 3 which that means ready_to_pch
		ld_reg          	:   OUT std_logic; 
		cnt_rst				:   OUT std_logic; 
		empty				:	IN	std_logic;	-- Check HDR0(goes to controller) 
		eq          		:   IN  std_logic;
		one_DB_data			:	IN std_logic;
		contains_data		:	IN std_logic
		);
		
end PCH_Interface_Controller;

architecture Behavioral of PCH_Interface_Controller is

	TYPE state IS (IDLE, INIT ,HDR_0 ,HDR_1, HDR_2, DATA_TX, wait1, EOP_STATE);
	SIGNAL pstate, nstate : state := IDLE;
	
begin
	----------------------------------------------------------------------------------------------------
	----------------- Sequential Part ------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	PROCESS (clk, rst)
		
	BEGIN
		IF (rst = '1') THEN
			pstate <= IDLE;
		ELSIF (clk = '1' AND clk'EVENT) THEN
			pstate <= nstate ;
		END IF;
	END PROCESS;
	----------------------------------------------------------------------------------------------------
	----------------- Combinaitonal next state block (mealy) -------------------------------------------
	----------------------------------------------------------------------------------------------------	
	PROCESS (pstate, empty, ready_to_IF, eq, contains_data, one_DB_data) BEGIN 
		nstate <= IDLE;
		
		CASE pstate IS  

			WHEN IDLE =>
			    nstate <= IDLE;
				IF (empty='0') THEN
					nstate <= INIT;
				END IF;

			WHEN INIT =>     -- HDR0 is on bus
				nstate <= HDR_0;
				
			WHEN HDR_0 =>            -- HDR0 & ready3 (ready_to_pch) will latch on bus.
			    IF (ready_to_IF ='1') THEN
					nstate <= HDR_1;
				ELSE
					nstate <= HDR_0;
				END IF;
				
			WHEN HDR_1 =>
				IF (ready_to_IF ='1' AND empty='0' AND contains_data='1') THEN
					nstate <= HDR_2;
				ELSIF (ready_to_IF ='1' AND empty='0' AND contains_data='0') THEN
					nstate <= EOP_STATE;
				ELSE
					nstate <= HDR_1;
				END IF;
				
			WHEN HDR_2 =>
				IF (ready_to_IF ='1' AND empty='0' AND one_DB_data='0') THEN
					nstate <= DATA_TX;
				ELSIF (ready_to_IF ='1' AND empty='0' AND one_DB_data='1') THEN
					nstate <= EOP_STATE;
				ELSE
					nstate <= HDR_2;
				END IF;
				
			WHEN DATA_TX =>
				IF (eq='1') THEN --   AND ready_to_IF ='1' AND empty='0'
					nstate <= EOP_STATE;
				ELSE
					nstate <= DATA_TX;
				END IF;

			WHEN EOP_STATE =>
				IF (ready_to_IF='1' AND empty='0') THEN --   AND ready_to_IF ='1' AND empty='0'
					nstate <= IDLE;
				ELSE
					nstate <= EOP_STATE;
				END IF;
				
			WHEN OTHERS =>
					nstate <= IDLE;
				
        END CASE;				
	END PROCESS;
	----------------------------------------------------------------------------------------------------
	----------------- Combinaitonal outputs block (mealy) -----------------------------------------------
	----------------------------------------------------------------------------------------------------
	PROCESS (pstate, empty, ready_to_IF, eq) BEGIN 
		ld_reg <= '0';
		pop <= '0';
		en_ready3_gen <= '0'; 
		sop <= '0';
		eop <= '0';
		cnt_en <= '0';
		cnt_rst <= '0';
		
		CASE pstate IS  

			WHEN IDLE =>
			    cnt_rst <= '1';

			WHEN INIT =>
				ld_reg <= '1';
				
			WHEN HDR_0 =>
				en_ready3_gen <= '1';
				sop <= '1';
				IF (ready_to_IF ='1') THEN
					pop <= '1';
				END IF;
				
			WHEN HDR_1 =>
				IF (empty='0') THEN
					en_ready3_gen <= '1';	
					IF (ready_to_IF ='1') THEN
						pop <= '1';				
					END IF;
				END IF;
			
			WHEN HDR_2 =>
				IF (empty='0') THEN
					en_ready3_gen <= '1';			
				END IF;
				
				-- IF (eq='1') THEN
				-- 	eop <= '1';
				-- END IF;
				
				IF (ready_to_IF ='1' AND empty='0') THEN
					pop <= '1';				
				END IF;
			
			WHEN DATA_TX =>
				IF (empty='0') THEN
					en_ready3_gen <= '1';			
				END IF;
				
				-- IF (eq='1') THEN
				-- 	eop <= '1';
				-- END IF;
				
				IF (ready_to_IF ='1' AND empty='0') THEN
					pop <= '1';
					cnt_en <= '1';
				END IF;

			WHEN EOP_STATE =>
				IF (empty='0') THEN
					en_ready3_gen <= '1';	
					eop <= '1';		
				END IF;
				IF (ready_to_IF ='1' AND empty='0') THEN
					pop <= '1';
					cnt_en <= '1';
				END IF;
				
			WHEN OTHERS =>
				
        END CASE;				
	END PROCESS;

	
end Behavioral;



-- --------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Interface_NBtoPCH_Top IS

	PORT
	(
		clk                 : IN  STD_LOGIC;
		rst                 : IN  STD_LOGIC;
		-- Northbridge interface: 
		push_send_fifo      : IN  STD_LOGIC; -- FIFO 2(Recive for PCH & Send for NB)
		dataout_to_pch      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); --FIFO 2
		ready_to_NB 			: OUT STD_LOGIC; --almost_full
		-- PCH interface:
		ready_to_IF         : IN  STD_LOGIC;
		sop_to_pch          : OUT STD_LOGIC; -- start of packet to PCH
		eop_to_pch          : OUT STD_LOGIC; -- end of packet to PCH
		datain_to_pch       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); --FIFO 2		
		ready3              : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) --Posted , Non-Posted, Comletion
	);
END Interface_NBtoPCH_Top;

ARCHITECTURE Behavioral OF Interface_NBtoPCH_Top IS

  SIGNAL pop : std_logic := '0';
  SIGNAL init : std_logic := '0';
  SIGNAL cnt_en : std_logic := '0';
  SIGNAL ld_len_cnt : std_logic := '0';
  SIGNAL en_ready3_gen : std_logic := '0';
  SIGNAL empty : std_logic := '0';
  SIGNAL eq : std_logic := '0';
  SIGNAL ld_reg : std_logic := '0'; 
  SIGNAL cnt_rst: std_logic := '0';
  SIGNAL one_DB_data_wire : STD_LOGIC;
  SIGNAL contains_data_wire : STD_LOGIC;

BEGIN
	-- Interface_NBtoPCH_DataPath
	Interface_NBtoPCH_DataPath1 : ENTITY WORK.Interface_NBtoPCH_DataPath
		PORT MAP
		(
			clk                 => clk,
			rst                 => rst,
			-- Northbridge interface:
			data_in            => dataout_to_pch,
			ready_to_NB        => ready_to_NB,
			push               => push_send_fifo,
			-- PCH interface:
			data_out           => datain_to_pch,
			ready3              => ready3,
			-- Controller (inside):
			pop                => pop,
			cnt_en              => cnt_en,
			en_ready3_gen => en_ready3_gen,
			ld_reg              => ld_reg,
			cnt_rst				=> cnt_rst,
			empty              => empty,
			eq              	=> eq,
			one_DB_data			=> one_DB_data_wire,
			contains_data		=> contains_data_wire
		);

	-- Interface_NBtoPCH_Controller
	Interface_NBtoPCH_Controller1 : ENTITY WORK.PCH_Interface_Controller
		PORT MAP
	    (
            clk                 => clk,
            rst                 => rst,
			-- PCH interface:
            ready_to_IF         => ready_to_IF,
            sop                 => sop_to_pch,
            eop                 => eop_to_pch,
			-- Controller (inside):
			pop                 => pop,
			cnt_en              => cnt_en,
			en_ready3_gen		=> en_ready3_gen,
			ld_reg              => ld_reg,
			cnt_rst				=> cnt_rst,
			empty               => empty,
			eq              => eq,
			one_DB_data			=> one_DB_data_wire,
			contains_data		=> contains_data_wire         
	    );

END Behavioral;