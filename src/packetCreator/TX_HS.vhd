--*****************************************************************************/
--	Filename:		TX_HS.vhd
--	Project:		MCI-PCH
--  Version:		1.000
--	History:		-
--	Date:			12 December 2023
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

ENTITY TX_HS_Controller IS 
PORT(
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;

    -- main controller interface
    start_tx : IN STD_LOGIC;
    tx_done  : OUT STD_LOGIC;

    -- Tx-HS signals
    tl_tx_dst_rdy          : IN STD_LOGIC;
    tl_tx_src_rdy_internal : OUT STD_LOGIC;
    tl_tx_src_sop          : OUT STD_LOGIC;
    tl_tx_src_eop          : OUT STD_LOGIC;

    --DP INTERFACE:
    contains_data : IN STD_LOGIC;
    one_DB_data   : IN STD_LOGIC;
    data_cnt_rst  : OUT STD_LOGIC;
    data_cnt_en   : OUT STD_LOGIC;
    Hdr1_sel      : OUT STD_LOGIC;
    Hdr2_sel      : OUT STD_LOGIC;
    Hdr3_sel      : OUT STD_LOGIC;
    data_sel      : OUT STD_LOGIC;
    eq            : IN STD_LOGIC;
    type_reg_rst  : OUT STD_LOGIC;
    type_reg_ld   : OUT STD_LOGIC;
    tx_buff_empty : IN STD_LOGIC;
    tx_buff_pop   : OUT STD_LOGIC
    );
END ENTITY TX_HS_Controller;

ARCHITECTURE Controller_ARC OF TX_HS_Controller IS
--STATE:
TYPE STATE IS (idle ,Hdr1, Hdr2, Hdr3, Hdr3_eop, send_data, wait_for_not_empty, wait_for_dst_rdy, eop, done);
SIGNAL PSTATE, NSTATE : STATE;
BEGIN
--proccesses:
    NEXT_STATE:   PROCESS (clk , rst)
    BEGIN
            IF rst = '1' THEN
                PSTATE<= idle;
            ELSIF clk = '1' AND clk'EVENT THEN 
                PSTATE <= NSTATE;
            END IF;
    END PROCESS;

