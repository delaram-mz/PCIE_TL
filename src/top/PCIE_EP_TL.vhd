--*****************************************************************************/
--	Filename:		PCIE_EP_TL.vhd
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
--  PCIE EndPoint Module
--  TLPs supported by this version: MRd, IORd, IOWr

--*****************************************************************************/
-- -------------------------------------------------------------
--  Top Module
-- -------------------------------------------------------------
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.Numeric_Std.all;

ENTITY PCIE_EP_TL IS 
PORT(
    clk:IN STD_LOGIC;
    rst:IN STD_LOGIC;
    -- TX
        -- TL
    ep_tl_tx_dst_rdy      : IN STD_LOGIC;
    ep_tl_tx_src_rdy_cmpl : OUT STD_LOGIC;
    ep_tl_tx_src_rdy_p    : OUT STD_LOGIC;
    ep_tl_tx_src_rdy_np   : OUT STD_LOGIC;
    ep_tl_tx_src_sop      : OUT STD_LOGIC;
    ep_tl_tx_src_eop      : OUT STD_LOGIC;
    ep_tl_tx_src_data     : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        -- DL
	ep_dl_tx_FC_cmp  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    ep_dl_tx_rdy_cmp : IN STD_LOGIC;
    ep_dl_tx_FC_p    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    ep_dl_tx_rdy_p   : IN STD_LOGIC;
    ep_dl_tx_FC_np   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    ep_dl_tx_rdy_np  : IN STD_LOGIC;
    
    -- RX
        -- TL
    ep_tl_rx_dst_rdy      : OUT STD_LOGIC;
    ep_tl_rx_src_rdy_cmpl : IN STD_LOGIC;
    ep_tl_rx_src_rdy_p    : IN STD_LOGIC;
    ep_tl_rx_src_rdy_np   : IN STD_LOGIC;
    ep_tl_rx_src_sop      : IN STD_LOGIC;
    ep_tl_rx_src_eop      : IN STD_LOGIC;
    ep_tl_rx_src_data     : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        -- DL
	ep_dl_rx_FC_cmp  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    ep_dl_rx_rdy_cmp : OUT STD_LOGIC;
    ep_dl_rx_FC_p    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    ep_dl_rx_rdy_p   : OUT STD_LOGIC;
    ep_dl_rx_FC_np   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    ep_dl_rx_rdy_np  : OUT STD_LOGIC;

    ep_IO_cbus : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
    ep_IO_dbus : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    ep_IO_abus : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

    --PHY interface
    ep_phy_send_pm_msg : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
    ep_phy_pm_msg_sent : OUT STD_LOGIC;
    ep_phy_incoming_pm_msg : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
    ep_phy_pm_msg_received : IN STD_LOGIC
    );
END ENTITY PCIE_EP_TL;

