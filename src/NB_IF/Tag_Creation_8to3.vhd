----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:19:36 08/15/2023 
-- Design Name: 
-- Module Name:    Tag_Creation_8to3 - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Tag_Creation_8to3 is
	Port ( 
		stats 					: in  STD_LOGIC_VECTOR (7 downto 0);
		Tag_out 					: out  STD_LOGIC_VECTOR (2 downto 0)
	);
end Tag_Creation_8to3;

architecture Behavioral of Tag_Creation_8to3 is

begin

	Tag_out <=  "000" WHEN ( stats(0) = '0' ) ELSE
					"001" WHEN ( stats(1) = '0' ) ELSE
					"010" WHEN ( stats(2) = '0' ) ELSE
					"011" WHEN ( stats(3) = '0' ) ELSE
					"100" WHEN ( stats(4) = '0' ) ELSE
					"101" WHEN ( stats(5) = '0' ) ELSE
					"110" WHEN ( stats(6) = '0' ) ELSE
					"111" WHEN ( stats(7) = '0' ) ELSE
					"000";

end Behavioral;

