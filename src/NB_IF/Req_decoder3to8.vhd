----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:19:48 08/12/2023 
-- Design Name: 
-- Module Name:    Req_decoder3to8 - Behavioral 
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

entity Req_decoder3to8 is
  port (
    dataIn  : in  std_logic_vector(2 downto 0);
    dataOut : out std_logic_vector(7 downto 0)
  );
end entity Req_decoder3to8;

architecture Behavioral of Req_decoder3to8 is
  signal dcdData : std_logic_vector(7 downto 0);
begin
  process(dataIn)
  begin
    case dataIn is
      when "000" =>
        dcdData <= "00000001";
      when "001" =>
        dcdData <= "00000010";
      when "010" =>
        dcdData <= "00000100";
      when "011" =>
        dcdData <= "00001000";
      when "100" =>
        dcdData <= "00010000";
      when "101" =>
        dcdData <= "00100000";
      when "110" =>
        dcdData <= "01000000";
      when "111" =>
        dcdData <= "10000000";		  
      when others =>
        dcdData <= "00000000";
    end case;
  end process;

  dataOut <= dcdData;
end architecture Behavioral;

