--*****************************************************************************/
--	Filename:		VCB_CONTROLER_RECEIVER.vhd
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
USE IEEE.std_logic_unsigned.all;

ENTITY VCB_CONTROLER_RECEIVER IS 
PORT(
    clk 									: IN STD_LOGIC;
    rst 									: IN STD_LOGIC;
    rx_Src_rdy_cmp 							: IN STD_LOGIC;
    rx_Src_rdy_p 							: IN STD_LOGIC;
    rx_Src_rdy_np 							: IN STD_LOGIC;
    rx_VCB_rdy   							: OUT STD_LOGIC;		
    rx_src_sop   							: IN STD_LOGIC;		    
    rx_src_eop   							: IN STD_LOGIC;		    
    dev_tl_tx_dst_rdy   					: IN STD_LOGIC;			-- destination of the packet is ready 
    dev_tl_tx_src_sop   					: OUT STD_LOGIC;		
    dev_tl_tx_src_eop   					: OUT STD_LOGIC;		
    
	nonposted_header_empty_from_gate 		: IN STD_LOGIC;
    comp_header_empty_from_gate 	 		: IN STD_LOGIC;
    posted_header_empty_from_gate 	 		: IN STD_LOGIC;
    TOP_HEADER_TRANSMIT_LD 			 		: OUT STD_LOGIC;			-- load top header data into register (this used to register the Hdr1 and use its information for furthur processing)
    
    SAVE_READY_RECEIVE_from_src		 		: OUT STD_LOGIC;			-- pre-name: SAVE_READY_RECEIVE_DLRM
    
    -- count the number of received DWs
	receiveDW		   						: OUT STD_LOGIC;		-- enable the counter to count the number of received DWs and so credit unit
 	-- count the number of sent DWs
	sendDW			   						: OUT STD_LOGIC;		-- enable the counter to count the number of send DWs and so credit unit
	 
	co_tx_pd 								: IN STD_LOGIC;
	co_tx_npd 								: IN STD_LOGIC;
	co_tx_cmpd								: IN STD_LOGIC;
	
	-- increment Credit received counter for header gating logic
	Incr_CR_nph 							: OUT STD_LOGIC;
	Incr_CR_ph  							: OUT STD_LOGIC;
	Incr_CR_cmph							: OUT STD_LOGIC;
	
	Incr_CR_d_cntrl  						: OUT STD_LOGIC;

	
	-- increment Credit send counter for header gating logic
	Incr_CA_cmph							: OUT STD_LOGIC;
	Incr_CA_ph  							: OUT STD_LOGIC;
	Incr_CA_nph 							: OUT STD_LOGIC;
	Incr_CA_d_cntrl  						: OUT STD_LOGIC;

	-- push data/hdr from VCB:
	push_ch 								: OUT STD_LOGIC;		-- push header to VCB
	push_ph 								: OUT STD_LOGIC;        -- push header to VCB
	push_nh									: OUT STD_LOGIC;        -- push header to VCB
	push_cd 								: OUT STD_LOGIC;		-- push Data to VCB
	push_pd 								: OUT STD_LOGIC;        -- push Data to VCB
	push_nd									: OUT STD_LOGIC;        -- push Data to VCB
	-- PUSH_DATA : OUT STD_LOGIC;	

	-- pop data/hdr to VCB
	pop_ch 									: OUT STD_LOGIC;		-- pop header to VCB
	pop_ph 									: OUT STD_LOGIC;        -- pop header to VCB
	pop_nh 									: OUT STD_LOGIC;        -- pop header to VCB
	pop_cd 									: OUT STD_LOGIC;        -- pop Data to VCB
	pop_pd 									: OUT STD_LOGIC;		-- pop Data to VCB
	pop_nd 									: OUT STD_LOGIC;        -- pop Data to VCB
    -- POP_HEADER 							: OUT STD_LOGIC;
    -- POP_DATA   							: OUT STD_LOGIC;
											
	
    -- COUNTER_EN_RECEIVE_DLRM : OUT STD_LOGIC;						-- -- ***************************** not used (in controller and datapath) ****************************************************************************************************************************************************************************************************************************************
    
	-- From ordering logic (posted/nonposted/cmpl data transmission Permission)
	ENS1 									: IN STD_LOGIC;			-- ready to send completion
    ENS2 									: IN STD_LOGIC;			-- ready to send posted
    ENS3 									: IN STD_LOGIC;			-- ready to send non-posted
	ENSEs_reg								: IN STD_LOGIC_vector(2 DOWNTO 0);			-- registered ENSs
	
    OrderingLogic_rdy 						: IN STD_LOGIC;			-- pre-name: TINA_READY
	
    READY_TO_OrderingLogic 					: OUT STD_LOGIC;		-- pre-name: READY_TO_TINA
    SAVE_ENS_SIG 							: OUT STD_LOGIC;
    ACK_TO_OrderingLogic 					: OUT STD_LOGIC;		-- pre-name: ACK_TO_TINA
    READY_TO_send_data   					: OUT STD_LOGIC;		-- pre-name: READY_TO_DLRM
    
	-- reset and enable signals for the counter that counts the number of transmtted data
	COUNTER_EN_SEND_DATA 					: OUT STD_LOGIC;
    COUNTER_RST_SEND_DATA 					: OUT STD_LOGIC;

	-- Choose between sending headers or data
	SHOW_HEADER 							: OUT STD_LOGIC;		-- send Headr
    SHOW_DATA   							: OUT STD_LOGIC;        -- send Data
	
    COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone : IN STD_LOGIC;		-- comparison result of the number of sent DWs with Total number of DWs that should be sent
 
    EMPTYh 									: IN STD_LOGIC;
    EMPTYd 									: IN STD_LOGIC;
    fullh  									: IN STD_LOGIC;
    fulld  									: IN STD_LOGIC
);
END VCB_CONTROLER_RECEIVER;

