--*****************************************************************************/
--	Filename:		VCB_DATAPATH_RECEIVER.vhd
--	Project:		MCI-PCH
--  Version:		1.000
--	History:		-
--	Date:			27 June 2023
--	Authors:	 	Javad, Atefeh
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
-- 64-bit address is not supported. So, 1 unit credt is equal to 3 DW (digest is not considered)

--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

ENTITY VCB_DATAPATH_RECEIVER IS 
GENERIC(log2sizefifo :INTEGER);
PORT(
    clk 									: IN STD_LOGIC;
    rst 									: IN STD_LOGIC;
    -- hanshaking while receiving data from another device:
	received_data_VCBin  					: IN STD_LOGIC_VECTOR(31 DOWNTO 0);		-- received data (pre-name: received_data_VCBin)
    rx_Src_rdy_cmp 							: IN STD_LOGIC;							-- rx_Src_rdy_cmp (while receiving data from external module or layer e.g. root complex or datalink layer)
    rx_Src_rdy_p 							: IN STD_LOGIC;							-- rx_Src_rdy_p   (while receiving data from external module or layer e.g. root complex or datalink layer)
    rx_Src_rdy_np 							: IN STD_LOGIC;							-- rx_Src_rdy_np  (while receiving data from external module or layer e.g. root complex or datalink layer)
    
	-- hanshaking while sending data to upper layer:
	VCB_out  								: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);	-- sent data	  
    VCB_SENDrdy_cmpl 						: OUT STD_LOGIC;                        -- tl_rx_src_rdy_cmp (While sending data to internal module or layer e.g. endpoint or transaction layer)
    VCB_SENDrdy_P 							: OUT STD_LOGIC;                        -- tl_rx_src_rdy_p   (While sending data to internal module or layer e.g. endpoint or transaction layer)
    VCB_SENDrdy_NP 							: OUT STD_LOGIC;                        -- tl_rx_src_rdy_np  (While sending data to internal module or layer e.g. endpoint or transaction layer)
    dev_tl_tx_dst_rdy 						: IN STD_LOGIC;    						-- destination of the packet is ready 

	nonposted_header_empty_from_gate 		: OUT STD_LOGIC;
    comp_header_empty_from_gate 	 		: OUT STD_LOGIC;
    posted_header_empty_from_gate 			: OUT STD_LOGIC;
    comp_header_full_from_gate   			: OUT STD_LOGIC;					-- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    comp_data_full_from_gate 	 			: OUT STD_LOGIC;			      -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    posted_header_full_from_gate 			: OUT STD_LOGIC;             -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    posted_data_full_from_gate 				: OUT STD_LOGIC;             -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    nonposted_header_full_from_gate 		: OUT STD_LOGIC;            -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    nonposted_data_full_from_gate 			: OUT STD_LOGIC;            -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************

	-- Update FC DLLP (data/Hdr flow control credits): 
    Fc_DLLPs_cmp 							: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);     
    Fc_DLLPs_p   							: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    Fc_DLLPs_np  							: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	-- Flow control ready signals:
	ready_cmp 								: OUT STD_LOGIC;
	ready_p   								: OUT STD_LOGIC;
	ready_np  								: OUT STD_LOGIC;
	
    
   -- count the number of received DWs
	receiveDW		   						: IN STD_LOGIC;		    -- enable the counter to count the number of received  DWs and so credit unit
 
	
	-- count the number of sent DWs
	sendDW			   						: IN STD_LOGIC;			-- enable the counter to count the number of send  DWs and so credit unit
	co_tx_pd 								: OUT STD_LOGIC;
	co_tx_npd 								: OUT STD_LOGIC;
	co_tx_cmpd								: OUT STD_LOGIC;
	
	-- increment Credit received counter for header gating logic
	Incr_CR_cmph 	 						: IN STD_LOGIC;
	Incr_CR_nph 							: IN STD_LOGIC;
	Incr_CR_ph 		   						: IN STD_LOGIC;	
	
	Incr_CR_d_cntrl  						: IN STD_LOGIC;

	-- increment Credit send counter for header gating logic
	Incr_CA_cmph 	 						: IN STD_LOGIC;
	Incr_CA_nph 							: IN STD_LOGIC;
	Incr_CA_ph 	 							: IN STD_LOGIC;
	
	Incr_CA_d_cntrl							: IN STD_LOGIC;
	
	-- push data/hdr from VCB:
	push_ch 								: IN STD_LOGIC;											-- push header to VCB
	push_ph 								: IN STD_LOGIC;     									-- push header to VCB
	push_nh									: IN STD_LOGIC;     									-- push header to VCB
	push_cd 								: IN STD_LOGIC;											-- push Data to VCB
	push_pd 								: IN STD_LOGIC;     									-- push Data to VCB
	push_nd									: IN STD_LOGIC;     									-- push Data to VCB
																									
	-- pop data/hdr to VCB:                  	                    								
	pop_ch 									: IN STD_LOGIC;											-- pop header to VCB
	pop_ph 									: IN STD_LOGIC;     									-- pop header to VCB
	pop_nh 									: IN STD_LOGIC;     									-- pop header to VCB
	pop_cd 									: IN STD_LOGIC;     									-- pop Data to VCB
	pop_pd 									: IN STD_LOGIC;											-- pop Data to VCB
	pop_nd 									: IN STD_LOGIC;     									-- pop Data to VCB
																									
    SAVE_READY_RECEIVE_from_src 			: IN STD_LOGIC;											-- pre-name: SAVE_READY_RECEIVE_DLRM
																									
	-- Choose between sending headers or data to be sent:           								
	SHOW_HEADER 							: IN STD_LOGIC;											-- send Headr
    SHOW_DATA 								: IN STD_LOGIC;											-- send Data
		
	-- From ordering logic (posted/nonposted/cmpl data transmission Permission)	
	ENS1 									: IN STD_LOGIC;											-- ready to send  Completion
    ENS2 									: IN STD_LOGIC;											-- ready to send  Posted
    ENS3 									: IN STD_LOGIC;											-- ready to send  non-posted
	ENSEs_reg								: OUT STD_LOGIC_vector(2 DOWNTO 0);						-- registered ENSs
		
    READY_TO_send_data		 				: IN STD_LOGIC;			
    TOP_HEADER_TRANSMIT_LD 					: IN STD_LOGIC;											-- load top header data into register (this used to register the Hdr1 and use its information for furthur processing)
	
	-- reset and enable signals for the counter that counts the number of transmitted data
    COUNTER_RST_SEND_DATA 					: IN STD_LOGIC;
    COUNTER_EN_SEND_DATA  					: IN STD_LOGIC;
		
    SAVE_ENS_SIG 	  						: IN STD_LOGIC;  

	
	COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone : OUT STD_LOGIC; 	-- comparison result of the number of sent DWs with Total number of DWs that should be sent

    fullh  								: OUT STD_LOGIC;
    fulld  								: OUT STD_LOGIC;
    EMPTYh 								: OUT STD_LOGIC;
    EMPTYd 								: OUT STD_LOGIC
);
END VCB_DATAPATH_RECEIVER;

