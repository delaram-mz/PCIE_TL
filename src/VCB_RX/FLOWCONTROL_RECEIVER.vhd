--*****************************************************************************/
--	Filename:		FLOWCONTROL_RECEIVER.vhd
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

--*****************************************************************************/
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

ENTITY FLOWCONTROL_RECEIVER IS 
GENERIC(log2sizefifo:INTEGER:=4);
PORT(
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    
    
	
	-- Flow control ready signals:
	ready_cmp 				: OUT STD_LOGIC;
    ready_p   				: OUT STD_LOGIC;
	ready_np  				: OUT STD_LOGIC;
	
	-- Update FC DLLP (Data/Hdr flow control credits):
	-- HdrFC_cmpl				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    -- DataFC_cmpl				: OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    -- HdrFC_posted   			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    -- DataFC_posted  			: OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    -- HdrFC_np  				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    -- DataFC_np   				: OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    Fc_DLLPs_cmp 			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    Fc_DLLPs_p   			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	Fc_DLLPs_np  			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	
    -- hanshaking while receiving data from another device:
    received_data_VCBin  	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    rx_Src_rdy_cmp 			: IN STD_LOGIC;
    rx_Src_rdy_p 			: IN STD_LOGIC;
    rx_Src_rdy_np 			: IN STD_LOGIC;
    rx_VCB_rdy   			: OUT STD_LOGIC;
    rx_src_sop   			: IN STD_LOGIC;
    rx_src_eop   			: IN STD_LOGIC;
	
	-- hanshaking while sending data to upper layer:
    VCB_out  				: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    VCB_SENDrdy_cmpl 		: OUT STD_LOGIC;
    VCB_SENDrdy_P 			: OUT STD_LOGIC;
    VCB_SENDrdy_NP 			: OUT STD_LOGIC;
    dev_tl_tx_dst_rdy   	: IN STD_LOGIC;
    dev_tl_tx_src_sop   	: OUT STD_LOGIC;
    dev_tl_tx_src_eop   	: OUT STD_LOGIC;
	
	-- ready from ordering logic
    ENS1    				: IN STD_LOGIC;			-- ready from ordering logic (cmpl )
    ENS2    				: IN STD_LOGIC;			-- ready from ordering logic (posted )
    ENS3    				: IN STD_LOGIC;			-- ready from ordering logic (non-posted )
	OrderingLogic_rdy 		: IN STD_LOGIC;
	
    READY_TO_OrderingLogic 	: OUT STD_LOGIC;		-- pre-name: READY_TO_TINA
    ACK_TO_OrderingLogic 	: OUT STD_LOGIC;
    tl_tx_src_vcb_hpf 		: OUT STD_LOGIC;
    tl_tx_src_vcb_hnpf 		: OUT STD_LOGIC;
    tl_tx_src_vcb_hcmpf 	: OUT STD_LOGIC;
    tl_tx_src_vcb_hpemp 	: OUT STD_LOGIC;
    tl_tx_src_vcb_hnpemp 	: OUT STD_LOGIC;
    tl_tx_src_vcb_hcmpemp 	: OUT STD_LOGIC;
    tl_tx_src_vcb_dpemp 	: OUT STD_LOGIC;
    tl_tx_src_vcb_dnpemp 	: OUT STD_LOGIC;
    tl_tx_src_vcb_dcmpemp 	: OUT STD_LOGIC
    );
END FLOWCONTROL_RECEIVER;
    
