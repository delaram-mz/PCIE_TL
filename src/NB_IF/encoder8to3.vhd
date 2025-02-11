-- **************************************************************************************
-- Filename: encoder8to3.vhd
-- Project: Segment_Selector
-- Version: 1.0
-- Date:
--
-- Module Name: encoder8to3
-- Description:
--
-- Dependencies:
--
-- File content description:
-- encoder for Northbridge datapath
--
-- **************************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity encoder8to3 is
  port (
    dataIn  : in  std_logic_vector(7 downto 0);
    dataOut : out std_logic_vector(2 downto 0)
  );
end entity encoder8to3;

architecture Behavioral of encoder8to3 is
  signal dcdData : std_logic_vector(2 downto 0);
begin
  process(dataIn)
  begin
    case dataIn is
      when "00000001" =>
        dcdData <= "000";
      when "00000010" =>
        dcdData <= "001";
      when "00000100" =>
        dcdData <= "010";
      when "00001000" =>
        dcdData <= "011";
      when "00010000" =>
        dcdData <= "100";
      when "00100000" =>
        dcdData <= "101";
      when "01000000" =>
        dcdData <= "110";
      when "10000000" =>
        dcdData <= "111";
      when others =>
        dcdData <= "000";
    end case;
  end process;

  dataOut <= dcdData;
end architecture Behavioral;
