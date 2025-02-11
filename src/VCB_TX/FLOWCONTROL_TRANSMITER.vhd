--*****************************************************************************/
--	Filename:		FLOWCONTROL_TRANSMITER.vhd
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

ENTITY FLOWCONTROL_TRANSMITER IS 
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
    del_tl_tx_src_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    del_tl_tx_src_rdy_1 : IN STD_LOGIC;
    del_tl_tx_src_rdy_2 : IN STD_LOGIC;
    del_tl_tx_src_rdy_3 : IN STD_LOGIC;
    del_tl_tx_dst_rdy : OUT STD_LOGIC;
    --del_tl_tx_src_sop : IN STD_LOGIC;   --not used
    del_tl_tx_src_eop : IN STD_LOGIC;
    dev_tl_tx_src_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    dev_tl_tx_src_rdy_1 : OUT STD_LOGIC;
    dev_tl_tx_src_rdy_2 : OUT STD_LOGIC;
    dev_tl_tx_src_rdy_3 : OUT STD_LOGIC;
    dev_tl_tx_dst_rdy : IN STD_LOGIC;
    dev_tl_tx_src_sop : OUT STD_LOGIC;
    dev_tl_tx_src_eop : OUT STD_LOGIC;
    ENS1 : IN STD_LOGIC;
    ENS2 : IN STD_LOGIC;
    ENS3 : IN STD_LOGIC;
    TINA_READY : IN STD_LOGIC;
    READY_TO_TINA : OUT STD_LOGIC;
    ACK_TO_TINA : OUT STD_LOGIC;
    tl_tx_src_vcb_hpf : OUT STD_LOGIC;
    tl_tx_src_vcb_hnpf : OUT STD_LOGIC;
    tl_tx_src_vcb_hcmpf : OUT STD_LOGIC;
    tl_tx_src_vcb_hpemp : OUT STD_LOGIC;
    tl_tx_src_vcb_hnpemp : OUT STD_LOGIC;
    tl_tx_src_vcb_hcmpemp : OUT STD_LOGIC;
    tl_tx_src_vcb_dpemp : OUT STD_LOGIC;
    tl_tx_src_vcb_dnpemp : OUT STD_LOGIC;
    tl_tx_src_vcb_dcmpemp : OUT STD_LOGIC
    );
END FLOWCONTROL_TRANSMITER;
    
