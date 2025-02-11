--*****************************************************************************/
--	Filename:		ORDERING_LOGIC.vhd
--	Project:		MCI-PCH
--  Version:		1.000
--	History:		-
--	Date:			9 July 2023
--	Authors:	 	Tina
--	Fist Author:    Tina
--	Last Author: 	Tina
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--
--*****************************************************************************/
--	File content description:

--ORDERING LOGIC CIRCUIT
--DATAPATH
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ordering_logic_datapath IS
    port(
        tl_tx_src_vcb_hpf, tl_tx_src_vcb_hnpf, tl_tx_src_vcb_hcmpf       :  IN STD_LOGIC; --signals show the transfer header has data
        tl_tx_src_vcb_hpemp, tl_tx_src_vcb_hnpemp, tl_tx_src_vcb_hcmpemp :  IN STD_LOGIC; --signals show the receiver header has space for data
        tl_tx_src_vcb_dpemp, tl_tx_src_vcb_dnpemp, tl_tx_src_vcb_dcmpemp :  IN STD_LOGIC;--signals show the receiver data has space for data
        sel_en                                                           :  IN STD_LOGIC;--tri state
        tl_tx_src_ol_pen, tl_tx_src_ol_npen, tl_tx_src_ol_cmpen          :  OUT STD_LOGIC--Enabling transfer buffers
    );
END ENTITY ordering_logic_datapath;

ARCHITECTURE ordering_logic_datapath_arc OF ordering_logic_datapath IS
    SIGNAL i0, i1, i2 : STD_LOGIC;
    SIGNAL out_sig    : STD_LOGIC;
    SIGNAL out_enc : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
    out_sig <=  i0 OR  i1 OR i2;
    i0 <= tl_tx_src_vcb_hpf AND tl_tx_src_vcb_hpemp;
    i1 <= tl_tx_src_vcb_hcmpf AND tl_tx_src_vcb_hcmpemp;
    i2 <= tl_tx_src_vcb_hnpf AND tl_tx_src_vcb_hnpemp;

    P_ENCODER: ENTITY WORK.p_encoder(p_encoder_arc) PORT MAP(in_p(0)=>i0,in_p(1)=>i1,in_p(2)=>i2,in_p(3)=>'1',out_p=>out_enc);

    
    tl_tx_src_ol_pen <= (NOT out_enc(0)) AND (NOT out_enc(1)) AND tl_tx_src_vcb_dpemp AND out_sig WHEN sel_en='1' ELSE 'Z';
    tl_tx_src_ol_cmpen <= (NOT out_enc(1)) AND tl_tx_src_vcb_dnpemp AND out_enc(0) AND out_sig WHEN sel_en='1' ELSE 'Z';
    tl_tx_src_ol_npen <= (NOT out_enc(0)) AND tl_tx_src_vcb_dcmpemp AND out_enc(1) AND out_sig WHEN sel_en='1' ELSE 'Z';

END ARCHITECTURE ordering_logic_datapath_arc;


--Controller
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ordering_logic_controller IS
    port(
        clk, rst                                                         :  IN STD_LOGIC; 
        ready_vcb, ack_vcb                                               :  IN STD_LOGIC;-- ready and ack from transfer
        ready_ol, sel_en                                                 : OUT STD_LOGIC
    );
END ENTITY ordering_logic_controller;

ARCHITECTURE ordering_logic_controller_arc OF ordering_logic_controller IS
    TYPE state IS (wait_ready, active_enable);
    SIGNAL pstate, nstate : state;
    
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN 
            pstate <= wait_ready;
        ELSIF clk = '1' AND clk'EVENT THEN
            pstate <= nstate;
        END IF;
    END PROCESS;

    PROCESS(pstate,ready_vcb,ack_vcb)
    BEGIN
    sel_en<='0';
    ready_ol<='0';

        CASE pstate IS 
            WHEN active_enable=>
                sel_en<='1';
                ready_ol<='1';
            WHEN OTHERS=>
        END CASE;
    END PROCESS;

    PROCESS(pstate,ready_vcb,ack_vcb)
    BEGIN
        CASE pstate IS 
            WHEN wait_ready=>
                IF ready_vcb = '0' THEN
                    nstate <= wait_ready;
                ELSE
                    nstate <= active_enable;
                END IF;

            WHEN active_enable=>
                IF ack_vcb='0' THEN
                    nstate <= active_enable; 
                ELSE 
                    nstate <= wait_ready; 
                END IF;  
            WHEN OTHERS=>
        END CASE;
    END PROCESS;
END ARCHITECTURE ordering_logic_controller_arc;

--Top Level
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ordering_logic IS
    port(
        clk, rst                                                         :  IN STD_LOGIC; 
        ready_vcb, ack_vcb                                               :  IN STD_LOGIC;
        tl_tx_src_vcb_hpf, tl_tx_src_vcb_hnpf, tl_tx_src_vcb_hcmpf       :  IN STD_LOGIC;
        tl_tx_src_vcb_hpemp, tl_tx_src_vcb_hnpemp, tl_tx_src_vcb_hcmpemp :  IN STD_LOGIC; 
        tl_tx_src_vcb_dpemp, tl_tx_src_vcb_dnpemp, tl_tx_src_vcb_dcmpemp :  IN STD_LOGIC;
        tl_tx_src_ol_pen, tl_tx_src_ol_npen, tl_tx_src_ol_cmpen          :  OUT STD_LOGIC;
        ready_ol                                                         :  OUT STD_LOGIC
    );
END ENTITY ordering_logic;

ARCHITECTURE ordering_logic_arc OF ordering_logic IS
SIGNAL sel_en : STD_LOGIC;
BEGIN
    Datapath_inst : ENTITY WORK.ordering_logic_datapath(ordering_logic_datapath_arc)
        PORT MAP(
            tl_tx_src_vcb_hpf=>tl_tx_src_vcb_hpf,
            tl_tx_src_vcb_hnpf=>tl_tx_src_vcb_hnpf,
            tl_tx_src_vcb_hcmpf=>tl_tx_src_vcb_hcmpf,
            tl_tx_src_vcb_hpemp => tl_tx_src_vcb_hpemp,
            tl_tx_src_vcb_hnpemp => tl_tx_src_vcb_hnpemp,
            tl_tx_src_vcb_hcmpemp => tl_tx_src_vcb_hcmpemp,
            tl_tx_src_vcb_dpemp => tl_tx_src_vcb_dpemp,
            tl_tx_src_vcb_dnpemp => tl_tx_src_vcb_dnpemp,
            tl_tx_src_vcb_dcmpemp => tl_tx_src_vcb_dcmpemp,
            sel_en => sel_en,
            tl_tx_src_ol_pen => tl_tx_src_ol_pen,
            tl_tx_src_ol_npen => tl_tx_src_ol_npen,
            tl_tx_src_ol_cmpen =>tl_tx_src_ol_cmpen
        );
    
    Controller_inst : ENTITY WORK.ordering_logic_controller(ordering_logic_controller_arc)
        PORT MAP(
            clk => clk,
            rst => rst,
            ready_vcb => ready_vcb,
            ack_vcb => ack_vcb,
            ready_ol => ready_ol,
            sel_en => sel_en
        );
END ARCHITECTURE ordering_logic_arc;
