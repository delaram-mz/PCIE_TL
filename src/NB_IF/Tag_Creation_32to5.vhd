----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:36:30 08/15/2023 
-- Design Name: 
-- Module Name:    Tag_Creation_32to5 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Tag_Creation_32to5 is
    Port ( 
			  stats : in  STD_LOGIC_VECTOR (31 downto 0);
           Tag_out : out  STD_LOGIC_VECTOR (4 downto 0)
			  );
end Tag_Creation_32to5;

architecture Behavioral of Tag_Creation_32to5 is

	type std_logic_aot is array (0 to 3) of 
		std_logic_vector(2 downto 0);
	signal part_ot_tag : std_logic_aot; 

begin

	TAG_Generate_for : for i in 0 to 3 generate
	ThreeTagGen: entity work.Tag_Creation_8to3
		port map (
		stats => stats ( ((i+1)*8)-1 downto  (i)*8 ) ,
		Tag_out => part_ot_tag(i)
		);
	end generate TAG_Generate_for;

	Tag_out <=  ("00"&part_ot_tag(0)) WHEN ( stats(7 downto 0) /= "11111111" ) ELSE
				("01"&part_ot_tag(1)) WHEN ( stats(15 downto 8) /= "11111111" ) ELSE
				("10"&part_ot_tag(2)) WHEN ( stats(23 downto 16) /= "11111111" ) ELSE
				("11"&part_ot_tag(3)) WHEN ( stats(31 downto 24) /= "11111111" ) ELSE
				("00000");


end Behavioral;