ARCHITECTURE ARCH1 OF FLOWCONTROL_TRANSMITER IS

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
    SIGNAL COUNTER_RST_RECIEVED_DATA : STD_LOGIC;
    SIGNAL SAVE_READY_RECEIVE_DLRM : STD_LOGIC;
    SIGNAL PUSH_HEADER : STD_LOGIC;
    SIGNAL PUSH_DATA : STD_LOGIC;
    SIGNAL COUNTER_EN_RECEIVE_DLRM : STD_LOGIC;
    SIGNAL comp_header_empty_from_gate : STD_LOGIC;
    SIGNAL posted_header_empty_from_gate : STD_LOGIC;
    SIGNAL SAVE_ENS_SIG : STD_LOGIC;
    SIGNAL COUNTER_RST_SEND_DATA : STD_LOGIC;
    SIGNAL READY_TO_DLRM : STD_LOGIC;
    SIGNAL COUNTER_EN_SEND_DATA : STD_LOGIC;
    SIGNAL SEND_HEADER_OR_DATA : STD_LOGIC;
    SIGNAL POP_HEADER : STD_LOGIC;
    SIGNAL POP_DATA : STD_LOGIC;
    SIGNAL SHOW_HEADER : STD_LOGIC;
    SIGNAL SHOW_DATA : STD_LOGIC;

    SIGNAL Send_sig_h : STD_LOGIC;
    SIGNAL Send_sig_d : STD_LOGIC;

    SIGNAL HEADER_COUNT_TO_TRANSMIT : STD_LOGIC;
    SIGNAL HEADER_COUNT_TO_RECEIVE : STD_LOGIC;
    SIGNAL HEADER_COUNT_RECEIVE_bg_Comparator_COUNTER_OUT_RECEIVE_DLRM : STD_LOGIC;
    SIGNAL HEADER_COUNT_RECEIVE_ls_Comparator_COUNTER_OUT_RECEIVE_DLRM : STD_LOGIC;

    SIGNAL comp_top_header_ld_to_receive : STD_LOGIC;
    SIGNAL posted_top_header_ld_to_receive : STD_LOGIC;
    SIGNAL nonposted_top_header_ld_to_receive : STD_LOGIC;
    SIGNAL comp_top_header_ld_to_transmit : STD_LOGIC;
    SIGNAL posted_top_header_ld_to_transmit : STD_LOGIC;
    SIGNAL nonposted_top_header_ld_to_transmit : STD_LOGIC;

    SIGNAL rst_reg : STD_LOGIC;												 
    SIGNAL TOP_HEADER_TRANSMIT_LD : STD_LOGIC;
    SIGNAL COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone : STD_LOGIC;
    SIGNAL COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT : STD_LOGIC;
    SIGNAL COUNTER_OUT_SEND_DATA_EQ_HEADER_COUNT_TRANSMIT : STD_LOGIC;
    SIGNAL COUNTER_OUT_SEND_DATA_ls_ONE : STD_LOGIC;    
    SIGNAL COUNTER_OUT_SEND_DATA_EQ_ONE : STD_LOGIC;
    SIGNAL COUNTER_OUT_RECEIVE_DLRM_ls_ONE : STD_LOGIC;
    SIGNAL COUNTER_OUT_RECEIVE_DLRM_EQ_ONE : STD_LOGIC;

    SIGNAL fullh : STD_LOGIC;
    SIGNAL fulld : STD_LOGIC;
    SIGNAL EMPTYh : STD_LOGIC;
    SIGNAL EMPTYd : STD_LOGIC;
    

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


