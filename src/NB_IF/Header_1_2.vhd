--*****************************************************************************/
--  Filename:        Header_1_2.vhd
--  Project:         MCI-PCH
--  Version:         1.000
--  History:        -
--  Date:            12 Aug 2023
--  Authors:        Soheil
--  First Author:    Soheil
--  Last Author:    Soheil
--  Copyright (C) 2022 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--
--*****************************************************************************/
--  File content description:
-- Northbridge Header 1 and Header2 encoder

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity Header_1_2 is
	PORT (
		Type_in                 : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
      	Tag_in                  : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
      	Byte_Enable             : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		Address                 : IN STD_LOGIC_VECTOR (28 DOWNTO 0);
		Cnfg_Addr               : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      	shift_address           : OUT STD_LOGIC;
	   	Header2                 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
      	Header1                 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end Header_1_2;

ARCHITECTURE Behavioral OF Header_1_2 IS
    signal Header1_BE_shift 		: STD_LOGIC_VECTOR (7 DOWNTO 0);
	 signal make_shift_address 	: STD_LOGIC ;	
	 signal temp 						: STD_LOGIC	;
BEGIN
    -- suported requests : I/O read and write - Configuration(I/O) read and write - MMIO read and write

    -- Header1
    Header1(31 DOWNTO 16) <= "0000000000000000";
    Header1(15 DOWNTO 13) <= "000";
    Header1(12 DOWNTO 8) <= Tag_in;
	 
	 temp <= (Byte_Enable(7) OR Byte_Enable(6) OR Byte_Enable(5) OR Byte_Enable(4));
    make_shift_address <= temp WHEN (Byte_Enable(3 DOWNTO 0) = "0000") ELSE
                     '0'; 

    Header1_BE_shift <= ("0000" & Byte_Enable(7 DOWNTO 4)) WHEN (make_shift_address = '1') ELSE
          ("0000" & Byte_Enable(3 DOWNTO 0));

    -- Header2 and Header1 BE
	PROCESS (Type_in, Byte_Enable, Header1_BE_shift, make_shift_address, Address, Cnfg_Addr)
	BEGIN
		CASE Type_in IS
        		WHEN "00000" =>                                             -- MMIO
                		-- Header1 BE
                		Header1(7 DOWNTO 0) <= Byte_Enable;
                		-- Header2                 
				Header2(31 DOWNTO 3) <= Address;
				Header2(2 DOWNTO 0) <= "000";  
			WHEN "00010" =>                                         -- I/O request
				-- Header1 BE
               			 Header1(7 DOWNTO 0) <= Header1_BE_shift;
                		-- Header2
                		Header2(31 DOWNTO 3) <= Address;
				Header2(2) <= make_shift_address;
				Header2(1 DOWNTO 0) <= "00";        
			WHEN "00100" | "00101" =>                               -- Configuration
				-- Header1 BE
               			 Header1(7 DOWNTO 0) <= Header1_BE_shift;
                		-- Header2
               			 Header2(31 DOWNTO 16) <= Cnfg_Addr(23 DOWNTO 8);
				Header2(15 DOWNTO 8) <= "00000000";
				Header2(7 DOWNTO 2) <= Cnfg_Addr(7 DOWNTO 2);
				Header2(1 DOWNTO 0) <= "00";
			WHEN OTHERS =>
               			Header1(7 DOWNTO 0) <= "00000000";
				Header2(31 DOWNTO 0) <= x"00000000";
		END CASE;
	END PROCESS;
	
	shift_address <= make_shift_address;

end architecture Behavioral;