ARCHITECTURE ARCH1 OF VCB_DATAPATH_RECEIVER IS
    -- SIGNAL COUNTER_OUT_RECEIVE_DLRM : STD_LOGIC_VECTOR(10 DOWNTO 0);	-- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    SIGNAL COUNTER_OUT_SEND_DATA : STD_LOGIC_VECTOR(10 DOWNTO 0);			-- number of sent DWs
    --SIGNAL HEADER_COUNT_RECEIVE : STD_LOGIC_VECTOR(2 DOWNTO 0);       -- not used
    SIGNAL HEADER_COUNT_TRANSMIT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL DATA_COUNT_TRANSMIT : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone : STD_LOGIC_VECTOR(11 DOWNTO 0);
	
	-- credit unit counter (to count number of DWs andfind when 1 credit unit is received)
 	SIGNAL CntrInint_rx_p			: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL CntrInint_rx_np 			: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL CntrInint_rx_cmp			: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL CntrInint_tx_p 			: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL CntrInint_tx_np 			: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL CntrInint_tx_cmp			: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL receivedDW_cntrst_p		: STD_LOGIC;
	SIGNAL receivedDW_cntrst_np		: STD_LOGIC;
	SIGNAL receivedDW_cntrst_cmp	: STD_LOGIC;
	SIGNAL receive_DW_cnten_cmpD	: STD_LOGIC;
	SIGNAL receive_DW_cnten_pD		: STD_LOGIC;
	SIGNAL receive_DW_cnten_npD		: STD_LOGIC;
	SIGNAL co_rx_pd  				: STD_LOGIC;					-- Cout of received DW Counter
	SIGNAL co_rx_npd 				: STD_LOGIC;					-- Cout of received DW Counter
	SIGNAL co_rx_cmpd				: STD_LOGIC;					-- Cout of received DW Counter
	SIGNAL num_rx_DW_p				: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL num_rx_DW_np				: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL num_rx_DW_cmpl			: STD_LOGIC_VECTOR(1 DOWNTO 0);
	-- credit unit counter (to count number of DWs and find when 1 credit unit is sent)
 	SIGNAL sendDW_cntrst_p			: STD_LOGIC;
	SIGNAL sendDW_cntrst_np			: STD_LOGIC;
	SIGNAL sendDW_cntrst_cmp		: STD_LOGIC;
	SIGNAL send_DW_cntr_cmpD		: STD_LOGIC;
	SIGNAL send_DW_cntr_pD			: STD_LOGIC;
	SIGNAL send_DW_cntr_npD			: STD_LOGIC;
	SIGNAL num_tx_DW_p				: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL num_tx_DW_np				: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL num_tx_DW_cmpl			: STD_LOGIC_VECTOR(1 DOWNTO 0);
	
    SIGNAL READIES:STD_LOGIC_VECTOR(2 DOWNTO 0);
    
    SIGNAL SHOW_ch : STD_LOGIC;
    SIGNAL SHOW_cd : STD_LOGIC;
    SIGNAL SHOW_ph : STD_LOGIC;
    SIGNAL SHOW_pd : STD_LOGIC;
    SIGNAL SHOW_nh : STD_LOGIC;
    SIGNAL SHOW_nd : STD_LOGIC;

    --SIGNAL ERR_cmph : STD_LOGIC;   -- not used
    --SIGNAL ERR_cmpd : STD_LOGIC;   -- not used
    --SIGNAL ERR_ph : STD_LOGIC;     -- not used
    --SIGNAL ERR_pd : STD_LOGIC;     -- not used
    --SIGNAL ERR_nph : STD_LOGIC;    -- not used
    --SIGNAL ERR_npd : STD_LOGIC;    -- not used

 
	SIGNAL Incr_CR_cmpd : STD_LOGIC;
    SIGNAL Incr_CR_pd : STD_LOGIC;
    SIGNAL Incr_CR_npd : STD_LOGIC;
 SIGNAL Incr_CA_cmpd : STD_LOGIC;
    SIGNAL Incr_CA_pd : STD_LOGIC;
    SIGNAL Incr_CA_npd : STD_LOGIC;

    SIGNAL comp_top_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL posted_top_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL nonposted_top_data : STD_LOGIC_VECTOR(31 DOWNTO 0);


    SIGNAL comp_top_header_ld_to_transmit : STD_LOGIC;
    SIGNAL posted_top_header_ld_to_transmit : STD_LOGIC;
    SIGNAL nonposted_top_header_ld_to_transmit : STD_LOGIC;
    
    SIGNAL full_comp_header : STD_LOGIC;
    SIGNAL full_posted_header : STD_LOGIC;
    SIGNAL full_nonposted_header : STD_LOGIC;
    SIGNAL full_comp_data : STD_LOGIC;
    SIGNAL full_posted_data : STD_LOGIC;
    SIGNAL full_nonposted_data : STD_LOGIC;
    SIGNAL empty_comp_data : STD_LOGIC;
    SIGNAL empty_posted_data : STD_LOGIC;
    SIGNAL empty_nonposted_data : STD_LOGIC;
    
    SIGNAL ENSES : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL dev_tl_tx_src_data_COMP_HEADER : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL dev_tl_tx_src_data_COMP_DATA : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL dev_tl_tx_src_data_POSTED_HEADER : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL dev_tl_tx_src_data_POSTED_DATA : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL dev_tl_tx_src_data_NONPOSTED_HEADER : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL dev_tl_tx_src_data_NONPOSTED_DATA : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL comp_top_header_trans : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL posted_top_header_trans : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL nonposted_top_header_trans : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL SAVED_READIES_in : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL SAVED_ENS_in : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL COUNTER_SEND_rst : STD_LOGIC;
     SIGNAL comp_header_empty_from_gate_SIG : STD_LOGIC;
    SIGNAL comp_data_empty_from_gate_SIG : STD_LOGIC;
    SIGNAL posted_header_empty_from_gate_SIG : STD_LOGIC;
    SIGNAL posted_data_empty_from_gate_SIG : STD_LOGIC;
    SIGNAL nonposted_header_empty_from_gate_SIG : STD_LOGIC;
    SIGNAL nonposted_data_empty_from_gate_SIG : STD_LOGIC;
     SIGNAL adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_in1 : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL Comparator_COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone_in1 : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL Comparator_COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT_in2 : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT_SIG : STD_LOGIC;
    SIGNAL COUNTER_OUT_SEND_DATA_EQ_HEADER_COUNT_TRANSMIT_SIG : STD_LOGIC;
    SIGNAL COUNTER_OUT_SEND_DATA_bg_HEADER_COUNT_TRANSMIT_SIG : STD_LOGIC;
    SIGNAL ZEROSIIG : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL ONESIG : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL COUNTER_EN_SEND_DATA_SIG : STD_LOGIC;
    SIGNAL HdrFC_cmpl			: STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL DataFC_cmpl			: STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL HdrFC_posted  		: STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL DataFC_posted 		: STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL HdrFC_np  			: STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL DataFC_np   			: STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL nposted_data_size : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL posted_data_size : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL comp_data_size : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_CIN : STD_LOGIC;
    SIGNAL ready_cmph : STD_LOGIC;
    SIGNAL ready_cmpd : STD_LOGIC;
    SIGNAL ready_ph : STD_LOGIC;
    SIGNAL ready_pd : STD_LOGIC;
    SIGNAL ready_nph : STD_LOGIC;
    SIGNAL ready_npd : STD_LOGIC;

    ---- Vivado -----------
    SIGNAL sig_fulld   : STD_LOGIC;
    SIGNAL sig_co_tx_pd    : STD_LOGIC;
    SIGNAL sig_co_tx_npd   : STD_LOGIC;
    SIGNAL sig_co_tx_cmpd  : STD_LOGIC;
    -----------------------

