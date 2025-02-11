--*****************************************************************************/
--  Filename:        Req_Buffer.vhd
--  Project:         MCI-PCH
--  Version:         1.000
--  History:        -
--  Date:            12 Aug 2023
--  Authors:        Soheil
--  First Author:    Soheil
--  Last Author:    Soheil
--  Copyright (C) 2022 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--
--*****************************************************************************/
--  File content description:
-- Northbridge Request Buffer

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_misc.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Req_Buffer is
   	generic (
		size_tag : positive := 5;
		size_register : positive := 11;
		depth_register : positive := 32
	);
	Port ( 
	   	clk 					: in  STD_LOGIC;
	   	rst 					: in  STD_LOGIC;		
		Requester_ID 			: in  STD_LOGIC_VECTOR (15 downto 0);
      	Tag_in 					: in  STD_LOGIC_VECTOR (size_tag-1 downto 0);
	   	DID_in 					: in  STD_LOGIC_VECTOR (7 downto 0);
	   	Shift_address_in 		: in  STD_LOGIC;
	   	defer 					: in  STD_LOGIC;
	   	write_req 				: in  STD_LOGIC;
	   	erase_req 				: in  STD_LOGIC;
	   	in_order_exist 			: out  STD_LOGIC;
	   	valid 					: out  STD_LOGIC;
	   	is_deferred 			: out  STD_LOGIC;
	   	DID_out 				: out  STD_LOGIC_VECTOR (7 downto 0);
	   	Shift_address_out 		: out  STD_LOGIC;
	   	Tag_out 				: out  STD_LOGIC_VECTOR (size_tag-1 downto 0)
	);
end Req_Buffer;

architecture Behavioral of Req_Buffer is

	signal stats 						: std_logic_vector (depth_register-1 downto 0);
	signal in_order_check 				: std_logic_vector (depth_register-1 downto 0);
	signal Reg_in 						: std_logic_vector (size_register-1 downto 0);
	signal new_tag 						: std_logic_vector (size_tag-1 downto 0);
	signal decoded_input_tag 			: std_logic_vector (depth_register-1 downto 0);
	signal decoded_new_tag 				: std_logic_vector (depth_register-1 downto 0);
	signal Reg_ld 						: std_logic_vector (depth_register-1 downto 0);
	signal data_out 					: std_logic_vector (size_register-1 downto 0);
	
	-- Register declaration
	type std_logic_aov is array (0 to depth_register-1) of 
		 std_logic_vector(size_register-1 downto 0);
	signal VReg : std_logic_aov;

begin

	-- input of Registers
	Reg_in <= ( '1' & defer & Shift_address_in & DID_in ) when ( erase_req = '0' ) 
					else ( others => '0');
	
	-- decoder 5to32s
	InputTagDecode: entity work.Req_decoder5to32
	port map (
	dataIn => Tag_in,
	dataOut => decoded_input_tag
	);
	
	NewTagDecode: entity work.Req_decoder5to32
	port map (
	dataIn => new_tag,
	dataOut => decoded_new_tag
	);	
	
	
	-- Load enable of Registers
	Reg_ld  <=  decoded_new_tag 		when (write_req='1') else 
					decoded_input_tag 	when (erase_req='1') else
					(others => '0');


	Reg_Generate_for : for i in 0 to (depth_register-1) generate
		Req_Buffer_Regs: entity work.Req_Register
		generic map ( size => size_register )
		port map (
		in_p => Reg_in,
		ldR => Reg_ld(i),
		clk => clk,
		rst => rst,
		out_p => VReg(i)
		);
	end generate Reg_Generate_for;


	Stats_Assignment_for : for i in 0 to (depth_register-1) generate
		stats(i) <= VReg(i)(size_register-1);
		in_order_check(i) <=  stats(i) and (not(VReg(i)(size_register-2)));
	end generate Stats_Assignment_for;



	FiveTagGen: entity work.Tag_Creation_32to5
	port map (
	stats => stats ,
	Tag_out => new_tag
	);
	

	data_out <= VReg ( to_integer(unsigned(Tag_in)));

	in_order_exist  <= or_reduce(in_order_check);
	valid 	<= '1' when ( data_out(size_register-1)='1' and Requester_ID=x"0000" )
					else '0';
	is_deferred  <= data_out(size_register-2);
	DID_out 	<= data_out(size_register-4 downto size_register-11);
	Shift_address_out <= data_out(size_register-3);
	Tag_out 	<= new_tag;



end Behavioral;

