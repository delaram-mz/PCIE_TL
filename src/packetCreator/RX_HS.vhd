--*****************************************************************************/
--	Filename:		RX_HS.vhd
--	Project:		MCI-PCH
--  Version:		1.000
--	History:		-
--	Date:			8 Augest 2023
--	Authors:	 	Delaram
--	Fist Author:    Delaram
--	Last Author: 	Delaram
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--
--*****************************************************************************/
--	File content description:
--  Controller, Datapath and Top module of TLP Creator: Receiver Hadshaking

--*****************************************************************************/

-- -------------------------------------------------------------
-- Controller
-- -------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY RX_HS_Controller IS 
PORT(
    clk           : IN STD_LOGIC;
    rst           : IN STD_LOGIC;

    tl_rx_dst_rdy : OUT STD_LOGIC;
    tl_rx_src_rdy : IN STD_LOGIC;
    tl_rx_src_sop : IN STD_LOGIC;
    tl_rx_src_eop : IN STD_LOGIC;
    tl_rx_src_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

    send_err_msg : OUT STD_LOGIC;
    err_msg_sent : IN STD_LOGIC;
    maxPayload : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
    
    rx_buff_push  : OUT STD_LOGIC;
    rx_buff_full  : IN STD_LOGIC
    );
END ENTITY RX_HS_Controller;

ARCHITECTURE Controller_ARC OF RX_HS_Controller IS

CONSTANT TLP_MRd    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
CONSTANT TLP_MWr    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000000";
CONSTANT TLP_IORd   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000010";
CONSTANT TLP_IOWr   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000010";
CONSTANT TLP_CfgRd0 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000100";
CONSTANT TLP_CfgWr0 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000100";
CONSTANT TLP_CfgRd1 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000101";
CONSTANT TLP_CfgWr1 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000101";
CONSTANT TLP_Cmpl   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00001010";
CONSTANT TLP_CmplD  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01001010";


CONSTANT maxPayload_128B : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
CONSTANT maxPayload_256B : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";
CONSTANT maxPayload_512B : STD_LOGIC_VECTOR(2 DOWNTO 0) := "010";
CONSTANT maxPayload_1024B : STD_LOGIC_VECTOR(2 DOWNTO 0) := "011";
CONSTANT maxPayload_2048B : STD_LOGIC_VECTOR(2 DOWNTO 0) := "100";
CONSTANT maxPayload_4096B : STD_LOGIC_VECTOR(2 DOWNTO 0) := "101";
CONSTANT maxPayload_reserved1 : STD_LOGIC_VECTOR(2 DOWNTO 0) := "110";
CONSTANT maxPayload_reserved2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := "111";

--STATE:
TYPE STATE IS (idle, hdr1, hdr2, hdr3, hdr3_eop, payload);
SIGNAL PSTATE, NSTATE : STATE;

SIGNAL malformed_flag_clr : STD_LOGIC;
SIGNAL malformed_flag_ld  : STD_LOGIC;
SIGNAL malformed_flag_out : STD_LOGIC;
SIGNAL malformed_flag_in  : STD_LOGIC;
SIGNAL send_err_msg_clr : STD_LOGIC;
SIGNAL send_err_msg_ld  : STD_LOGIC;
SIGNAL send_err_msg_out : STD_LOGIC;
SIGNAL send_err_msg_in  : STD_LOGIC;
SIGNAL len_reg_ld   : STD_LOGIC;
SIGNAL pl_cnt_en    : STD_LOGIC;
SIGNAL pl_cnt_rst   : STD_LOGIC;
SIGNAL typ_reg_in, typ_reg_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL typ_reg_ld : STD_LOGIC;
SIGNAL len_reg_out, expct_len  : STD_LOGIC_VECTOR (9 DOWNTO 0);
SIGNAL len_reg_in   : STD_LOGIC_VECTOR (9 DOWNTO 0);
SIGNAL pl_cnt_out   : STD_LOGIC_VECTOR (9 DOWNTO 0);

SIGNAL exceed_maxPayload : STD_LOGIC;
SIGNAL undefinedType : STD_LOGIC;
BEGIN
    -- normal functionality:
    -- tl_rx_dst_rdy <= NOT(rx_buff_full);
    -- rx_buff_push <= '1' WHEN (tl_rx_src_rdy='1' AND rx_buff_full='0') ELSE '0';


    tl_rx_dst_rdy <= (NOT(rx_buff_full)) AND (NOT(send_err_msg_out));
    rx_buff_push <= '1' WHEN (tl_rx_src_rdy='1' AND rx_buff_full='0' AND (send_err_msg_out = '0')) ELSE '0';


    -- observing the payload count:
--proccesses:
    NEXT_STATE:   PROCESS (clk , rst)
    BEGIN
        IF rst = '1' THEN
            PSTATE<= idle;
        ELSIF clk = '1' AND clk'EVENT THEN 
            PSTATE <= NSTATE;
        END IF;
    END PROCESS;

    STATE_TRANSITION:   PROCESS (PSTATE ,tl_rx_src_sop, rx_buff_push, tl_rx_src_eop) BEGIN
        NSTATE<=idle; --INACTIVE VALUE
        CASE PSTATE IS
            WHEN idle =>
                IF (tl_rx_src_sop = '1' AND rx_buff_push = '1') THEN
                    NSTATE <= hdr2;
                ELSE
                    NSTATE <= idle;
                END IF;
                            
            WHEN hdr2 =>
                IF (rx_buff_push = '0')THEN
                    NSTATE <= hdr2;
                ELSE
                    NSTATE <= hdr3;
                END IF;

            WHEN hdr3 =>
                IF (rx_buff_push = '1' AND tl_rx_src_eop = '1') THEN
                    NSTATE <= idle;
                ELSIF(rx_buff_push = '1' AND tl_rx_src_eop = '0') THEN
                    NSTATE <= payload;
                ELSE
                    NSTATE <= hdr3;
                END IF;

            WHEN payload =>
                IF (tl_rx_src_eop = '0' AND rx_buff_push = '1') THEN
                    NSTATE <= payload;
                ELSIF (tl_rx_src_eop = '1' AND rx_buff_push = '1') THEN
                    NSTATE <= idle;
                ELSE 
                    NSTATE <= payload;
                END IF;
            WHEN OTHERS=>
            
        END CASE;
    END PROCESS;

    OUTPUTS:   PROCESS (PSTATE, tl_rx_src_sop, tl_rx_src_eop, rx_buff_push) BEGIN
        --INITIALIZATION TO INACTIVE VALUES:
        malformed_flag_clr <= '0';
        len_reg_ld <= '0';
        malformed_flag_ld <= '0';
        pl_cnt_en <= '0';
        pl_cnt_rst <= '0';
        typ_reg_ld <= '0';
        send_err_msg_ld <= '0';
        CASE PSTATE IS
            WHEN idle =>  
                pl_cnt_rst <= '1';
                IF (tl_rx_src_sop = '1') THEN
                    len_reg_ld <= '1';
                    typ_reg_ld <= '1';
                END IF;

            WHEN hdr2 =>
                malformed_flag_clr <= '1';

            WHEN hdr3 =>  
            IF (tl_rx_src_eop = '1' AND rx_buff_push = '1') THEN
                malformed_flag_ld <= '1';
                send_err_msg_ld <= '1';

            END IF;

            WHEN payload => 
                IF (rx_buff_push = '1') THEN
                    pl_cnt_en <= '1';
                END IF;
                IF (tl_rx_src_eop = '1') THEN
                    malformed_flag_ld <= '1';
                    send_err_msg_ld <= '1';
                END IF; 

            WHEN OTHERS=>
    
        END CASE;
    END PROCESS;



    --DP :
    payload_counter: ENTITY WORK.COUNTER GENERIC MAP(inputbit=>10) 
    PORT MAP(
        clk  => clk,
        rst => pl_cnt_rst, 
        en => pl_cnt_en, 
        cnt_output => pl_cnt_out
        );
    length_register: ENTITY WORK.GENERIC_REG GENERIC MAP(N=>10) 
    PORT MAP(
        clk=>clk, 
        rst=>rst, 
        ld=>len_reg_ld, 
        reg_in=>len_reg_in, 
        reg_out=>len_reg_out
        );
    len_reg_in <= tl_rx_src_data(9 DOWNTO 0);

    malformed_flag_in <= '0' WHEN (expct_len = pl_cnt_out) ELSE '1';

    type_register: ENTITY WORK.GENERIC_REG GENERIC MAP(N=>8) 
    PORT MAP(
        clk=>clk, 
        rst=>rst, 
        ld=>typ_reg_ld, 
        reg_in=>typ_reg_in, 
        reg_out=>typ_reg_out
        );
    typ_reg_in <= tl_rx_src_data(31 DOWNTO 24);

    PROCESS (typ_reg_out, len_reg_out) BEGIN
        undefinedType <= '0';
        expct_len <= (OTHERS => '0');


        CASE typ_reg_out IS

        WHEN TLP_MRd =>
            expct_len <= (OTHERS => '0');
        WHEN TLP_MWr =>
            expct_len <= len_reg_out - 1;
        WHEN TLP_IORd => 
            expct_len <= "0000000001";
        WHEN TLP_IOWr =>
            expct_len <= "0000000001";
        WHEN TLP_CfgRd0 =>
            expct_len <= "0000000001";
        WHEN TLP_CfgWr0 =>
            expct_len <= "0000000001";
        WHEN TLP_CfgRd1 =>
            expct_len <= "0000000001";
        WHEN TLP_CfgWr1 =>
            expct_len <= "0000000001";
        WHEN TLP_Cmpl =>
            expct_len <= "0000000000";
        WHEN TLP_CmplD =>
            expct_len <= "0000000001";

        WHEN OTHERS =>
            undefinedType <= '1';
        END CASE;

    END PROCESS;

    malformed_flag_register: ENTITY WORK.OneBit_REG
        PORT MAP(
            clk => clk,
            rst => malformed_flag_clr,
            ld => malformed_flag_ld, 
            reg_in => malformed_flag_in OR exceed_maxPayload OR undefinedType,
            reg_out => malformed_flag_out
        );

    send_err_msg_register: ENTITY WORK.OneBit_REG
        PORT MAP(
            clk => clk,
            rst => err_msg_sent OR rst,
            ld => send_err_msg_ld,
            reg_in => malformed_flag_in,
            reg_out => send_err_msg_out
        );
    -- send_err_msg_in <= '1';
    send_err_msg <= send_err_msg_out;

    PROCESS (len_reg_out, maxPayload) BEGIN
        exceed_maxPayload <= '0';
        CASE (maxPayload) IS
            WHEN maxPayload_128B =>
                IF (len_reg_out > "0001111111") THEN
                    exceed_maxPayload <= '1';
                END IF;

            WHEN maxPayload_256B =>
                IF (len_reg_out > "0011111111") THEN
                    exceed_maxPayload <= '1';
                END IF;
            WHEN maxPayload_512B =>
                IF (len_reg_out > "0111111111") THEN
                    exceed_maxPayload <= '1';
                END IF;
            WHEN maxPayload_1024B =>
                IF (len_reg_out > "1111111111") THEN
                    exceed_maxPayload <= '1';
                END IF;
            WHEN maxPayload_2048B =>
                exceed_maxPayload <= '1';            
            WHEN maxPayload_4096B =>
                exceed_maxPayload <= '1';
            WHEN maxPayload_reserved1 =>
                exceed_maxPayload <= '1';
            WHEN maxPayload_reserved2 =>
                exceed_maxPayload <= '1';

            WHEN OTHERS =>

        END CASE;
    END PROCESS;
