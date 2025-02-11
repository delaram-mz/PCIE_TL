library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ORing3 is
    Port ( a : in  STD_LOGIC;
           b : in  STD_LOGIC;
           c : in  STD_LOGIC;
           y : out STD_LOGIC);
end ORing3;

architecture Behavioral of ORing3 is
begin
    y <= a or b or c;
end Behavioral;