-- --------------------------- MAIN CTRL ---------------------------
    STATE_TRANSITION:   PROCESS (PSTATE ,start_tx, tl_tx_dst_rdy, contains_data, eq, tx_buff_empty, one_DB_data) BEGIN
        NSTATE<=idle; --INACTIVE VALUE

        CASE PSTATE IS
            WHEN idle =>
                IF (start_tx='0') THEN 
                    NSTATE <= idle;
                ELSE
                    NSTATE <= Hdr1;
                END IF ;
                
            WHEN Hdr1 =>
                IF (tl_tx_dst_rdy = '0') THEN
                    NSTATE <= Hdr1;
                ELSE
                    NSTATE <= Hdr2;
                END IF;
                    
            WHEN Hdr2 =>
                IF (tl_tx_dst_rdy = '0') THEN
                    NSTATE <= Hdr2;
                ELSE
                    IF (contains_data = '1') THEN
                        NSTATE <= Hdr3;
                    ELSE
                        NSTATE <= Hdr3_eop;
                    END If;
                END IF;

            WHEN Hdr3_eop =>
                IF (tl_tx_dst_rdy = '0') THEN
                    NSTATE <= Hdr3_eop;
                ELSE
                    NSTATE <= done;
                END IF;
                -- or maybe just: --??
                -- NSTATE <= done;
                
            WHEN Hdr3 =>
                IF (tl_tx_dst_rdy = '0' ) THEN
                    NSTATE <= Hdr3;
                ELSE
                    IF (one_DB_data = '0') THEN
                        NSTATE <= send_data;
                    ELSE 
                        NSTATE <= eop;
                    END IF;
                END IF;

            WHEN send_data =>
                -- IF ( eq = '1' AND tl_tx_dst_rdy = '0') THEN
                --     NSTATE <= eop;
                -- ELSE
                --     IF (tx_buff_empty = '1') THEN
                --         NSTATE <= wait_for_not_empty;
                --     ELSE
                --         IF (tl_tx_dst_rdy = '1') THEN
                --             NSTATE <= send_data;
                --         ELSE
                --             NSTATE <= wait_for_dst_rdy;
                --         END IF;
                --     END IF;
                -- END IF;

                IF (eq = '0' AND tl_tx_dst_rdy = '0' AND tx_buff_empty = '0') THEN
                    NSTATE <= wait_for_dst_rdy;

                ELSIF (eq = '0' AND tl_tx_dst_rdy = '0' AND tx_buff_empty = '1') THEN
                    NSTATE <= wait_for_not_empty;

                ELSIF (eq = '0' AND tl_tx_dst_rdy = '1' AND tx_buff_empty = '0') THEN
                    NSTATE <= send_data;

                ELSIF (eq = '0' AND tl_tx_dst_rdy = '1' AND tx_buff_empty = '1') THEN
                    NSTATE <= wait_for_not_empty;

                ELSIF (eq = '1' AND tl_tx_dst_rdy = '0' AND tx_buff_empty = '0') THEN
                    NSTATE <= wait_for_dst_rdy;

                ELSIF (eq = '1' AND tl_tx_dst_rdy = '0' AND tx_buff_empty = '1') THEN
                    NSTATE <= wait_for_dst_rdy;

                ELSIF (eq = '1' AND tl_tx_dst_rdy = '1' AND tx_buff_empty = '0') THEN
                    NSTATE <= eop;

                ELSIF (eq = '1' AND tl_tx_dst_rdy = '1' AND tx_buff_empty = '1') THEN
                    NSTATE <= eop;
                END IF;


            WHEN wait_for_dst_rdy =>
                IF (eq = '1' AND tl_tx_dst_rdy = '1' ) THEN
                    NSTATE <= eop;

                ELSIF (eq = '0' AND tl_tx_dst_rdy = '1') THEN
                    NSTATE <= send_data;

                ELSIF (eq = '0' AND tl_tx_dst_rdy = '0') THEN
                    NSTATE <= wait_for_dst_rdy;

                ELSIF (eq = '1' AND tl_tx_dst_rdy = '0') THEN
                    NSTATE <= wait_for_dst_rdy;
                END IF;

            WHEN wait_for_not_empty =>
                IF (tl_tx_dst_rdy = '0' AND tx_buff_empty = '0' ) THEN
                    NSTATE <= wait_for_dst_rdy;

                ELSIF (tl_tx_dst_rdy = '0' AND tx_buff_empty = '1' ) THEN
                    NSTATE <= wait_for_not_empty;

                ELSIF (tl_tx_dst_rdy = '1' AND tx_buff_empty = '0' ) THEN
                    NSTATE <= send_data;
                    
                ELSIF (tl_tx_dst_rdy = '1' AND tx_buff_empty = '1' ) THEN
                    NSTATE <= wait_for_not_empty;
                 END IF;
            

            WHEN eop =>
                IF (tl_tx_dst_rdy = '0' OR tx_buff_empty = '1' ) THEN
                    NSTATE <= eop;
                ELSE
                    NSTATE <= done;
                END IF;
            
            when done =>
                IF (start_tx = '1') THEN
                    NSTATE <= done;
                ELSE
                    NSTATE <= idle;
                END IF;

            WHEN OTHERS=>
        END CASE;
    END PROCESS;

    OUTPUTS:   PROCESS (PSTATE, tl_tx_dst_rdy, eq, tx_buff_empty) BEGIN
        --INITIALIZATION TO INACTIVE VALUES:
        data_cnt_rst           <= '0'; 
        data_cnt_en            <= '0';
        Hdr1_sel               <= '0'; 
        Hdr2_sel               <= '0'; 
        Hdr3_sel               <= '0'; 
        data_sel               <= '0';
        tl_tx_src_rdy_internal <= '0'; 
        tl_tx_src_eop          <= '0'; 
        tl_tx_src_sop          <= '0';
        tx_buff_pop            <= '0';
        tx_done                <= '0';
        type_reg_rst           <= '0';
        type_reg_ld            <= '0';

        CASE PSTATE IS
            WHEN idle =>
                -- type_reg_rst<='1';
                type_reg_ld<='1';

            WHEN Hdr1 =>    
                tl_tx_src_rdy_internal <= '1';
                tl_tx_src_sop <= '1';
                Hdr1_sel <= '1';
                -- type_reg_ld<='1';
                
            WHEN Hdr2 =>
                tl_tx_src_rdy_internal <= '1';
                Hdr2_sel <= '1';

            WHEN Hdr3 =>
                tl_tx_src_rdy_internal <= '1';
                Hdr3_sel <= '1';
                data_cnt_rst <= '1';

            WHEN Hdr3_eop =>
                tl_tx_src_rdy_internal <= '1';
                Hdr3_sel <= '1';
                tl_tx_src_eop <= '1';

            WHEN send_data =>
                data_sel <= '1';
                IF( tx_buff_empty = '0')THEN
                    tl_tx_src_rdy_internal <= '1';
                END IF;
                IF (tx_buff_empty = '0' AND tl_tx_dst_rdy = '1') THEN
                    data_cnt_en <= '1';
                    tx_buff_pop <= '1';
                END IF;

            WHEN wait_for_dst_rdy =>
                tl_tx_src_rdy_internal <= '1';
                data_sel <= '1';
                IF (tl_tx_dst_rdy = '1') THEN
                    tx_buff_pop <= '1';
                    data_cnt_en <= '1';
                END IF;

            WHEN wait_for_not_empty =>
                data_sel <= '1';
                IF (tx_buff_empty = '0') THEN
                    tl_tx_src_rdy_internal <= '1';
                END IF;
                IF (tx_buff_empty = '0' AND tl_tx_dst_rdy = '1') THEN
                    data_cnt_en <= '1';
                    tx_buff_pop <= '1';
                END IF;

            WHEN eop =>
                data_sel <= '1';
                IF (tx_buff_empty = '0') THEN
                    tl_tx_src_rdy_internal <= '1';
                    tl_tx_src_eop <= '1';
                END IF;
                IF (tl_tx_dst_rdy = '1' AND tx_buff_empty = '0') THEN
                    tx_buff_pop <= '1';
                    data_cnt_en <= '1';
                END IF;

            WHEN done =>
                tx_done <= '1';
                    
            WHEN OTHERS=>

        END CASE;
    END PROCESS;