DATAPATH_M: ENTITY WORK.VCB_DATAPATH_TRANSMITER
GENERIC MAP (
    log2sizefifo => log2sizefifo
)
PORT MAP (
    clk                             => clk,
    rst                             => rst,
    del_tl_tx_src_data              => del_tl_tx_src_data,
    del_tl_tx_src_rdy_1             => del_tl_tx_src_rdy_1,
    del_tl_tx_src_rdy_2             => del_tl_tx_src_rdy_2,
    del_tl_tx_src_rdy_3             => del_tl_tx_src_rdy_3,
    Fc_DLLPs_cmp                    => Fc_DLLPs_cmp,
    Fc_DLLPs_p                      => Fc_DLLPs_p,
    Fc_DLLPs_np                     => Fc_DLLPs_np,
    ready_cmp                       => ready_cmp,
    ready_p                         => ready_p,
    ready_np                        => ready_np,
    PUSH_HEADER                     => PUSH_HEADER,
    PUSH_DATA                       => PUSH_DATA,
    dev_tl_tx_dst_rdy               => dev_tl_tx_dst_rdy,
    POP_HEADER                      => POP_HEADER,
    POP_DATA                        => POP_DATA,
    SHOW_HEADER                     => SHOW_HEADER,
    SHOW_DATA                       => SHOW_DATA,
    ENS1                            => ENS1,
    ENS2                            => ENS2,
    ENS3                            => ENS3,
    READY_TO_DLRM                   => READY_TO_DLRM,
    rst_reg					        => rst_reg,										 
    TOP_HEADER_TRANSMIT_LD          => TOP_HEADER_TRANSMIT_LD,
    COUNTER_RST_RECIEVED_DATA       => COUNTER_RST_RECIEVED_DATA,
    COUNTER_EN_RECEIVE_DLRM         => COUNTER_EN_RECEIVE_DLRM,
    COUNTER_RST_SEND_DATA           => COUNTER_RST_SEND_DATA,
    COUNTER_EN_SEND_DATA            => COUNTER_EN_SEND_DATA,
    SAVE_READY_RECEIVE_DLRM         => SAVE_READY_RECEIVE_DLRM,
    SAVE_ENS_SIG                    => SAVE_ENS_SIG,
    dev_tl_tx_src_data              => dev_tl_tx_src_data,
    dev_tl_tx_src_rdy_1             => dev_tl_tx_src_rdy_1,
    dev_tl_tx_src_rdy_2             => dev_tl_tx_src_rdy_2,
    dev_tl_tx_src_rdy_3             => dev_tl_tx_src_rdy_3,
    nonposted_header_empty_from_gate => nonposted_header_empty_from_gate,
    comp_header_empty_from_gate      => comp_header_empty_from_gate,
    posted_header_empty_from_gate    => posted_header_empty_from_gate,
    comp_header_full_from_gate       => comp_header_full_from_gate,
    comp_data_full_from_gate         => comp_data_full_from_gate,
    posted_header_full_from_gate     => posted_header_full_from_gate,
    posted_data_full_from_gate       => posted_data_full_from_gate,
    nonposted_header_full_from_gate  => nonposted_header_full_from_gate,
    nonposted_data_full_from_gate    => nonposted_data_full_from_gate,
    Send_sig_h                      => Send_sig_h,
    Send_sig_d                      => Send_sig_d,
    HEADER_COUNT_RECEIVE_bg_Comparator_COUNTER_OUT_RECEIVE_DLRM => HEADER_COUNT_RECEIVE_bg_Comparator_COUNTER_OUT_RECEIVE_DLRM,
    HEADER_COUNT_RECEIVE_ls_Comparator_COUNTER_OUT_RECEIVE_DLRM => HEADER_COUNT_RECEIVE_ls_Comparator_COUNTER_OUT_RECEIVE_DLRM,
    COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone => COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone,
    COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT => COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT,
    --COUNTER_OUT_SEND_DATA_EQ_HEADER_COUNT_TRANSMIT => COUNTER_OUT_SEND_DATA_EQ_HEADER_COUNT_TRANSMIT, -----not used in datapath
    COUNTER_OUT_SEND_DATA_ls_ONE => COUNTER_OUT_SEND_DATA_ls_ONE,
    COUNTER_OUT_SEND_DATA_EQ_ONE => COUNTER_OUT_SEND_DATA_EQ_ONE,
    COUNTER_OUT_RECEIVE_DLRM_ls_ONE => COUNTER_OUT_RECEIVE_DLRM_ls_ONE,
    COUNTER_OUT_RECEIVE_DLRM_EQ_ONE => COUNTER_OUT_RECEIVE_DLRM_EQ_ONE,
    fullh                           => fullh,
    fulld                           => fulld,
    EMPTYh                          => EMPTYh,
    EMPTYd                          => EMPTYd
);



