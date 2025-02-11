
--*****************************************************************************/
--	Filename:		VCB_FC_GATING_LOGIC_RECEIVER.vhd
--	Project:		MCI-PCH
--  Version:		2.000
--	History:		-
--	Date:			27 August 2024
--	Authors:	 	Javad , Atefeh
--	Fist Author:    Javad
--	Last Author: 	Atefeh
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--
--*****************************************************************************/
--	File content description:
--  This code is receiver part of flow control logic 
--  It will calculate DataFC/HdrFC for DLLP packet 
--*****************************************************************************/


LIBRARY IEEE;
USE IEEE.Std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;

ENTITY VCB_FC_GATING_LOGIC_RECEIVER IS 
GENERIC (Field_Size     :INTEGER;
		 rx_Buff_size_credit	:STD_LOGIC_VECTOR); 	 
PORT(
    clk 			: IN  STD_LOGIC;
    rst 			: IN  STD_LOGIC;
    Incr_CR 		: IN  STD_LOGIC;
    Incr_CA 		: IN  STD_LOGIC;
    ERR 			: OUT STD_LOGIC;
    credit			: OUT STD_LOGIC_VECTOR(Field_Size -1 DOWNTO 0);		-- pre-name: Fc_DLLPs
    ready 			: OUT STD_LOGIC										-- Receiver FC is ready when the error is not happen
);
END VCB_FC_GATING_LOGIC_RECEIVER;
ARCHITECTURE ARCH1 OF VCB_FC_GATING_LOGIC_RECEIVER IS
    SIGNAL CR					: STD_LOGIC_VECTOR(Field_Size -1 DOWNTO 0);
    SIGNAL CA					: STD_LOGIC_VECTOR(Field_Size - 1 DOWNTO 0);
    SIGNAL adder_Fc_DLLPsS_IN2	: STD_LOGIC_VECTOR(Field_Size -1 DOWNTO 0);
    SIGNAL CA_CR				: STD_LOGIC_VECTOR(Field_Size  DOWNTO 0);
	signal Threshold  			: STD_LOGIC_VECTOR(Field_Size -1 downto 0);
	SIGNAL ERROR				: STD_LOGIC;
BEGIN

    CREDIT_RCV: ENTITY WORK.COUNTER generic map(inputbit	=> Field_Size)
    port map(
        clk => clk,
        rst => rst,
        en => Incr_CR,
        cnt_output => CR
    );

	-- Credit Allocate counter ( according to p.118 spec.2, it initialized  to the buffer size and 
	-- Incremented as the Receiver Transaction Layer makes additional receive buffer space available by processing Received TLPs 
	CREDIT_ALLOC: ENTITY WORK.COUNTER_init (ARCH)
    GENERIC MAP(inputbit	=> Field_Size)
    port MAP (clk			=> clk ,
			  rst			=> rst ,
			  en			=> Incr_CA ,
			  init			=> rx_Buff_size_credit  ,
			  cnt_output	=> CA );
			  

    -- ----------------------------------------------------------------------
	-- claculate error according to p.119, spec2 (CREDITS_ALLOCATED - CREDITS_RECEIVED) mod 2[Field Size]>= 2[Field Size] /2 )
	
	adder_Fc_DLLPsS_IN2 <= NOT CR ;	
	
	-- unsigned arithmetic ( add CA with 2's complement of CR).
	-- (CR is converted in the upper line and is added with '1' using Cin in adder. So, its 2's complement is created)
	adder_Fc_DLLPsS: ENTITY WORK.Adder generic map(BITS => Field_Size)
    port map(
        in1 => CA,
        in2 => adder_Fc_DLLPsS_IN2,
        Cin => '1',
        out1 => CA_CR
    );
	
	 -- Calculate the threshold
     Threshold <= '1' & (Field_Size -2 DOWNTO 0 => '0') ;
					 

	Error_Check: ENTITY WORK.Comparator generic map(BITS => Field_Size)
		port map(
			in1 => CA_CR (Field_Size -1 DOWNTO 0),
			in2 => Threshold,
			bg  => ERROR  );
    -- ----------------------------------------------------------------------------

	credit <= CA;
	ERR <= ERROR;
    ready <= NOT ERROR;		-- Receiver FC is ready when the error is not happen

 

END ARCHITECTURE;