BEGIN
	
    ------ Vivado -----------
    fulld <= sig_fulld;
    co_tx_pd <= sig_co_tx_pd;
    co_tx_npd <= sig_co_tx_npd;
    co_tx_cmpd <= sig_co_tx_cmpd;
    ------------------------

	-- Flow control ready signals: 
    ready_cmp 		<= ready_cmph AND ready_cmpd;
    ready_p   		<= ready_ph   AND ready_pd;
    ready_np  		<= ready_nph  AND ready_npd;

    -- flow control credits
 
	Fc_DLLPs_cmp <= "10" & "10" & "000000" & HdrFC_cmpl   & "00" & DataFC_cmpl ;
	Fc_DLLPs_p   <= "10" & "00" & "000000" & HdrFC_posted & "00" & DataFC_posted ;
	Fc_DLLPs_np  <= "10" & "01" & "000000" & HdrFC_np     & "00" & DataFC_np ;
-- --------------------------------------------------------------

    -- empty and full signal of Data & Hdr VCBs: --------------------------------------
	EMPTYh <= comp_header_empty_from_gate_SIG WHEN (ENSES(0)='1') ELSE posted_header_empty_from_gate_SIG WHEN (ENSES(1)='1') ELSE nonposted_header_empty_from_gate_SIG;
    EMPTYd <= comp_data_empty_from_gate_SIG WHEN (ENSES(0)='1') ELSE posted_data_empty_from_gate_SIG WHEN (ENSES(1)='1') ELSE nonposted_data_empty_from_gate_SIG;
    
    fullh <= full_comp_header WHEN (rx_Src_rdy_cmp='1') ELSE full_posted_header WHEN (rx_Src_rdy_p='1') ELSE full_nonposted_header;
    -------- Vivado ------
    --fulld <= full_comp_data WHEN (rx_Src_rdy_cmp='1') ELSE full_posted_data WHEN (rx_Src_rdy_p='1') ELSE full_nonposted_data;
    sig_fulld <= full_comp_data WHEN (rx_Src_rdy_cmp='1') ELSE full_posted_data WHEN (rx_Src_rdy_p='1') ELSE full_nonposted_data;
    -----------------------