END ARCHITECTURE Controller_ARC;

-- -------------------------------------------------------------
--  Datapath
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY TX_HS_DP IS
    PORT(
        clk:IN STD_LOGIC;
        rst:IN STD_LOGIC;

        --Header Register signals
        tx_hdr1: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        tx_hdr2: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        tx_hdr3: IN STD_LOGIC_VECTOR (31 DOWNTO 0);

        tl_tx_dst_rdy : IN STD_LOGIC;
        -- output interface
        tx_buff_data_out : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        tl_tx_src_data: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        tl_tx_src_rdy_cmpl: OUT STD_LOGIC;
        tl_tx_src_rdy_p: OUT STD_LOGIC;
        tl_tx_src_rdy_np: OUT STD_LOGIC;
        
        data_length: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
        cmpl_reg_in: IN STD_LOGIC;
        p_reg_in: IN STD_LOGIC;
        np_reg_in: IN STD_LOGIC;
        
        --CONTROLLER INTERFACE:
        tl_tx_src_rdy_internal: IN STD_LOGIC;
        data_cnt_rst, data_cnt_en: IN STD_LOGIC;
        Hdr1_sel, Hdr2_sel, Hdr3_sel, data_sel: IN STD_LOGIC;
        contains_data, one_DB_data : OUT STD_LOGIC;
        type_reg_rst, type_reg_ld : IN STD_LOGIC;
        eq: OUT STD_LOGIC

   );
END ENTITY TX_HS_DP;

ARCHITECTURE DP_ARC OF TX_HS_DP IS 
SIGNAL data_cnt_out : STD_LOGIC_VECTOR (9 DOWNTO 0);
SIGNAL tx_address_cnt_out : STD_LOGIC_VECTOR (9 DOWNTO 0);
SIGNAL tx_address_cnt_en_gated : STD_LOGIC;
SIGNAL cmpl_reg_out, p_reg_out, np_reg_out : STD_LOGIC;
BEGIN
    contains_data <= '1' WHEN (data_length /= B"0000000000") ELSE '0';
    one_DB_data <= '1' WHEN (data_length = 1) ELSE '0';

    --MULTIPLEXER INSTANCE:
    out_mux: ENTITY WORK.Mux4to1 PORT MAP(in0=>tx_hdr1, in1=>tx_hdr2, in2=>tx_hdr3, in3=>tx_buff_data_out, sel0=>Hdr1_sel, sel1=>Hdr2_sel, sel2=>Hdr3_sel, sel3=>data_sel, out_p=>tl_tx_src_data);

    --counter INSTANCE:
    data_counter: ENTITY WORK.COUNTER GENERIC MAP(inputbit=>10) PORT MAP(clk=>clk, rst=>data_cnt_rst, en=>data_cnt_en, cnt_output=>data_cnt_out);
    
    --comaprator:
    eq <= '1' WHEN data_cnt_out = ((data_length - 1) -1) ELSE '0';

    -- one bit register instances:
    cmpl_reg: ENTITY WORK.OneBit_REG PORT MAP (clk=>clk, rst=>type_reg_rst, ld=>type_reg_ld, reg_in=>cmpl_reg_in, reg_out=>cmpl_reg_out);
    p_reg: ENTITY WORK.OneBit_REG PORT MAP (clk=>clk, rst=>type_reg_rst, ld=>type_reg_ld, reg_in=>p_reg_in, reg_out=>p_reg_out);
    np_reg: ENTITY WORK.OneBit_REG PORT MAP (clk=>clk, rst=>type_reg_rst, ld=>type_reg_ld, reg_in=>np_reg_in, reg_out=>np_reg_out);

    tl_tx_src_rdy_cmpl <= cmpl_reg_out WHEN (tl_tx_src_rdy_internal = '1') ELSE '0';
    tl_tx_src_rdy_p <= p_reg_out WHEN (tl_tx_src_rdy_internal = '1') ELSE '0';
    tl_tx_src_rdy_np <= np_reg_out WHEN (tl_tx_src_rdy_internal = '1') ELSE '0';


