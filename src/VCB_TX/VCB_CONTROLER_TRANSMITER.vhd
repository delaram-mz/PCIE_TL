--*****************************************************************************/
--	Filename:		CONTROLER.vhd
--	Project:		MCI-PCH
--  Version:		1.100
--	History:		-
--	Date:			26 September 2024
--	Authors:	 	Javad,Delaram,Mohammad
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
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.std_logic_unsigned.all;

ENTITY VCB_CONTROLER_TRANSMITER IS 
	PORT(

		--****************************************************************** inputs **********************************************************************-- 

		clk                                                                             : IN STD_LOGIC;  -- Clock signal to synchronize all operations
		rst                                                                             : IN STD_LOGIC;  -- Reset signal to initialize or reset the controller

		-- Indicates if source 1, 2, or 3 is ready to send data
		del_tl_tx_src_rdy_1                                                             : IN STD_LOGIC;  
		del_tl_tx_src_rdy_2                                                             : IN STD_LOGIC;
		del_tl_tx_src_rdy_3                                                             : IN STD_LOGIC;

		--del_tl_tx_src_sop                                                               : IN STD_LOGIC;  -- Start of packet signal from the source   --- not use
		del_tl_tx_src_eop                                                               : IN STD_LOGIC;  -- End of packet signal from the source

		dev_tl_tx_dst_rdy                                                               : IN STD_LOGIC;  -- Indicates if the destination is ready to receive data

		-- Indicates if the FIFO for comparison, posted, or non-posted headers/data is full
		--comp_header_full_from_gate                                                      : IN STD_LOGIC;   -- not used 
		--comp_data_full_from_gate                                                        : IN STD_LOGIC;    -- not used
		--posted_header_full_from_gate                                                    : IN STD_LOGIC;   -- not used
		--posted_data_full_from_gate                                                      : IN STD_LOGIC;   -- not used
		--nonposted_header_full_from_gate                                                 : IN STD_LOGIC;   -- not used
		--nonposted_data_full_from_gate                                                   : IN STD_LOGIC;   -- not used

		-- Indicates if the FIFO for comparison, posted, or non-posted headers is empty
		nonposted_header_empty_from_gate                                                : IN STD_LOGIC;  
		comp_header_empty_from_gate                                                     : IN STD_LOGIC;
		posted_header_empty_from_gate                                                   : IN STD_LOGIC;

		-- Status signals for sources 1, 2, and 3
		ENS1                                                                            : IN STD_LOGIC;  
		ENS2                                                                            : IN STD_LOGIC;
		ENS3                                                                            : IN STD_LOGIC;

		TINA_READY : IN STD_LOGIC;  -- Indicates if TINA is ready to receive data

		--Send_sig_h                                                                      : IN STD_LOGIC;  -- Signal to allow sending of headers
		--Send_sig_d                                                                      : IN STD_LOGIC;  -- Signal to allow sending of data

		-- Comparator outputs for managing data and header counts
		--HEADER_COUNT_RECEIVE_bg_Comparator_COUNTER_OUT_RECEIVE_DLRM                     : IN STD_LOGIC;  
		--HEADER_COUNT_RECEIVE_ls_Comparator_COUNTER_OUT_RECEIVE_DLRM                     : IN STD_LOGIC;
		COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone    : IN STD_LOGIC;
		--COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT                                  : IN STD_LOGIC;
		--COUNTER_OUT_SEND_DATA_EQ_HEADER_COUNT_TRANSMIT                                  : IN STD_LOGIC;  --not used
		--COUNTER_OUT_SEND_DATA_ls_ONE                                                    : IN STD_LOGIC;
		--COUNTER_OUT_SEND_DATA_EQ_ONE                                                    : IN STD_LOGIC;
		--COUNTER_OUT_RECEIVE_DLRM_ls_ONE                                                 : IN STD_LOGIC;
		--COUNTER_OUT_RECEIVE_DLRM_EQ_ONE                                                 : IN STD_LOGIC;

		-- Indicates if the header or data FIFO is empty or full
		EMPTYh                                                                          : IN STD_LOGIC;  
		EMPTYd                                                                          : IN STD_LOGIC;
		fullh                                                                           : IN STD_LOGIC;
		fulld                                                                           : IN STD_LOGIC;



		--****************************************************************** output **********************************************************************-- 


		del_tl_tx_dst_rdy           : OUT STD_LOGIC;  -- Indicates to the source that the destination is ready to receive data
		dev_tl_tx_src_sop           : OUT STD_LOGIC;  -- Start of packet signal to the destination
		dev_tl_tx_src_eop           : OUT STD_LOGIC;  -- End of packet signal to the destination

		-- Controls for loading, pushing, and popping headers and data from the FIFO
		rst_reg					    : OUT STD_LOGIC;  		-- ********************************* new*************
		TOP_HEADER_TRANSMIT_LD      : OUT STD_LOGIC;  
		PUSH_HEADER                 : OUT STD_LOGIC;  
		PUSH_DATA                   : OUT STD_LOGIC;  
		POP_HEADER                  : OUT STD_LOGIC;  
		POP_DATA                    : OUT STD_LOGIC;  

		-- Signals for resetting and enabling counters
		COUNTER_RST_RECIEVED_DATA   : OUT STD_LOGIC;  
		COUNTER_EN_RECEIVE_DLRM     : OUT STD_LOGIC;  
		COUNTER_RST_SEND_DATA       : OUT STD_LOGIC;  
		COUNTER_EN_SEND_DATA        : OUT STD_LOGIC;  

		-- Indicates readiness for communication with TINA or DLRM
		READY_TO_TINA               : OUT STD_LOGIC;  
		READY_TO_DLRM               : OUT STD_LOGIC;  
		ACK_TO_TINA                 : OUT STD_LOGIC;  -- Acknowledgement signal to TINA

		-- Signals for saving and showing data without removing it from the FIFO
		SAVE_READY_RECEIVE_DLRM     : OUT STD_LOGIC;  
		SAVE_ENS_SIG                : OUT STD_LOGIC;  
		SHOW_HEADER                 : OUT STD_LOGIC;  
		SHOW_DATA                   : OUT STD_LOGIC



	);
