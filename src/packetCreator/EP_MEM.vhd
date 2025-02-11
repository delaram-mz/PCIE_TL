--******************************************************************************
--	Filename:		EP_MEM.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.900
--	History:
--	Date:			20 April 2021
--	Last Author: 	HANIEH
--  Copyright (C) 2021 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	Dual Port Memory of EndPoint                              
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
	
ENTITY EP_MEM IS
	PORT (
		clk, rst, readMEM, writeMEM : IN STD_LOGIC;
		readAddr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		writeAddr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		writeData : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		readData        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
--		rwData          : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		readyMEM        : OUT STD_LOGIC
	);
END ENTITY EP_MEM;

ARCHITECTURE behaviour OF EP_MEM IS
	TYPE data_mem IS ARRAY (0 TO 63) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL memory : data_mem;

	IMPURE FUNCTION InitFromFile 
	RETURN data_mem IS
		FILE MEMFile : TEXT OPEN read_mode IS "EP_MEM.txt";
		VARIABLE MEMFileLine : LINE;
		VARIABLE GOOD : BOOLEAN;
		VARIABLE fstatus: FILE_OPEN_STATUS;
		VARIABLE MEM : data_mem;
	BEGIN	
		READLINE(MEMFile, MEMFileLine);
		FOR I IN 0 TO 63 LOOP
			IF NOT ENDFILE(MEMFile) THEN
				READLINE(MEMFile, MEMFileLine);
				READ(MEMFileLine, MEM(I), GOOD);
	--			REPORT "Status from FILE: '" & BOOLEAN'IMAGE(GOOD) & "'";
			END IF;
		END LOOP;
		
		FILE_close(MEMFile);
		RETURN MEM;
	END FUNCTION;


BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			FOR I IN 0 TO 63 LOOP
				memory(I) <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32));
			END LOOP;
			memory <= InitFromFile;
		ELSIF clk = '1' AND clk'EVENT THEN
			IF writeMem = '1' THEN
				memory(TO_INTEGER(UNSIGNED(writeAddr))) <= writeData;
--				memory(TO_INTEGER(UNSIGNED(addr))) <= rwData;
				readyMEM <= '1';
			END IF;
			
			IF readMEM = '1' THEN
				readyMEM <= '1';
			END IF;
		END IF;
	END PROCESS;

    readData <= memory(TO_INTEGER(UNSIGNED(readAddr))) WHEN readMEM = '1' ELSE
--    rwData <= memory(TO_INTEGER(UNSIGNED(addr))) WHEN readMEM = '1' ELSE
			    (OTHERS => 'Z'); 
END ARCHITECTURE behaviour;