END ARCHITECTURE DP_ARC;
-- -------------------------------------------------------------
--  Top Module
-- -------------------------------------------------------------

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.Numeric_Std.all;


ENTITY TX_HS_TOP IS 
PORT(
    clk:IN STD_LOGIC;
    rst:IN STD_LOGIC;

    -- main controller interface
    start_tx : IN STD_LOGIC;
    tx_done : OUT STD_LOGIC;

    tl_tx_dst_rdy : IN STD_LOGIC;
    tl_tx_src_rdy_cmpl: OUT STD_LOGIC;
    tl_tx_src_rdy_p: OUT STD_LOGIC;
    tl_tx_src_rdy_np: OUT STD_LOGIC;
    tl_tx_src_sop : OUT STD_LOGIC;
    tl_tx_src_eop : OUT STD_LOGIC;
    tl_tx_src_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);


    tx_hdr1: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    tx_hdr2: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    tx_hdr3: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    tx_buff_data_out : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

    data_length: IN STD_LOGIC_VECTOR (9 DOWNTO 0);


    cmpl_reg_in: IN STD_LOGIC;
    p_reg_in: IN STD_LOGIC;
    np_reg_in: IN STD_LOGIC;

    tx_buff_empty : IN STD_LOGIC;
    tx_buff_pop : OUT STD_LOGIC
    );
END ENTITY TX_HS_TOP;

ARCHITECTURE TOP_ARC OF TX_HS_TOP IS
    SIGNAL contains_data_wire, one_DB_data_wire, data_cnt_rst_wire, data_cnt_en_wire, Hdr1_sel_wire, Hdr2_sel_wire, Hdr3_sel_wire, data_sel_wire,eq_wire, tl_tx_src_rdy_internal, type_reg_rst, type_reg_ld: STD_LOGIC;
    BEGIN
-- DATA PATH INSTANTIATION:
    DataPath: ENTITY WORK.TX_HS_DP(DP_ARC) PORT MAP (clk =>clk, rst=>rst,
    tx_hdr1=>tx_hdr1, 
    tx_hdr2=>tx_hdr2, 
    tx_hdr3=>tx_hdr3,
    tl_tx_dst_rdy=>tl_tx_dst_rdy,
    tx_buff_data_out=>tx_buff_data_out,
    tl_tx_src_data=>tl_tx_src_data,
    tl_tx_src_rdy_cmpl=>tl_tx_src_rdy_cmpl,
    tl_tx_src_rdy_p=>tl_tx_src_rdy_p,
    tl_tx_src_rdy_np=>tl_tx_src_rdy_np,
    tl_tx_src_rdy_internal=>tl_tx_src_rdy_internal,
    contains_data=>contains_data_wire,
    one_DB_data=>one_DB_data_wire,
    p_reg_in=>p_reg_in,
    np_reg_in=>np_reg_in,
    cmpl_reg_in=>cmpl_reg_in,
    type_reg_rst=>type_reg_rst,
    type_reg_ld=>type_reg_ld,
    data_cnt_rst=>data_cnt_rst_wire, data_cnt_en=>data_cnt_en_wire,
    Hdr1_sel=>Hdr1_sel_wire, Hdr2_sel=>Hdr2_sel_wire, Hdr3_sel=>Hdr3_sel_wire, data_sel=>data_sel_wire,
    eq=>eq_wire,
    data_length=>data_length
        );

-- CONTROLLER INSTANTIATION:
    Controller : ENTITY WORK.TX_HS_Controller(Controller_ARC) PORT MAP (clk =>clk, rst=>rst,
    start_tx=>start_tx,
    tx_done=>tx_done,
    tl_tx_dst_rdy=>tl_tx_dst_rdy,
    tl_tx_src_rdy_internal=>tl_tx_src_rdy_internal,
    tl_tx_src_sop=>tl_tx_src_sop, 
    tl_tx_src_eop=>tl_tx_src_eop,
    tx_buff_pop=>tx_buff_pop, 
    tx_buff_empty=>tx_buff_empty,
    contains_data=>contains_data_wire,
    one_DB_data=>one_DB_data_wire,
    type_reg_rst=>type_reg_rst,
    type_reg_ld=>type_reg_ld,
    data_cnt_rst=>data_cnt_rst_wire, data_cnt_en=>data_cnt_en_wire,
    Hdr1_sel=>Hdr1_sel_wire, Hdr2_sel=>Hdr2_sel_wire, Hdr3_sel=>Hdr3_sel_wire, data_sel=>data_sel_wire,
    eq=>eq_wire);

END ARCHITECTURE TOP_ARC ;