ARCHITECTURE ARCH1 OF FLOWCONTROL_RECEIVER IS

    SIGNAL comp_top_header_ld : STD_LOGIC;
    SIGNAL comp_top_data_ld : STD_LOGIC;
    SIGNAL posted_top_header_ld : STD_LOGIC;
    SIGNAL posted_top_data_ld : STD_LOGIC;
    SIGNAL nonposted_top_header_ld : STD_LOGIC;
    SIGNAL nonposted_top_data_ld : STD_LOGIC;

    SIGNAL comp_top_header : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL comp_top_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL posted_top_header : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL posted_top_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL nonposted_top_header : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL nonposted_top_data : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL comp_header_full_from_gate : STD_LOGIC;
    SIGNAL comp_data_full_from_gate : STD_LOGIC;
    SIGNAL posted_header_full_from_gate : STD_LOGIC;
    SIGNAL posted_data_full_from_gate : STD_LOGIC;
    SIGNAL nonposted_header_full_from_gate : STD_LOGIC;
    SIGNAL nonposted_data_full_from_gate : STD_LOGIC;
    SIGNAL nonposted_header_empty_from_gate : STD_LOGIC;
    -- SIGNAL COUNTER_RST_RECIEVED_DATA : STD_LOGIC;			-- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    SIGNAL SAVE_READY_RECEIVE_from_src : STD_LOGIC;				-- pre-name: SAVE_READY_RECEIVE_DLRM
    -- SIGNAL PUSH_HEADER : STD_LOGIC;
    -- SIGNAL PUSH_DATA : STD_LOGIC;
	SIGNAL receiveDW 	: STD_LOGIC;
	-- SIGNAL rxDW_Cntrst 	: STD_LOGIC;
	SIGNAL sendDW	 	: STD_LOGIC;
	-- SIGNAL txDW_Cntrst 	: STD_LOGIC;
	
	SIGNAL co_tx_pd 	: STD_LOGIC;
	SIGNAL co_tx_npd 	: STD_LOGIC;
	SIGNAL co_tx_cmpd	: STD_LOGIC;
	
	-- increment Credit received counter of headers
	SIGNAL Incr_CR_nph : STD_LOGIC;
	SIGNAL Incr_CR_ph  : STD_LOGIC;
	SIGNAL Incr_CR_cmph: STD_LOGIC;
	
	SIGNAL Incr_CR_d_cntrl 	: STD_LOGIC;
	SIGNAL Incr_CA_d_cntrl 	: STD_LOGIC;

	SIGNAL Incr_CA_cmph: STD_LOGIC;
	SIGNAL Incr_CA_ph  : STD_LOGIC;
	SIGNAL Incr_CA_nph : STD_LOGIC;
	
	
	SIGNAL push_ch  	: STD_LOGIC;
	SIGNAL push_ph  	: STD_LOGIC;
	SIGNAL push_nh		: STD_LOGIC;
	SIGNAL push_cd  	: STD_LOGIC;
	SIGNAL push_pd  	: STD_LOGIC;
	SIGNAL push_nd	 	: STD_LOGIC;
	SIGNAL pop_ch 	 	: STD_LOGIC;
	SIGNAL pop_ph 	 	: STD_LOGIC;
	SIGNAL pop_nh 	 	: STD_LOGIC;
	SIGNAL pop_cd 	 	: STD_LOGIC;
	SIGNAL pop_pd 	 	: STD_LOGIC;
	SIGNAL pop_nd 	 	: STD_LOGIC;
	
	
    -- SIGNAL COUNTER_EN_RECEIVE_DLRM : STD_LOGIC;		-- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    SIGNAL comp_header_empty_from_gate : STD_LOGIC;
    SIGNAL posted_header_empty_from_gate : STD_LOGIC;
    SIGNAL SAVE_ENS_SIG : STD_LOGIC;
    SIGNAL COUNTER_RST_SEND_DATA : STD_LOGIC;
    SIGNAL READY_TO_send_data : STD_LOGIC;
    SIGNAL COUNTER_EN_SEND_DATA : STD_LOGIC;
    SIGNAL SEND_HEADER_OR_DATA : STD_LOGIC;
    -- SIGNAL POP_HEADER : STD_LOGIC;
    -- SIGNAL POP_DATA : STD_LOGIC;
	
	-- Choose between sending headers or data
    SIGNAL SHOW_HEADER : STD_LOGIC;
    SIGNAL SHOW_DATA : STD_LOGIC;

    SIGNAL HEADER_COUNT_TO_TRANSMIT : STD_LOGIC;
    SIGNAL HEADER_COUNT_TO_RECEIVE : STD_LOGIC;
    -- SIGNAL HEADER_COUNT_RECEIVE_bg_Comparator_COUNTER_OUT_RECEIVE_DLRM : STD_LOGIC;
    -- SIGNAL HEADER_COUNT_RECEIVE_ls_Comparator_COUNTER_OUT_RECEIVE_DLRM : STD_LOGIC;

    SIGNAL comp_top_header_ld_to_receive : STD_LOGIC;
    SIGNAL posted_top_header_ld_to_receive : STD_LOGIC;
    SIGNAL nonposted_top_header_ld_to_receive : STD_LOGIC;
    SIGNAL comp_top_header_ld_to_transmit : STD_LOGIC;
    SIGNAL posted_top_header_ld_to_transmit : STD_LOGIC;
    SIGNAL nonposted_top_header_ld_to_transmit : STD_LOGIC;

    SIGNAL TOP_HEADER_TRANSMIT_LD : STD_LOGIC;
    SIGNAL COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone : STD_LOGIC;
    -- SIGNAL COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT : STD_LOGIC;
    -- SIGNAL COUNTER_OUT_SEND_DATA_EQ_HEADER_COUNT_TRANSMIT : STD_LOGIC;
    -- SIGNAL COUNTER_OUT_SEND_DATA_ls_ONE : STD_LOGIC;    
    -- SIGNAL COUNTER_OUT_SEND_DATA_EQ_ONE : STD_LOGIC;
    -- SIGNAL COUNTER_OUT_RECEIVE_DLRM_ls_ONE : STD_LOGIC;
    -- SIGNAL COUNTER_OUT_RECEIVE_DLRM_EQ_ONE : STD_LOGIC;
    SIGNAL fullh : STD_LOGIC;
    SIGNAL fulld : STD_LOGIC;
    SIGNAL EMPTYh : STD_LOGIC;
    SIGNAL EMPTYd : STD_LOGIC;
	SIGNAL ENSEs_reg	:  STD_LOGIC_vector(2 DOWNTO 0);	-- registered ENSs

