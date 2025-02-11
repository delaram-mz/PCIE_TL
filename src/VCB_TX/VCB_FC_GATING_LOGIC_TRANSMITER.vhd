--*****************************************************************************/
--	Filename:		VCB_FC_GATING_LOGIC_TRANSMITER.vhd
--	Project:		MCI-PCH
--  Version:		1.000
--	History:		-
--	Date:			27 June 2023
--	Authors:	 	Javad, Mohammad, Atefeh
--	Fist Author:    Javad
--	Last Author: 	Mohammad
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--
--*****************************************************************************/
--	File content description:

--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.Std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;

ENTITY VCB_FC_GATING_LOGIC_TRANSMITER IS 
    GENERIC (
        Field_Size : INTEGER;   -- Declare inputbit as a generic parameter
		PTLP_size  : INTEGER  
    );
PORT(
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    Incr : IN STD_LOGIC;
    Ptlp : IN STD_LOGIC_VECTOR(PTLP_size - 1 DOWNTO 0);
    Send : OUT STD_LOGIC;
    Fc_DLLPs : IN STD_LOGIC_VECTOR(Field_Size - 1  DOWNTO 0);
    ready : IN STD_LOGIC
   
);
END VCB_FC_GATING_LOGIC_TRANSMITER;

ARCHITECTURE ARCH1 OF VCB_FC_GATING_LOGIC_TRANSMITER IS
    SIGNAL CC: STD_LOGIC_VECTOR(Field_Size-1 DOWNTO 0);  -- Use the inputbit generic
    SIGNAL CR: STD_LOGIC_VECTOR(Field_Size DOWNTO 0);
    SIGNAL CL: STD_LOGIC_VECTOR(Field_Size-1 DOWNTO 0);
    SIGNAL CL_Reg_in: STD_LOGIC_VECTOR(Field_Size-1 DOWNTO 0);
    signal ptlp_int : STD_LOGIC_VECTOR(Field_Size-1 DOWNTO 0);
	SIGNAL bg :  STD_LOGIC;
    SIGNAL eq :  STD_LOGIC ;
	SIGNAL adder_Fc_DLLPsS_IN2	: STD_LOGIC_VECTOR(Field_Size-1 DOWNTO 0);
    SIGNAL CL_CR				: STD_LOGIC_VECTOR(Field_Size  DOWNTO 0);
	signal Threshold  			: STD_LOGIC_VECTOR(Field_Size-1 downto 0);
	
	
BEGIN

    CC_count: ENTITY WORK.COUNTER  
        GENERIC MAP(inputbit => Field_Size)  -- Pass the generic variable here
    PORT MAP(
        clk => clk,
        rst => rst,
        en => Incr,
        cnt_output => CC
    );

    ptlp_int <= (Field_Size-1 DOWNTO PTLP_size => '0') & Ptlp;




    Adder_PTLP: ENTITY WORK.Adder generic map(BITS => Field_Size)
    PORT MAP(
        in1 => CC,
        in2 => ptlp_int,
        Cin => '0',
        out1 => CR
    );
	
	   -- ----------------------------------------------------------------------
	-- claculate send permission (CREDITS_Limit - CREDITS_RECEIVED) mod 2^[Field Size]>= 2^[Field Size] /2 )
	
	adder_Fc_DLLPsS_IN2 <= NOT CR (Field_Size -1 DOWNTO 0) ;	
	
	-- unsigned arithmetic ( add CA with 2's complement of CR).
	-- (CR is converted in the upper line and is added with '1' using Cin in adder. So, its 2's complement is created)
	adder_Fc_DLLPsS: ENTITY WORK.Adder generic map(BITS => Field_Size)
    port map(
        in1 => CL,
        in2 => adder_Fc_DLLPsS_IN2,
        Cin => '1',
        out1 => CL_CR
    );
	
	 -- Calculate the threshold
    Threshold <= '1' & (Field_Size -2 DOWNTO 0 => '0') ;
					 

	Send_Permission: ENTITY WORK.Comparator generic map(BITS => Field_Size)
		port map(
			in1 => Threshold,
			in2 => CL_CR (Field_Size -1 DOWNTO 0),
			bg  => bg ,
			eq => eq			);
			Send <= bg OR eq;
    -- ----------------------------------------------------------------------------
 
    CL_Reg_in <= (Fc_DLLPs);
    
    CL_Reg: ENTITY WORK.GENERIC_REG  
        GENERIC MAP(N => Field_Size)  -- Adjust for the extra bit
    PORT MAP(
        clk => clk,
        rst => rst,
        ld => ready,
        reg_in => CL_Reg_in,
        reg_out => CL
    );

END ARCHITECTURE;