END ARCHITECTURE Controller_ARC;

-- -------------------------------------------------------------
--  Top Module
-- -------------------------------------------------------------

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.Numeric_Std.all;


ENTITY RX_HS_TOP IS 
PORT(
    clk:IN STD_LOGIC;
    rst:IN STD_LOGIC;

    tl_rx_dst_rdy : OUT STD_LOGIC;
    tl_rx_src_rdy : IN STD_LOGIC;
    tl_rx_src_sop : IN STD_LOGIC;
    tl_rx_src_eop : IN STD_LOGIC;
    tl_rx_src_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

    rx_buff_full  : IN STD_LOGIC;
    rx_buff_push  : OUT STD_LOGIC;
    maxPayload : IN STD_LOGIC_VECTOR (2 DOWNTO 0);


    send_err_msg : OUT STD_LOGIC;
    err_msg_sent : IN STD_LOGIC
    );
END ENTITY RX_HS_TOP;
    
ARCHITECTURE TOP_ARC OF RX_HS_TOP IS
    BEGIN

-- -- DataPath INSTANTIATION:
--     DataPath : ENTITY WORK.RX_HS_DP(DP_ARC) 
--     PORT MAP (
--         clk           => clk, 
--         rst           => rst,
--         tl_rx_dst_rdy => tl_rx_dst_rdy,
--         tl_rx_src_rdy => tl_rx_src_rdy, 
--         tl_rx_src_sop => tl_rx_src_sop, 
--         tl_rx_src_eop => tl_rx_src_eop,
--         rx_buff_push  => rx_buff_push, 
--         rx_buff_full  => rx_buff_full);

        -- CONTROLLER INSTANTIATION:
    Controller : ENTITY WORK.RX_HS_Controller(Controller_ARC) 
    PORT MAP (
        clk           => clk, 
        rst           => rst,
        tl_rx_dst_rdy => tl_rx_dst_rdy,
        tl_rx_src_rdy => tl_rx_src_rdy, 
        tl_rx_src_sop => tl_rx_src_sop, 
        tl_rx_src_eop => tl_rx_src_eop,
        tl_rx_src_data => tl_rx_src_data,
        rx_buff_push  => rx_buff_push, 
        rx_buff_full  => rx_buff_full,
        send_err_msg  => send_err_msg, 
        err_msg_sent  => err_msg_sent,
        maxPayload  => maxPayload );
END ARCHITECTURE TOP_ARC ;

