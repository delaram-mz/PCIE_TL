--*****************************************************************************/
--	Filename:		VCB_DATAPATH_TRANSMITER.vhd
--	Project:		MCI-PCH
--  Version:		1.000
--	History:		-
--	Date:			27 June 2023
--	Authors:	 	Javad
--	Fist Author:    Javad
--	Last Author: 	Javad
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
USE IEEE.NUMERIC_STD.ALL;

ENTITY VCB_DATAPATH_TRANSMITER IS 
	GENERIC(log2sizefifo:INTEGER:=6);
	PORT(

		   --****************************************************************** inputs **********************************************************************-- 
		   -- Clock signal for synchronizing all internal operations
		clk                             : IN STD_LOGIC;

		-- Reset signal to initialize all registers and counters
		rst                             : IN STD_LOGIC;

		-- 32-bit input data to be processed and transmitted
		del_tl_tx_src_data              : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

		-- Ready signals indicating the readiness of different incoming data (non posted - posted - completion )
		del_tl_tx_src_rdy_1             : IN STD_LOGIC;
		del_tl_tx_src_rdy_2             : IN STD_LOGIC;
		del_tl_tx_src_rdy_3             : IN STD_LOGIC;

		-- Flow control data for component, posted, completion  and non-posted  types
		Fc_DLLPs_cmp                    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		Fc_DLLPs_p                      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		Fc_DLLPs_np                     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

		-- Ready signals for receiving Fc_DLLPs in gating logics 
		ready_cmp                       : IN STD_LOGIC;
		ready_p                         : IN STD_LOGIC;
		ready_np                        : IN STD_LOGIC;

		-- Control signals for pushing data into FIFOs
		PUSH_HEADER                     : IN STD_LOGIC;
		PUSH_DATA                       : IN STD_LOGIC;

		-- Signal indicating the readiness of the destination to receive data
		dev_tl_tx_dst_rdy               : IN STD_LOGIC;

		-- Control signals for popping data from FIFOs
		POP_HEADER                      : IN STD_LOGIC;
		POP_DATA                        : IN STD_LOGIC;

		-- Control signals for showing the current data in FIFOs
		SHOW_HEADER                     : IN STD_LOGIC;
		SHOW_DATA                       : IN STD_LOGIC;

		-- Enable signals to select between different data paths
		ENS1                            : IN STD_LOGIC;
		ENS2                            : IN STD_LOGIC;
		ENS3                            : IN STD_LOGIC;

		-- Signal indicating readiness to send data to the destination
		READY_TO_DLRM                   : IN STD_LOGIC;

		-- Signal to load the top header for transmission
		rst_reg					        : IN STD_LOGIC;					-- ********************************* new*************
		TOP_HEADER_TRANSMIT_LD          : IN STD_LOGIC;

		-- Control signals for resetting and enabling the internal counters
		COUNTER_RST_RECIEVED_DATA       : IN STD_LOGIC;
		COUNTER_EN_RECEIVE_DLRM         : IN STD_LOGIC;
		COUNTER_RST_SEND_DATA           : IN STD_LOGIC;
		COUNTER_EN_SEND_DATA            : IN STD_LOGIC;

		-- Signals for saving the current ready and enable states
		SAVE_READY_RECEIVE_DLRM         : IN STD_LOGIC;
		SAVE_ENS_SIG                    : IN STD_LOGIC;




		--****************************************************************** output **********************************************************************-- 

		-- 32-bit output data that has been processed and is ready for transmission
		dev_tl_tx_src_data                              : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

		-- Ready signals indicating the status of different data paths for output
		dev_tl_tx_src_rdy_1                                                             : OUT STD_LOGIC;
		dev_tl_tx_src_rdy_2                                                             : OUT STD_LOGIC;
		dev_tl_tx_src_rdy_3                                                             : OUT STD_LOGIC;

		-- Signals indicating whether the corresponding FIFO is empty
		nonposted_header_empty_from_gate                                                : OUT STD_LOGIC;
		comp_header_empty_from_gate                                                     : OUT STD_LOGIC;
		posted_header_empty_from_gate                                                   : OUT STD_LOGIC;

		-- Signals indicating whether the corresponding FIFO is full
		comp_header_full_from_gate                                                      : OUT STD_LOGIC;
		comp_data_full_from_gate                                                        : OUT STD_LOGIC;
		posted_header_full_from_gate                                                    : OUT STD_LOGIC;
		posted_data_full_from_gate                                                      : OUT STD_LOGIC;
		nonposted_header_full_from_gate                                                 : OUT STD_LOGIC;
		nonposted_data_full_from_gate                                                   : OUT STD_LOGIC;

		-- Signals to control the sending of headers and data
		Send_sig_h                                                                      : OUT STD_LOGIC;
		Send_sig_d                                                                      : OUT STD_LOGIC;

		-- Comparison and status signals for counters and data transmission
		HEADER_COUNT_RECEIVE_bg_Comparator_COUNTER_OUT_RECEIVE_DLRM                     : OUT STD_LOGIC;
		HEADER_COUNT_RECEIVE_ls_Comparator_COUNTER_OUT_RECEIVE_DLRM                     : OUT STD_LOGIC;
		COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone    : OUT STD_LOGIC;
		COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT                                  : OUT STD_LOGIC;
		--COUNTER_OUT_SEND_DATA_EQ_HEADER_COUNT_TRANSMIT                                  : OUT STD_LOGIC;   -- deleted in syntesis because it is not used 
		COUNTER_OUT_SEND_DATA_ls_ONE                                                    : OUT STD_LOGIC;
		COUNTER_OUT_SEND_DATA_EQ_ONE                                                    : OUT STD_LOGIC;
		COUNTER_OUT_RECEIVE_DLRM_ls_ONE                                                 : OUT STD_LOGIC;
		COUNTER_OUT_RECEIVE_DLRM_EQ_ONE                                                 : OUT STD_LOGIC;

		-- Signals indicating the full or empty status of the corresponding data paths
		fullh                                                                           : OUT STD_LOGIC;
		fulld                                                                           : OUT STD_LOGIC;
		EMPTYh                                                                          : OUT STD_LOGIC;
		EMPTYd                                                                          : OUT STD_LOGIC


	);