END VCB_CONTROLER_TRANSMITER;

ARCHITECTURE ARCH1 OF VCB_CONTROLER_TRANSMITER IS
    TYPE RECIEVING IS (IDLE,SAVE_HEADER1,SAVE_HEADER2,SAVE_HEADER3,WAITH1,WAITH2,WAITH3,SAVE_DATA,WAIT_D);

    TYPE SENDING IS (WAIT_FOR_NOT_EMPTY,WAIT_FOR_TINA_READY,WAIT_FOR_ENS,SAVE_ENS,SENT1,SENT2,SENT3,RDYSEND1,RDYSEND2,RDYSEND3,SENTD,RDYSENDD);

    SIGNAL P_STATE,N_STATE:RECIEVING:=IDLE;
    SIGNAL P_STATES,N_STATES:SENDING:=WAIT_FOR_NOT_EMPTY;
    SIGNAL del_tl_tx_dst_rdy_sig : STD_LOGIC;
    SIGNAL EMPTY : STD_LOGIC;

BEGIN
    

    PROCESS(clk,rst) BEGIN
        IF(rst='1') THEN
            P_STATE<=SAVE_HEADER1;
        ELSIF(clk='1' AND clk'EVENT) THEN
            P_STATE<=N_STATE;
        END IF;
    END PROCESS;
    
    PROCESS(P_STATE,fullh,fulld,del_tl_tx_src_eop,del_tl_tx_src_rdy_1,del_tl_tx_src_rdy_2,del_tl_tx_src_rdy_3) BEGIN
        CASE P_STATE IS
             
            WHEN  SAVE_HEADER1=>
                IF(((del_tl_tx_src_rdy_1='1') OR
                (del_tl_tx_src_rdy_2='1') OR
                (del_tl_tx_src_rdy_3='1')) AND fullh='0') THEN
                    N_STATE<=SAVE_HEADER2;
                ELSE
                    N_STATE<=WAITH1;
                END IF;
            WHEN  WAITH1=>
                IF(((del_tl_tx_src_rdy_1='1') OR
                (del_tl_tx_src_rdy_2='1') OR
                (del_tl_tx_src_rdy_3='1')) AND fullh='0') THEN
                    N_STATE<=SAVE_HEADER2;
                ELSE
                    N_STATE<=WAITH1;
                END IF;
            WHEN  SAVE_HEADER2=>
                IF(((del_tl_tx_src_rdy_1='1') OR
                (del_tl_tx_src_rdy_2='1') OR
                (del_tl_tx_src_rdy_3='1')) AND fullh='0') THEN
                    N_STATE<=SAVE_HEADER3;
                ELSE
                    N_STATE<=WAITH2;
                END IF;
            WHEN  WAITH2=>
                IF(((del_tl_tx_src_rdy_1='1') OR
                (del_tl_tx_src_rdy_2='1') OR
                (del_tl_tx_src_rdy_3='1')) AND fullh='0') THEN
                    N_STATE<=SAVE_HEADER3;
                ELSE
                    N_STATE<=WAITH2;
                END IF;
            WHEN  SAVE_HEADER3=>
                IF(del_tl_tx_src_eop='1' AND fullh='0') THEN
                    N_STATE<=SAVE_HEADER1;
                ELSIF(((del_tl_tx_src_rdy_1='1') OR
                (del_tl_tx_src_rdy_2='1') OR
                (del_tl_tx_src_rdy_3='1')) AND fullh='0') THEN
                    N_STATE<=SAVE_DATA;
                ELSE
                    N_STATE<=WAITH3;
                END IF;
            WHEN  WAITH3=>
                IF(del_tl_tx_src_eop='1' AND fullh='0') THEN
                    N_STATE<=SAVE_HEADER1;
                ELSIF(((del_tl_tx_src_rdy_1='1') OR
                (del_tl_tx_src_rdy_2='1') OR
                (del_tl_tx_src_rdy_3='1')) AND fullh='0' AND fulld='0') THEN
                    N_STATE<=SAVE_DATA;
                ELSE
                    N_STATE<=WAITH3;
                END IF;
            WHEN  SAVE_DATA=>
                IF(del_tl_tx_src_eop='1' AND fulld='0') THEN
                    N_STATE<=SAVE_HEADER1;
                ELSIF(((del_tl_tx_src_rdy_1='1') OR
                (del_tl_tx_src_rdy_2='1') OR
                (del_tl_tx_src_rdy_3='1')) AND fulld='0') THEN
                    N_STATE<=SAVE_DATA;
                ELSE
                    N_STATE<=WAIT_D;
                END IF;
            WHEN  WAIT_D=>
                IF(del_tl_tx_src_eop='1' AND fulld='0') THEN
                    N_STATE<=SAVE_HEADER1;
                ELSIF(((del_tl_tx_src_rdy_1='1') OR
                (del_tl_tx_src_rdy_2='1') OR
                (del_tl_tx_src_rdy_3='1')) AND fulld='0') THEN
                    N_STATE<=SAVE_DATA;
                ELSE
                    N_STATE<=WAIT_D;
                END IF;
            WHEN OTHERS=>
                N_STATE<=SAVE_HEADER1;
        END CASE;
    END PROCESS;


    PROCESS(P_STATE,del_tl_tx_src_rdy_1,del_tl_tx_src_eop,del_tl_tx_src_rdy_2,del_tl_tx_src_rdy_3,fullh,fulld) BEGIN
        COUNTER_RST_RECIEVED_DATA<='0';
        SAVE_READY_RECEIVE_DLRM<='0';
        COUNTER_EN_RECEIVE_DLRM<='0';
        CASE P_STATE IS  
            WHEN  IDLE=>
            WHEN  SAVE_HEADER1=>
            WHEN  WAITH1=>
                SAVE_READY_RECEIVE_DLRM<='1';
            WHEN  WAITH2=>
            WHEN  WAITH3=>
            WHEN  WAIT_D=>
            WHEN  SAVE_HEADER2=>
            WHEN  SAVE_HEADER3=>
            WHEN  SAVE_DATA=>
            WHEN OTHERS=>
        END CASE;
    END PROCESS;
    
    del_tl_tx_dst_rdy<= (NOT fulld) WHEN (P_STATE=SAVE_DATA) ELSE (NOT fullh);
    -- PUSH_HEADER <= ;
    PUSH_HEADER         <= '1' WHEN (fullh='0' AND (P_STATE/=SAVE_DATA AND P_STATE/=WAIT_D) AND (del_tl_tx_src_rdy_1='1' OR del_tl_tx_src_rdy_2='1' OR del_tl_tx_src_rdy_3='1')) ELSE '0';
    PUSH_DATA           <= '1' WHEN (fulld='0' AND (P_STATE=SAVE_DATA OR P_STATE=WAIT_D)    AND (del_tl_tx_src_rdy_1='1' OR del_tl_tx_src_rdy_2='1' OR del_tl_tx_src_rdy_3='1')) ELSE '0';
    
    
    PROCESS(clk,rst) BEGIN
        IF(rst='1') THEN
            P_STATES<=WAIT_FOR_NOT_EMPTY;
        ELSIF(clk='1' AND clk'EVENT) THEN
            P_STATES<=N_STATES;
        END IF;
    END PROCESS;


    --EMPTY<= EMPTYh WHEN (COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT='1' OR COUNTER_OUT_SEND_DATA_ls_ONE='1' OR COUNTER_OUT_SEND_DATA_EQ_ONE='1') ELSE EMPTYd;    -- NOT USED
    PROCESS(P_STATES,ENS1,ENS2,EMPTYh,EMPTYd,ENS3,TINA_READY,comp_header_empty_from_gate,
    posted_header_empty_from_gate,nonposted_header_empty_from_gate,dev_tl_tx_dst_rdy,
    COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone) BEGIN
        CASE P_STATES IS
            WHEN  WAIT_FOR_NOT_EMPTY=>
                IF(comp_header_empty_from_gate='0' OR
                   posted_header_empty_from_gate='0' OR
                   nonposted_header_empty_from_gate='0') THEN
                    N_STATES<=WAIT_FOR_TINA_READY;
                ELSE
                    N_STATES<=WAIT_FOR_NOT_EMPTY;
                END IF;
            WHEN  WAIT_FOR_TINA_READY=>
                IF(TINA_READY='1') THEN
                    N_STATES<=WAIT_FOR_ENS;
                ELSE
                    N_STATES<=WAIT_FOR_TINA_READY;
                END IF;
            WHEN  WAIT_FOR_ENS=>
                IF(ENS1='0' AND ENS2='0' AND ENS3='0') THEN
                    N_STATES<=WAIT_FOR_ENS;
                ELSE
                    N_STATES<=SAVE_ENS;
                END IF;
            WHEN  SAVE_ENS=>
                N_STATES<=RDYSEND1;
            WHEN  RDYSEND1=>
                IF(dev_tl_tx_dst_rdy='0') THEN
                    N_STATES<=RDYSEND1;
                ELSE
                    N_STATES<=SENT1;
                END IF;
            WHEN  SENT1=>
                IF(dev_tl_tx_dst_rdy='0' OR EMPTYh='1') THEN
                    N_STATES<=RDYSEND2;
                ELSE
                    N_STATES<=SENT2;
                END IF;
            WHEN  RDYSEND2=>
                IF(dev_tl_tx_dst_rdy='0' OR EMPTYh='1') THEN
                    N_STATES<=RDYSEND2;
                ELSE
                    N_STATES<=SENT2;
                END IF;
            WHEN  SENT2=>
                IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1' AND dev_tl_tx_dst_rdy='1') THEN
                    N_STATES<=WAIT_FOR_NOT_EMPTY;
                ELSIF(dev_tl_tx_dst_rdy='0' OR EMPTYh='1') THEN
                    N_STATES<=RDYSEND3;
                ELSE
                    N_STATES<=SENTD;
                END IF;
            WHEN  RDYSEND3=>
                IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1' AND dev_tl_tx_dst_rdy='1') THEN
                    N_STATES<=WAIT_FOR_NOT_EMPTY;
                ELSIF(dev_tl_tx_dst_rdy='0' OR EMPTYh='1') THEN
                    N_STATES<=RDYSEND3;
                ELSE
                    N_STATES<=SENT3;
                END IF;
            WHEN  SENT3=>
                IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1' AND dev_tl_tx_dst_rdy='1') THEN
                    N_STATES<=WAIT_FOR_NOT_EMPTY;
                ELSIF(dev_tl_tx_dst_rdy='0' OR EMPTYh='1') THEN
                    N_STATES<=RDYSENDD;
                ELSE
                    N_STATES<=SENTD;
                END IF;
            WHEN  RDYSENDD=>
                IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1' AND dev_tl_tx_dst_rdy='1') THEN
                    N_STATES<=WAIT_FOR_NOT_EMPTY;
                ELSIF(dev_tl_tx_dst_rdy='0' OR EMPTYd='1') THEN
                    N_STATES<=RDYSENDD;
                ELSE
                    N_STATES<=SENTD;
                END IF;
            WHEN  SENTD=>
                IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1' AND dev_tl_tx_dst_rdy='1') THEN
                    N_STATES<=WAIT_FOR_NOT_EMPTY;
                ELSIF(dev_tl_tx_dst_rdy='0' OR EMPTYd='1') THEN
                    N_STATES<=RDYSENDD;
                ELSE
                    N_STATES<=SENTD;
                END IF;
            WHEN OTHERS=>
                N_STATES<=WAIT_FOR_NOT_EMPTY;
        END CASE;
    END PROCESS;

     --in process these signal deleted because they werent used : COUNTER_OUT_SEND_DATA_EQ_HEADER_COUNT_TRANSMIT , COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT 
     --                                                             COUNTER_OUT_SEND_DATA_ls_ONE , COUNTER_OUT_SEND_DATA_EQ_ONE ,
     --                                                            
    PROCESS(P_STATES,EMPTYh,EMPTYd,dev_tl_tx_dst_rdy,
    COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone) BEGIN
        READY_TO_TINA<='0';SAVE_ENS_SIG<='0';COUNTER_RST_SEND_DATA<='0';ACK_TO_TINA<='0';
        READY_TO_DLRM <= '0';TOP_HEADER_TRANSMIT_LD<='0';COUNTER_EN_SEND_DATA<='0';rst_reg <= '0';
        POP_HEADER<='0';POP_DATA<='0';SHOW_HEADER<='0';SHOW_DATA<='0';dev_tl_tx_src_sop<='0';dev_tl_tx_src_eop<='0';
        CASE P_STATES IS  
            WHEN  WAIT_FOR_NOT_EMPTY=>
				TOP_HEADER_TRANSMIT_LD<='1';   		 
				rst_reg <= '0';                		 
            WHEN  WAIT_FOR_TINA_READY=>
                READY_TO_TINA<='1';
            WHEN  WAIT_FOR_ENS=>
                READY_TO_TINA<='1';
            WHEN  SAVE_ENS=>
                READY_TO_TINA<='1';
                SAVE_ENS_SIG<='1';
                COUNTER_RST_SEND_DATA<='1';
                ACK_TO_TINA<='1';


            WHEN  RDYSEND1=>
                SHOW_HEADER         <='1';
                READY_TO_DLRM       <= '1';
                dev_tl_tx_src_sop   <='1';
                IF(dev_tl_tx_dst_rdy='1') THEN
                    POP_HEADER<='1';
                    COUNTER_EN_SEND_DATA<='1'; 	 
                END IF;
                

            WHEN  SENT1=>
            IF(EMPTYh='0') THEN
                READY_TO_DLRM <= '1';
                SHOW_HEADER<='1';
                IF(dev_tl_tx_dst_rdy='1') THEN
                    POP_HEADER<='1';
                    COUNTER_EN_SEND_DATA<='1';
                END IF;
            END IF;

            WHEN  RDYSEND2=>
                IF(EMPTYh='0') THEN
                    READY_TO_DLRM <= '1';
                    SHOW_HEADER<='1';
                    IF(dev_tl_tx_dst_rdy='1') THEN
                        POP_HEADER<='1';
                        COUNTER_EN_SEND_DATA<='1';
                    END IF;
                END IF;


            WHEN  SENT2=>
                IF(EMPTYh='0') THEN
                    READY_TO_DLRM <= '1';
                    SHOW_HEADER<='1';
                    IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1') THEN  
                        dev_tl_tx_src_eop<='1';                                                                
                    END IF;                                                                                    
                    IF(dev_tl_tx_dst_rdy='1') THEN                                                             
                        POP_HEADER<='1';                                                                       
                        COUNTER_EN_SEND_DATA<='1';                                                             
                    END IF;                                                                                    
                END IF;                                                                                        
																											   
																											   
            WHEN  RDYSEND3=>                                                                                   
                IF(EMPTYh='0') THEN                                                                            
                    READY_TO_DLRM <= '1';                                                                      
                    SHOW_HEADER<='1';                                                                          
                    IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1') THEN  
                        dev_tl_tx_src_eop<='1';
                    END IF;
                    IF(dev_tl_tx_dst_rdy='1') THEN
                        POP_HEADER<='1';
                        COUNTER_EN_SEND_DATA<='1';
                    END IF;
                END IF;

            WHEN  SENT3=>
                IF(EMPTYh='0') THEN
                    READY_TO_DLRM<='1';
                    IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1') THEN  
                        dev_tl_tx_src_eop<='1';                                                                
                    END IF;                                                                                    
                    SHOW_DATA<='1';                                                                            
                    IF(dev_tl_tx_dst_rdy='1') THEN                                                             
                        POP_DATA<='1';                                                                         
                        COUNTER_EN_SEND_DATA<='1';                                                             
                    END IF;                                                                                    
                END IF;                                                                                        
																											   
            WHEN  RDYSENDD=>                                                                                   
                IF(EMPTYd='0') THEN                                                                            
                    READY_TO_DLRM<='1';                                                                        
                    IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1') THEN  
                        dev_tl_tx_src_eop<='1';                                                                
                    END IF;                                                                                    
                    SHOW_DATA<='1';                                                                            
                    IF(dev_tl_tx_dst_rdy='1') THEN                                                             
                        POP_DATA<='1';                                                                         
                        COUNTER_EN_SEND_DATA<='1';                                                             
                    END IF;                                                                                    
                END IF;                                                                                        
																											   
																											   
            WHEN  SENTD=>                                                                                      
                IF(EMPTYd='0') THEN                                                                            
                    READY_TO_DLRM <= '1';                                                                      
                    IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1') THEN  
                        dev_tl_tx_src_eop<='1';
                    END IF;
                    SHOW_DATA<='1';
                    IF(dev_tl_tx_dst_rdy='1') THEN
                        POP_DATA<='1';
                        COUNTER_EN_SEND_DATA<='1';
                    END IF;
                END IF;



            WHEN OTHERS=>
        END CASE;
    END PROCESS;



END ARCHITECTURE;


