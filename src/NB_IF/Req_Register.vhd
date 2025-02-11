----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:31:26 08/12/2023 
-- Design Name: 
-- Module Name:    Req_Register - Behavioral 
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

entity Req_Register is
    generic (
        size : positive := 4
    );
    port (
        in_p    : in  std_logic_vector(size-1 downto 0);
        ldR     : in  std_logic;
        clk     : in  std_logic;
        rst     : in  std_logic;
        out_p   : out std_logic_vector(size-1 downto 0)
    );
end entity Req_Register;

architecture Behavioral of Req_Register is
    signal Rreg : std_logic_vector(size-1 downto 0);
begin
    out_p <= Rreg;

    RREGP: process(clk, rst)
    begin
        if rst = '1' then
            Rreg <= (others => '0');
        elsif rising_edge(clk) then
            if ldR = '1' then
                Rreg <= in_p;
            end if;
        end if;
    end process RREGP;
end architecture Behavioral;

