----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:47:18 08/12/2023 
-- Design Name: 
-- Module Name:    PCH_Req_Decode - Behavioral 
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

entity PCH_Req_Decode is
	Port ( 
		Header0 					: in  STD_LOGIC_VECTOR (31 downto 0);
		Len							: out STD_LOGIC_VECTOR (3 downto 0);
		is_cmpl 					: out  STD_LOGIC;
		with_data 					: out  STD_LOGIC
	);
end PCH_Req_Decode;

architecture Behavioral of PCH_Req_Decode is

begin
	is_cmpl <= '1' when ( Header0(28 downto 24) = "01010" ) else '0';
	
	with_data <= '1' when ( Header0(31 downto 29) = "010" ) else '0';
	
	Len <= Header0(3 downto 0);

end Behavioral;

