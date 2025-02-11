library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity register_file is
Port ( 	  
	clk        : in  STD_LOGIC;
	rst        : in  STD_LOGIC;
	en         : in STD_LOGIC;
	rd_wr      : in STD_LOGIC;  -- ~rd
	addr       : in  STD_LOGIC_VECTOR (2 downto 0);
	data_in    : in  STD_LOGIC_VECTOR (31 downto 0);
	data_read  : out STD_LOGIC_VECTOR (31 downto 0);
	data_out0  : out STD_LOGIC_VECTOR (31 downto 0);
	data_out1  : out STD_LOGIC_VECTOR (31 downto 0);
	data_out2  : out STD_LOGIC_VECTOR (31 downto 0);
	data_out3  : out STD_LOGIC_VECTOR (31 downto 0);
	data_out4  : out STD_LOGIC_VECTOR (31 downto 0)             
	);
end register_file;

architecture Behavioral of register_file is
	type reg_file_mem is array(0 TO 4) of STD_LOGIC_VECTOR(31 downto 0);
    signal reg_file : reg_file_mem;
begin
	process(clk,rst) begin
		if (rst = '1') then
					reg_file <=(OTHERS => (OTHERS =>'0'));
		elsif (clk'event and clk = '1') then
            if(en='1') then
			    if (rd_wr = '1') then
			        reg_file(conv_integer(unsigned(addr))) <= data_in ;
			    end if;
            end if;
		end if;
	end process;

	data_read <= reg_file(conv_integer(unsigned(addr))) when (rd_wr = '0' and en ='1') else
				(OTHERS =>'Z');
					
    data_out0 <= x"00000CF8";
    data_out1 <= x"00000CFC";
    data_out2 <= reg_file(2);
    data_out3 <= reg_file(3);
	data_out4 <= reg_file(4);
				
end Behavioral;


