--******************************************************************************
--	Filename:		Config_RF.vhd
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
	
ENTITY Config_RF IS
	PORT (
		clk, rst, readRF, writeRF : IN STD_LOGIC;
		readAddr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		writeAddr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		writeData : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		readData  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

		status	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		command	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		BAR0	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		BAR1	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		BAR2	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		BAR3	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		BAR4	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		BAR5	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		capPtr	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		capID	: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		mask	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		maxPayload : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		send_error_allowed : OUT STD_LOGIC

		);
END ENTITY Config_RF;

ARCHITECTURE behaviour OF Config_RF IS

	CONSTANT PCIe_capID : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10100000"; -- correct value
	CONSTANT PM_capID : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000001"; -- correct value
	CONSTANT cfg_hdr_base : STD_LOGIC_VECTOR (9 DOWNTO 0) := "0000000000";
	CONSTANT cfg_hdr_size : INTEGER := 16;
	CONSTANT PCIe_cfg_cap_base : STD_LOGIC_VECTOR (9 DOWNTO 0) := "0100000000"; -- 256
	CONSTANT PCIe_cfg_cap_size : INTEGER := 10;
	CONSTANT PM_cfg_cap_base : STD_LOGIC_VECTOR (9 DOWNTO 0) := "0100101100"; -- 300
	CONSTANT PM_cfg_cap_size : INTEGER := 15;

	TYPE config_header IS ARRAY (0 TO cfg_hdr_size - 1) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	TYPE PCIe_config_capability IS ARRAY (0 TO PCIe_cfg_cap_size-1) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	TYPE PM_config_capability IS ARRAY (0 TO PM_cfg_cap_size-1) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL cfg_hdr : config_header;
	SIGNAL PCIe_cfg_cap : PCIe_config_capability;
	SIGNAL PM_cfg_cap : PM_config_capability;

	SIGNAL read_target_hdr : STD_LOGIC;
	SIGNAL write_target_hdr : STD_LOGIC;
	SIGNAL PCIe_read_target_cap : STD_LOGIC;
	SIGNAL PM_read_target_cap : STD_LOGIC;
	SIGNAL PCIe_write_target_cap : STD_LOGIC;
	SIGNAL PM_write_target_cap : STD_LOGIC;

	SIGNAL cap_writeAddr : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cap_readAddr : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cap_writeData : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL current_cap : STD_LOGIC_VECTOR(31 DOWNTO 0);

	IMPURE FUNCTION InitFromFile_cfg_hdr 
	RETURN config_header IS -- this is same as initial config from SW
		FILE MEMFile : TEXT OPEN read_mode IS "config_hdr.txt";
		VARIABLE MEMFileLine : LINE;
		VARIABLE GOOD : BOOLEAN;
		VARIABLE fstatus: FILE_OPEN_STATUS;
		VARIABLE MEM : config_header;
	BEGIN	
		READLINE(MEMFile, MEMFileLine);
		FOR I IN 0 TO cfg_hdr_size-1 LOOP
			IF NOT ENDFILE(MEMFile) THEN
				READLINE(MEMFile, MEMFileLine);
				READ(MEMFileLine, MEM(I), GOOD);
	--			REPORT "Status from FILE: '" & BOOLEAN'IMAGE(GOOD) & "'";
			END IF;
		END LOOP;
		FILE_close(MEMFile);
		RETURN MEM;
	END FUNCTION;

	IMPURE FUNCTION InitFromFile_PCIe_cfg_cap 
	RETURN PCIe_config_capability IS -- this is same as initial config from SW
		FILE MEMFile : TEXT OPEN read_mode IS "config_cap_PCIe.txt";
		VARIABLE MEMFileLine : LINE;
		VARIABLE GOOD : BOOLEAN;
		VARIABLE fstatus: FILE_OPEN_STATUS;
		VARIABLE MEM : PCIe_config_capability;
	BEGIN	
		READLINE(MEMFile, MEMFileLine);
		FOR I IN 0 TO PCIe_cfg_cap_size-1 LOOP
			IF NOT ENDFILE(MEMFile) THEN
				READLINE(MEMFile, MEMFileLine);
				READ(MEMFileLine, MEM(I), GOOD);
	--			REPORT "Status from FILE: '" & BOOLEAN'IMAGE(GOOD) & "'";
			END IF;
		END LOOP;
		FILE_close(MEMFile);
		RETURN MEM;
	END FUNCTION;

	IMPURE FUNCTION InitFromFile_PM_cfg_cap 
	RETURN PM_config_capability IS -- this is same as initial config from SW
		FILE MEMFile : TEXT OPEN read_mode IS "config_cap_PM.txt";
		VARIABLE MEMFileLine : LINE;
		VARIABLE GOOD : BOOLEAN;
		VARIABLE fstatus: FILE_OPEN_STATUS;
		VARIABLE MEM : PM_config_capability;
	BEGIN	
		READLINE(MEMFile, MEMFileLine);
		FOR I IN 0 TO PM_cfg_cap_size-1 LOOP
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

	cfg_hdr_address_logic: PROCESS (readAddr, writeAddr, capID) BEGIN
		IF ((readAddr >= cfg_hdr_base) AND (readAddr < std_logic_vector(to_unsigned(cfg_hdr_size-1, readAddr'length))) AND capID = "00000000") THEN
			read_target_hdr <= '1';
		ELSE
			read_target_hdr <= '0';
		END IF;
		IF ((writeAddr >= cfg_hdr_base) AND (writeAddr < std_logic_vector(to_unsigned(cfg_hdr_size-1, writeAddr'length))) AND capID = "00000000") THEN
			write_target_hdr <= '1';
		ELSE
			write_target_hdr <= '0';
		END IF;
	END PROCESS;

	cfg_cap_write_address_logic: PROCESS (capID, writeAddr) BEGIN
		cap_writeAddr <= (OTHERS=>'Z');
		current_cap <= (OTHERS=>'0');
		PCIe_write_target_cap <= '0';
		PM_write_target_cap <= '0';

		CASE (capID) IS
			WHEN PCIe_capID => --Error handling
				IF (writeRF = '1') THEN
					cap_writeAddr <=  writeAddr;
					PCIe_write_target_cap <= '1';
					current_cap <= PCIe_cfg_cap(TO_INTEGER(unsigned(writeAddr)));
				END IF;

			WHEN PM_capID => --Error handling
				IF (writeRF = '1') THEN
					cap_writeAddr <=  writeAddr;
					PM_write_target_cap <= '1';
					current_cap <= PM_cfg_cap(TO_INTEGER(unsigned(writeAddr)));
				END IF;

			WHEN "00000000" => -- SW access or access to hdr -- check address range
				IF ((writeAddr >= cfg_hdr_base) AND (writeAddr < std_logic_vector(to_unsigned(cfg_hdr_size-1, writeAddr'length))) AND capID = "00000000") THEN
					PCIe_write_target_cap <= '0';
					PM_write_target_cap <= '0';
					current_cap <= cfg_hdr(TO_INTEGER(unsigned(writeAddr)));

				ELSIF ( -- SW access to capability aread
					((writeAddr >= PCIe_cfg_cap_base) AND (writeAddr < std_logic_vector(unsigned(PCIe_cfg_cap_base) + to_unsigned(PCIe_cfg_cap_size -1, writeAddr'length))))) THEN
					PCIe_write_target_cap <= '1';
					cap_writeAddr <= std_logic_vector(unsigned(writeAddr) - unsigned(PCIe_cfg_cap_base));
					current_cap <= PCIe_cfg_cap(TO_INTEGER(unsigned(writeAddr) - unsigned(PCIe_cfg_cap_base)));

				ELSIF ( -- SW access to capability aread
					((writeAddr >= PM_cfg_cap_base) AND (writeAddr < std_logic_vector(unsigned(PM_cfg_cap_base) + to_unsigned(PM_cfg_cap_size -1, writeAddr'length))))) THEN
					PM_write_target_cap <= '1';
					cap_writeAddr <= std_logic_vector(unsigned(writeAddr) - unsigned(PM_cfg_cap_base));
					current_cap <= PM_cfg_cap(TO_INTEGER(unsigned(writeAddr) - unsigned(PM_cfg_cap_base)));
				
				ELSE
					PCIe_write_target_cap <= '0';
					PM_write_target_cap <= '0';
					current_cap <= (OTHERS=>'0');

				END IF;
			WHEN OTHERS =>
		END CASE;
	END PROCESS;

	cfg_cap_read_address_logic: PROCESS (capID, readAddr) BEGIN
		cap_readAddr <= (OTHERS=>'Z');
		PCIe_read_target_cap <= '0';
		PM_read_target_cap <= '0';

		CASE (capID) IS
			WHEN PCIe_capID => --Error handling
				IF (readRF = '1') THEN
					cap_readAddr <=  readAddr;
					PCIe_read_target_cap <= '1';
				END IF;

			WHEN PM_capID => --Error handling
				IF (readRF = '1') THEN
					cap_readAddr <=  readAddr;
					PM_read_target_cap <= '1';
				END IF;

			WHEN "00000000" => -- SW access or access to hdr -- check address range
				IF ( -- SW access to capability aread
					((readAddr >= PCIe_cfg_cap_base) AND (readAddr < std_logic_vector(unsigned(PCIe_cfg_cap_base) + to_unsigned(PCIe_cfg_cap_size -1, readAddr'length))))) THEN
					PCIe_read_target_cap <= '1';
					cap_readAddr <=  std_logic_vector(unsigned(readAddr) - unsigned(PCIe_cfg_cap_base));
				ELSIF ( -- SW access to capability aread
					((readAddr >= PM_cfg_cap_base) AND (readAddr < std_logic_vector(unsigned(PM_cfg_cap_base) + to_unsigned(PM_cfg_cap_size -1, readAddr'length))))) THEN
					PM_read_target_cap <= '1';
					cap_readAddr <=  std_logic_vector(unsigned(readAddr) - unsigned(PM_cfg_cap_base));
				ELSE
					PCIe_read_target_cap <= '0';
					PM_read_target_cap <= '0';
				END IF;
			WHEN OTHERS =>
		END CASE;
	END PROCESS;

	write_cfg_hdr: PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			FOR I IN 0 TO cfg_hdr_size-1 LOOP
				cfg_hdr(I) <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32));
			END LOOP;
			cfg_hdr <= InitFromFile_cfg_hdr;
		ELSIF clk = '1' AND clk'EVENT THEN
			IF writeRF = '1' AND write_target_hdr ='1' THEN
				cfg_hdr(TO_INTEGER(UNSIGNED(writeAddr))) <= writeData;
				-- readyMEM <= '1';
			END IF;
			
			-- IF readMEM = '1' THEN
			-- 	readyMEM <= '1';
			-- END IF;
		END IF;
	END PROCESS;

	read_process : PROCESS (readAddr, readRF, read_target_hdr, PCIe_read_target_cap, PM_read_target_cap) BEGIN
		IF (readRF = '1' AND read_target_hdr ='1') THEN
			readData <= cfg_hdr(TO_INTEGER(UNSIGNED(readAddr)));
		ELSIF (readRF = '1' AND PCIe_read_target_cap ='1') THEN
			readData <= PCIe_cfg_cap(TO_INTEGER(UNSIGNED(cap_readAddr)));
		ELSIF (readRF = '1' AND PM_read_target_cap ='1') THEN
			readData <= PM_cfg_cap(TO_INTEGER(UNSIGNED(cap_readAddr)));
		ELSE
			readData <= (OTHERS => 'Z');
		END IF;
	END PROCESS;



	cap_write_data: PROCESS (mask, writeData, writeRF, current_cap) begin
		IF (writeRF = '1') THEN
			for i in mask'range loop
				IF (mask(i) = '1') THEN
					cap_writeData(i) <= writeData(i);
				ELSE 
					cap_writeData(i) <= current_cap (i);
				END IF;
			end loop;
		ELSE
			cap_writeData <= (OTHERS => 'Z');
		END IF;
	END PROCESS;

	write_cfg_cap: PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			FOR I IN 0 TO PCIe_cfg_cap_size-1 LOOP
				PCIe_cfg_cap(I) <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32));
			END LOOP;
			FOR I IN 0 TO PCIe_cfg_cap_size-1 LOOP
				PM_cfg_cap(I) <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32));
			END LOOP;
			PCIe_cfg_cap <= InitFromFile_PCIe_cfg_cap;
			PM_cfg_cap <= InitFromFile_PM_cfg_cap;
		ELSIF clk = '1' AND clk'EVENT THEN
			IF writeRF = '1' AND PCIe_write_target_cap ='1' THEN
				PCIe_cfg_cap(TO_INTEGER(UNSIGNED(cap_writeAddr))) <= cap_writeData;
				-- readyMEM <= '1';
			END IF;

			IF writeRF = '1' AND PM_write_target_cap ='1' THEN
				CASE (cap_writeAddr) IS
					WHEN "0000000000" =>
						PM_cfg_cap(0)(31 DOWNTO 21) <= cap_writeData(31 DOWNTO 21);
						PM_cfg_cap(0)(20) <= '0';
						PM_cfg_cap(0)(19) <= '0';
						PM_cfg_cap(0)(18 DOWNTO 0) <= cap_writeData(18 DOWNTO 0);
						

					WHEN "0000000001" =>
						PM_cfg_cap(TO_INTEGER(UNSIGNED(cap_writeAddr))) <= cap_writeData;


					WHEN OTHERS =>
						PM_cfg_cap(TO_INTEGER(UNSIGNED(cap_writeAddr))) <= cap_writeData;
				END CASE;
				-- readyMEM <= '1';
			END IF;
			
			-- IF readMEM = '1' THEN
			-- 	readyMEM <= '1';
			-- END IF;
		END IF;
	END PROCESS;

	status <= cfg_hdr(1)(31 DOWNTO 16);
	command <= cfg_hdr(1)(15 DOWNTO 0);
	BAR0 <= cfg_hdr(4)(31 DOWNTO 0);
	BAR1 <= cfg_hdr(5)(31 DOWNTO 0);
	BAR2 <= cfg_hdr(6)(31 DOWNTO 0);
	BAR3 <= cfg_hdr(7)(31 DOWNTO 0);
	BAR4 <= cfg_hdr(8)(31 DOWNTO 0);
	BAR5 <= cfg_hdr(9)(31 DOWNTO 0);
	capPtr <= cfg_hdr(13)(7 DOWNTO 0);
	maxPayload <= PCIe_cfg_cap(1)(2 DOWNTO 0);
	-- custom signal generation (EH)
	send_error_allowed <= command(8) OR PCIe_cfg_cap(2)(2);


END ARCHITECTURE behaviour;

