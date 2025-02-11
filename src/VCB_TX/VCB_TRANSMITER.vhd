
--*****************************************************************************/
--	Filename:		VCB_TRANSMITER.vhd
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
USE IEEE.Std_logic_1164.all;

ENTITY VCB_TRANSMITER IS
GENERIC(log2sizefifo:INTEGER:=3);
PORT(
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    Fc_DLLPs_cmp : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    ready_cmp : IN STD_LOGIC;
    Fc_DLLPs_p : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    ready_p : IN STD_LOGIC;
    Fc_DLLPs_np : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    ready_np : IN STD_LOGIC;
    tl_tx_src_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    tl_tx_src_rdy_cmpl : IN STD_LOGIC;
    tl_tx_src_rdy_p : IN STD_LOGIC;
    tl_tx_src_rdy_np : IN STD_LOGIC;
    tl_tx_dst_rdy : OUT STD_LOGIC;
    --tl_tx_src_sop : IN STD_LOGIC;    --  noot used
    tl_tx_src_eop : IN STD_LOGIC;
    Src_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    Src_rdy_cmp : OUT STD_LOGIC;
    Src_rdy_p : OUT STD_LOGIC;
    Src_rdy_np : OUT STD_LOGIC;
    Dst_rdy : IN STD_LOGIC;
    Src_sop : OUT STD_LOGIC;
    Src_eop : OUT STD_LOGIC
    );
END VCB_TRANSMITER;

ARCHITECTURE ARCH1 OF VCB_TRANSMITER IS
    SIGNAL ENS1 : STD_LOGIC;
    SIGNAL ENS2 : STD_LOGIC;
    SIGNAL ENS3 : STD_LOGIC;
    SIGNAL TINA_READY : STD_LOGIC;
    SIGNAL READY_TO_TINA : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_hcmpf : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_hpf : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_hnpf : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_hcmpemp : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_hpemp : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_hnpemp : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_dcmpemp : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_dpemp : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_dnpemp : STD_LOGIC;
    SIGNAL ACK_TO_TINA : STD_LOGIC;
BEGIN
    FLOWCONTROL: ENTITY WORK.FLOWCONTROL_TRANSMITER
    generic map(log2sizefifo => log2sizefifo)
    port map(
        clk => clk,
        rst => rst,

        Fc_DLLPs_cmp => Fc_DLLPs_cmp,
        ready_cmp => ready_cmp,
        Fc_DLLPs_p => Fc_DLLPs_p,
        ready_p => ready_p,
        Fc_DLLPs_np => Fc_DLLPs_np,
        ready_np => ready_np,

        del_tl_tx_src_data =>tl_tx_src_data,
        del_tl_tx_src_rdy_1 => tl_tx_src_rdy_cmpl,
        del_tl_tx_src_rdy_2 => tl_tx_src_rdy_p,
        del_tl_tx_src_rdy_3 => tl_tx_src_rdy_np,
        del_tl_tx_dst_rdy => tl_tx_dst_rdy,
        --del_tl_tx_src_sop => tl_tx_src_sop,
        del_tl_tx_src_eop => tl_tx_src_eop,
        dev_tl_tx_src_data => Src_data,
        dev_tl_tx_src_rdy_1 => Src_rdy_cmp,
        dev_tl_tx_src_rdy_2 => Src_rdy_p,
        dev_tl_tx_src_rdy_3 => Src_rdy_np,
        dev_tl_tx_dst_rdy => Dst_rdy,
        dev_tl_tx_src_sop => Src_sop,
        dev_tl_tx_src_eop => Src_eop,
        ENS1 => ENS1,
        ENS2 => ENS2,
        ENS3 => ENS3,
        TINA_READY => TINA_READY,
        READY_TO_TINA => READY_TO_TINA,
        ACK_TO_TINA => ACK_TO_TINA,
        tl_tx_src_vcb_hpf => tl_tx_src_vcb_hpf,
        tl_tx_src_vcb_hnpf => tl_tx_src_vcb_hnpf,
        tl_tx_src_vcb_hcmpf => tl_tx_src_vcb_hcmpf,
        tl_tx_src_vcb_hpemp => tl_tx_src_vcb_hpemp,
        tl_tx_src_vcb_hnpemp => tl_tx_src_vcb_hnpemp,
        tl_tx_src_vcb_hcmpemp => tl_tx_src_vcb_hcmpemp,
        tl_tx_src_vcb_dpemp => tl_tx_src_vcb_dpemp,
        tl_tx_src_vcb_dnpemp => tl_tx_src_vcb_dnpemp,
        tl_tx_src_vcb_dcmpemp => tl_tx_src_vcb_dcmpemp
    );


    tina: ENTITY WORK.ordering_logic port map(
        clk => clk,
        rst => rst,
        ready_vcb => READY_TO_TINA,
        ack_vcb => ACK_TO_TINA,
        tl_tx_src_vcb_hpf => tl_tx_src_vcb_hpf,
        tl_tx_src_vcb_hnpf => tl_tx_src_vcb_hnpf,
        tl_tx_src_vcb_hcmpf => tl_tx_src_vcb_hcmpf,
        tl_tx_src_vcb_hpemp => tl_tx_src_vcb_hpemp,
        tl_tx_src_vcb_hnpemp => tl_tx_src_vcb_hnpemp,
        tl_tx_src_vcb_hcmpemp => tl_tx_src_vcb_hcmpemp,
        tl_tx_src_vcb_dpemp => tl_tx_src_vcb_dpemp,
        tl_tx_src_vcb_dnpemp => tl_tx_src_vcb_dnpemp,
        tl_tx_src_vcb_dcmpemp => tl_tx_src_vcb_dcmpemp,
        tl_tx_src_ol_cmpen => ENS1,
        tl_tx_src_ol_pen => ENS2,
        tl_tx_src_ol_npen => ENS3,
        ready_ol => TINA_READY
    );



END ARCHITECTURE;