END VCB_DATAPATH_TRANSMITER;

ARCHITECTURE ARCH1 OF VCB_DATAPATH_TRANSMITER IS
    SIGNAL COUNTER_OUT_RECEIVE_DLRM : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL COUNTER_OUT_SEND_DATA : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL HEADER_COUNT_RECEIVE : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL HEADER_COUNT_TRANSMIT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL DATA_COUNT_TRANSMIT : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL READIES:STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL push_ch : STD_LOGIC;
    SIGNAL pop_ch : STD_LOGIC;
    SIGNAL push_cd : STD_LOGIC;
    SIGNAL pop_cd : STD_LOGIC;
    SIGNAL push_ph : STD_LOGIC;
    SIGNAL pop_ph : STD_LOGIC;
    SIGNAL push_pd : STD_LOGIC;
    SIGNAL pop_pd : STD_LOGIC;
    SIGNAL push_nh : STD_LOGIC;
    SIGNAL pop_nh : STD_LOGIC;
    SIGNAL push_nd : STD_LOGIC;
    SIGNAL pop_nd : STD_LOGIC;

    SIGNAL SHOW_ch : STD_LOGIC;
    SIGNAL SHOW_cd : STD_LOGIC;
    SIGNAL SHOW_ph : STD_LOGIC;
    SIGNAL SHOW_pd : STD_LOGIC;
    SIGNAL SHOW_nh : STD_LOGIC;
    SIGNAL SHOW_nd : STD_LOGIC;

    SIGNAL Send_sig_cmph : STD_LOGIC;
    SIGNAL Send_sig_cmpd : STD_LOGIC;
    SIGNAL Send_sig_ph : STD_LOGIC;
    SIGNAL Send_sig_pd : STD_LOGIC;
    SIGNAL Send_sig_nph : STD_LOGIC;
    SIGNAL Send_sig_npd : STD_LOGIC;
    
    SIGNAL Incr_cmph : STD_LOGIC;
    SIGNAL Incr_cmpd : STD_LOGIC;
    SIGNAL Incr_ph : STD_LOGIC;
    SIGNAL Incr_pd : STD_LOGIC;
    SIGNAL Incr_nph : STD_LOGIC;
    SIGNAL Incr_npd : STD_LOGIC;

    SIGNAL Ptlp_cmph : STD_LOGIC_VECTOR(2 DOWNTO 0);			    
    SIGNAL Ptlp_cmpd : STD_LOGIC_VECTOR(9 DOWNTO 0);		        
    SIGNAL Ptlp_ph : STD_LOGIC_VECTOR(2 DOWNTO 0);		            
    SIGNAL Ptlp_pd : STD_LOGIC_VECTOR(9 DOWNTO 0);		            
    SIGNAL Ptlp_nph : STD_LOGIC_VECTOR(2 DOWNTO 0);		            
    SIGNAL Ptlp_npd : STD_LOGIC_VECTOR(9 DOWNTO 0);		            

    SIGNAL comp_top_header : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL comp_top_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL posted_top_header : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL posted_top_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL nonposted_top_header : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL nonposted_top_data : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL comp_top_header_ld_to_transmit : STD_LOGIC;
    SIGNAL posted_top_header_ld_to_transmit : STD_LOGIC;
    SIGNAL nonposted_top_header_ld_to_transmit : STD_LOGIC;
    
    
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

    SIGNAL full_comp_header : STD_LOGIC;
    SIGNAL full_posted_header : STD_LOGIC;
    SIGNAL full_nonposted_header : STD_LOGIC;
    SIGNAL full_comp_data : STD_LOGIC;
    SIGNAL full_posted_data : STD_LOGIC;
    SIGNAL full_nonposted_data : STD_LOGIC;
    
    SIGNAL SAVED_READIES_reg_in : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL SAVED_ENS_reg_in : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL COUNTER_SEND_rst : STD_LOGIC;
    SIGNAL COUNTER_EN_SEND_DATA_SIG : STD_LOGIC;
    SIGNAL COUNTER_RECEIVE_rst : STD_LOGIC;
    SIGNAL comp_header_empty_from_gate_SIG : STD_LOGIC;
    SIGNAL comp_data_empty_from_gate_SIG : STD_LOGIC;
    SIGNAL posted_header_empty_from_gate_SIG : STD_LOGIC;
    SIGNAL posted_data_empty_from_gate_SIG : STD_LOGIC;
    SIGNAL nonposted_header_empty_from_gate_SIG : STD_LOGIC;
    SIGNAL nonposted_data_empty_from_gate_SIG : STD_LOGIC;
    SIGNAL Cmp_COUNTER_OUT_RECEIVE_DLRM_VS_HEADER_COUNT_RECEIVE : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_in1 : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL Comparator_COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone_in1 : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL Comparator_COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_in2 : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL HEADER_COUNT_RECEIVE_bg_Comparator_COUNTER_OUT_RECEIVE_DLRM_SIG : STD_LOGIC;
    SIGNAL HEADER_COUNT_RECEIVE_ls_Comparator_COUNTER_OUT_RECEIVE_DLRM_SIG : STD_LOGIC;
    SIGNAL HEADER_COUNT_RECEIVE_eq_Comparator_COUNTER_OUT_RECEIVE_DLRM_SIG : STD_LOGIC;
    SIGNAL COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT_SIG : STD_LOGIC;
    SIGNAL COUNTER_OUT_SEND_DATA_EQ_HEADER_COUNT_TRANSMIT_SIG : STD_LOGIC;
    SIGNAL COUNTER_OUT_SEND_DATA_bg_HEADER_COUNT_TRANSMIT_SIG : STD_LOGIC;
    SIGNAL ONE : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL MINUSONES : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL Fc_DLLPs_cmph : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Fc_DLLPs_cmpd : STD_LOGIC_VECTOR(11 DOWNTO 0);      				 
    SIGNAL Fc_DLLPs_ph : STD_LOGIC_VECTOR(7 DOWNTO 0);         				 
    SIGNAL Fc_DLLPs_pd : STD_LOGIC_VECTOR(11 DOWNTO 0);        				 
    SIGNAL Fc_DLLPs_nph : STD_LOGIC_VECTOR(7 DOWNTO 0);        				 
    SIGNAL Fc_DLLPs_npd : STD_LOGIC_VECTOR(11 DOWNTO 0);       				 
    SIGNAL nposted_data_size : STD_LOGIC_VECTOR(9 DOWNTO 0);   				 
    SIGNAL posted_data_size : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL comp_data_size : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_CIN : STD_LOGIC;
    signal out_counter_gating_cmph : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal out_counter_gating_cmpd : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal out_counter_gating_ph : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal out_counter_gating_pd : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal out_counter_gating_nph : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal out_counter_gating_npd : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal rst_int : STD_LOGIC;
    signal COUNTER_OUT_SEND_DATA_EQ_ONE_int : STD_LOGIC;
    signal COUNTER_OUT_SEND_DATA_ls_ONE_int : STD_LOGIC;
 