-- -------------------------------------------------------------------------
 -- ----------------------------------------------------------------------------------------
	-- *********************************************************************************************************************************************************************************************************************************************************************
	-- ** revised
	-- Increment CR when 1 credit unit data is pushed into the VCB
	
	-- count the number of pushed DW into the VCB. So, receiving 1 credit data is claculated
	-- As 64-bit address is not supported in the current version, 1 unit credit = 3DWs (digest is not considered)
	
	--posted
	receivedDW_cntr_p : ENTITY WORK.COUNTER_rst (ARCH)
    GENERIC MAP(inputbit		=>  2)
    port MAP (clk				=>  clk,
			  rst				=>  rst,
			  en 				=>  receive_DW_cnten_pD,
			  cntrrst 			=>  receivedDW_cntrst_p,
			  CntrInint			=>  CntrInint_rx_p,
			  cnt_output		=>  num_rx_DW_p);		-- DW number of received cmp header 
	
	--non-posted
	receivedDW_cntr_np : ENTITY WORK.COUNTER_rst (ARCH)
    GENERIC MAP(inputbit		=>  2)
    port MAP (clk				=>  clk,
			  rst				=>  rst,
			  en 				=>  receive_DW_cnten_npD,
			  cntrrst 			=>  receivedDW_cntrst_np,
			  CntrInint			=>  CntrInint_rx_np,
			  cnt_output		=>  num_rx_DW_np);		-- DW number of received cmp header 
	
	-- completion
	receivedDW_cntr_cmpl : ENTITY WORK.COUNTER_rst (ARCH)
    GENERIC MAP(inputbit		=>  2)
    port MAP (clk				=>  clk,
			  rst				=>  rst,
			  en 				=>  receive_DW_cnten_cmpD,
			  cntrrst 			=>  receivedDW_cntrst_cmp,
			  CntrInint			=>  CntrInint_rx_cmp,
			  cnt_output		=>  num_rx_DW_cmpl);		-- DW number of received cmp header 
			  

	receivedDW_cntrst_p   <= (  co_rx_pd  ) ;
	receivedDW_cntrst_np  <= (  co_rx_npd ) ;
	receivedDW_cntrst_cmp <= (  co_rx_cmpd) ;
	
	CntrInint_rx_p <= "01" WHEN Incr_CR_pd = '1' AND receive_DW_cnten_pD = '1' AND co_rx_pd = '1' ELSE "00";  -- In the case that the counter is for example "01" and the next packet has 3 DW data. 
	CntrInint_rx_np <= "01" WHEN Incr_CR_npd = '1' AND receive_DW_cnten_npD = '1' AND  co_rx_npd = '1' ELSE "00";  -- In the case that the counter is for example "01" and the next packet has 3 DW data. 
	CntrInint_rx_cmp <= "01" WHEN Incr_CR_cmpd = '1' AND receive_DW_cnten_cmpD = '1' AND co_rx_cmpd = '1' ELSE "00";  -- In the case that the counter is for example "01" and the next packet has 3 DW data. 
	
	co_rx_pd  <= '1' WHEN num_rx_DW_p = "11" ELSE '0';
	co_rx_npd  <= '1' WHEN num_rx_DW_np = "11" ELSE '0';
	co_rx_cmpd  <= '1' WHEN num_rx_DW_cmpl = "11" ELSE '0';
	
	Incr_CR_pd 	<= '1' WHEN   num_rx_DW_p = "11" AND    Incr_CR_d_cntrl = '1' AND READIES(1) = '1' ELSE '0';	
	Incr_CR_npd  <= '1' WHEN  num_rx_DW_np = "11" AND   Incr_CR_d_cntrl = '1' AND READIES(2) = '1' ELSE '0';
	Incr_CR_cmpd  <= '1' WHEN num_rx_DW_cmpl = "11" AND Incr_CR_d_cntrl = '1' AND READIES(0) = '1' ELSE '0';
	
	--------------- Vivado ---------------------------------
    --receive_DW_cnten_pD <= receiveDW AND READIES(1)    AND (NOT(fulld)); 
    --receive_DW_cnten_npD <= receiveDW AND READIES(2)   AND (NOT(fulld)); 
    --receive_DW_cnten_cmpD <= receiveDW  AND READIES(0) AND (NOT(fulld)); 
    receive_DW_cnten_pD <= receiveDW AND READIES(1)    AND (NOT(sig_fulld)); 
    receive_DW_cnten_npD <= receiveDW AND READIES(2)   AND (NOT(sig_fulld)); 
    receive_DW_cnten_cmpD <= receiveDW  AND READIES(0) AND (NOT(sig_fulld)); 
    --------------------------------------------------------
	 
	-- *********************************************************************************************************************************************************************************************************************************************************************
	-- ----------------------------------------------------------------------------------------
 
	-- ** revised
	-- Increment CA when 1 unit credit  data is poped  from VCB
	
	-- count the number of poped DW from  VCB. So, sending 1 credit data is claculated
	-- As 64-bit address is not supported in current version, 1 unit credit = 3DWs (digest is ignored)
	
	-- popsted credits:
	send_DW_cntr_p : ENTITY WORK.COUNTER_rst (ARCH)
    GENERIC MAP(inputbit		=>  2)
    port MAP (clk				=>  clk,
			  rst				=>  rst,
			  en 				=>  send_DW_cntr_pD,
			  cntrrst 			=>  sendDW_cntrst_p,
			  CntrInint			=>  CntrInint_tx_p,
			  cnt_output		=>  num_tx_DW_p);		-- DW number of received cmp header 
	
	-- non-popsted credits:
	send_DW_cntr_np : ENTITY WORK.COUNTER_rst (ARCH)
    GENERIC MAP(inputbit		=>  2)
    port MAP (clk				=>  clk,
			  rst				=>  rst,
			  en 				=>  send_DW_cntr_npD,
			  cntrrst 			=>  sendDW_cntrst_np,
			  CntrInint			=>  CntrInint_tx_np,
			  cnt_output		=>  num_tx_DW_np);		-- DW number of received cmp header 
	
	-- Completion credits:
	send_DW_cntr_cmp : ENTITY WORK.COUNTER_rst (ARCH)
    GENERIC MAP(inputbit		=>  2)
    port MAP (clk				=>  clk,
			  rst				=>  rst,
			  en 				=>  send_DW_cntr_cmpD,
			  cntrrst 			=>  sendDW_cntrst_cmp,
			  CntrInint			=>  CntrInint_tx_cmp,
			  cnt_output		=>  num_tx_DW_cmpl);	-- DW number of received cmp header 
	
              
    ----------------------- Vivado -----------------------------  
	--sendDW_cntrst_p <=   ( co_tx_pd  ); 		-- when rst = '1' or the counter, counts to "11", reset the counter
	--sendDW_cntrst_np <=  ( co_tx_npd ); 	-- when rst = '1' or the counter, counts to "11", reset the counter
	--sendDW_cntrst_cmp <= ( co_tx_cmpd); 		-- when rst = '1' or the counter, counts to "11", reset the counter

    sendDW_cntrst_p <=   ( sig_co_tx_pd  ); 		-- when rst = '1' or the counter, counts to "11", reset the counter
	sendDW_cntrst_np <=  ( sig_co_tx_npd ); 	-- when rst = '1' or the counter, counts to "11", reset the counter
	sendDW_cntrst_cmp <= ( sig_co_tx_cmpd); 		-- when rst = '1' or the counter, counts to "11", reset the counter

	
	--CntrInint_tx_p <= "01" WHEN Incr_CA_pd = '1' AND   send_DW_cntr_pD = '1' AND co_tx_pd = '1' ELSE "00";  -- In the case that the counter is for example "01" and the next packet has 3 DW data. 
	--CntrInint_tx_np <= "01" WHEN Incr_CA_npd = '1' AND  send_DW_cntr_npD = '1' AND  co_tx_npd = '1' ELSE "00";  -- In the case that the counter is for example "01" and the next packet has 3 DW data. 
	--CntrInint_tx_cmp <= "01" WHEN Incr_CA_cmpd = '1' AND send_DW_cntr_cmpD = '1' AND co_tx_cmpd = '1' ELSE "00";  -- In the case that the counter is for example "01" and the next packet has 3 DW data. 


	CntrInint_tx_p <= "01" WHEN Incr_CA_pd = '1' AND   send_DW_cntr_pD = '1' AND     sig_co_tx_pd = '1' ELSE "00";  -- In the case that the counter is for example "01" and the next packet has 3 DW data. 
	CntrInint_tx_np <= "01" WHEN Incr_CA_npd = '1' AND  send_DW_cntr_npD = '1' AND   sig_co_tx_npd = '1' ELSE "00";  -- In the case that the counter is for example "01" and the next packet has 3 DW data. 
	CntrInint_tx_cmp <= "01" WHEN Incr_CA_cmpd = '1' AND send_DW_cntr_cmpD = '1' AND sig_co_tx_cmpd = '1' ELSE "00";  -- In the case that the counter is for example "01" and the next packet has 3 DW data. 

	
	--co_tx_pd <= '1' WHEN num_tx_DW_p = "11" ELSE '0';
	--co_tx_npd <= '1' WHEN num_tx_DW_np = "11" ELSE '0';
	--co_tx_cmpd <= '1' WHEN num_tx_DW_cmpl = "11" ELSE '0';


    sig_co_tx_pd <= '1' WHEN num_tx_DW_p = "11" ELSE '0';
	sig_co_tx_npd <= '1' WHEN num_tx_DW_np = "11" ELSE '0';
	sig_co_tx_cmpd <= '1' WHEN num_tx_DW_cmpl = "11" ELSE '0';
    -----------------------------------------------------------

	Incr_CA_pd <= '1' WHEN num_tx_DW_p =  "11" AND     ENSES(1)= '1'   AND Incr_CA_d_cntrl = '1' ELSE '0';
	Incr_CA_npd <= '1' WHEN num_tx_DW_np =  "11" AND    ENSES(2)= '1'  AND Incr_CA_d_cntrl = '1' ELSE '0';
	Incr_CA_cmpd <= '1' WHEN num_tx_DW_cmpl = "11" AND   ENSES(0)= '1' AND Incr_CA_d_cntrl = '1' ELSE '0';
	
    send_DW_cntr_pD <= sendDW AND ENSES(1)   ; 
    send_DW_cntr_npD <= sendDW AND ENSES(2)  ; 
    send_DW_cntr_cmpD <= sendDW AND ENSES(0) ; 
	
 
   	-- *********************************************************************************************************************************************************************************************************************************************************************
	 
    -- -- select between sending headers or data to be sent: -----------------------------------
	SHOW_ch			<=(ENSES(0) AND SHOW_HEADER);
    SHOW_cd			<=(ENSES(0) AND SHOW_DATA);
    SHOW_ph			<=(ENSES(1) AND SHOW_HEADER);
    SHOW_pd			<=(ENSES(1) AND SHOW_DATA);
    SHOW_nh			<=(ENSES(2) AND SHOW_HEADER);
    SHOW_nd			<=(ENSES(2) AND SHOW_DATA);
	-- ----------------------------------------------------------------------------------------

    --HEADER_COUNT_RECEIVE  <="010";
    HEADER_COUNT_TRANSMIT <="011";
	
	-- define data size according to the information in header 1
    nposted_data_size <= ("0000000000") WHEN nonposted_top_header_trans(31 DOWNTO 30)="00" ELSE ("1111111111") WHEN nonposted_top_header_trans(9 DOWNTO 0)="0000000000" ELSE nonposted_top_header_trans(9 DOWNTO 0);		 -- When bit [31:30] is "00" means that the packet is without data. Else it has data. Now, if the length of the packet (bit [9:0] hdr1) is all '0', means the data sze is 1024. else, bits [9:0] defines the length.
    posted_data_size <= ("0000000000") WHEN posted_top_header_trans(31 DOWNTO 30)="00" ELSE ("1111111111") WHEN posted_top_header_trans(9 DOWNTO 0)="0000000000" ELSE posted_top_header_trans(9 DOWNTO 0);		             -- When bit [31:30] is "00" means that the packet is without data. Else it has data. Now, if the length of the packet (bit [9:0] hdr1) is all '0', means the data sze is 1024. else, bits [9:0] defines the length.
    comp_data_size <= ("0000000000") WHEN comp_top_header_trans(31 DOWNTO 30)="00" ELSE ("1111111111") WHEN comp_top_header_trans(9 DOWNTO 0)="0000000000" ELSE comp_top_header_trans(9 DOWNTO 0);							 -- When bit [31:30] is "00" means that the packet is without data. Else it has data. Now, if the length of the packet (bit [9:0] hdr1) is all '0', means the data sze is 1024. else, bits [9:0] defines the length.
    DATA_COUNT_TRANSMIT<=comp_data_size WHEN ENSES(0)='1' ELSE posted_data_size WHEN ENSES(1)='1' ELSE nposted_data_size;	-- length of data that should be sent
    
    VCB_SENDrdy_cmpl<= READY_TO_send_data AND ENSES(0);			-- ready to send cmpl if ordering logic determines that is  cmpl packet type's turn
    VCB_SENDrdy_P<= READY_TO_send_data AND ENSES(1);			-- ready to send posted if ordering logic determines that is  posted packet type's turn
    VCB_SENDrdy_NP<= READY_TO_send_data AND ENSES(2);			-- ready to send non-posted if ordering logic determines that is  non-posted packet type's turn

    VCB_out <= dev_tl_tx_src_data_COMP_HEADER      WHEN show_ch='1' ELSE     
						  dev_tl_tx_src_data_COMP_DATA        WHEN show_cd='1' ELSE     
						  dev_tl_tx_src_data_POSTED_HEADER    WHEN show_ph='1' ELSE
						  dev_tl_tx_src_data_POSTED_DATA      WHEN show_pd='1' ELSE
						  dev_tl_tx_src_data_NONPOSTED_HEADER WHEN show_nh='1' ELSE
						  dev_tl_tx_src_data_NONPOSTED_DATA   WHEN show_nd='1' ELSE (OTHERS=>'0');

    -- *********************************************************************************************************************************************************************************************************************************************************************
	-- -- These are needed as Ordering logic of Receiver side is just like as Transmitter side. The following signals are used in Trnasmitter side
	--    and is for telling the ordering logic that the other device that is receiver, is not full and can process new data
	--    as the following signals is not required in the receiver side, but the ordering logic needs these signals, it should be assigned to '0'
	-- *********************************************************************************************************************************************************************************************************************************************************************
	comp_header_full_from_gate   <= '0';
    comp_data_full_from_gate     <= '0';
    posted_header_full_from_gate <= '0';
    posted_data_full_from_gate   <= '0';
    nonposted_header_full_from_gate <= '0';
    nonposted_data_full_from_gate <= '0';
	-- -- *******************************************************************************************************************************************************************************************************************************************************************
	    
    comp_top_header_ld_to_transmit <= (ENSES(0) AND TOP_HEADER_TRANSMIT_LD);
    posted_top_header_ld_to_transmit <= (ENSES(1) AND TOP_HEADER_TRANSMIT_LD);
    nonposted_top_header_ld_to_transmit <= (ENSES(2) AND TOP_HEADER_TRANSMIT_LD);
    
   	-- ----------------------------------------------------------------------------------------------
	-- 6 VCBs ( cmpl hde/data , posted Hdr/data , nonposted Hdr/data):
	
    -- completion Hdr & Data VCBs:
	COMP_HEADER_ENTITY: ENTITY WORK.FIFO generic map(log2size => log2sizefifo)
    port map(
        clk 	 => clk,
        rst 	 => rst,
        Push 	 => push_ch,
        Pop 	 => pop_ch,
        data_in  => received_data_VCBin,
        data_top => dev_tl_tx_src_data_COMP_HEADER,
        full 	 => full_comp_header,
        empty	 => comp_header_empty_from_gate_SIG
    );
    comp_header_empty_from_gate <= comp_header_empty_from_gate_SIG;
    COMP_TOP_HEADER_ENTITY_TRANSMIT: ENTITY WORK.GENERIC_REG generic map(N=>32)		-- register header for extracting necessary informations such as length of data
    port map(
        clk  	=> clk,
        rst  	=> rst,
        ld 		=> comp_top_header_ld_to_transmit,
        reg_in 	=> dev_tl_tx_src_data_COMP_HEADER,
        reg_out => comp_top_header_trans
    );
    COMP_DATA_ENTITY: ENTITY WORK.FIFO generic map(log2size=>log2sizefifo)
    port map(
        clk 	 => clk,
        rst 	 => rst,
        Push 	 => push_cd,
        Pop 	 => pop_cd,
        data_in  => received_data_VCBin,
        data_top => dev_tl_tx_src_data_COMP_DATA,
        full 	 => full_comp_data,
        empty	 => comp_data_empty_from_gate_SIG
    );
	
	-- Posted Hdr & Data VCBs:
    POSTED_HEADER_ENTITY: ENTITY WORK.FIFO generic map(log2size=>log2sizefifo)
    port map(
        clk => clk,
        rst => rst,
        Push => Push_ph,
        Pop => Pop_ph,
        data_in => received_data_VCBin,
        data_top => dev_tl_tx_src_data_POSTED_HEADER,
        full => full_posted_header,
        empty => posted_header_empty_from_gate_SIG
    );
    posted_header_empty_from_gate <= posted_header_empty_from_gate_SIG;
    POSTED_TOP_HEADER_ENTITY_TRANSMIT: ENTITY WORK.GENERIC_REG generic map(N=>32)	-- register header for extracting necessary informations such as length of data
    port map(
        clk => clk,
        rst => rst,
        ld => posted_top_header_ld_to_transmit,
        reg_in => dev_tl_tx_src_data_POSTED_HEADER,
        reg_out => posted_top_header_trans
    );
    POSTED_DATA_ENTITY: ENTITY WORK.FIFO generic map(log2size=>log2sizefifo)
    port map(
        clk => clk,
        rst => rst,
        Push => Push_pd,
        Pop => Pop_pd,
        data_in => received_data_VCBin,
        data_top => dev_tl_tx_src_data_POSTED_DATA,
        full => full_posted_data,
        empty => posted_data_empty_from_gate_SIG
    );
	
	-- non-Posted Hdr & Data VCBs:
    NONPOSTED_HEADER_ENTITY: ENTITY WORK.FIFO generic map(log2size=>log2sizefifo)
    port map(
        clk => clk,
        rst => rst,
        Push => Push_nh,
        Pop => Pop_nh,
        data_in => received_data_VCBin,
        data_top => dev_tl_tx_src_data_NONPOSTED_HEADER,
        full => full_nonposted_header,
        empty => nonposted_header_empty_from_gate_SIG
    );
    nonposted_header_empty_from_gate <= nonposted_header_empty_from_gate_SIG;
    NONPOSTED_TOP_HEADER_ENTITY_TRANSMIT: ENTITY WORK.GENERIC_REG generic map(N=>32)	-- register header for extracting necessary informations such as length of data
    port map(
        clk => clk,
        rst => rst,
        ld => nonposted_top_header_ld_to_transmit,
        reg_in => dev_tl_tx_src_data_NONPOSTED_HEADER,
        reg_out => nonposted_top_header_trans
    );
    NONPOSTED_DATA_ENTITY: ENTITY WORK.FIFO generic map(log2size=>log2sizefifo)
    port map(
        clk => clk,
        rst => rst,
        Push => Push_nd,
        Pop => Pop_nd,
        data_in => received_data_VCBin,
        data_top => dev_tl_tx_src_data_NONPOSTED_DATA,
        full => full_nonposted_data,
        empty => nonposted_data_empty_from_gate_SIG
    );
	-- ----------------------------------------------------------------------------------------------

	
	-- ----------------------------------------------------------------------------------------------
	-- register readies from source of transaction (while receiving DWs) :
	SAVED_READIES_in <= (rx_Src_rdy_np & rx_Src_rdy_p & rx_Src_rdy_cmp);
    SAVED_READIES: ENTITY WORK.GENERIC_REG generic map(N=>3)
    port map(
        clk => clk,
        rst => rst,
        ld => SAVE_READY_RECEIVE_from_src,
        reg_in => SAVED_READIES_in,
        reg_out => READIES
    );
	-- register readies from ordering logic (while sending DWs) :
    SAVED_ENS_in <= (ENS3,ENS2,ENS1);
    SAVED_ENS: ENTITY WORK.GENERIC_REG generic map(N=>3)
    port map(
        clk => clk,
        rst => rst,
        ld => SAVE_ENS_SIG,
        reg_in => SAVED_ENS_in,
        reg_out => ENSES
    );
	ENSEs_reg <= ENSES;
	-- ----------------------------------------------------------------------------------------------
	
	-- ------------------------------------------------------------------------------------------------------------------
	-- 6 VCB flow control CA/CR counters  ( cmpl hde/data , posted Hdr/data , nonposted Hdr/data)
    GATING_LOGIC_TRANS_cmph: ENTITY WORK.VCB_FC_GATING_LOGIC_RECEIVER 
	GENERIC MAP (Field_Size     => 8,
				 rx_Buff_size_credit   => std_logic_vector(to_unsigned((2**log2sizefifo)/3, 8)))	-- As per each 3 DW one credit consumed, and CA is of unit f credit, the buffer sze will devide to 3
	port map(
        clk 				=> clk,
        rst 				=> rst,
        Incr_CR 			=> Incr_CR_cmph,
        Incr_CA 			=> Incr_CA_cmph,
        ERR	   				=> open,
        -- ERR	   				=> ERR_cmph,
        credit 				=> HdrFC_cmpl,	
        ready 				=> ready_cmph
    );
    GATING_LOGIC_TRANS_cmpd: ENTITY WORK.VCB_FC_GATING_LOGIC_RECEIVER 
	GENERIC MAP (Field_Size     => 12,
				 rx_Buff_size_credit   => std_logic_vector(to_unsigned((2**log2sizefifo)/3, 12)) )
	port map(
        clk 				=> clk,
        rst 				=> rst,
        Incr_CR 			=> Incr_CR_cmpd,
        Incr_CA 			=> Incr_CA_cmpd,
        ERR 				=> open,
        -- ERR 				=> ERR_cmpd,
        credit  			=> DataFC_cmpl,	
        ready   			=> ready_cmpd
    );
    GATING_LOGIC_TRANS_ph: ENTITY WORK.VCB_FC_GATING_LOGIC_RECEIVER 
	GENERIC MAP (Field_Size     => 8,
				 rx_Buff_size_credit   => std_logic_vector(to_unsigned((2**log2sizefifo)/3, 8)))
	port map(
        clk 				=> clk,
        rst 				=> rst,
        Incr_CR 			=> Incr_CR_ph,
        Incr_CA    			=> Incr_CA_ph,
        -- ERR    				=> ERR_ph,
        ERR    				=> open,
        credit 				=> HdrFC_posted,	
        ready  				=> ready_ph
    );
    GATING_LOGIC_TRANS_pd: ENTITY WORK.VCB_FC_GATING_LOGIC_RECEIVER 
	GENERIC MAP (Field_Size     => 12,
				 rx_Buff_size_credit   => std_logic_vector(to_unsigned((2**log2sizefifo)/3, 12)))
	port map(
        clk 	   			=> clk,
        rst 	   			=> rst,
        Incr_CR    			=> Incr_CR_pd,
        Incr_CA 			=> Incr_CA_pd,
        --ERR    				=> ERR_pd,
        ERR    				=> open,
        credit 				=> DataFC_posted,		
        ready  				=> ready_pd
    );    
	
    GATING_LOGIC_TRANS_nph: ENTITY WORK.VCB_FC_GATING_LOGIC_RECEIVER 
	GENERIC MAP (Field_Size     => 8,
				 rx_Buff_size_credit   => std_logic_vector(to_unsigned((2**log2sizefifo)/3, 8)))
	port map(
        clk					=> clk,
        rst					=> rst,
        Incr_CR 			=> Incr_CR_nph,
        Incr_CA 			=> Incr_CA_nph,
        --ERR        			=> ERR_nph,
        ERR        			=> open,
        credit     			=> HdrFC_np,		
        ready      			=> ready_nph
    );
	
    GATING_LOGIC_TRANS_npd: ENTITY WORK.VCB_FC_GATING_LOGIC_RECEIVER
	GENERIC MAP (Field_Size     => 12,
				 rx_Buff_size_credit   => std_logic_vector(to_unsigned((2**log2sizefifo)/3, 12))
				 )
	port map(
        clk 				=> clk,
        rst 				=> rst,
        Incr_CR 			=> Incr_CR_npd,
        Incr_CA				=> Incr_CA_npd,
        ERR    				=> open,
        -- ERR    				=> ERR_npd,
        credit 				=> DataFC_np,		
        ready  				=> ready_npd
    );
	-- --------------------------------------------------------------------------------------------------------------------
    
	-- count the number of sent DWs:---------------------------
	COUNTER_SEND:ENTITY WORK.COUNTER generic map(inputbit=>11)
    port map(
        clk => clk,
        rst => COUNTER_SEND_rst,
        en => COUNTER_EN_SEND_DATA_SIG,
        cnt_output => COUNTER_OUT_SEND_DATA
    );
	COUNTER_SEND_rst <= (COUNTER_RST_SEND_DATA OR rst);
	COUNTER_EN_SEND_DATA_SIG <= COUNTER_EN_SEND_DATA AND dev_tl_tx_dst_rdy;

	-- --------------------------------------------------------
	
	-- -----------------------------------------------------------------------------------------------------------------------------------------
	-- check if the number of sent data + hdr DWs is equal to the length of data payload size(specified in hdr1 bits [9:0]) + 3DWs of hdr
	
	adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_in1(2 DOWNTO 0) <= HEADER_COUNT_TRANSMIT;		-- number of headers = 3Dws
    adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_in1(9 DOWNTO 3) <= (OTHERS=>'0');
		
		-- add the number hdrs and length of data
		adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT: ENTITY WORK.Adder generic map(BITS=>10)
		port map(
			in1 => adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_in1,		-- 3Dws
			in2 => DATA_COUNT_TRANSMIT,											-- length of data (specified in hdr1 bits [9:0])
			Cin => '0',
			out1 => HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT				-- 3Dw (Hdr) + length of data
		);
    ZEROSIIG(10 DOWNTO 0)<=(OTHERS=>'1');
    adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_CIN <= '1' WHEN (DATA_COUNT_TRANSMIT="1111111111" AND (READIES(1)='1' OR READIES(2)='1')) ELSE '0';
    
	adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone: ENTITY WORK.Adder generic map(BITS=>11)
    port map(
        in1 => HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT,
        in2 => ZEROSIIG,
        Cin => adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_CIN,
        out1 => HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone			-- Total number of DWs that should be sent - 1 : 3Dw (Hdr) + length of data - 1
    );
    
	Comparator_COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone_in1(10 DOWNTO 0) <= COUNTER_OUT_SEND_DATA;		-- number of sent DWs
    Comparator_COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone_in1(11) <= HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone(11);
    
	Comparator_COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone: ENTITY WORK.Comparator generic map(BITS=>12)
    port map(
        in1 => Comparator_COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone_in1,		-- number of sent DWs
        in2 => HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone,											-- Total number of DWs that should be sent - 1 = 3Dw (Hdr) + length of data - 1	
        eq => COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone						-- compare the number of sent DWs with Total number of DWs that should be sent
    );
	-- -----------------------------------------------------------------------------------------------------------------------------------------

END ARCHITECTURE;