BEGIN
    
tl_tx_src_vcb_hcmpf <= NOT comp_header_empty_from_gate;
tl_tx_src_vcb_hpf <= NOT posted_header_empty_from_gate;
tl_tx_src_vcb_hnpf <= NOT nonposted_header_empty_from_gate;


tl_tx_src_vcb_hcmpemp <= NOT comp_header_full_from_gate;
tl_tx_src_vcb_hpemp <= NOT posted_header_full_from_gate;
tl_tx_src_vcb_hnpemp <= NOT nonposted_header_full_from_gate;
tl_tx_src_vcb_dcmpemp <= NOT comp_data_full_from_gate;
tl_tx_src_vcb_dpemp <= NOT posted_data_full_from_gate;
tl_tx_src_vcb_dnpemp <= NOT nonposted_data_full_from_gate;


DATAPATH_M: ENTITY WORK.VCB_DATAPATH_RECEIVER 
generic map(log2sizefifo => log2sizefifo)
port map(
    clk => clk,
    rst => rst,
    received_data_VCBin => received_data_VCBin,
    rx_Src_rdy_cmp => rx_Src_rdy_cmp,
    rx_Src_rdy_p => rx_Src_rdy_p,
    rx_Src_rdy_np => rx_Src_rdy_np,
    dev_tl_tx_dst_rdy => dev_tl_tx_dst_rdy,
    VCB_out => VCB_out,
    VCB_SENDrdy_cmpl => VCB_SENDrdy_cmpl,
    VCB_SENDrdy_P => VCB_SENDrdy_P,
    VCB_SENDrdy_NP => VCB_SENDrdy_NP,

    nonposted_header_empty_from_gate => nonposted_header_empty_from_gate,
    comp_header_empty_from_gate => comp_header_empty_from_gate,
    posted_header_empty_from_gate => posted_header_empty_from_gate,

    -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
	comp_header_full_from_gate => comp_header_full_from_gate,
    comp_data_full_from_gate => comp_data_full_from_gate,
    posted_header_full_from_gate => posted_header_full_from_gate,
    posted_data_full_from_gate => posted_data_full_from_gate,
    nonposted_header_full_from_gate => nonposted_header_full_from_gate,
    nonposted_data_full_from_gate => nonposted_data_full_from_gate,
	-- -- *********************************************************************************************************************************************************************************************************************************************************************

    -- COUNTER_EN_RECEIVE_DLRM => COUNTER_EN_RECEIVE_DLRM,		-- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    COUNTER_RST_SEND_DATA => COUNTER_RST_SEND_DATA,
    COUNTER_EN_SEND_DATA => COUNTER_EN_SEND_DATA,
    -- COUNTER_RST_RECIEVED_DATA => COUNTER_RST_RECIEVED_DATA,		-- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************

    TOP_HEADER_TRANSMIT_LD => TOP_HEADER_TRANSMIT_LD,


    -- PUSH_HEADER => PUSH_HEADER,
    -- PUSH_DATA => PUSH_DATA,
 
    receiveDW		   						=> receiveDW ,		-- enable the counter to count the number of received  DWs and so credit unit
    -- rxDW_Cntrst		   						=> rxDW_Cntrst ,		-- enable the counter to count the number of received  DWs and so credit unit
	co_tx_pd 								=> co_tx_pd 	  ,
	co_tx_npd 								=> co_tx_npd 	  ,
	co_tx_cmpd								=> co_tx_cmpd	  ,
	sendDW			   						=> sendDW	 ,		-- enable the counter to count the number of send  DWs and so credit unit
	-- txDW_Cntrst		   						=> txDW_Cntrst,		-- reset the senddDW_cntr
	-- increment Credit received counter
	Incr_CR_nph  							=> Incr_CR_nph  ,
	Incr_CR_ph   							=> Incr_CR_ph   ,
	Incr_CR_cmph 							=> Incr_CR_cmph , 
	Incr_CR_d_cntrl							=> Incr_CR_d_cntrl , 
	Incr_CA_d_cntrl							=> Incr_CA_d_cntrl , 
	Incr_CA_cmph 							=> Incr_CA_cmph ,
	Incr_CA_ph   							=> Incr_CA_ph   ,
	Incr_CA_nph  							=> Incr_CA_nph  , 
	
	-- push data/hdr from VCB:                
	push_ch 								=> push_ch  ,		-- push header to VCB
	push_ph 								=> push_ph  ,        -- push header to VCB
	push_nh									=> push_nh	 ,        -- push header to VCB	        
	push_cd 								=> push_cd  ,		-- push Data to VCB
	push_pd 								=> push_pd  ,        -- push Data to VCB
	push_nd									=> push_nd	 ,        -- push Data to VCB
											 
	-- pop data/hdr from VCB:               
	pop_ch 									=> pop_ch 	 ,		-- push header to VCB
	pop_ph 									=> pop_ph 	 ,        -- push header to VCB
	pop_nh 									=> pop_nh 	 ,        -- push header to VCB
	pop_cd 									=> pop_cd 	 ,        -- push Data to VCB
	pop_pd 									=> pop_pd 	 ,		-- push Data to VCB
	pop_nd 									=> pop_nd 	 ,        -- push Data to VCB
		

    SAVE_READY_RECEIVE_from_src => SAVE_READY_RECEIVE_from_src,
    -- POP_HEADER => POP_HEADER,
    -- POP_DATA => POP_DATA,

    SHOW_HEADER => SHOW_HEADER,
    SHOW_DATA => SHOW_DATA,

	-- ready from ordering logic		
    ENS1 => ENS1,
    ENS2 => ENS2,
    ENS3 => ENS3,
	ENSEs_reg => ENSEs_reg,
    SAVE_ENS_SIG => SAVE_ENS_SIG,
	
	-- Update FC DLLP:
	-- HdrFC_cmpl		=>  HdrFC_cmpl			  ,	
	-- DataFC_cmpl		=>  DataFC_cmpl			  ,	
	-- HdrFC_posted   	=>  HdrFC_posted   		  ,	
	-- DataFC_posted  	=>  DataFC_posted  		  ,	
	-- HdrFC_np  		=>  HdrFC_np  			  ,	
	-- DataFC_np   	=>  DataFC_np   		  ,	
	Fc_DLLPs_cmp 	=> Fc_DLLPs_cmp			  ,
    Fc_DLLPs_p   	=> Fc_DLLPs_p  			  ,
    Fc_DLLPs_np  	=> Fc_DLLPs_np 			  ,	

    READY_TO_send_data   => READY_TO_send_data,
    
    ready_cmp       => ready_cmp,
	ready_p         => ready_p,
	ready_np        => ready_np,
	
    
    -- HEADER_COUNT_RECEIVE_bg_Comparator_COUNTER_OUT_RECEIVE_DLRM => HEADER_COUNT_RECEIVE_bg_Comparator_COUNTER_OUT_RECEIVE_DLRM,		-- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    -- HEADER_COUNT_RECEIVE_ls_Comparator_COUNTER_OUT_RECEIVE_DLRM => HEADER_COUNT_RECEIVE_ls_Comparator_COUNTER_OUT_RECEIVE_DLRM,		-- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone => COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone,
    -- COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT => COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT,  -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    -- COUNTER_OUT_SEND_DATA_EQ_HEADER_COUNT_TRANSMIT => COUNTER_OUT_SEND_DATA_EQ_HEADER_COUNT_TRANSMIT,  -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    -- COUNTER_OUT_SEND_DATA_ls_ONE => COUNTER_OUT_SEND_DATA_ls_ONE,                                      -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    -- COUNTER_OUT_SEND_DATA_EQ_ONE => COUNTER_OUT_SEND_DATA_EQ_ONE,                                      -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    -- COUNTER_OUT_RECEIVE_DLRM_ls_ONE => COUNTER_OUT_RECEIVE_DLRM_ls_ONE,                                -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    -- COUNTER_OUT_RECEIVE_DLRM_EQ_ONE => COUNTER_OUT_RECEIVE_DLRM_EQ_ONE,                                -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    fullh => fullh,
    fulld => fulld,
    EMPTYh => EMPTYh,
    EMPTYd => EMPTYd
    );