BEGIN

COUNTER_OUT_SEND_DATA_EQ_ONE <= COUNTER_OUT_SEND_DATA_EQ_ONE_INT ;
COUNTER_OUT_SEND_DATA_LS_ONE <= COUNTER_OUT_SEND_DATA_LS_ONE_INT ;



----- Extracting free space for header and data portions in reciever from component, posted,completion and non-posted flow control signals ----

  																					 
    Fc_DLLPs_cmph   <=  Fc_DLLPs_cmp(21 DOWNTO 14);    		     					 
    Fc_DLLPs_cmpd   <=  Fc_DLLPs_cmp(11 DOWNTO 0);     		     					 
																					 
    Fc_DLLPs_ph     <=  Fc_DLLPs_p(21 DOWNTO 14);      		     					 
    Fc_DLLPs_pd     <=  Fc_DLLPs_p(11 DOWNTO 0);       		     					 
																					 
    Fc_DLLPs_nph    <=  Fc_DLLPs_np(21 DOWNTO 14);     		     					 
    Fc_DLLPs_npd    <=  Fc_DLLPs_np(11 DOWNTO 0);      		     					 



----- Generating push signals for headers and data based on readiness and control inputs for component, posted,completion and non-posted flow control signals -----

    push_ch     <=(del_tl_tx_src_rdy_1 AND PUSH_HEADER);
    push_cd     <=(del_tl_tx_src_rdy_1 AND PUSH_DATA);

    push_ph     <=(del_tl_tx_src_rdy_2 AND PUSH_HEADER);
    push_pd     <=(del_tl_tx_src_rdy_2 AND PUSH_DATA);

    push_nh     <=(del_tl_tx_src_rdy_3 AND PUSH_HEADER);
    push_nd     <=(del_tl_tx_src_rdy_3 AND PUSH_DATA);


