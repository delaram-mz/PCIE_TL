--*****************************************************************************/
--	Filename:		Interface_PCHtoNB_Top.vhd
--	Project:		MCI-PCH
--  Version:		1
--	History:		-
--	Date:			 2024
--	Authors:	 	Hossein
--	Fist Author:    Hossein
--	Last Author: 	
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--
--*****************************************************************************/
--	File content description:
--  Top module of the interface wich is the interface between PCH and northbridge

--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Interface_PCHtoNB_Top IS

	PORT
	(
		clk                 : IN  STD_LOGIC;
		rst                 : IN  STD_LOGIC;
		-- Northbridge interface:
		pop_receive_fifo    : IN  STD_LOGIC;
		datain_from_pch     : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		ready3         		: IN  STD_LOGIC_VECTOR(2 DOWNTO 0); --Posted , Non-Posted, Comletion
		-- PCH interface:
		dataout_to_nb       : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		ready_to_pch 	    : OUT STD_LOGIC;
		start_pch           : OUT STD_LOGIC 
	);
END Interface_PCHtoNB_Top;

ARCHITECTURE Behavioral OF Interface_PCHtoNB_Top IS

  signal  rdy3,full,push: std_logic := '0';

BEGIN
	-- Interface_NBtoPCH_DataPath
	Interface_PCHtoNB_DataPath1 : ENTITY work.Interface_PCHtoNB_DataPath
		PORT MAP
		(
			clk                => clk,
			rst                => rst,

			-- Northbridge interface:
			data_out           => datain_from_pch,
			start_pch          => start_pch,
			pop                => pop_receive_fifo,

			-- PCH interface:
			ready3             => ready3,
			data_in            => dataout_to_nb,

			-- Controller (inside):

			full               => full
			
		);

	-- Interface_PCHtoNB_Controller
	Interface_PCHtoNB_Controller1 : ENTITY work.Interface_PCHtoNB_Controller
		PORT MAP
	    (
            clk                 => clk,
            rst                 => rst,
			-- PCH interface:
			ready_to_pch        => ready_to_pch,
			-- Controller (inside):
			full                => full
	    );

END Behavioral;