ARCHITECTURE ARCH1 OF VCB_CONTROLER_RECEIVER IS
    TYPE RECIEVING IS (SAVE_HEADER1,SAVE_HEADER2,SAVE_HEADER3,
 	SAVE_DATA,WAIT_D);
    TYPE SENDING IS (WAIT_FOR_NOT_EMPTY,WAIT_FOR_OrdeingLogic_READY,WAIT_FOR_ENS,SAVE_ENS,SENT1,SENT2,RDYSEND1,RDYSEND2,RDYSEND3,SENTD,RDYSENDD); --- SENT3 deleted, not used
    SIGNAL P_STATE_rx,N_STATE_rx:RECIEVING;
    SIGNAL P_STATES_tx,N_STATES_tx:SENDING:=WAIT_FOR_NOT_EMPTY;
     SIGNAL PUSH_HEADER :  STD_LOGIC;
	--SIGNAL co_tx_Cntr :  STD_LOGIC; -- not used
BEGIN
    


    PROCESS(clk,rst) BEGIN
        IF(rst='1') THEN
            P_STATE_rx <= SAVE_HEADER1;
        ELSIF(clk='1' AND clk'EVENT) THEN
            P_STATE_rx <= N_STATE_rx;
        END IF;
    END PROCESS;
    
    PROCESS(P_STATE_rx,fullh,fulld,rx_src_eop,rx_Src_rdy_cmp,rx_Src_rdy_p,rx_Src_rdy_np) BEGIN
        CASE P_STATE_rx IS
             WHEN  SAVE_HEADER1=>
                IF(((rx_Src_rdy_cmp='1') OR
                (rx_Src_rdy_p='1') OR
                (rx_Src_rdy_np='1')) AND fullh='0') THEN
                    N_STATE_rx<=SAVE_HEADER2;
                ELSE
                    N_STATE_rx<=SAVE_HEADER1;
                END IF;
            WHEN  SAVE_HEADER2=>
                IF(((rx_Src_rdy_cmp='1') OR
                (rx_Src_rdy_p='1') OR
                (rx_Src_rdy_np='1')) AND fullh='0') THEN
                    N_STATE_rx<=SAVE_HEADER3;
                ELSE
                     N_STATE_rx<=SAVE_HEADER2;
                END IF;
             WHEN  SAVE_HEADER3=>
                IF(rx_src_eop='1' AND fullh='0') THEN
                    N_STATE_rx<=SAVE_HEADER1;
                ELSIF(((rx_Src_rdy_cmp='1') OR
                (rx_Src_rdy_p='1') OR
                (rx_Src_rdy_np='1')) AND fullh='0') THEN
                    N_STATE_rx<=SAVE_DATA;
                ELSE
                     N_STATE_rx<=SAVE_HEADER3;
                END IF;
              WHEN  SAVE_DATA=>
                IF(rx_src_eop='1' AND fulld='0') THEN
                    N_STATE_rx<=SAVE_HEADER1;
                ELSIF(((rx_Src_rdy_cmp='1') OR
                (rx_Src_rdy_p='1') OR
                (rx_Src_rdy_np='1')) AND fulld='0') THEN
                    N_STATE_rx<=SAVE_DATA;
                ELSE
                    N_STATE_rx<=WAIT_D;
                END IF;
            WHEN  WAIT_D=>
                IF(rx_src_eop='1' AND fulld='0') THEN
                    N_STATE_rx<=SAVE_HEADER1;
                ELSIF(((rx_Src_rdy_cmp='1') OR
                (rx_Src_rdy_p='1') OR
                (rx_Src_rdy_np='1')) AND fulld='0') THEN
                    N_STATE_rx<=SAVE_DATA;
                ELSE
                    N_STATE_rx<=WAIT_D;
                END IF;
            WHEN OTHERS=>
                N_STATE_rx<=SAVE_HEADER1;
        END CASE;
    END PROCESS;

    PROCESS(P_STATE_rx,rx_Src_rdy_cmp,rx_src_eop,rx_Src_rdy_p,rx_Src_rdy_np,fullh,fulld) BEGIN
         SAVE_READY_RECEIVE_from_src<='0';
 		rx_VCB_rdy <= '0'; 
		 PUSH_HEADER <= '0';
 		-- push and count data
		push_cd 		<= '0';
 		push_pd 		<= '0';
 		push_nd			<= '0';
		
		Incr_CR_d_cntrl <= '0';
		Incr_CR_nph <= '0'; 
		Incr_CR_ph <= '0';
		Incr_CR_cmph <= '0';	
 		receiveDW	 	<= '0';							-- it is used for counting the number of received DW, and so, define when 1 credit is received 
		SAVE_READY_RECEIVE_from_src		<=	'0';		-- As the receiveDW will increment the receivedDW_cntr in the next clk and ready signals is needed to define a credit unit is for which type of packets (cmp/p/np), the ready signals should be registerd 
				
				                           
        CASE P_STATE_rx IS   
            WHEN  SAVE_HEADER1=>
				SAVE_READY_RECEIVE_from_src <= '1';
				Incr_CR_d_cntrl <= '1';					-- This signal is asserted in this state, because there is a case that the 3rd data is received in the previous state that is save_Data and the counter will incremented in this state and got "11" value 
				 
				PUSH_HEADER <= '1';
				IF fullh='0' THEN 
					rx_VCB_rdy <= '1'; 
					
				ELSE
					rx_VCB_rdy <= '0'; 
				END IF;
				
            
            WHEN  WAIT_D=>
				IF fulld='0' THEN 
					rx_VCB_rdy <= '1';
				END IF;
            WHEN  SAVE_HEADER2=>
				PUSH_HEADER <= '1';
				IF fullh='0' THEN
					rx_VCB_rdy <= '1'; 

				ELSE
					rx_VCB_rdy <= '0'; 
				END IF;
				
            WHEN  SAVE_HEADER3=>
				PUSH_HEADER <= '1';
				IF fullh='0' THEN 
					rx_VCB_rdy <= '1'; 
					IF rx_Src_rdy_cmp = '1'  THEN
						Incr_CR_cmph <= '1';					-- In this state all 3 DWs are received (1 credit). So, credit received counter of cmpl should be increment
					ELSIF rx_Src_rdy_p = '1'  THEN
						Incr_CR_ph <= '1';						-- In this state all 3 DWs are received (1 credit). So, credit received counter of posted should be increment
					ELSIF rx_Src_rdy_np = '1'  THEN
						Incr_CR_nph <= '1';						-- In this state all 3 DWs are received (1 credit). So, credit received counter of nonposted should be increment
					END IF;
				ELSE										
					rx_VCB_rdy <= '0'; 
				END IF;
				
            WHEN  SAVE_DATA=>
				SAVE_READY_RECEIVE_from_src		<=	'1';	-- As the received DW will increment the receivedDW_cntr in the next clk and ready signals is needed to define a credit unit is for which type of packets (cmp/p/np), the ready signals should be registerd 
				Incr_CR_d_cntrl <= '1';
				IF fulld='0' THEN 
					rx_VCB_rdy <= '1'; 
					IF rx_Src_rdy_cmp = '1'  THEN
						push_cd <= '1';
						receiveDW <= '1';
					ELSIF rx_Src_rdy_p = '1'  THEN
						push_pd <= '1';
						receiveDW <= '1';
					ELSIF rx_Src_rdy_np = '1'  THEN
						push_nd <= '1';
						receiveDW <= '1';
					END IF;
				ELSE
					rx_VCB_rdy <= '0'; 
				END IF;
				
            WHEN OTHERS=>
			
			rx_VCB_rdy <= '0';
			PUSH_HEADER <= '0'; 
 			-- push and count data
			push_cd 		<= '0';
 			push_pd 		<= '0';
 			push_nd			<= '0';
			
			Incr_CR_nph  <= '0'; 
			Incr_CR_ph   <= '0';
			Incr_CR_cmph <= '0';
			Incr_CR_d_cntrl <= '0';
			
			receiveDW	 	<= '0';
 			SAVE_READY_RECEIVE_from_src		<=	'0';
        END CASE;
    END PROCESS;
    push_ch <= '1' WHEN  rx_Src_rdy_cmp = '1'  AND PUSH_HEADER = '1' AND fullh = '0' ELSE '0';
	push_ph <= '1' WHEN  rx_Src_rdy_p = '1'    AND PUSH_HEADER = '1' AND fullh = '0' ELSE '0';
	push_nh <= '1' WHEN  rx_Src_rdy_np = '1'    AND PUSH_HEADER = '1' AND fullh = '0' ELSE '0';
    -- co_tx_Cntr <=  co_tx_pd OR co_tx_npd  OR co_tx_cmpd;  -- not used	
	                                            	
    PROCESS(clk,rst) BEGIN                     	
        IF(rst='1') THEN            
            P_STATES_tx<=WAIT_FOR_NOT_EMPTY;
        ELSIF(clk='1' AND clk'EVENT) THEN
            P_STATES_tx<=N_STATES_tx;
        END IF;
    END PROCESS;

--PROCESS(clk,rst) BEGIN  
--    IF(clk='1' AND clk'EVENT) THEN 
--        P_STATES_tx<=N_STATES_tx;                  	
--        IF(rst='1') THEN            
--                P_STATES_tx<=WAIT_FOR_NOT_EMPTY; 
--        END IF;           
--    END IF;
--END PROCESS;

-- *********************************************************************************************************************************************************************************************************************************************************************
	
	PROCESS(P_STATES_tx, ENS1, ENS2, ENS3,EMPTYh,EMPTYd,OrderingLogic_rdy,comp_header_empty_from_gate,
    posted_header_empty_from_gate,nonposted_header_empty_from_gate,dev_tl_tx_dst_rdy,
    COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone) BEGIN
        CASE P_STATES_tx IS
            WHEN  WAIT_FOR_NOT_EMPTY=>
                IF(comp_header_empty_from_gate='0' OR
                   posted_header_empty_from_gate='0' OR
                   nonposted_header_empty_from_gate='0') THEN
                    N_STATES_tx<=WAIT_FOR_OrdeingLogic_READY;
                ELSE
                    N_STATES_tx<=WAIT_FOR_NOT_EMPTY;
                END IF;
            WHEN  WAIT_FOR_OrdeingLogic_READY=>
                IF(OrderingLogic_rdy='1') THEN
                    N_STATES_tx<=WAIT_FOR_ENS;
                ELSE
                    N_STATES_tx<=WAIT_FOR_OrdeingLogic_READY;
                END IF;
            WHEN  WAIT_FOR_ENS=>
                IF(ENS1='0' AND ENS2='0' AND ENS3='0') THEN
                    N_STATES_tx<=WAIT_FOR_ENS;
                ELSE
                    N_STATES_tx<=SAVE_ENS;
                END IF;
            WHEN  SAVE_ENS=>
                N_STATES_tx<=RDYSEND1;
            WHEN  RDYSEND1=>
                IF(dev_tl_tx_dst_rdy='0') THEN
                    N_STATES_tx<=RDYSEND1;
                ELSE
                    N_STATES_tx<=SENT1;
                END IF;
            WHEN  SENT1=>
                IF(dev_tl_tx_dst_rdy='0' OR EMPTYh='1') THEN
                    N_STATES_tx<=RDYSEND2;
                ELSE
                    N_STATES_tx<=SENT2;
                END IF;
            WHEN  RDYSEND2=>
                IF(dev_tl_tx_dst_rdy='0' OR EMPTYh='1') THEN
                    N_STATES_tx<=RDYSEND2;
                ELSE
                    N_STATES_tx<=SENT2;
                END IF;
            WHEN  SENT2=>
                IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1' AND dev_tl_tx_dst_rdy='1') THEN
                    N_STATES_tx<=WAIT_FOR_NOT_EMPTY;
                ELSIF(dev_tl_tx_dst_rdy='0' OR EMPTYh='1') THEN
                    N_STATES_tx<=RDYSEND3;
                ELSE
                    N_STATES_tx<=SENTD;
                END IF;
            WHEN  RDYSEND3=>
                IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1' AND dev_tl_tx_dst_rdy='1') THEN
                    N_STATES_tx<=WAIT_FOR_NOT_EMPTY;
                ELSIF(dev_tl_tx_dst_rdy='0' OR EMPTYh='1') THEN
                    N_STATES_tx<=RDYSEND3;
                ELSE
                    -- N_STATES_tx<=SENT3;
                    N_STATES_tx <= RDYSENDD;
                END IF;
             
            WHEN  RDYSENDD=>
                IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1' AND dev_tl_tx_dst_rdy='1') THEN
                    N_STATES_tx<=WAIT_FOR_NOT_EMPTY;
                ELSIF(dev_tl_tx_dst_rdy='0' OR EMPTYd='1') THEN
                    N_STATES_tx<=RDYSENDD;
                ELSE
                    N_STATES_tx<=SENTD;
                END IF;
            WHEN  SENTD=>
                IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1' AND dev_tl_tx_dst_rdy='1') THEN
                    N_STATES_tx<=WAIT_FOR_NOT_EMPTY;
                ELSIF(dev_tl_tx_dst_rdy='0' OR EMPTYd='1') THEN
                    N_STATES_tx<=RDYSENDD;
                ELSE
                    N_STATES_tx<=SENTD;
                END IF;
            WHEN OTHERS=>
                N_STATES_tx<=WAIT_FOR_NOT_EMPTY;
        END CASE;
    END PROCESS;

    -- additional signal that is deleted from sensivitiy list : co_tx_Cntr
    
    PROCESS(P_STATES_tx,ENSEs_reg,EMPTYh,EMPTYd,dev_tl_tx_dst_rdy,
	COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone) BEGIN
        READY_TO_OrderingLogic<='0';SAVE_ENS_SIG<='0';COUNTER_RST_SEND_DATA<='0';ACK_TO_OrderingLogic<='0';
        READY_TO_send_data <= '0';TOP_HEADER_TRANSMIT_LD<='0';COUNTER_EN_SEND_DATA<='0';
		SHOW_HEADER<='0';SHOW_DATA<='0';dev_tl_tx_src_sop<='0';dev_tl_tx_src_eop<='0';
		pop_ch <= '0';
		pop_ph <= '0';
		pop_nh <= '0';
		pop_cd <= '0';
		pop_pd <= '0';
		pop_nd <= '0';
		sendDW <= '0'; 
		Incr_CA_cmph <= '0';
		Incr_CA_ph   <= '0';
		Incr_CA_nph  <= '0';
		Incr_CA_d_cntrl	<= '0';

		
        CASE P_STATES_tx IS  
            WHEN  WAIT_FOR_NOT_EMPTY=>
				-- txDW_Cntrst <= '1';
				Incr_CA_d_cntrl <= '1';
            WHEN  WAIT_FOR_OrdeingLogic_READY=>
                READY_TO_OrderingLogic<='1';
				
            WHEN  WAIT_FOR_ENS=>
                READY_TO_OrderingLogic<='1';
            WHEN  SAVE_ENS=>
                READY_TO_OrderingLogic<='1';
                SAVE_ENS_SIG<='1';
                COUNTER_RST_SEND_DATA<='1';
                ACK_TO_OrderingLogic<='1';
				


            WHEN  RDYSEND1=>
                SHOW_HEADER<='1';
                READY_TO_send_data <= '1';
                IF(dev_tl_tx_dst_rdy='1') THEN
					IF ( ENSEs_reg(0) = '1') THEN 
						pop_ch <='1';
						-- sendDW <= '1';
					ELSIF (ENSEs_reg(1) = '1') THEN 
						pop_ph <='1';
						-- sendDW <= '1';
					ELSIF (ENSEs_reg(2) = '1') THEN 
						pop_nh <='1';
						-- sendDW <= '1';
					END IF;
					
					COUNTER_EN_SEND_DATA<='1';
					TOP_HEADER_TRANSMIT_LD<='1';
                END IF;
                dev_tl_tx_src_sop<='1';

            WHEN  SENT1=>
            IF(EMPTYh='0') THEN
                READY_TO_send_data <= '1';
                SHOW_HEADER<='1';
                IF(dev_tl_tx_dst_rdy='1') THEN
                    IF ( ENSEs_reg(0) = '1') THEN 
						pop_ch <='1';
						-- sendDW <= '1';
					ELSIF (ENSEs_reg(1) = '1') THEN 
						pop_ph <='1';
						-- sendDW <= '1';
					ELSIF (ENSEs_reg(2) = '1') THEN 
						pop_nh <='1';
						-- sendDW <= '1';
					END IF;
                    COUNTER_EN_SEND_DATA<='1';
                END IF;
            END IF;

            WHEN  RDYSEND2=>
                IF(EMPTYh='0') THEN
                    READY_TO_send_data <= '1';
                    SHOW_HEADER<='1';
                    IF(dev_tl_tx_dst_rdy='1') THEN
                        IF ( ENSEs_reg(0) = '1') THEN 
							pop_ch <='1';
							-- sendDW <= '1';
						ELSIF (ENSEs_reg(1) = '1') THEN 
							pop_ph <='1';
							-- sendDW <= '1';
						ELSIF (ENSEs_reg(2) = '1') THEN 
							pop_nh <='1';
							-- sendDW <= '1';
						END IF;
                        COUNTER_EN_SEND_DATA<='1';
                    END IF;
                END IF;


            WHEN  SENT2=>
                IF(EMPTYh='0') THEN
                    READY_TO_send_data <= '1';
                    SHOW_HEADER<='1';
                    IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1') THEN --HAVE TO MODIFY
                        dev_tl_tx_src_eop<='1';
                    END IF;
                    IF(dev_tl_tx_dst_rdy='1') THEN
                        IF ( ENSEs_reg(0) = '1') THEN 
							pop_ch <='1';
							Incr_CA_cmph <= '1';
							-- sendDW <= '1';
						ELSIF (ENSEs_reg(1) = '1') THEN 
							pop_ph <='1';
							Incr_CA_ph <= '1';
							-- sendDW <= '1';
						ELSIF (ENSEs_reg(2) = '1') THEN 
							pop_nh <='1';
							Incr_CA_nph <= '1';
							-- sendDW <= '1';
						END IF;
                        COUNTER_EN_SEND_DATA<='1';
                    END IF;
                END IF;


            WHEN  RDYSEND3=>
                IF(EMPTYh='0') THEN
                    READY_TO_send_data <= '1';
                    SHOW_HEADER<='1';
                    IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1') THEN --HAVE TO MODIFY
                        dev_tl_tx_src_eop<='1';
                    END IF;
                    IF(dev_tl_tx_dst_rdy='1') THEN
                        IF ( ENSEs_reg(0) = '1') THEN 
							pop_ch <='1';
							Incr_CA_cmph <= '1';
							
						ELSIF (ENSEs_reg(1) = '1') THEN 
							pop_ph <='1';
							Incr_CA_ph <= '1'; 
						ELSIF (ENSEs_reg(2) = '1') THEN 
							pop_nh <='1';
							Incr_CA_nph <= '1'; 
						END IF;
                        COUNTER_EN_SEND_DATA<='1';
                    END IF;
                END IF;
 
            WHEN  RDYSENDD=>
                IF(EMPTYd='0') THEN
                    READY_TO_send_data<='1';
					Incr_CA_d_cntrl <= '1';
                    IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1') THEN --HAVE TO MODIFY
                        dev_tl_tx_src_eop<='1';
                    END IF;
                    SHOW_DATA<='1';
                    IF(dev_tl_tx_dst_rdy='1') THEN
                        IF ( ENSEs_reg(0) = '1') THEN 
							pop_cd <='1';
							sendDW <= '1';
						ELSIF (ENSEs_reg(1) = '1') THEN 
							pop_pd <='1';
							sendDW <= '1';
						ELSIF (ENSEs_reg(2) = '1') THEN 
							pop_nd <='1';
							sendDW <= '1';
						END IF;
                        COUNTER_EN_SEND_DATA<='1';
                    END IF;
                END IF;


            WHEN  SENTD=>
                IF(EMPTYd='0') THEN
                    READY_TO_send_data <= '1';
					Incr_CA_d_cntrl <= '1';
                    IF(COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone='1') THEN --HAVE TO MODIFY
                        dev_tl_tx_src_eop<='1';
                    END IF;
                    SHOW_DATA<='1';
                    IF(dev_tl_tx_dst_rdy='1') THEN
                        IF ( ENSEs_reg(0) = '1') THEN 
							pop_cd <='1';
							sendDW <= '1';
						ELSIF (ENSEs_reg(1) = '1') THEN 
							pop_pd <='1';
							sendDW <= '1';
						ELSIF (ENSEs_reg(2) = '1') THEN 
							pop_nd <='1';
							sendDW <= '1';
						END IF;
                        COUNTER_EN_SEND_DATA<='1';
                    END IF;
                END IF;



            WHEN OTHERS=>
				READY_TO_OrderingLogic<='0';SAVE_ENS_SIG<='0';COUNTER_RST_SEND_DATA<='0';ACK_TO_OrderingLogic<='0';
				READY_TO_send_data <= '0';TOP_HEADER_TRANSMIT_LD<='0';COUNTER_EN_SEND_DATA<='0';
 				SHOW_HEADER<='0';SHOW_DATA<='0';dev_tl_tx_src_sop<='0';dev_tl_tx_src_eop<='0';
				pop_ch <= '0';
				pop_ph <= '0';
				pop_nh <= '0';
				pop_cd <= '0';
				pop_pd <= '0';
				pop_nd <= '0';
				sendDW <= '0'; 
				Incr_CA_cmph <= '0';
				Incr_CA_ph   <= '0';
				Incr_CA_nph  <= '0';
				Incr_CA_d_cntrl<= '0';
        END CASE;
    END PROCESS;


END ARCHITECTURE;