----- Generating pop signals for headers and data based on enable signals, pop commands, and destination readiness -----

    pop_ch      <=(ENSES(0) AND POP_HEADER AND dev_tl_tx_dst_rdy);
    pop_cd      <=(ENSES(0) AND POP_DATA AND dev_tl_tx_dst_rdy);

    pop_ph      <=(ENSES(1) AND POP_HEADER AND dev_tl_tx_dst_rdy);
    pop_pd      <=(ENSES(1) AND POP_DATA AND dev_tl_tx_dst_rdy);
    
    pop_nh      <=(ENSES(2) AND POP_HEADER AND dev_tl_tx_dst_rdy);
    pop_nd      <=(ENSES(2) AND POP_DATA AND dev_tl_tx_dst_rdy);

----- Generating show signals for headers and data to select which type of data will be issue to output -----

    SHOW_ch     <=(ENSES(0) AND SHOW_HEADER);
    SHOW_cd     <=(ENSES(0) AND SHOW_DATA);

    SHOW_ph     <=(ENSES(1) AND SHOW_HEADER);
    SHOW_pd     <=(ENSES(1) AND SHOW_DATA);

    SHOW_nh     <=(ENSES(2) AND SHOW_HEADER);
    SHOW_nd     <=(ENSES(2) AND SHOW_DATA);

----- Generating increment signals for header and data counters  to increment consumed credit in gating logic -----

    
    data3_incrementing_gating_logic_cmph : entity work.counter2bit
        port map (
            clk    => clk,       
            reset  => rst,     
            enable => pop_ch,    
            count  => out_counter_gating_cmph,     
            cout   => Incr_cmph      
        );

    
    data3_incrementing_gating_logic_cmpd : entity work.counter2bit
        port map (
            clk    => clk,       
            reset  => rst,     
            enable => pop_cd,    
            count  => out_counter_gating_cmpd,     
            cout   => Incr_cmpd      
        );

    
    data3_incrementing_gating_logic_ph : entity work.counter2bit
        port map (
            clk    => clk,       
            reset  => rst,     
            enable => pop_ph,    
            count  => out_counter_gating_ph,     
            cout   => Incr_ph      
        );
    
    
    data3_incrementing_gating_logic_pd : entity work.counter2bit
        port map (
            clk    => clk,       
            reset  => rst,     
            enable => pop_pd,    
            count  => out_counter_gating_pd,     
            cout   => Incr_pd     
        );
    

    
    data3_incrementing_gating_logic_nph : entity work.counter2bit
        port map (
            clk    => clk,       
            reset  => rst,     
            enable => pop_nh,    
            count  => out_counter_gating_nph,     
            cout   => Incr_nph  
        );

   
    data3_incrementing_gating_logic_npd : entity work.counter2bit
        port map (
            clk    => clk,       
            reset  => rst,     
            enable => pop_nd,    
            count  => out_counter_gating_npd,     
            cout   => Incr_npd  
        );



----- Generating send signals for headers and data based on selected data paths and corresponding send conditions -----

    Send_sig_h<=((ENSES(0) AND Send_sig_cmph) OR (ENSES(1) AND Send_sig_ph) OR (ENSES(2) AND Send_sig_nph));
    Send_sig_d<=((ENSES(0) AND Send_sig_cmpd) OR (ENSES(1) AND Send_sig_pd) OR (ENSES(2) AND Send_sig_npd));



----- Assigning empty and full status signals for headers and data based on selected data paths and readiness signals

    EMPTYh <=   comp_header_empty_from_gate_SIG WHEN (ENSES(0) = '1') ELSE 
                posted_header_empty_from_gate_SIG WHEN (ENSES(1) = '1') ELSE 
                nonposted_header_empty_from_gate_SIG;

    EMPTYd <=   comp_data_empty_from_gate_SIG WHEN (ENSES(0) = '1') ELSE 
                posted_data_empty_from_gate_SIG WHEN (ENSES(1) = '1') ELSE 
                nonposted_data_empty_from_gate_SIG;

    fullh  <=   full_comp_header WHEN (del_tl_tx_src_rdy_1 = '1') ELSE 
                full_posted_header WHEN (del_tl_tx_src_rdy_2 = '1') ELSE 
                full_nonposted_header;

    fulld  <=   full_comp_data WHEN (del_tl_tx_src_rdy_1 = '1') ELSE 
                full_posted_data WHEN (del_tl_tx_src_rdy_2 = '1') ELSE 
                full_nonposted_data;




