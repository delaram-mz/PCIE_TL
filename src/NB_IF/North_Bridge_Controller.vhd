--*****************************************************************************/
--	Filename:		North_Bridge_Controller.vhd
--	Project:		MCI-PCH
--  Version:		1.1
--	History:		-
--	Date:			16 January 2024
--	Authors:	 	Hossein, Alireza
--	Fist Author:    Hossein
--	Last Author: 	Hossein
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--
--*****************************************************************************/
--	File content description:
--  Controller of Northbridge
--  
--  Alireza's Modifications:   style, IO/Mem to PCH branch states changed a little
--  Hossein's Modifications:   removed "start_to_pch" signal ,
--  Changed IO to PCH Branche: add some new state(WAIT#_ ON_Send_FIFO) for handshaking with InterFace - 
--                             changed position of "LD_HDR" and next "wait" 


--*****************************************************************************/

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY North_Bridge_Controller IS 

	PORT(
			-- System Interface
		    clk : IN STD_LOGIC;
			rst : IN STD_LOGIC;
			-- CPU Control Interface
            RS_ready : IN STD_LOGIC;
			empty : IN STD_LOGIC;
			full : IN STD_LOGIC;
			start_cpu : IN STD_LOGIC;
			ready_cpu : IN STD_LOGIC;
			DEN  : IN STD_LOGIC; -- cpu to NB
            start_pch : IN STD_LOGIC; -- pch to NB
			ready_pch : IN STD_LOGIC; -- pch to NB
            RS_ready_to_cpu : OUT STD_LOGIC; -- NB to cpu
			pop : OUT STD_LOGIC; -- NB to cpu
			push : OUT STD_LOGIC; -- NB to cpu
			ready_to_cpu : OUT STD_LOGIC; -- NB to cpu
			start_to_cpu : OUT STD_LOGIC; -- NB to cpu
            RS_controller  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- NB to cpu
			RS_cpu         : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- cpu to NB
			push_send_fifo			: OUT STD_LOGIC; -- NB to pch
			pop_receive_fifo		: OUT STD_LOGIC; -- NB to pch
--			start_to_pch			: OUT STD_LOGIC; -- NB to pch
			read_ready_to_pch : OUT STD_LOGIC; -- NB to pch     
    --      data_valid_to_pch : OUT STD_LOGIC; -- NB to pch
	--		ready_to_pch : OUT STD_LOGIC; -- NB to pch		
		    sel_cpu_req : OUT STD_LOGIC;
			sel_defer_req : OUT STD_LOGIC;
			ld_req : OUT STD_LOGIC;
			sel_cpu_addr : OUT STD_LOGIC;
			sel_defer_addr : OUT STD_LOGIC;
			ld_addr : OUT STD_LOGIC;
			sel_defer_attr : OUT STD_LOGIC;
			sel_cpu_attr : OUT STD_LOGIC;
			ld_attr : OUT STD_LOGIC;
            sel_RS_cpu : OUT STD_LOGIC;
			sel_RS_pch : OUT STD_LOGIC;
			sel_RS_defer: OUT STD_LOGIC;
            Write_to_RequestBuffer : OUT STD_LOGIC;
			RequestBuffer_erase : OUT STD_LOGIC;
            in_order_exist : IN STD_LOGIC;
			valid : IN STD_LOGIC;
			is_deferred :IN STD_LOGIC;
            sel_RB_DID : OUT STD_LOGIC;  -- Request Buffer
			sel_DR_DID : OUT STD_LOGIC;  -- Deffered Response
			sel_cpu_DID : OUT STD_LOGIC;
            ld_length: OUT STD_LOGIC;
            ld_len_cnt : OUT STD_LOGIC;
			cnt_en : OUT STD_LOGIC;
            co_len : IN STD_LOGIC;
            sel_len_cpu : OUT STD_LOGIC;
			sel_len_pch : OUT STD_LOGIC;
			sel_len_defer : OUT STD_LOGIC;
            length_0 : IN STD_LOGIC;
            sel_cnfg_mem :OUT STD_LOGIC;
            ld_cnfg_addr : OUT STD_LOGIC;
			cnfg_en : OUT STD_LOGIC;
			cnfg_rd_wr : OUT STD_LOGIC;
			cnfg_addr31 : IN STD_LOGIC;
            sel_shift_RB : OUT STD_LOGIC;  --Shift Addr
			sel_shift_DR : OUT STD_LOGIC;  --Shift Addr
			sel_shift_cpu : OUT STD_LOGIC; --Shift Addr
			ld_shift_addr : OUT STD_LOGIC; --Shift Addr
            mem : IN STD_LOGIC;
			io : IN STD_LOGIC;
			rd : IN STD_LOGIC;
			wr : IN STD_LOGIC;
			special_in : IN STD_LOGIC;
            sel_data_first_part : OUT STD_LOGIC;
			sel_data_second_part : OUT STD_LOGIC;
			sel_data_full_part : OUT STD_LOGIC;
			ld_read_register : OUT STD_LOGIC;
            special_sig : OUT STD_LOGIC;
            response_shift_addr : IN STD_LOGIC;
            sel_data_from_pch : OUT STD_LOGIC;
			sel_data_from_DR_fifo : OUT STD_LOGIC;
            CF8_flag :IN STD_LOGIC;
			CFC_flag :IN STD_LOGIC;
			DRAM_flag :IN STD_LOGIC;
			-- Vivado OTHERS_flag :IN STD_LOGIC;
			MMIO_flag :IN STD_LOGIC;
			CnfgSpace_flag :IN STD_LOGIC;
        --  CF8_flag,CFC_flag,DRAM_flag,OTHERS_flag,MMIO_flag,CnfgSpace_flag :OUT STD_LOGIC;
            is_cmpl : IN STD_LOGIC;
			with_data : IN STD_LOGIC;
            cnfg_itself : IN STD_LOGIC;
			ld_hdr0 : OUT STD_LOGIC;
			sel_hdr0_cpu : OUT STD_LOGIC;
			sel_hdr0_pch : OUT STD_LOGIC;
			ld_hdr1 : OUT STD_LOGIC;
			sel_hdr1_cpu : OUT STD_LOGIC;
			sel_hdr1_pch : OUT STD_LOGIC;
			ld_hdr2 : OUT STD_LOGIC;
			sel_hdr2_cpu : OUT STD_LOGIC;
			sel_hdr2_pch : OUT STD_LOGIC;
            sel_hdr0 : OUT STD_LOGIC;
			sel_hdr1 : OUT STD_LOGIC;
			sel_hdr2 : OUT STD_LOGIC;
            sel_hdr_to_pch : OUT STD_LOGIC;
			sel_cpu_to_pch : OUT STD_LOGIC;
			sel_pch_to_pch : OUT STD_LOGIC;
			sel_ddr_to_pch : OUT STD_LOGIC;
            sel_data_to_DR_fifo : OUT STD_LOGIC;    -- Deffered Response
			sel_header_to_DR_fifo : OUT STD_LOGIC;	-- Deffered Response
            pop_DR_fifo : OUT STD_LOGIC;			-- Deffered Response
			push_DR_fifo : OUT STD_LOGIC;			-- Deffered Response
			defer_fifo_empty : IN STD_LOGIC;
			DR_rd : IN STD_LOGIC;
			DR_wr : IN STD_LOGIC;
			cpu_defer_rd : IN STD_LOGIC;
			cpu_defer_wr : IN STD_LOGIC;
			ld_wr_rd_reg : OUT STD_LOGIC
		);		
END North_Bridge_Controller;
	
ARCHITECTURE behavioral OF North_Bridge_Controller IS
   
	TYPE state IS (IDLE,LD_CPU_REQ,CPU_REQ,
                  SPECIAL,--Special Branch
                  IO_0,WAIT1_ON_SEND_FIFO,LD_HDR,CPU_HDR_0,CPU_HDR_1,CPU_HDR_2,DEFER_READ_RS,DEFER_WRITE_RS,WRITE_RS,
                  WAIT1_ON_CPU,FIRST_WRITE_DATA,WAIT2_ON_SEND_FIFO,WRITE_1,WRITE_2, --IO Branch
                  WAIT2_ON_CPU,POP_CNFG_ADDR,CHECK_CNFG_ADDR,IDLE_CNFG,CPU_REQ_CNFG,CF8_RS,
                  CPU_REQ_CNFG_CHECK,CNFG,ITSELF_NB,
                  READ_CNFG_RS,WRITE_CNFG_RS,READ_WAIT2,WRITE_WAIT,PUSH_CNFG,READ_CNFG,POP_CNFG,WRITE_CNFG,
                  DEFER_ITCNFG_RS,WAIT6_ON_CPU,POP_CNFG_DEFER,WRITE_CNFG_DEFER,LD2CPU1,WAIT3_ON_CPU,CPU_RS1_WR,DUMMY1,CPU_RS1_RD,READ_WAIT3,PUSH_CNFG_DEFER,READ_CNFG_DEFER, --CNFG Branch
                  DEFER_IDLE,POP_DR_HD,DEFER_DR_REQ,WAIT4_ON_CPU,CPU_RS3,READ_WAIT1,FIRST_PCH_READ1,SECOND_PCH_READ1,
                  CPU_WAIT1,PUSH_DEFER, --DEFER Branch
                  PCH_HDR_0,PCH_HDR_1,PCH_HDR_2,
                  CHECK_CMPL,ERASE_CMPL,	--Compeltion From PCH Branch
				  READ_CMPL_RS,LD2CPU2,WAIT5_ON_CPU,PCH_RS1_WR,DUMMY2,PCH_RS1_RD,READ_WAIT4,FIRST_PCH_READ2,SECOND_PCH_READ2,CPU_WAIT2,PUSH_CPU,
				  PUSH_HDR_DR_FIFO,FIRST_PCH_READ3,SECOND_PCH_READ3,PUSH_DATA_DR_FIFO,
				  EXCEPTION ----EXCEPTION
				  
                  --MEM_0,MMIO,DDR,WRITE_DDR,READ_WAIT_DDR,READ_DDR,
                  --WAIT2_ON_CPU,POP_CNFG_Addr,IDLE_CNFG,CPU_REG_CNFG,
                  --CNFG,DOWN_STREAM,ITSELF_NB 
                  );
	SIGNAL pstate, nstate :state := IDLE;
	
BEGIN

	----------------------------------------------------------------------------------------------------
	----------------- Sequential Part ------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	
	PROCESS (clk, rst)
		
	BEGIN
		IF (rst = '1') THEN
			pstate <= idle;
		ELSIF (clk = '1' AND clk'EVENT) THEN
			pstate <= nstate ;
		END IF;
	END PROCESS;
	
	----------------------------------------------------------------------------------------------------
	----------------- Combinaitonal next state block (mealy) -------------------------------------------
	----------------------------------------------------------------------------------------------------

	PROCESS (pstate, start_cpu, start_pch, special_in, io, CF8_flag, ready_pch,
				DEN, wr, rd, co_len, empty, cnfg_addr31, CFC_flag, cnfg_itself, full,
				ready_cpu, RS_ready, RS_cpu, in_order_exist, defer_fifo_empty,
				is_cmpl, valid, with_data, 
				DR_wr, DR_rd, is_deferred, cpu_defer_rd, cpu_defer_wr, mem, MMIO_flag ) 
	BEGIN 

		nstate <= IDLE;

		CASE pstate IS  

			WHEN IDLE =>
				IF (start_cpu='1') THEN 
					nstate <= LD_CPU_REQ;
				ELSIF(start_pch='1') THEN 
					nstate <= PCH_HDR_0;
				ELSE
					nstate <= IDLE;
				END IF;
	
			WHEN LD_CPU_REQ =>
				nstate <= CPU_REQ;

			WHEN CPU_REQ =>						-- Note In this edition IF(mem='1') isn't consider
				IF (special_in = '1') THEN
					nstate <= SPECIAL;
				ELSIF (io = '1') THEN
					nstate <= IO_0;
				ELSIF (mem='1' AND MMIO_flag='1') THEN
					nstate <= IO_0;
				ELSE 
					nstate <= CPU_REQ;
				END IF;
			-----------------------------Attention SPECIAL isn't consider-------------------------------------					
			---WHEN SPECIAL =>
				--nstate <= IDLE;
			------------------------------------- IO    Branch -----------------------------------------------
			WHEN IO_0 => 
				IF(CF8_flag = '0') THEN 
--					nstate <= WAIT_ON_PCH;
					nstate <= LD_HDR;
				ELSIF(CF8_flag = '1') THEN	
					nstate <= CF8_RS;
--					nstate <= WAIT2_ON_CPU;
				ELSE
					nstate <= IO_0;
				END IF;
			
--			WHEN WAIT_ON_PCH =>
--				IF (ready_pch <= '0') THEN 
--					nstate <= WAIT_ON_PCH;
--				elsIF (ready_pch <= '1') THEN
--					nstate <= LD_HDR;
--				ELSE
--					nstate <= WAIT_ON_PCH;
--				END IF;

			WHEN LD_HDR =>
--				nstate <= CPU_HDR_0;
				nstate <= WAIT1_ON_SEND_FIFO;


			WHEN WAIT1_ON_SEND_FIFO =>
			nstate <= WAIT1_ON_SEND_FIFO; 
			if (ready_pch <= '0') then 
				nstate <= WAIT1_ON_SEND_FIFO;
			elsif (ready_pch <= '1') then
				nstate <= CPU_HDR_0;
			end if;	
			

			WHEN CPU_HDR_0 =>
				nstate <= CPU_HDR_1;

			WHEN CPU_HDR_1 =>
				nstate <= CPU_HDR_2;

			WHEN CPU_HDR_2 =>
				IF(DEN = '1' AND wr = '1') THEN
					nstate <= DEFER_WRITE_RS;
				ELSIF (DEN = '0' AND wr = '1') THEN
					nstate <= WRITE_RS;
				ELSIF (DEN = '0' AND rd = '1') THEN
					nstate <= IDLE;
				ELSIF (DEN = '1' AND rd = '1') THEN
					nstate <= DEFER_READ_RS;
				ELSE
					nstate <= CPU_HDR_2;
				END IF;

			WHEN DEFER_READ_RS =>
				nstate <= IDLE;

			WHEN DEFER_WRITE_RS =>
				IF(co_len = '1' ) THEN
				   nstate <= IDLE;
				ELSIF (empty = '1' AND co_len = '0') THEN
				   nstate <= WAIT1_ON_CPU;
				ELSIF (empty = '0' AND co_len = '0') THEN 
				   nstate <= First_Write_Data;
				ELSE
					nstate <= DEFER_WRITE_RS;
				END IF;
					 	
			WHEN WRITE_RS =>
				IF (co_len = '1') THEN
					nstate <= IDLE;
				ELSIF (empty = '0' AND co_len = '0') THEN
					nstate <= First_Write_Data;
				ELSIF (empty = '1' AND co_len = '0') THEN
					nstate <= WAIT1_ON_CPU;
				ELSE
					nstate <= WRITE_RS;
				END IF;

			WHEN WAIT1_ON_CPU =>
				IF(empty ='1') THEN
					nstate <= WAIT1_ON_CPU;
				ELSIF (empty = '0') THEN
					nstate <= First_Write_Data;
				ELSE
					nstate <= WAIT1_ON_CPU;
				END IF;
			
			WHEN FIRST_WRITE_DATA =>
--				nstate <= WRITE_1;
				nstate <= WAIT2_ON_SEND_FIFO;

			WHEN WAIT2_ON_SEND_FIFO =>
				IF (ready_pch <= '0') THEN 
					nstate <= WAIT2_ON_SEND_FIFO;
				ELSIF (ready_pch <= '1') THEN
					nstate <= WRITE_1;
				ELSE
					nstate <= WAIT2_ON_SEND_FIFO;
				END IF;
				
			
			WHEN WRITE_1 =>
				IF (co_len = '1') THEN
					nstate <= IDLE;
				ELSE
					nstate <= WRITE_2;
				END IF;
			
			WHEN WRITE_2 =>
				IF (co_len = '1') THEN
					nstate <= IDLE;
				ELSIF (co_len = '0' AND empty ='1') THEN
					nstate <= WAIT1_ON_CPU;
				ELSE
					nstate <= FIRST_WRITE_DATA;
				END IF;
			------------------------- CNFG  Branch -----------------------------------------------
			
			WHEN CF8_RS =>
				IF (empty = '0') then
					nstate <= POP_CNFG_ADDR;
				ELSE 
					nstate <= WAIT2_ON_CPU;
				END IF;
			
			WHEN WAIT2_ON_CPU =>
				IF (empty ='1') THEN
					nstate <= WAIT2_ON_CPU;
				ELSE
					nstate <= POP_CNFG_ADDR;
				END IF;

			WHEN POP_CNFG_ADDR =>
				nstate <= CHECK_CNFG_ADDR;

			WHEN CHECK_CNFG_ADDR =>
				IF (cnfg_addr31 ='1') THEN
					nstate <= IDLE_CNFG;
				ELSE
					nstate <= IO_0;
				END IF;	
			
			WHEN IDLE_CNFG =>
				IF (start_cpu = '1') THEN
					nstate <= CPU_REQ_CNFG;
				ELSE
					nstate <= IDLE_CNFG;
				END IF;
						
			WHEN CPU_REQ_CNFG =>
				nstate <= CPU_REQ_CNFG_CHECK;

			WHEN CPU_REQ_CNFG_CHECK =>
				IF (CFC_flag = '0') THEN
					nstate <= EXCEPTION;
				ELSIF (CFC_flag = '1' AND io = '1') THEN 
					nstate <= CNFG;
				ELSE	-- ???
					nstate <= CPU_REQ_CNFG_CHECK;
				END IF;
	
			WHEN CNFG =>
				IF (cnfg_itself = '0') THEN 
					nstate <= LD_HDR;
				ELSE 
					nstate <= ITSELF_NB;
				END IF;

			WHEN ITSELF_NB =>
				IF(DEN = '1') THEN 
					nstate <= DEFER_ITCNFG_RS;
				ELSIF (DEN = '0' AND wr = '1') THEN
					nstate <= WRITE_CNFG_RS;
				ELSIF (DEN = '0' AND rd = '1') THEN
					nstate <= READ_CNFG_RS;
				ELSE	-- ???
					nstate <= ITSELF_NB ;
				END IF;
			
			-----------------(DEN = '0' AND wr = '1')----------	
			WHEN WRITE_CNFG_RS =>
				IF (empty ='1') THEN
					nstate <= WRITE_WAIT;
				ELSE
					nstate <= POP_CNFG;
				END IF;
			
			WHEN WRITE_WAIT =>	
				IF (empty ='1') THEN
					nstate <= WRITE_WAIT;
				ELSE
					nstate <= POP_CNFG;
				END IF;

			WHEN POP_CNFG =>
				nstate <= WRITE_CNFG;
						
			WHEN WRITE_CNFG =>	
				nstate <= IDLE;
				
			------------------ (DEN = '0' AND rd = '1') -------
			WHEN READ_CNFG_RS =>
				IF (full ='1') THEN
					nstate <= READ_WAIT2;
				ELSE
					nstate <= READ_CNFG;
				END IF;

			WHEN READ_WAIT2 =>
				IF (full ='1') THEN
					nstate <= READ_WAIT2;
				ELSE
					nstate <= READ_CNFG;
				END IF;
						
			WHEN READ_CNFG =>
				nstate <= PUSH_CNFG;

			WHEN PUSH_CNFG =>
				nstate <= IDLE;

			--------------------(DEN = '1')-------------------
			WHEN DEFER_ITCNFG_RS =>
				IF (empty ='1' AND wr = '1') THEN
					nstate <= WAIT6_ON_CPU;
				ELSIF (empty ='0' AND wr = '1') THEN
					nstate <= POP_CNFG_DEFER;
				ELSIF (rd = '1') THEN
					nstate <= LD2CPU1;
				ELSE	-- ???
					nstate <= DEFER_ITCNFG_RS;
				END IF;

			WHEN WAIT6_ON_CPU =>
				IF (empty ='1') THEN
					nstate <= WAIT6_ON_CPU;
				ELSE
					nstate <= POP_CNFG_DEFER;
				END IF;
					
			WHEN POP_CNFG_DEFER =>
				nstate <= WRITE_CNFG_DEFER;

			WHEN WRITE_CNFG_DEFER =>
				nstate <= LD2CPU1;

			WHEN LD2CPU1 =>
				nstate <= WAIT3_ON_CPU;

			WHEN WAIT3_ON_CPU =>
				IF (ready_cpu ='1' AND cpu_defer_wr ='1') THEN
					nstate <= CPU_RS1_WR;
				ELSIF (ready_cpu ='1' AND cpu_defer_rd ='1') THEN
					nstate <= CPU_RS1_RD;
				ELSIF (ready_cpu ='0') THEN
					nstate <= WAIT3_ON_CPU;
				END IF;


			WHEN CPU_RS1_WR =>								
				nstate <= DUMMY1;

			WHEN DUMMY1 =>							
				nstate <= IDLE;
			
			WHEN CPU_RS1_RD =>								
				nstate <= CPU_RS1_RD;
				IF (full ='1') THEN
					nstate <= READ_WAIT3;
				ELSIF(full = '0') THEN
					nstate <= READ_CNFG_DEFER;
				END IF;

			WHEN READ_WAIT3 =>
				IF (full ='1') THEN
					nstate <= READ_WAIT3;
				ELSE
					nstate <= READ_CNFG_DEFER;
				END IF;		

			WHEN READ_CNFG_DEFER =>
				nstate <= PUSH_CNFG_DEFER;

			WHEN PUSH_CNFG_DEFER =>
				nstate <= IDLE;
				
			--------------------------DEFER Branch------------------------------------------------
			WHEN DEFER_IDLE =>
				IF(in_order_exist = '1' OR defer_fifo_empty = '1') THEN
					nstate <= IDLE;
				ELSE
					nstate <= POP_DR_HD;
				END IF;

			WHEN POP_DR_HD =>
				nstate <= DEFER_DR_REQ;

			WHEN DEFER_DR_REQ =>
				nstate <= WAIT4_ON_CPU;

			WHEN WAIT4_ON_CPU =>
				IF (ready_cpu ='1') THEN
					nstate <= CPU_RS3;
				ELSIF (ready_cpu ='0') THEN
					nstate <= WAIT4_ON_CPU;
				ELSE
					nstate <= WAIT4_ON_CPU;
				END IF;

			WHEN CPU_RS3 =>
				IF (RS_Ready ='0') THEN
					nstate <= CPU_RS3;
				------Attention------------
				--ELSIF (RS_cpu = "") THEN -- error
				ELSIF(RS_cpu = "111" AND DR_wr ='1') THEN --normal data
					nstate <= DEFER_IDLE;
				ELSIF(RS_cpu = "111" AND DR_rd ='1') THEN --normal data
					nstate <= READ_WAIT1;
				ELSE
					nstate <= CPU_RS3;
				END IF;
					
			WHEN READ_WAIT1 =>
				IF (full ='1') THEN
					nstate <= READ_WAIT1;
				ELSE
					nstate <= FIRST_PCH_READ1;
				END IF;

			WHEN FIRST_PCH_READ1 =>
				IF (co_len ='0') THEN
					nstate <= SECOND_PCH_READ1;
				ELSE
					nstate <= FIRST_PCH_READ1;
				END IF;
					
			WHEN SECOND_PCH_READ1 =>
				IF (full = '1' ) THEN 
					nstate <= CPU_WAIT1;
				ELSIF(full ='0') THEN
					nstate <= PUSH_DEFER;
				ELSE
					nstate <= SECOND_PCH_READ1;
				END IF;

			WHEN CPU_WAIT1 =>
				IF (full = '1' ) THEN 
					nstate <= CPU_WAIT1;
				ELSIF(full ='0') THEN
					nstate <= PUSH_DEFER;
				ELSE
					nstate <= CPU_WAIT1;
				END IF;
					
			WHEN PUSH_DEFER =>
				IF (co_len ='1') THEN
					nstate <= DEFER_IDLE;
				ELSE
					nstate <= FIRST_PCH_READ1;
				END IF;

			--------------------------From PCH Branch---------------------------------------------
			WHEN PCH_HDR_0 =>
				nstate <= PCH_HDR_1;

			WHEN PCH_HDR_1 =>
				nstate <= PCH_HDR_2;

			WHEN PCH_HDR_2 =>
				IF(is_cmpl = '1') THEN 
					nstate <= CHECK_CMPL;
				----------Attention------------
				---	ELSIF (io_req) THEN
				---	ELSIF (is_message) THEN
				ELSE
					nstate <= PCH_HDR_2;
				END IF;	
				
			----------Completion Branch----------------------------------------------------------					
			WHEN CHECK_CMPL =>
				IF(valid ='1' AND is_deferred = '0' AND with_data = '0') THEN
					nstate <= ERASE_CMPL;
				ELSIF (valid ='1' AND is_deferred = '0' AND with_data = '1') THEN
					nstate <= READ_CMPL_RS;
				ELSIF (valid ='1' AND is_deferred = '1' AND in_order_exist = '0') THEN
					nstate <= LD2CPU2;
				ELSIF (valid ='1' AND is_deferred = '1' AND in_order_exist = '1') THEN
					nstate <= PUSH_HDR_DR_FIFO;
				--ELSIF(valid = '0') THEN
				--	nstate <= Unexpected Competion;
				ELSE
					nstate <= CHECK_CMPL;
				END IF;

			WHEN ERASE_CMPL =>
				nstate <= DEFER_IDLE;

			WHEN READ_CMPL_RS =>
				nstate <= READ_WAIT4;

			WHEN LD2CPU2 =>
				nstate <= WAIT5_ON_CPU;
					
			WHEN WAIT5_ON_CPU =>
			    IF (ready_cpu ='1' AND with_data='1' ) THEN
					nstate <= PCH_RS1_RD;
				ELSIF (ready_cpu ='1' AND with_data='0' ) THEN
					nstate <= PCH_RS1_WR;
				else
					nstate <= WAIT5_ON_CPU;
				END IF;

			WHEN PCH_RS1_WR =>
					nstate <= DUMMY2;
			

			WHEN DUMMY2 =>
					nstate <= DEFER_IDLE;		

					
			WHEN PCH_RS1_RD =>
					nstate <= READ_WAIT4;
					
			WHEN READ_WAIT4 =>
				IF (full ='1') THEN
					nstate <= READ_WAIT4;
				ELSE
					nstate <= FIRST_PCH_READ2;
				END IF;

--			WHEN FIRST_PCH_READ2 =>
--				IF (co_len ='0') THEN
--					nstate <= SECOND_PCH_READ2;
--				ELSE
--					nstate <= FIRST_PCH_READ2;
--				END IF;

			WHEN FIRST_PCH_READ2 =>
				IF (full ='1') THEN
					nstate <= CPU_WAIT2;
				ELSE
					nstate <= PUSH_CPU;
				END IF;

			WHEN SECOND_PCH_READ2 =>
				IF (full ='1') THEN
					nstate <= CPU_WAIT2;
				ELSE
					nstate <= PUSH_CPU;
				END IF;

			WHEN CPU_WAIT2 =>
				IF (full ='1') THEN
					nstate <= CPU_WAIT2;
				ELSE
					nstate <= PUSH_CPU;
				END IF;
					
			WHEN PUSH_CPU =>
				nstate <= PUSH_CPU;
				IF (co_len ='1') THEN
					nstate <= DEFER_IDLE;
				ELSE
					nstate <= FIRST_PCH_READ2;
				END IF;

			WHEN PUSH_HDR_DR_FIFO =>
				IF (with_data ='1') THEN
					nstate <= FIRST_PCH_READ3;
				ELSE
					nstate <= IDLE;
				END IF;

			WHEN FIRST_PCH_READ3 => 
				IF(co_len ='1') THEN
					nstate <= PUSH_DATA_DR_FIFO;
				ELSE
					nstate <= SECOND_PCH_READ3;
				END IF;
						
			WHEN SECOND_PCH_READ3 => 
				IF (co_len = '1') THEN 
					nstate <= PUSH_DATA_DR_FIFO;
				ELSE
					nstate <= SECOND_PCH_READ3;
				END IF;	


			WHEN PUSH_DATA_DR_FIFO => 			
				nstate <= IDLE;

			WHEN OTHERS =>
				nstate <= IDLE;	
        END CASE;				
	END PROCESS;

	----------------------------------------------------------------------------------------------------
	----------------- Combinaitonal outputs block (mealy) -----------------------------------------------
	----------------------------------------------------------------------------------------------------

	PROCESS (pstate, start_cpu, start_pch, special_in, io, CF8_flag, ready_pch,
				DEN, co_len, empty, cnfg_addr31, CFC_flag, cnfg_itself, full,
				rd, ready_cpu, RS_ready, RS_cpu, in_order_exist, defer_fifo_empty,
				length_0, response_shift_addr, is_cmpl, valid, with_data, wr,
				DR_wr, DR_rd, is_deferred, cpu_defer_rd, cpu_defer_wr, mem, MMIO_flag ) 
	BEGIN 

    RS_ready_to_cpu <= '0';pop<= '0';push<= '0';ready_to_cpu<= '0';start_to_cpu<= '0';
    RS_controller<= (OTHERS =>'0');
    push_send_fifo <= '0'; pop_receive_fifo <= '0'; read_ready_to_pch <= '0';
--	start_to_pch <= '0'; 
    sel_cpu_req <= '0';sel_defer_req <= '0';ld_req <= '0';sel_cpu_addr <= '0';sel_defer_addr <= '0';ld_addr <= '0';sel_cpu_attr <= '0';sel_defer_attr <= '0';ld_attr <= '0';
    sel_RS_cpu <= '0';sel_RS_pch <= '0';sel_RS_defer <= '0';
    Write_to_RequestBuffer <= '0';RequestBuffer_erase <= '0';
    sel_RB_DID <= '0';sel_DR_DID <= '0';sel_cpu_DID <= '0';
    ld_length <= '0';
    ld_len_cnt <= '0';cnt_en <= '0';
    sel_len_cpu <= '0';sel_len_pch <= '0';sel_len_defer <= '0';
    sel_cnfg_mem <= '0';
    ld_cnfg_addr<= '0'; cnfg_en <= '0'; cnfg_rd_wr <= '0';
	sel_shift_RB <= '0';sel_shift_DR <= '0';sel_shift_cpu <= '0';ld_shift_addr <= '0';
    sel_data_first_part <= '0'; sel_data_second_part <= '0'; sel_data_full_part <= '0'; ld_read_register <= '0';
    special_sig <= '0';
    sel_data_from_pch <= '0';sel_data_from_DR_fifo <= '0';
    --CF8_flag <= '0';CFC_flag <= '0';DRAM_flag <= '0';OTHERS_flag <= '0';MMIO_flag <= '0';CnfgSpace_flag <= '0';
    sel_hdr0 <= '0';sel_hdr1 <= '0';sel_hdr2 <= '0';
    sel_hdr_to_pch <= '0';sel_cpu_to_pch <= '0';sel_pch_to_pch <= '0';sel_ddr_to_pch <= '0';
    sel_data_to_DR_fifo <= '0'; sel_header_to_DR_fifo <= '0'; 
    pop_DR_fifo <= '0'; push_DR_fifo <= '0';
	sel_hdr0_pch <='0'; sel_hdr1_pch <= '0'; sel_hdr2_pch <= '0';
	ld_hdr0 <='0'; ld_hdr1 <='0'; ld_hdr2 <='0'; 
	sel_hdr0_cpu <='0'; sel_hdr1_cpu <='0'; sel_hdr2_cpu <='0'; 
	ld_wr_rd_reg <= '0';

		CASE pstate IS  

			WHEN IDLE =>
				ready_to_cpu <= '1';
		--		ready_to_pch <= '1';
	
			WHEN LD_CPU_REQ =>
				ld_req <= '1';  sel_cpu_req <= '1';
				ld_addr <= '1'; sel_cpu_addr <= '1';
				ld_attr <= '1'; sel_cpu_attr <= '1';

			WHEN CPU_REQ =>
				-- Note In this edition IF(mem='1') isn't consider
				
			------------------------------------- IO    Branch -----------------------------------------------
			WHEN IO_0 => 
				ld_len_cnt <= '1'; sel_len_cpu <= '1';
				ld_length <= '1';  sel_shift_cpu <= '1';
				ld_shift_addr <= '1';
				
--			WHEN WAIT_ON_PCH =>
--				start_to_pch <= '1';

			WHEN LD_HDR =>
					ld_hdr0 <= '1'; ld_hdr1 <= '1'; ld_hdr2 <= '1';
					sel_hdr0_cpu <= '1'; sel_hdr1_cpu <= '1'; sel_hdr2_cpu <= '1';
					Write_to_RequestBuffer <='1';

			WHEN WAIT1_ON_SEND_FIFO =>
--				    start_to_pch <= '1';

			WHEN CPU_HDR_0 =>
					sel_hdr0 <= '1'; sel_hdr_to_pch <= '1';
					push_send_fifo <= '1';
--					data_valid_to_pch <= '1';

			WHEN CPU_HDR_1 =>
					sel_hdr1 <= '1'; sel_hdr_to_pch <= '1';
					push_send_fifo <= '1';
--					data_valid_to_pch <= '1';

			WHEN CPU_HDR_2 =>
				   sel_hdr2 <= '1'; sel_hdr_to_pch <= '1';
				   push_send_fifo <= '1';
--			       data_valid_to_pch <= '1';

			WHEN DEFER_READ_RS =>
				   RS_controller <= "010"; RS_ready_to_cpu <= '1';
				   sel_RS_defer <= '1';

			WHEN DEFER_WRITE_RS =>
					RS_controller <= "010"; RS_ready_to_cpu <= '1';
					sel_RS_cpu <= '1';	 	
			WHEN WRITE_RS =>
					RS_controller<= "101"; RS_ready_to_cpu <= '1';
					sel_RS_cpu <= '1';

			WHEN WAIT1_ON_CPU =>
					
			WHEN FIRST_WRITE_DATA =>
					pop <= '1'; cnt_en <= '1';


			WHEN WAIT2_ON_SEND_FIFO =>
			
					
			WHEN WRITE_1 =>
--					data_valid_to_pch <= '1';
					push_send_fifo <= '1';
					sel_cpu_to_pch <= '1';
					cnt_en <= '1';
					IF (length_0 = '1' ) THEN
						IF(response_shift_addr = '1' ) THEN
							sel_data_second_part <= '1';
						ELSIF(response_shift_addr = '0') THEN
							sel_data_first_part <= '1';
						END IF;
					ELSIF(length_0 = '0') THEN
						sel_data_first_part <= '1';
					END IF;
					
			WHEN WRITE_2 =>
--				    data_valid_to_pch <= '1';
					push_send_fifo <= '1';
					sel_data_second_part <= '1';
					sel_cpu_to_pch <= '1';
					
			------------------------------------- CNFG  Branch -----------------------------------------------
			
			WHEN CF8_RS =>
				RS_controller<= "101";
				RS_ready_to_cpu <= '1';
				sel_RS_cpu <= '1';
						
			WHEN WAIT2_ON_CPU =>
				

			WHEN POP_CNFG_ADDR =>
					pop <= '1';

			WHEN CHECK_CNFG_ADDR =>
			        ld_cnfg_addr <= '1';
					sel_data_first_part <= '1';
					
			WHEN IDLE_CNFG =>
					ready_to_cpu <= '1';
						
			WHEN CPU_REQ_CNFG =>
					ld_req  <= '1';  sel_cpu_req <= '1';
					ld_addr <= '1';  sel_cpu_addr <= '1';
					ld_attr <= '1';  sel_cpu_attr <= '1';

			WHEN CPU_REQ_CNFG_CHECK =>
	
			WHEN CNFG =>
					ld_len_cnt  <= '1';sel_len_cpu <= '1';
					ld_length   <= '1';sel_shift_cpu <= '1';
					ld_shift_addr <= '1';

			WHEN ITSELF_NB =>
			
			-------------------------(DEN = '0' AND wr = '1')------------
			WHEN WRITE_CNFG_RS =>
					RS_controller <= "101"; RS_ready_to_cpu <= '1';
				    sel_RS_cpu <= '1';
			
			WHEN WRITE_WAIT =>	

			WHEN POP_CNFG =>
					pop <= '1';
						
			WHEN WRITE_CNFG =>	
					cnfg_en <= '1';
				    cnfg_rd_wr <= '1';
					sel_data_second_part <= '1';
					
			-------------------------- (DEN = '0' AND rd = '1') ----------
			WHEN READ_CNFG_RS =>
					RS_controller <= "111"; RS_ready_to_cpu <= '1';
					sel_RS_cpu <= '1';

			WHEN READ_WAIT2 =>
						
			WHEN READ_CNFG =>

					cnfg_en <= '1';
					cnfg_rd_wr <= '0';
					sel_cnfg_mem <= '1';
					ld_read_register <= '1';

			WHEN PUSH_CNFG =>
					push <= '1';
					sel_data_second_part <= '1';

			----------------------------(DEN = '1')------------------------
			WHEN DEFER_ITCNFG_RS =>
					RS_controller <= "010"; RS_ready_to_cpu <= '1';
			        sel_RS_defer <= '1';

			WHEN WAIT6_ON_CPU =>
					
			WHEN POP_CNFG_DEFER =>
				    pop <= '1';

			WHEN WRITE_CNFG_DEFER =>
					cnfg_rd_wr <= '1';
					sel_data_second_part <= '1';
					cnfg_en <= '1';

			WHEN LD2CPU1 =>
					ld_req <= '1';        sel_defer_req <= '1';
					ld_addr <= '1';       sel_defer_addr <= '1';
					ld_attr <= '1';       sel_defer_attr <= '1';
					sel_cpu_DID <= '1';    
					ld_wr_rd_reg <= '1';

			WHEN WAIT3_ON_CPU =>
					start_to_cpu <= '1';
					ready_to_cpu <= '1';
					
			WHEN CPU_RS1_WR =>	
					RS_controller <= "101";
					RS_ready_to_cpu <= '1';
					sel_RS_cpu <= '1';

			WHEN DUMMY1 =>

			WHEN CPU_RS1_RD =>								
					RS_controller <= "111";
					RS_ready_to_cpu <= '1';
					sel_RS_cpu <= '1';

			WHEN READ_WAIT3 =>

			WHEN READ_CNFG_DEFER =>
					sel_cnfg_mem <= '1';
					cnfg_en <= '1';	
					cnfg_rd_wr <= '0';
					ld_read_register <= '1';

			WHEN PUSH_CNFG_DEFER =>
					push <= '1';
					sel_data_second_part <= '1';

			--------------------------------------DEFER Branch----------------------------------------------
			WHEN DEFER_IDLE =>

			WHEN POP_DR_HD =>
					pop_DR_fifo <= '1';

			WHEN DEFER_DR_REQ =>
					ld_req <= '1';         sel_defer_req <= '1';
					ld_addr <= '1';        sel_defer_addr <= '1';
					ld_attr <= '1';        sel_defer_attr <= '1';
					sel_len_defer <= '1';  ld_len_cnt <= '1';
					sel_DR_DID <= '1';     ld_length <= '1';
					sel_shift_DR <= '1';   ld_shift_addr <= '1';

			WHEN WAIT4_ON_CPU =>
				    start_to_cpu <= '1';

			WHEN CPU_RS3 =>
					
			WHEN READ_WAIT1 =>

			WHEN FIRST_PCH_READ1 =>
					pop_DR_fifo <= '1'; cnt_en <= '1';
					
			WHEN SECOND_PCH_READ1 =>
					pop_DR_fifo <= '1'; ld_read_register <= '1';
					cnt_en <= '1'; sel_data_from_DR_fifo <= '1';

			WHEN CPU_WAIT1 =>
					
			WHEN PUSH_DEFER =>
					push <= '1';
					sel_data_from_DR_fifo <= '1';
					IF (length_0 = '1' ) THEN
						IF(response_shift_addr = '1' ) THEN
							sel_data_second_part <= '1';
						ELSIF(response_shift_addr = '0') THEN
							sel_data_first_part <= '1';
						END IF;
					ELSIF(length_0 = '0') THEN
						sel_data_full_part <= '1';
					END IF;

			--------------------------------------From PCH Branch---------------------------------------------
			WHEN PCH_HDR_0 =>
					ld_hdr0 <= '1';
					sel_hdr0_pch <= '1';
					pop_receive_fifo <= '1';

			WHEN PCH_HDR_1 =>
					ld_hdr1 <= '1';
					sel_hdr1_pch <= '1';
					pop_receive_fifo <= '1';

			WHEN PCH_HDR_2 =>
					ld_hdr2 <= '1';
					sel_hdr2_pch <= '1';
					pop_receive_fifo <= '1';
				
			-------------Completion Branch----------------------------------------------------------------------					
			WHEN CHECK_CMPL =>
					ld_len_cnt <= '1'; sel_len_pch <= '1';
					ld_length <= '1';    sel_shift_RB <= '1';
					ld_shift_addr <= '1';

			WHEN ERASE_CMPL =>
					RequestBuffer_erase <= '1';

			WHEN READ_CMPL_RS =>
					RS_controller <= "111";          RS_ready_to_cpu <= '1';
					sel_RS_pch <= '1';   RequestBuffer_erase <= '1';

			WHEN LD2CPU2 =>
				    ld_req <= '1';        sel_defer_req <= '1';
					ld_addr <= '1';       sel_defer_addr <= '1';
					ld_attr <= '1';       sel_defer_attr <= '1';
					RequestBuffer_erase <= '1';
					sel_RB_DID <= '1'; 
					
			WHEN WAIT5_ON_CPU =>
					start_to_cpu <= '1';
					ready_to_cpu <= '1';
					
			
			WHEN PCH_RS1_WR =>
					RS_controller <= "101";
					RS_ready_to_cpu <= '1';
					sel_RS_pch <= '1';

			WHEN DUMMY2 =>
									
			
								
			WHEN PCH_RS1_RD =>
					RS_controller <= "111";
					RS_ready_to_cpu <= '1';
					sel_RS_pch <= '1';			


			WHEN READ_WAIT4 =>

--			WHEN FIRST_PCH_READ2 =>
--					read_ready_to_pch <= '1';
--					cnt_en <= '1';
--					pop_receive_fifo <= '1';
--					sel_data_from_pch <= '1';


			WHEN FIRST_PCH_READ2 =>
				    ld_read_register <= '1'; 
					read_ready_to_pch <= '1';
					cnt_en <= '1';
					pop_receive_fifo <= '1';
					sel_data_from_pch <= '1';

			WHEN SECOND_PCH_READ2 =>
					read_ready_to_pch <= '1';  cnt_en <= '1'; 
					ld_read_register <= '1';   sel_data_from_pch <= '1';
					pop_receive_fifo <= '1';

			WHEN CPU_WAIT2 =>
					
			WHEN PUSH_CPU =>
					push <= '1';
					sel_data_from_pch <= '1';
					IF (length_0 = '1' ) THEN
						IF(response_shift_addr = '1' ) THEN
							sel_data_second_part <= '1';
						ELSIF(response_shift_addr = '0') THEN
							sel_data_first_part <= '1';
						END IF;
					ELSIF(length_0 = '0') THEN
						sel_data_full_part <= '1';
					END IF;

			WHEN PUSH_HDR_DR_FIFO =>
				    push_DR_fifo <= '1';
					requestBuffer_erase <= '1';
					sel_header_to_DR_fifo <= '1';
					cnt_en <= '1';

			WHEN FIRST_PCH_READ3 => 
					read_ready_to_pch <= '1';  
					cnt_en <= '1';
						
			WHEN SECOND_PCH_READ3 => 
					read_ready_to_pch <= '1';
					push_DR_fifo <= '1';
					sel_data_to_DR_fifo <= '1';
					cnt_en <= '1';

			WHEN PUSH_DATA_DR_FIFO => 
					push_DR_fifo <= '1';
					sel_data_to_DR_fifo  <= '1';
			
			WHEN OTHERS => 

        END CASE;				
	END PROCESS;
	
END behavioral;



