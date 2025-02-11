library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity ready3_generator is

	PORT(

		-- input
        data_in                   :	IN	std_logic_vector(7 DOWNTO 0); -- FMT + Type        
        en_ready3_generator       : IN  std_logic;
		-- output
        data_out                  :	OUT	std_logic_vector(2 DOWNTO 0) -- Posted + Non-Posted + Completion  
        );
end ready3_generator;

architecture Behavioral of ready3_generator is

  signal temp : std_logic_vector(2 downto 0):= (OTHERS => '0');

begin
	
  -----------------Attention: We don't support Completion--------------------  
    process(data_in)
    begin
    case data_in is
      when "00000100" | "00000101" =>   -- Configue Read(Non-Posted)
        temp <= "010";
      when "00000010" =>                -- IO_Read(Non-Posted)
        temp <= "010";
      when "01000100" | "01000101"  =>  -- Configue Write(Non-Posted)
        temp <= "010";                   
      when "01000010" =>                -- IO_Write(Non-Posted)       
        temp <= "010";
      when "00000000" =>                -- MMIO_Read(Non - Posted)
        temp <= "010";
      when "01000000" =>                -- MMIO_Write(Posted)
        temp <= "100";         	  
      when others =>
        temp <= "000";
    end case;
  end process;

  data_out <= temp when  en_ready3_generator = '1' else 
              (OTHERS => '0');

end Behavioral;

