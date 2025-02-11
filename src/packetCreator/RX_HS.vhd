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
    
    rx_buff_push  : OUT STD_LOGIC;
    rx_buff_full  : IN STD_LOGIC
    );
END ENTITY RX_HS_Controller;

ARCHITECTURE Controller_ARC OF RX_HS_Controller IS
--STATE:
TYPE STATE IS (wait_for_rdy_full, store);
-- SIGNAL PSTATE, NSTATE : STATE;
BEGIN
    tl_rx_dst_rdy <= NOT(rx_buff_full);
    rx_buff_push <= '1' WHEN (tl_rx_src_rdy='1' AND rx_buff_full='0') ELSE '0';

-- --proccesses:
--     NEXT_STATE:   PROCESS (clk , rst)
--     BEGIN
--         IF rst = '1' THEN
--             PSTATE<= wait_for_rdy_full;
--         ELSIF clk = '1' AND clk'EVENT THEN 
--             PSTATE <= NSTATE;
--         END IF;
--     END PROCESS;

--     STATE_TRANSITION:   PROCESS (PSTATE ,tl_rx_src_rdy, rx_buff_full) BEGIN
--         NSTATE<=wait_for_rdy_full; --INACTIVE VALUE
--         CASE PSTATE IS
--             WHEN wait_for_rdy_full =>
--                 IF (tl_rx_src_rdy='1' AND rx_buff_full = '0') THEN
--                     NSTATE <= store;
--                 ELSE
--                     NSTATE <= wait_for_rdy_full;
--                 END IF;

--                 -- IF (tl_rx_src_rdy='0' OR rx_buff_full = '1') THEN 
--                 --     NSTATE <= wait_for_rdy_full;
--                 -- ELSIF (tl_rx_src_rdy='1' AND rx_buff_full = '0') THEN
--                 --     NSTATE <= store;
--                 -- END IF ;
                            
--             WHEN store =>
--                 IF (tl_rx_src_rdy = '1' AND rx_buff_full = '0')THEN
--                     NSTATE <= store;
--                 ELSE 
--                     NSTATE <= wait_for_rdy_full;
--                 END IF;

--                 -- IF (tl_rx_src_rdy = '0' OR rx_buff_full = '1' OR tl_rx_src_eop = '1') THEN
--                 --     NSTATE <= wait_for_rdy_full;
--                 -- ELSIF (tl_rx_src_rdy = '1' AND rx_buff_full = '0') THEN
--                 --     NSTATE <= store;
--                 -- END IF;
--             WHEN OTHERS=>
            
--         END CASE;
--     END PROCESS;

--     OUTPUTS:   PROCESS (PSTATE ,tl_rx_src_rdy, rx_buff_full) BEGIN
--         --INITIALIZATION TO INACTIVE VALUES:
--         -- tl_rx_dst_rdy <= '0';
--         -- rx_buff_push <= '0';
--         CASE PSTATE IS
--             WHEN wait_for_rdy_full =>    
--                 IF (tl_rx_src_rdy='1' AND rx_buff_full = '0') THEN
--                 --     tl_rx_dst_rdy <= '1';
--                     -- rx_buff_push <= '1'; 
--                 END IF;

--             WHEN store =>
--                 -- it has to stay in the mealy format so that the changes in full and dst_rdy are in synch
--                 -- IF (tl_rx_src_rdy = '1' AND rx_buff_full = '0' AND tl_rx_src_eop = '0') THEN
--                 --     tl_rx_dst_rdy <= '1';
--                 --     rx_buff_push <= '1'; 
--                 -- END IF;

--                 -- if there are receive and the buffer is not full => push
--                 -- IF (rx_buff_full = '0') THEN
--                 --     tl_rx_dst_rdy <= '1';
--                 -- END IF;
--                 -- IF (tl_rx_src_rdy = '1' AND rx_buff_full = '0') THEN
--                     -- tl_rx_dst_rdy <= '1';
--                     -- rx_buff_push <= '1'; 
--                 -- END IF;

--             WHEN OTHERS=>
    
--         END CASE;
--     END PROCESS;
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

    rx_buff_full  : IN STD_LOGIC;
    rx_buff_push  : OUT STD_LOGIC
    );
END ENTITY RX_HS_TOP;
    
ARCHITECTURE TOP_ARC OF RX_HS_TOP IS
    BEGIN

-- CONTROLLER INSTANTIATION:
    Controller : ENTITY WORK.RX_HS_Controller(Controller_ARC) 
    PORT MAP (
        clk           => clk, 
        rst           => rst,
        tl_rx_dst_rdy => tl_rx_dst_rdy,
        tl_rx_src_rdy => tl_rx_src_rdy, 
        tl_rx_src_sop => tl_rx_src_sop, 
        tl_rx_src_eop => tl_rx_src_eop,
        rx_buff_push  => rx_buff_push, 
        rx_buff_full  => rx_buff_full);
END ARCHITECTURE TOP_ARC ;

