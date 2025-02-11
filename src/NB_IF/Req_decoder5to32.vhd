----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:03:53 08/12/2023 
-- Design Name: 
-- Module Name:    Req_decoder5to32 - Behavioral 
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


entity Req_decoder5to32 is
  port (
    dataIn  : in  std_logic_vector(4 downto 0);
    dataOut : out std_logic_vector(31 downto 0)
  );
end entity Req_decoder5to32;

architecture Behavioral of Req_decoder5to32 is

  signal dcdData : std_logic_vector(31 downto 0);
  signal small_data : std_logic_vector(7 downto 0);
  
begin

	EightD: entity work.Req_decoder3to8
	port map (
	dataIn => dataIn(2 downto 0),
	dataOut => small_data
	);

	process(dataIn,small_data)
	begin
		dcdData <=(OTHERS =>'0');
		case dataIn(4 downto 3) is
			when "00" =>
			  dcdData <= ("000000000000000000000000" & small_data );
			when "01" =>
			  dcdData <= ("0000000000000000" & small_data & "00000000");
			when "10" =>
			  dcdData <= ("00000000" & small_data & "0000000000000000");
			when "11" =>
			  dcdData <= ( small_data & "000000000000000000000000" );  
			when others =>
			  dcdData <= "00000000000000000000000000000000";
		end case;
	end process;
  dataOut <= dcdData;
end architecture Behavioral;