CONTROLER_M: ENTITY WORK.VCB_CONTROLER_RECEIVER port map(
    clk => clk,
    rst => rst,
    rx_Src_rdy_cmp => rx_Src_rdy_cmp,
    rx_Src_rdy_p => rx_Src_rdy_p,
    rx_Src_rdy_np => rx_Src_rdy_np,
    rx_VCB_rdy => rx_VCB_rdy,
    rx_src_sop => rx_src_sop,
    rx_src_eop => rx_src_eop,
    dev_tl_tx_dst_rdy => dev_tl_tx_dst_rdy,
    dev_tl_tx_src_sop => dev_tl_tx_src_sop,
    dev_tl_tx_src_eop => dev_tl_tx_src_eop,

	nonposted_header_empty_from_gate => nonposted_header_empty_from_gate,
    comp_header_empty_from_gate => comp_header_empty_from_gate,
    posted_header_empty_from_gate => posted_header_empty_from_gate,

    -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    -- comp_header_full_from_gate => comp_header_full_from_gate,
    -- comp_data_full_from_gate => comp_data_full_from_gate,
    -- posted_header_full_from_gate => posted_header_full_from_gate,
    -- posted_data_full_from_gate => posted_data_full_from_gate,
    -- nonposted_header_full_from_gate => nonposted_header_full_from_gate,
    -- nonposted_data_full_from_gate => nonposted_data_full_from_gate,
-- -- *********************************************************************************************************************************************************************************************************************************************************************

    COUNTER_RST_SEND_DATA => COUNTER_RST_SEND_DATA,
    COUNTER_EN_SEND_DATA => COUNTER_EN_SEND_DATA,
    -- COUNTER_EN_RECEIVE_DLRM => COUNTER_EN_RECEIVE_DLRM,		-- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    -- COUNTER_RST_RECIEVED_DATA => COUNTER_RST_RECIEVED_DATA,		-- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************

    TOP_HEADER_TRANSMIT_LD => TOP_HEADER_TRANSMIT_LD,


    -- PUSH_HEADER => PUSH_HEADER,
    -- PUSH_DATA => PUSH_DATA,
	receiveDW		   						=> receiveDW 	,		-- enable the counter to count the number of received  DWs and so credit unit
	-- rxDW_Cntrst		   						=> rxDW_Cntrst 	,		-- enable the counter to count the number of received  DWs and so credit unit	
	co_tx_pd 								=> co_tx_pd 	  ,
	co_tx_npd 								=> co_tx_npd 	  ,
	co_tx_cmpd								=> co_tx_cmpd	  ,
	sendDW			   						=> sendDW	 	,		-- enable the counter to count the number of send  DWs and so credit unit
	-- txDW_Cntrst		   						=> txDW_Cntrst,		-- reset the senddDW_cntr
	-- increment Credit received counter
	Incr_CR_nph  							=> Incr_CR_nph  ,
	Incr_CR_ph   							=> Incr_CR_ph   ,
	Incr_CR_cmph 							=> Incr_CR_cmph , 
	Incr_CR_d_cntrl							=> Incr_CR_d_cntrl , 
	Incr_CA_d_cntrl							=> Incr_CA_d_cntrl , 
	Incr_CA_cmph 							=> Incr_CA_cmph ,
	Incr_CA_ph   							=> Incr_CA_ph   ,
	Incr_CA_nph  							=> Incr_CA_nph  , 
	-- push data/hdr from VCB:                
	push_ch 								=> push_ch  	,		-- push header to VCB
	push_ph 								=> push_ph  	,       -- push header to VCB
	push_nh									=> push_nh		,       -- push header to VCB        
	push_cd 								=> push_cd  	,		-- push Data to VCB
	push_pd 								=> push_pd  	,       -- push Data to VCB
	push_nd									=> push_nd	 	,       -- push Data to VCB
											 
	-- pop data/hdr from VCB:               
	pop_ch 									=> pop_ch 	 	,		-- push header to VCB
	pop_ph 									=> pop_ph 	 	,       -- push header to VCB
	pop_nh 									=> pop_nh 	 	,       -- push header to VCB
	pop_cd 									=> pop_cd 	 	,       -- push Data to VCB
	pop_pd 									=> pop_pd 	 	,		-- push Data to VCB
	pop_nd 									=> pop_nd 	 	,       -- push Data to VCB
	
    
    SAVE_READY_RECEIVE_from_src => SAVE_READY_RECEIVE_from_src,		
    -- POP_HEADER => POP_HEADER,
    -- POP_DATA => POP_DATA,
    
    SHOW_HEADER => SHOW_HEADER,
    SHOW_DATA => SHOW_DATA,

    ENS1 => ENS1,
    ENS2 => ENS2,
    ENS3 => ENS3,
	ENSEs_reg => ENSEs_reg,
    SAVE_ENS_SIG => SAVE_ENS_SIG,

    READY_TO_send_data => READY_TO_send_data,

    OrderingLogic_rdy => OrderingLogic_rdy,
    READY_TO_OrderingLogic => READY_TO_OrderingLogic,
    ACK_TO_OrderingLogic => ACK_TO_OrderingLogic,
    -- HEADER_COUNT_RECEIVE_bg_Comparator_COUNTER_OUT_RECEIVE_DLRM => HEADER_COUNT_RECEIVE_bg_Comparator_COUNTER_OUT_RECEIVE_DLRM,  -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    -- HEADER_COUNT_RECEIVE_ls_Comparator_COUNTER_OUT_RECEIVE_DLRM => HEADER_COUNT_RECEIVE_ls_Comparator_COUNTER_OUT_RECEIVE_DLRM,	-- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone => COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone,
    -- COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT => COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT, -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    -- COUNTER_OUT_SEND_DATA_EQ_HEADER_COUNT_TRANSMIT => COUNTER_OUT_SEND_DATA_EQ_HEADER_COUNT_TRANSMIT, -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    -- COUNTER_OUT_SEND_DATA_ls_ONE => COUNTER_OUT_SEND_DATA_ls_ONE,                                     -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    -- COUNTER_OUT_SEND_DATA_EQ_ONE => COUNTER_OUT_SEND_DATA_EQ_ONE,                                     -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    -- COUNTER_OUT_RECEIVE_DLRM_ls_ONE => COUNTER_OUT_RECEIVE_DLRM_ls_ONE,                               -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    -- COUNTER_OUT_RECEIVE_DLRM_EQ_ONE => COUNTER_OUT_RECEIVE_DLRM_EQ_ONE,                               -- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    fullh => fullh,                                                                                      
    fulld => fulld,
    EMPTYh => EMPTYh,
    EMPTYd => EMPTYd
);


END ARCHITECTURE;