VCB_CONTROLER_INSTANCE : ENTITY WORK.VCB_CONTROLER_TRANSMITER
PORT MAP (
    clk                                     => clk,
    rst                                     => rst,
    del_tl_tx_src_rdy_1                     => del_tl_tx_src_rdy_1,
    del_tl_tx_src_rdy_2                     => del_tl_tx_src_rdy_2,
    del_tl_tx_src_rdy_3                     => del_tl_tx_src_rdy_3,
    --del_tl_tx_src_sop                       => del_tl_tx_src_sop,  -- not used
    del_tl_tx_src_eop                       => del_tl_tx_src_eop,
    dev_tl_tx_dst_rdy                       => dev_tl_tx_dst_rdy,
    --comp_header_full_from_gate              => comp_header_full_from_gate,       -- not used
    --comp_data_full_from_gate                => comp_data_full_from_gate,         -- not used
    --posted_header_full_from_gate            => posted_header_full_from_gate,
    --posted_data_full_from_gate              => posted_data_full_from_gate,
    --nonposted_header_full_from_gate         => nonposted_header_full_from_gate,
    --nonposted_data_full_from_gate           => nonposted_data_full_from_gate,
    nonposted_header_empty_from_gate        => nonposted_header_empty_from_gate,
    comp_header_empty_from_gate             => comp_header_empty_from_gate,
    posted_header_empty_from_gate           => posted_header_empty_from_gate,
    ENS1                                    => ENS1,
    ENS2                                    => ENS2,
    ENS3                                    => ENS3,
    TINA_READY                              => TINA_READY,
    --Send_sig_h                              => Send_sig_h,
    --Send_sig_d                              => Send_sig_d,
    --HEADER_COUNT_RECEIVE_bg_Comparator_COUNTER_OUT_RECEIVE_DLRM => HEADER_COUNT_RECEIVE_bg_Comparator_COUNTER_OUT_RECEIVE_DLRM,     -- not used
    --HEADER_COUNT_RECEIVE_ls_Comparator_COUNTER_OUT_RECEIVE_DLRM => HEADER_COUNT_RECEIVE_ls_Comparator_COUNTER_OUT_RECEIVE_DLRM,     -- not used
    COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone => COUNTER_OUT_SEND_DATA_HEADER_COUNT_TRANSMIT_add_DATA_COUNT_TRANSMIT_minusone,
    --COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT => COUNTER_OUT_SEND_DATA_ls_HEADER_COUNT_TRANSMIT,
    --COUNTER_OUT_SEND_DATA_EQ_HEADER_COUNT_TRANSMIT => COUNTER_OUT_SEND_DATA_EQ_HEADER_COUNT_TRANSMIT,  -- not used
    --COUNTER_OUT_SEND_DATA_ls_ONE            => COUNTER_OUT_SEND_DATA_ls_ONE,
    --COUNTER_OUT_SEND_DATA_EQ_ONE            => COUNTER_OUT_SEND_DATA_EQ_ONE,
    --COUNTER_OUT_RECEIVE_DLRM_ls_ONE         => COUNTER_OUT_RECEIVE_DLRM_ls_ONE,
    --COUNTER_OUT_RECEIVE_DLRM_EQ_ONE         => COUNTER_OUT_RECEIVE_DLRM_EQ_ONE,
    EMPTYh                                  => EMPTYh,
    EMPTYd                                  => EMPTYd,
    fullh                                   => fullh,
    fulld                                   => fulld,
    del_tl_tx_dst_rdy                       => del_tl_tx_dst_rdy,
    dev_tl_tx_src_sop                       => dev_tl_tx_src_sop,
    dev_tl_tx_src_eop                       => dev_tl_tx_src_eop,
    rst_reg				                    => rst_reg,									 
    TOP_HEADER_TRANSMIT_LD                  => TOP_HEADER_TRANSMIT_LD,
    PUSH_HEADER                             => PUSH_HEADER,
    PUSH_DATA                               => PUSH_DATA,
    POP_HEADER                              => POP_HEADER,
    POP_DATA                                => POP_DATA,
    COUNTER_RST_RECIEVED_DATA               => COUNTER_RST_RECIEVED_DATA,
    COUNTER_EN_RECEIVE_DLRM                 => COUNTER_EN_RECEIVE_DLRM,
    COUNTER_RST_SEND_DATA                   => COUNTER_RST_SEND_DATA,
    COUNTER_EN_SEND_DATA                    => COUNTER_EN_SEND_DATA,
    READY_TO_TINA                           => READY_TO_TINA,
    READY_TO_DLRM                           => READY_TO_DLRM,
    ACK_TO_TINA                             => ACK_TO_TINA,
    SAVE_READY_RECEIVE_DLRM                 => SAVE_READY_RECEIVE_DLRM,
    SAVE_ENS_SIG                            => SAVE_ENS_SIG,
    SHOW_HEADER                             => SHOW_HEADER,
    SHOW_DATA                               => SHOW_DATA
);


END ARCHITECTURE;