--***************************************--
    HEADER_COUNT_RECEIVE<="010";
    HEADER_COUNT_TRANSMIT<="011";
--***************************************--


----- Determining data sizes based on top header values and selecting the appropriate data size for transmission -----

nposted_data_size <= "0000000000" WHEN nonposted_top_header_trans(31 DOWNTO 30) = "00" ELSE 
                     "1111111111" WHEN nonposted_top_header_trans(9 DOWNTO 0) = "0000000000" ELSE 
                     nonposted_top_header_trans(9 DOWNTO 0);

posted_data_size  <= "0000000000" WHEN posted_top_header_trans(31 DOWNTO 30) = "00" ELSE 
                     "1111111111" WHEN posted_top_header_trans(9 DOWNTO 0) = "0000000000" ELSE 
                     posted_top_header_trans(9 DOWNTO 0);

comp_data_size    <= "0000000000" WHEN comp_top_header_trans(31 DOWNTO 30) = "00" ELSE 
                     "1111111111" WHEN comp_top_header_trans(9 DOWNTO 0) = "0000000000" ELSE 
                     comp_top_header_trans(9 DOWNTO 0);

DATA_COUNT_TRANSMIT <= comp_data_size    WHEN ENSES(0) = '1' ELSE 
                       posted_data_size  WHEN ENSES(1) = '1' ELSE 
                       nposted_data_size;
 
------------------------------datacount must be dw---------------------------------------------

----- Assigning header and data counts to the appropriate portions of Ptlp signals for component, completion posted, and non-posted paths ------

 
     Ptlp_cmph   <= "001";
     Ptlp_cmpd   <= std_logic_vector(to_unsigned(to_integer(unsigned(comp_data_size)) / 3, 10)); 	 
     Ptlp_ph    <= "001";                                                                            
     Ptlp_pd     <= std_logic_vector(to_unsigned(to_integer(unsigned(posted_data_size)) / 3, 10));   
     Ptlp_nph   <= "001";                                                                            
     Ptlp_npd    <= std_logic_vector(to_unsigned(to_integer(unsigned(nposted_data_size)) / 3, 10));  
     
----- Setting readiness signals for transmission based on the selected data types -----

    dev_tl_tx_src_rdy_1 <= READY_TO_DLRM AND ENSES(0);
    dev_tl_tx_src_rdy_2 <= READY_TO_DLRM AND ENSES(1);
    dev_tl_tx_src_rdy_3 <= READY_TO_DLRM AND ENSES(2);


----- Selecting the appropriate output fifio for transmission data  based on show signals for different data paths -----

dev_tl_tx_src_data <= dev_tl_tx_src_data_COMP_HEADER      WHEN show_ch = '1' ELSE
                      dev_tl_tx_src_data_COMP_DATA        WHEN show_cd = '1' ELSE
                      dev_tl_tx_src_data_POSTED_HEADER    WHEN show_ph = '1' ELSE
                      dev_tl_tx_src_data_POSTED_DATA      WHEN show_pd = '1' ELSE
                      dev_tl_tx_src_data_NONPOSTED_HEADER WHEN show_nh = '1' ELSE
                      dev_tl_tx_src_data_NONPOSTED_DATA   WHEN show_nd = '1' ELSE 
                      (OTHERS => '0');


----- Updating  full status signals according to credit status in receiver -----

    comp_header_full_from_gate      <= NOT Send_sig_cmph;
    comp_data_full_from_gate        <= NOT Send_sig_cmpd;
    
    posted_header_full_from_gate    <= NOT Send_sig_ph;
    posted_data_full_from_gate      <= NOT Send_sig_pd;

    nonposted_header_full_from_gate <= NOT Send_sig_nph;
    nonposted_data_full_from_gate   <= NOT Send_sig_npd;


   
----- Instantiating FIFO for component headers and a register to store the top header for transmission -----