ARCHITECTURE TOP_ARC OF PCIE_EP_TL IS
    -- TX path signals
	SIGNAL tl_tx_dst_rdy : STD_LOGIC := '0';
    SIGNAL tl_tx_src_rdy : STD_LOGIC := '0';
    SIGNAL tl_tx_src_sop : STD_LOGIC := '0';
    SIGNAL tl_tx_src_eop : STD_LOGIC := '0';
    SIGNAL tl_tx_src_rdy_cmpl : STD_LOGIC;
    SIGNAL tl_tx_src_rdy_p : STD_LOGIC;
    SIGNAL tl_tx_src_rdy_np : STD_LOGIC;

    -- RX path signals
	SIGNAL tl_rx_dst_rdy : STD_LOGIC := '0';
    -- SIGNAL tl_rx_src_rdy : STD_LOGIC := '0';
    SIGNAL ep_tl_rx_src_rdy : STD_LOGIC := '0'; --for malformedTLP test
    SIGNAL tl_rx_src_sop : STD_LOGIC := '0';
    SIGNAL tl_rx_src_eop : STD_LOGIC := '0';
    SIGNAL tl_rx_src_rdy_cmpl : STD_LOGIC;
    SIGNAL tl_rx_src_rdy_p : STD_LOGIC;
    SIGNAL tl_rx_src_rdy_np : STD_LOGIC;

    -- Internal signals
    SIGNAL start_tx : STD_LOGIC := '0';
    SIGNAL tx_done  : STD_LOGIC := '0';
    SIGNAL tl_tx_src_data : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL tl_rx_src_data : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL tx_hdr1_in : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL tx_hdr2_in : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL tx_hdr3_in : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL tx_hdr1_ld : STD_LOGIC;
    SIGNAL tx_hdr2_ld : STD_LOGIC;
    SIGNAL tx_hdr3_ld : STD_LOGIC;
    SIGNAL get_data_from_mem : STD_LOGIC;
    SIGNAL got_data_from_mem : STD_LOGIC;
    SIGNAL get_data_from_IO : STD_LOGIC;
    SIGNAL data_length : STD_LOGIC_VECTOR (9 DOWNTO 0);
    SIGNAL readMEM : STD_LOGIC;
    SIGNAL writeMEM : STD_LOGIC;
    SIGNAL readyMEM : STD_LOGIC;
    SIGNAL readData : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL writeData : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL rx_memAddr : STD_LOGIC_VECTOR (9 dOWNTO 0);
    SIGNAL tx_memAddr : STD_LOGIC_VECTOR (9 dOWNTO 0);
    SIGNAL cmpl_reg_in: STD_LOGIC;
    SIGNAl p_reg_in: STD_LOGIC;
    SIGNAL np_reg_in: STD_LOGIC;
    SIGNAL base_address : STD_LOGIC_VECTOR (9 DOWNTO 0);

    -- RF interface
    SIGNAL ep_cfg_readRF : STD_LOGIC;
    SIGNAL ep_cfg_writeRF : STD_LOGIC;
    SIGNAL ep_cfg_writeData : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL ep_cfg_readData : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL ep_cfg_tx_memAddr : STD_LOGIC_VECTOR (9 DOWNTO 0);
    SIGNAL ep_cfg_rx_memAddr : STD_LOGIC_VECTOR (9 DOWNTO 0);
    SIGNAL get_data_from_cfg : STD_LOGIC;

    SIGNAL cfg_status   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL cfg_command  : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL cfg_BAR0 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL cfg_BAR1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL cfg_BAR2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL cfg_BAR3 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL cfg_BAR4 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL cfg_BAR5 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL cfg_capPtr   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL cfg_capID	: STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL cfg_mask	: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL cfg_send_error_allowed : STD_LOGIC;
    SIGNAL cfg_maxPayload : STD_LOGIC_VECTOR (2 DOWNTO 0);


    BEGIN
    -- Flow Control instance (Tx path)
    Flow_Control_transmit_inst: ENTITY WORK.VCB_TRANSMITER 
        GENERIC MAP (3)
        PORT MAP(
            clk                => clk,
            rst                => rst,
            Fc_DLLPs_cmp       => ep_dl_tx_FC_cmp,
            ready_cmp          => ep_dl_tx_rdy_cmp,
            Fc_DLLPs_p         => ep_dl_tx_FC_p,
            ready_p            => ep_dl_tx_rdy_p,
            Fc_DLLPs_np        => ep_dl_tx_FC_np,
            ready_np           => ep_dl_tx_rdy_np,
            tl_tx_src_data     => tl_tx_src_data,
            tl_tx_src_rdy_cmpl => tl_tx_src_rdy_cmpl,
            tl_tx_src_rdy_p    => tl_tx_src_rdy_p,
            tl_tx_src_rdy_np   => tl_tx_src_rdy_np,
            tl_tx_dst_rdy      => tl_tx_dst_rdy,
            -- Vivado tl_tx_src_sop      => tl_tx_src_sop,
            tl_tx_src_eop      => tl_tx_src_eop,
            Src_data           => ep_tl_tx_src_data,
            Src_rdy_cmp        => ep_tl_tx_src_rdy_cmpl,
            Src_rdy_p          => ep_tl_tx_src_rdy_p,
            Src_rdy_np         => ep_tl_tx_src_rdy_np,
            Dst_rdy            => ep_tl_tx_dst_rdy,
            Src_sop            => ep_tl_tx_src_sop,
            Src_eop            => ep_tl_tx_src_eop
            );
    -- TLP Creator instance (Tx path)
    Transmitter_inst : ENTITY WORK.TLP_Creator_Transmitter_TOP(TOP_ARC)
        GENERIC MAP (3)    
        PORT MAP(
            clk                => clk,
            rst                => rst,
            start_tx           => start_tx,
            tx_done            => tx_done,
            tl_tx_dst_rdy      => tl_tx_dst_rdy, 
            tl_tx_src_rdy_cmpl => tl_tx_src_rdy_cmpl,
            tl_tx_src_rdy_p    => tl_tx_src_rdy_p,
            tl_tx_src_rdy_np   => tl_tx_src_rdy_np, 
            tl_tx_src_sop      => tl_tx_src_sop, 
            tl_tx_src_eop      => tl_tx_src_eop, 
            tl_tx_src_data     => tl_tx_src_data, 
            tx_hdr1_in         => tx_hdr1_in, 
            tx_hdr2_in         => tx_hdr2_in, 
            tx_hdr3_in         => tx_hdr3_in,
            tx_hdr1_ld         => tx_hdr1_ld, 
            tx_hdr2_ld         => tx_hdr2_ld, 
            tx_hdr3_ld         => tx_hdr3_ld,
            get_data_from_mem  => get_data_from_mem,
            got_data_from_mem  => got_data_from_mem,
            data_length        => data_length,
            base_address       => base_address,
            cmpl_reg_in        => cmpl_reg_in,
            p_reg_in           => p_reg_in,
            np_reg_in          => np_reg_in,
            readMEM            => readMEM, 
            readData           => readData, 
            readyMEM           => readyMEM,
            tx_memAddr         => tx_memAddr,
            get_data_from_IO   => get_data_from_IO,
            IO_dbus            => ep_IO_dbus,
            get_data_from_cfg  => get_data_from_cfg,
            cfg_readData       => ep_cfg_readData,
            readRF             => ep_cfg_readRF,
            cfg_tx_memAddr     => ep_cfg_tx_memAddr
           );
    -- EP MEMORY
   EP_MEM : ENTITY WORK.EP_MEM(behaviour)
       PORT MAP(
           clk       => clk, 
           rst       => rst, 
           readMEM   => readMEM, 
           writeMEM  => writeMEM,
           writeData => writeData, 
           readData  => readData, 
           readyMEM  => readyMEM,
           readAddr  => tx_memAddr,
           writeAddr => rx_memAddr
       );

    -- Configuration Register File
   Config_RF : ENTITY WORK.Config_RF(behaviour)
       PORT MAP(
           clk       => clk, 
           rst       => rst, 
           readRF    => ep_cfg_readRF, 
           writeRF   => ep_cfg_writeRF,
           writeData => ep_cfg_writeData, 
           readData  => ep_cfg_readData, 
           readAddr  => ep_cfg_tx_memAddr,
           writeAddr => ep_cfg_rx_memAddr,
           status   => cfg_status,
           command  => cfg_command,
           BAR0 => cfg_BAR0,
           BAR1 => cfg_BAR1,
           BAR2 => cfg_BAR2,
           BAR3 => cfg_BAR3,
           BAR4 => cfg_BAR4,
           BAR5 => cfg_BAR5,
           capPtr   => cfg_capPtr,
           capID => cfg_capID,
           mask	 => cfg_mask,
           maxPayload => cfg_maxPayload,
           send_error_allowed => cfg_send_error_allowed
       );
    -- TLP Creator instance (Rx path)
    Receiver_inst : ENTITY WORK.TLP_Creator_Receiver_TOP(TOP_ARC)
        GENERIC MAP (3) 
        PORT MAP(
            clk               => clk, 
            rst               => rst,
            start_tx          => start_tx,
            tx_done           => tx_done,
            tl_rx_dst_rdy     => ep_tl_rx_dst_rdy, 
            tl_rx_src_rdy     => ep_tl_rx_src_rdy, 
            tl_rx_src_sop     => ep_tl_rx_src_sop, 
            tl_rx_src_eop     => ep_tl_rx_src_eop, 
            tl_rx_src_data    => ep_tl_rx_src_data, 
            tx_hdr1_in        => tx_hdr1_in, 
            tx_hdr2_in        => tx_hdr2_in, 
            tx_hdr3_in        => tx_hdr3_in,
            tx_hdr1_ld        => tx_hdr1_ld, 
            tx_hdr2_ld        => tx_hdr2_ld, 
            tx_hdr3_ld        => tx_hdr3_ld,
            get_data_from_mem => get_data_from_mem,
            got_data_from_mem => got_data_from_mem,
            data_length       => data_length,
            base_address      => base_address,
            cmpl              => cmpl_reg_in,
            p                 => p_reg_in,
            np                => np_reg_in,
            writeMEM          => writeMEM,
            writeData         => writeData,
            rx_memAddr        => rx_memAddr,
            get_data_from_IO  => get_data_from_IO,
            IO_cbus           => ep_IO_cbus,
            IO_abus           => ep_IO_abus,
            IO_dbus           => ep_IO_dbus,
            get_data_from_cfg => get_data_from_cfg,
            writeRF           => ep_cfg_writeRF,
            cfg_writeData     => ep_cfg_writeData,
            cfg_rx_memAddr    => ep_cfg_rx_memAddr,
            capID             => cfg_capID,
            mask	          => cfg_mask,
            maxPayload        => cfg_maxPayload,
            send_error_allowed => cfg_send_error_allowed,
                --PHY interface
            send_pm_msg => ep_phy_send_pm_msg, 
            pm_msg_sent => ep_phy_pm_msg_sent, 
            incoming_pm_msg => ep_phy_incoming_pm_msg, 
            pm_msg_received => ep_phy_pm_msg_received
           );
    -- -- Flow Control instance (Rx path)  --for malformedTLP test
    -- Flow_Control_receive_inst: ENTITY WORK.VCB_RECEIVER 
    --     GENERIC MAP (6)     
    --     PORT MAP(
    --         clk               => clk,
    --         rst               => rst,
    --         Fc_DLLPs_cmp      => ep_dl_rx_Fc_cmp,
    --         ready_cmp         => ep_dl_rx_rdy_cmp,
    --         Fc_DLLPs_p        => ep_dl_rx_Fc_p,
    --         ready_p           => ep_dl_rx_rdy_p,
    --         Fc_DLLPs_np       => ep_dl_rx_Fc_np,
    --         ready_np          => ep_dl_rx_rdy_np,
    --         Src_data          => ep_tl_rx_src_data,
    --         Src_rdy_cmp       => ep_tl_rx_src_rdy_cmpl,
    --         Src_rdy_p         => ep_tl_rx_src_rdy_p,
    --         Src_rdy_np        => ep_tl_rx_src_rdy_np,
    --         Dst_rdy           => ep_tl_rx_dst_rdy,
    --         Src_sop           => ep_tl_rx_src_sop,
    --         Src_eop           => ep_tl_rx_src_eop,
    --         tl_rx_src_data    => tl_rx_src_data,
    --         tl_rx_src_rdy_cmp => tl_rx_src_rdy_cmpl,
    --         tl_rx_src_rdy_p   => tl_rx_src_rdy_p,
    --         tl_rx_src_rdy_np  => tl_rx_src_rdy_np,
    --         tl_rx_dst_rdy     => tl_rx_dst_rdy,
    --         tl_rx_src_sop     => tl_rx_src_sop,
    --         tl_rx_src_eop     => tl_rx_src_eop
    --         );
            
    -- packet creator receiver read signal
    -- tl_rx_src_rdy <= tl_rx_src_rdy_cmpl OR tl_rx_src_rdy_p OR tl_rx_src_rdy_np;  --for malformedTLP test
    ep_tl_rx_src_rdy <= ep_tl_rx_src_rdy_cmpl OR ep_tl_rx_src_rdy_p OR ep_tl_rx_src_rdy_np;
END ARCHITECTURE TOP_ARC ;

