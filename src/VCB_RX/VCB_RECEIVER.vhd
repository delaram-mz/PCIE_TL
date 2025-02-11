--*****************************************************************************/
--	Filename:		VCB_RECEIVER.vhd
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

ENTITY VCB_RECEIVER IS
GENERIC(log2sizefifo:INTEGER:=6);
PORT(
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
	
	-- Flow control ready signals:
	ready_cmp 				: OUT STD_LOGIC;							-- ready from gating logic (shows that DLL is working correctly)
    ready_p   				: OUT STD_LOGIC;							-- ready from gating logic (shows that DLL is working correctly)
	ready_np  				: OUT STD_LOGIC;							-- ready from gating logic (shows that DLL is working correctly)
    
	-- Update FC DLLP (Data/Hdr flow control credits):
	Fc_DLLPs_cmp 				: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    Fc_DLLPs_p   				: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    Fc_DLLPs_np  				: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	-- Coming Data from external module and relevant handshaking
    Src_data 					: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    Src_rdy_cmp 				: IN STD_LOGIC;
    Src_rdy_p   				: IN STD_LOGIC;
    Src_rdy_np  				: IN STD_LOGIC;
    Dst_rdy 					: OUT STD_LOGIC;
    Src_sop 					: IN STD_LOGIC;
    Src_eop 					: IN STD_LOGIC;
	
	-- Ou data to higher layer
    tl_rx_src_data  			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    tl_rx_src_rdy_cmp 			: OUT STD_LOGIC;
    tl_rx_src_rdy_p   			: OUT STD_LOGIC;
    tl_rx_src_rdy_np  			: OUT STD_LOGIC;
    tl_rx_dst_rdy 				: IN STD_LOGIC;
    tl_rx_src_sop 				: OUT STD_LOGIC;
    tl_rx_src_eop 				: OUT STD_LOGIC
    );
END VCB_RECEIVER;

ARCHITECTURE ARCH1 OF VCB_RECEIVER IS
    SIGNAL ENS1 : STD_LOGIC;
    SIGNAL ENS2 : STD_LOGIC;
    SIGNAL ENS3 : STD_LOGIC;
    SIGNAL OrderingLogic_rdy : STD_LOGIC;
    SIGNAL READY_TO_OrderingLogic : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_hcmpf : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_hpf : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_hnpf : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_hcmpemp : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_hpemp : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_hnpemp : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_dcmpemp : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_dpemp : STD_LOGIC;
    SIGNAL tl_tx_src_vcb_dnpemp : STD_LOGIC;
    SIGNAL ACK_TO_OrderingLogic : STD_LOGIC;
BEGIN
    FLOWCONTROL: ENTITY WORK.FLOWCONTROL_RECEIVER 
    generic map(log2sizefifo => log2sizefifo)
    port map(
        clk => clk,
        rst => rst,
		
		ready_cmp => ready_cmp,
		ready_p => ready_p,
		ready_np => ready_np,
		
			-- Update FC DLLP:
		 
        Fc_DLLPs_cmp => Fc_DLLPs_cmp,
        Fc_DLLPs_p => Fc_DLLPs_p,
        Fc_DLLPs_np => Fc_DLLPs_np,
	
        

        received_data_VCBin =>Src_data,
        rx_Src_rdy_cmp 		=> Src_rdy_cmp,
        rx_Src_rdy_p   		=> Src_rdy_p,
        rx_Src_rdy_np 		=> Src_rdy_np,
        rx_VCB_rdy    		=> Dst_rdy,
        rx_src_sop  		=> Src_sop,
        rx_src_eop 			=> Src_eop,
        VCB_out			    => tl_rx_src_data,
        VCB_SENDrdy_cmpl 	=> tl_rx_src_rdy_cmp,
        VCB_SENDrdy_P    	=> tl_rx_src_rdy_p,
        VCB_SENDrdy_NP   	=> tl_rx_src_rdy_np,
        dev_tl_tx_dst_rdy   => tl_rx_dst_rdy,
        dev_tl_tx_src_sop   => tl_rx_src_sop,
        dev_tl_tx_src_eop   => tl_rx_src_eop,
        ENS1 => ENS1,
        ENS2 => ENS2,
        ENS3 => ENS3,
        OrderingLogic_rdy => OrderingLogic_rdy,
        READY_TO_OrderingLogic => READY_TO_OrderingLogic,
        ACK_TO_OrderingLogic => ACK_TO_OrderingLogic,
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
        clk 						=> clk,
        rst 						=> rst,
        ready_vcb   				=> READY_TO_OrderingLogic,
        ack_vcb     				=> ACK_TO_OrderingLogic,
        tl_tx_src_vcb_hpf     		=> tl_tx_src_vcb_hpf,
        tl_tx_src_vcb_hnpf    		=> tl_tx_src_vcb_hnpf,
        tl_tx_src_vcb_hcmpf   		=> tl_tx_src_vcb_hcmpf,
        tl_tx_src_vcb_hpemp   		=> tl_tx_src_vcb_hpemp,
        tl_tx_src_vcb_hnpemp  		=> tl_tx_src_vcb_hnpemp,
        tl_tx_src_vcb_hcmpemp 		=> tl_tx_src_vcb_hcmpemp,
        tl_tx_src_vcb_dpemp   		=> tl_tx_src_vcb_dpemp,
        tl_tx_src_vcb_dnpemp  		=> tl_tx_src_vcb_dnpemp,
        tl_tx_src_vcb_dcmpemp 		=> tl_tx_src_vcb_dcmpemp,
		
		-- (posted/nonposted/cmpl data transmission Permission)
        tl_tx_src_ol_cmpen  		=> ENS1,
        tl_tx_src_ol_pen    		=> ENS2,
        tl_tx_src_ol_npen   		=> ENS3,
        ready_ol 		    		=> OrderingLogic_rdy
    );



END ARCHITECTURE;