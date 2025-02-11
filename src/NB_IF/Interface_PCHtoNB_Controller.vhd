--*****************************************************************************/
--	Filename:		Interface_NBtoPCH_Controller.vhd
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
--  Controller of interface module wich is the interface between PCH and northbridge
--  
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Interface_PCHtoNB_Controller IS

	PORT (
		clk : IN Std_logic;
		rst : IN Std_logic;
		-- PCH interface:
		ready_to_pch : OUT Std_logic;
		-- Controller (inside):
		full : IN Std_logic
	);

END Interface_PCHtoNB_Controller;

ARCHITECTURE Behavioral OF Interface_PCHtoNB_Controller IS

	TYPE state IS (wait_full, push_data);
	SIGNAL pstate, nstate : state := wait_full;

BEGIN

	PROCESS (clk, rst)

	BEGIN
		IF (rst = '1') THEN
			pstate <= wait_full;
		ELSIF (clk = '1' AND clk'EVENT) THEN
			pstate <= nstate;
		END IF;
	END PROCESS;

	PROCESS (pstate, full) BEGIN

		ready_to_pch <= '0';

		CASE pstate IS

			WHEN wait_full =>

				nstate <= wait_full;
				IF (full = '0') THEN
					nstate <= push_data;
				END IF;

			WHEN push_data =>

				ready_to_pch <= '1';
				nstate <= push_data;
				IF (full = '1') THEN
					nstate <= wait_full;
				END IF;

			WHEN OTHERS =>
				nstate <= wait_full;

		END CASE;
	END PROCESS;

END Behavioral;