-- completion header  --

    CMP_HEADER_FIFO_ENTITY: ENTITY WORK.FIFO generic map(log2size=>log2sizefifo)
    port map(
        clk         => clk,
        rst         => rst,
        Push        => push_ch,
        Pop         => pop_ch,
        data_in     => del_tl_tx_src_data,
        data_top    => dev_tl_tx_src_data_COMP_HEADER,
        full        => full_comp_header,
        empty       => comp_header_empty_from_gate_SIG
    );
    
    rst_int <= rst OR rst_reg;     --- for synthesis 
    
    comp_header_empty_from_gate <= comp_header_empty_from_gate_SIG;
    CMP_TOP_HDR_ENTITY: ENTITY WORK.GENERIC_REG generic map(N=>32)
    port map(
        clk         => clk,
        --- rst         => rst OR rst_reg,  ----- for synthesis
        rst         => rst_int,								 
         ld          => TOP_HEADER_TRANSMIT_LD,						 
        reg_in      => dev_tl_tx_src_data_COMP_HEADER,
        reg_out     => comp_top_header_trans
    );

    -- completion data  --

    CMP_DATA_FIFO_ENTITY: ENTITY WORK.FIFO generic map(log2size=>log2sizefifo)
    port map(
        clk         => clk,
        rst         => rst,
        Push        => push_cd,
        Pop         => pop_cd,
        data_in     => del_tl_tx_src_data,
        data_top    => dev_tl_tx_src_data_COMP_DATA,
        full        => full_comp_data,
        empty       => comp_data_empty_from_gate_SIG
    );


    -- posted header --

    P_HDR_FIFO_ENTITY: ENTITY WORK.FIFO generic map(log2size=>log2sizefifo)
    port map(
        clk         => clk,
        rst         => rst,
        Push        => Push_ph,
        Pop         => Pop_ph,
        data_in     => del_tl_tx_src_data,
        data_top    => dev_tl_tx_src_data_POSTED_HEADER,
        full        => full_posted_header,
        empty       => posted_header_empty_from_gate_SIG
    );

    posted_header_empty_from_gate <= posted_header_empty_from_gate_SIG;
    P_TOP_HDR_ENTITY: ENTITY WORK.GENERIC_REG generic map(N=>32)
    port map(
        clk         => clk,
        --- rst         => rst OR rst_reg,
        rst         => rst_int,							  	 
         ld          => TOP_HEADER_TRANSMIT_LD,                    	 
        reg_in      => dev_tl_tx_src_data_POSTED_HEADER,
        reg_out     => posted_top_header_trans
    );

    -- posted data --

    P_DATA_FIFO_ENTITY: ENTITY WORK.FIFO generic map(log2size=>log2sizefifo)
    port map(
        clk         => clk,
        rst         => rst,
        Push        => Push_pd,
        Pop         => Pop_pd,
        data_in     => del_tl_tx_src_data,
        data_top    => dev_tl_tx_src_data_POSTED_DATA,
        full        => full_posted_data,
        empty       => posted_data_empty_from_gate_SIG
    );

    -- nonposted header --

    NP_HDR_FIFO_ENTITY: ENTITY WORK.FIFO generic map(log2size=>log2sizefifo)
    port map(
        clk         => clk,
        rst         => rst,
        Push        => Push_nh,
        Pop         => Pop_nh,
        data_in     => del_tl_tx_src_data,
        data_top    => dev_tl_tx_src_data_NONPOSTED_HEADER,
        full        => full_nonposted_header,
        empty       => nonposted_header_empty_from_gate_SIG
    );
    nonposted_header_empty_from_gate <= nonposted_header_empty_from_gate_SIG;
    NP_TOP_HDR_ENTITY: ENTITY WORK.GENERIC_REG generic map(N=>32)
    port map(
        clk         => clk,
        --- rst         => rst OR rst_reg,  ----- for synthesis
        rst         => rst_int,							 
         ld          => TOP_HEADER_TRANSMIT_LD,                  
        reg_in      => dev_tl_tx_src_data_NONPOSTED_HEADER,
        reg_out     => nonposted_top_header_trans
    );

    -- nonposted data --

    NP_DATA_FIFO_ENTITY: ENTITY WORK.FIFO generic map(log2size=>log2sizefifo)
    port map(
        clk         => clk,
        rst         => rst,
        Push        => Push_nd,
        Pop         => Pop_nd,
        data_in     => del_tl_tx_src_data,
        data_top    => dev_tl_tx_src_data_NONPOSTED_DATA,
        full        => full_nonposted_data,
        empty       => nonposted_data_empty_from_gate_SIG
    );


    ----- Saving the current ready signals and enable states into registers for later use -----

    SAVED_READIES_reg_in <= (del_tl_tx_src_rdy_3  &  del_tl_tx_src_rdy_2  &  del_tl_tx_src_rdy_1);
    SAVED_READIES: ENTITY WORK.GENERIC_REG generic map(N=>3)
    port map(
        clk         => clk,
        rst         => rst,
        ld          => SAVE_READY_RECEIVE_DLRM,
        reg_in      => SAVED_READIES_reg_in,
        reg_out     => READIES
    );
    SAVED_ENS_reg_in <= (ENS3,ENS2,ENS1);
    SAVED_ENS: ENTITY WORK.GENERIC_REG generic map(N=>3)
    port map(
        clk         => clk,
        rst         => rst,
        ld          => SAVE_ENS_SIG,
        reg_in      => SAVED_ENS_reg_in,
        reg_out     => ENSES
    );




    GATING_LOGIC_TRANS_cmph: ENTITY WORK.VCB_FC_GATING_LOGIC_TRANSMITER
      GENERIC MAP(
        Field_Size => 8 ,
		PTLP_size => 3
    )
    
     port map(
        clk         => clk,
        rst         => rst,
        Incr        => Incr_cmph,
        Ptlp        => Ptlp_cmph,
        Send        => Send_sig_cmph,
        Fc_DLLPs    => Fc_DLLPs_cmph,
        ready       => ready_cmp
    );
 
    ----- Instantiating the gating logic for each data type, controlling data flow based on various control signals -----


    GATING_LOGIC_TRANS_cmpd: ENTITY WORK.VCB_FC_GATING_LOGIC_TRANSMITER
     GENERIC MAP(
        Field_Size => 12,
		PTLP_size => 10
    )
    
     port map(
        clk         => clk,
        rst         => rst,
        Incr        => Incr_cmpd,
        Ptlp        => Ptlp_cmpd,
        Send        => Send_sig_cmpd,
        Fc_DLLPs    => Fc_DLLPs_cmpd,
        ready       => ready_cmp
    );
    GATING_LOGIC_TRANS_ph: ENTITY WORK.VCB_FC_GATING_LOGIC_TRANSMITER
     GENERIC MAP(
        Field_Size => 8 ,
		PTLP_size => 3
    )
    
     port map(
        clk         => clk,
        rst         => rst,
        Incr        => Incr_ph,
        Ptlp        => Ptlp_ph,
        Send        => Send_sig_ph,
        Fc_DLLPs    => Fc_DLLPs_ph,
        ready       => ready_p
    );
    GATING_LOGIC_TRANS_pd: ENTITY WORK.VCB_FC_GATING_LOGIC_TRANSMITER
     GENERIC MAP(
        Field_Size => 12 ,
		PTLP_size => 10
    )

     port map(
        clk         => clk,
        rst         => rst,
        Incr        => Incr_pd,
        Ptlp        => Ptlp_pd,
        Send        => Send_sig_pd,
        Fc_DLLPs    => Fc_DLLPs_pd,
        ready       => ready_p
    );    
    GATING_LOGIC_TRANS_nph: ENTITY WORK.VCB_FC_GATING_LOGIC_TRANSMITER
     GENERIC MAP(
        Field_Size => 8,
		PTLP_size => 3
    )
    
     port map(
        clk         => clk,
        rst         => rst,
        Incr        => Incr_nph,
        Ptlp        => Ptlp_nph,
        Send        => Send_sig_nph,
        Fc_DLLPs    => Fc_DLLPs_nph,
        ready       => ready_np
    );
    GATING_LOGIC_TRANS_npd: ENTITY WORK.VCB_FC_GATING_LOGIC_TRANSMITER
     GENERIC MAP(
        Field_Size => 12 ,
		PTLP_size => 10
    )
    
     port map(
        clk         => clk,
        rst         => rst,
        Incr        => Incr_npd,
        Ptlp        => Ptlp_npd,
        Send        => Send_sig_npd,
        Fc_DLLPs    => Fc_DLLPs_npd,
        ready       => ready_np
    );



    ----- Configuring send and receive counters with reset and enable logic for managing data flow -----

    COUNTER_SEND_rst            <= (COUNTER_RST_SEND_DATA OR rst);
    COUNTER_EN_SEND_DATA_SIG    <= COUNTER_EN_SEND_DATA AND dev_tl_tx_dst_rdy;
    COUNTER_SEND:ENTITY WORK.COUNTER generic map(inputbit=>11)
    port map(
        clk         => clk,
        rst         => COUNTER_SEND_rst,
        en          => COUNTER_EN_SEND_DATA_SIG,
        cnt_output  => COUNTER_OUT_SEND_DATA                --- indicate how many data has been sent
    );

    COUNTER_RECEIVE_rst         <= (COUNTER_RST_RECIEVED_DATA OR rst);
    COUNTER_RECEIVE:ENTITY WORK.COUNTER generic map(inputbit=>11)
    port map(
        clk         => clk,
        rst         => COUNTER_RECEIVE_rst,
        en          => COUNTER_EN_RECEIVE_DLRM,
        cnt_output  => COUNTER_OUT_RECEIVE_DLRM             --- indicate how many data has been received 
    );



    ----- Comparing header count with the receive counter to determine if the received data matches the expected headers -----


    Cmp_COUNTER_OUT_RECEIVE_DLRM_VS_HEADER_COUNT_RECEIVE(2 DOWNTO 0) <= HEADER_COUNT_RECEIVE;
    Cmp_COUNTER_OUT_RECEIVE_DLRM_VS_HEADER_COUNT_RECEIVE(10 DOWNTO 3) <= (OTHERS=>'0');

    HEADER_COUNT_RECEIVE_bg_Comparator_COUNTER_OUT_RECEIVE_DLRM <= HEADER_COUNT_RECEIVE_bg_Comparator_COUNTER_OUT_RECEIVE_DLRM_SIG;
    HEADER_COUNT_RECEIVE_ls_Comparator_COUNTER_OUT_RECEIVE_DLRM <= HEADER_COUNT_RECEIVE_ls_Comparator_COUNTER_OUT_RECEIVE_DLRM_SIG;

    Cmp_COUNTER_OUT_RECEIVE_DLRM_HEADER_COUNT_RECEIVE: ENTITY WORK.Comparator generic map(BITS=>11)
    port map(
        in1 => Cmp_COUNTER_OUT_RECEIVE_DLRM_VS_HEADER_COUNT_RECEIVE,
        in2 => COUNTER_OUT_RECEIVE_DLRM,
        bg => HEADER_COUNT_RECEIVE_bg_Comparator_COUNTER_OUT_RECEIVE_DLRM_SIG,
        eq => HEADER_COUNT_RECEIVE_eq_Comparator_COUNTER_OUT_RECEIVE_DLRM_SIG,
        ls => HEADER_COUNT_RECEIVE_ls_Comparator_COUNTER_OUT_RECEIVE_DLRM_SIG
    );



    ----- Preparing inputs for adding header and data counts with conditional carry-in based on maximum data count and readiness -----

    adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_in1(2 DOWNTO 0) <= HEADER_COUNT_TRANSMIT;
    adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_in1(9 DOWNTO 3) <= (OTHERS=>'0');

    adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_CIN <= '1' WHEN (DATA_COUNT_TRANSMIT="1111111111" AND (READIES(1)='1' OR READIES(2)='1')) ELSE '0';   
    adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT: ENTITY WORK.Adder generic map(BITS=>10)
    port map(
        in1         => adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_in1,
        in2         => DATA_COUNT_TRANSMIT,                                         -----indicate data size that will be sent to receiver 
        Cin         => adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_CIN,
        out1        => HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT                ----- The total number of ( data + header ) to be sent 
    );
 
    ----- Subtracting one from the combined header and data count by adding all ones (two's complement subtraction) -----  

    MINUSONES<=(OTHERS=>'1');
    adder_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone: ENTITY WORK.Adder generic map(BITS=>11)
    port map(
        in1 => HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT,
        in2 => MINUSONES,
        Cin => '0',
        out1 => HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone
    );


 
    ----- Comparing the send data counter with the adjusted (minus one) header and data count to check for equality -----
    ----- the number of data (minus one) that will be sent , has been compared with the number of data that has been sent -----

    Comparator_COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone_in1(10 DOWNTO 0) <= COUNTER_OUT_SEND_DATA;
    Comparator_COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone_in1(11) <= HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone(11);     
    Comparator_COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone: ENTITY WORK.Comparator generic map(BITS=>12)
    port map(
        in1 => Comparator_COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone_in1,
        in2 => HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone,                             
        eq => COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone
    );

 
    ----- Comparing the send data counter with the header transmit count to determine if the data count is less, equal, or greater -----
 
    Comparator_COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_in2(2 DOWNTO 0) <= HEADER_COUNT_TRANSMIT;
    Comparator_COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_in2(10 DOWNTO 3) <= (OTHERS=>'0');
    
    COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT <= COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT_SIG;
    Comparator_COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT: ENTITY WORK.Comparator generic map(BITS=>11)
    port map(
        in1 => COUNTER_OUT_SEND_DATA,
        in2 => Comparator_COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_in2,
        ls => COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT_SIG,
        eq => COUNTER_OUT_SEND_DATA_EQ_HEADER_COUNT_TRANSMIT_SIG,
        bg => COUNTER_OUT_SEND_DATA_bg_HEADER_COUNT_TRANSMIT_SIG
    );

 
----- Generating pop signals for headers and data based on enable signals, pop commands, and destination readiness -----

    ONE(0)<='1';
    ONE(10 DOWNTO 1)<=(OTHERS=>'0');
    Comparator_COUNTER_OUT_SEND_DATA_ls_ONE: ENTITY WORK.Comparator generic map(BITS=>11)
    port map(
        in1 => COUNTER_OUT_SEND_DATA,
        in2 => ONE,
        ls => COUNTER_OUT_SEND_DATA_ls_ONE_INT,
        eq => COUNTER_OUT_SEND_DATA_EQ_ONE_INT
    );
    Comparator_COUNTER_OUT_RECEIVE_DLRM_ls_ONE: ENTITY WORK.Comparator generic map(BITS=>11)
    port map(
        in1 => COUNTER_OUT_RECEIVE_DLRM,
        in2 => ONE,
        ls => COUNTER_OUT_RECEIVE_DLRM_ls_ONE,
        eq => COUNTER_OUT_RECEIVE_DLRM_EQ_ONE
    );

END ARCHITECTURE;
