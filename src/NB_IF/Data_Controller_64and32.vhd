
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:36:30 08/15/2023 
-- Design Name: 
-- Module Name:    Data_Controller_64and32 - Behavioral 
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
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY Data_Controller_64and32 IS
    GENERIC (
	    cpu_data_size : positive := 64;
		bridge_data_size : positive := 32
		);
    Port ( 
        clk                         : IN STD_LOGIC;
        rst                         : in STD_LOGIC;
        datain_cpu                  : in STD_LOGIC_VECTOR (cpu_data_size-1 downto 0);
        data_from_bridge            : in STD_LOGIC_VECTOR (bridge_data_size-1 downto 0);
        sel_data_first_part         : in STD_LOGIC;
        sel_data_second_part        : in STD_LOGIC;
        sel_data_full_part          : in STD_LOGIC;
        ld_read_register            : in STD_LOGIC;

        dataout_to_cpu              : out  STD_LOGIC_VECTOR (cpu_data_size-1 downto 0);
        data_to_bridge              : out  STD_LOGIC_VECTOR (bridge_data_size-1 downto 0)
    );
END Data_Controller_64and32;

ARCHITECTURE Behavioral of Data_Controller_64and32 IS
    SIGNAL DReg : STD_LOGIC_VECTOR (bridge_data_size-1 DOWNTO 0);
BEGIN

    Data_Register: ENTITY work.Req_Register
    GENERIC MAP ( size => bridge_data_size )
    PORT MAP (
        in_p => data_from_bridge,
        ldR => ld_read_register,
        clk => clk,
        rst => rst,
        out_p => DReg
    );


	dataout_to_cpu <= ( x"00000000" & DReg )        WHEN (sel_data_first_part='1')      ELSE
			          ( DReg & x"00000000" )        WHEN (sel_data_second_part = '1')   ELSE 
			          ( data_from_bridge & DReg )   WHEN (sel_data_full_part = '1')     ELSE 
			          ( OTHERS =>'0');

	data_to_bridge <= ( datain_cpu(31 DOWNTO 0) )   WHEN (sel_data_first_part='1')      ELSE
			          ( datain_cpu(63 DOWNTO 32) )  WHEN (sel_data_second_part = '1')   ELSE 
			          ( OTHERS =>'0');


END Behavioral;

