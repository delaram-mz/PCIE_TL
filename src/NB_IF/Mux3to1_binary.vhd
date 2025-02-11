LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY Mux3to1_binary IS
    GENERIC(inputbit:INTEGER:=5 );
	PORT (
		in0, in1, in2     : IN STD_LOGIC_VECTOR(inputbit-1 downto 0);
		sel0, sel1, sel2  : IN STD_LOGIC;
		out_P             : OUT STD_LOGIC_VECTOR(inputbit-1 downto 0)
	);
END ENTITY Mux3to1_binary;

ARCHITECTURE behaviour OF Mux3to1_binary IS
BEGIN
	out_P <=  	in0 WHEN sel0 = '1' ELSE
			  	in1 WHEN sel1 = '1' ELSE
			  	in2 WHEN sel2 = '1' ELSE
			  	(Out_P'RANGE =>'0');
END ARCHITECTURE behaviour;
