--*****************************************************************************/
--	Filename:		TOP.vhd
--	Project:		MCI-PCH
--  Version:		1.0
--	History:		-
--	Date:			7 January 2025
--	Authors:	 	Hossein
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
--  Hossein's Modifications:   Adapt to North_Bridge_Controller_v1.1.vhd


--*****************************************************************************/

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP is
port(
    
    clk                             : in std_logic;
    rst                             : in std_logic;
    ep_tl_rx_src_rdy_p              : in std_logic;
    ep_tl_rx_src_sop                : in std_logic;
    ep_tl_rx_src_data               : in STD_LOGIC_VECTOR (31 DOWNTO 0);
    ep_tl_rx_src_eop                : in std_logic;
    ep_tl_rx_src_rdy_np             : in std_logic;
    ep_tl_rx_dst_rdy                : out std_logic;
    tl_rx_src_data_2                : out STD_LOGIC_VECTOR (31 DOWNTO 0)
                   
);
end TOP;

architecture Behavioral of TOP is
	
 -- TLP Creator Signals (Tx path)

    --SIGNAL tl_rx_src_data_2 : STD_LOGIC_VECTOR (31 DOWNTO 0);

    -- connections to outside
	SIGNAL ep_tl_tx_dst_rdy : STD_LOGIC := '0';
    SIGNAL ep_tl_tx_src_rdy_cmpl : STD_LOGIC := '0';
    SIGNAL ep_tl_tx_src_rdy_p : STD_LOGIC := '0';
    SIGNAL ep_tl_tx_src_rdy_np : STD_LOGIC := '0';
    SIGNAL ep_tl_tx_src_sop : STD_LOGIC := '0';
    SIGNAL ep_tl_tx_src_eop : STD_LOGIC := '0';
    SIGNAL ep_tl_tx_src_data : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');

    --SIGNAL ep_tl_rx_dst_rdy : STD_LOGIC := '0';
    SIGNAL ep_tl_rx_src_rdy_cmpl : STD_LOGIC := '0';
    --SIGNAL ep_tl_rx_src_rdy_p : STD_LOGIC := '0';
    --SIGNAL ep_tl_rx_src_rdy_np : STD_LOGIC := '0';
    --SIGNAL ep_tl_rx_src_sop : STD_LOGIC := '0';
    --SIGNAL ep_tl_rx_src_eop : STD_LOGIC := '0';
    --SIGNAL ep_tl_rx_src_data : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');


    -- data link signals
    SIGNAL ep_dl_tx_FC_cmp: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ep_dl_tx_rdy_cmp: STD_LOGIC;
    SIGNAL ep_dl_tx_FC_p: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ep_dl_tx_rdy_p: STD_LOGIC;
    SIGNAL ep_dl_tx_FC_np: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ep_dl_tx_rdy_np: STD_LOGIC;

    SIGNAL ep_dl_rx_FC_cmp: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ep_dl_rx_rdy_cmp: STD_LOGIC;
    SIGNAL ep_dl_rx_FC_p: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ep_dl_rx_rdy_p: STD_LOGIC;
    SIGNAL ep_dl_rx_FC_np: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ep_dl_rx_rdy_np: STD_LOGIC;

    -- IO Signals
    SIGNAL ep_IO_cbus : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL ep_IO_dbus : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL ep_IO_abus : STD_LOGIC_VECTOR (31 DOWNTO 0);




begin

    ep_IO_dbus <= X"AAAAAAAA" WHEN ep_IO_cbus = "01" ELSE (OTHERS => 'Z');
 
    --EP1 Instance
    EP1_Instance: ENTITY WORK.PCIE_EP_TL(TOP_ARC)
    PORT MAP(
        clk => clk,
        rst => rst,

        ep_tl_tx_dst_rdy      => ep_tl_tx_dst_rdy,
        ep_tl_tx_src_rdy_cmpl => ep_tl_tx_src_rdy_cmpl,
        ep_tl_tx_src_rdy_p    => ep_tl_tx_src_rdy_p,
        ep_tl_tx_src_rdy_np   => ep_tl_tx_src_rdy_np,
        ep_tl_tx_src_sop      => ep_tl_tx_src_sop,
        ep_tl_tx_src_eop      => ep_tl_tx_src_eop,
        ep_tl_tx_src_data     => ep_tl_tx_src_data,
        ep_dl_tx_FC_cmp       => ep_dl_tx_FC_cmp,
        ep_dl_tx_rdy_cmp      => ep_dl_tx_rdy_cmp,
        ep_dl_tx_FC_p         => ep_dl_tx_FC_p,
        ep_dl_tx_rdy_p        => ep_dl_tx_rdy_p,
        ep_dl_tx_FC_np        => ep_dl_tx_FC_np,
        ep_dl_tx_rdy_np       => ep_dl_tx_rdy_np,
            
        ep_tl_rx_dst_rdy      => ep_tl_rx_dst_rdy,
        ep_tl_rx_src_rdy_cmpl => ep_tl_rx_src_rdy_cmpl,
        ep_tl_rx_src_rdy_p    => ep_tl_rx_src_rdy_p,
        ep_tl_rx_src_rdy_np   => ep_tl_rx_src_rdy_np,
        ep_tl_rx_src_sop      => ep_tl_rx_src_sop,
        ep_tl_rx_src_eop      => ep_tl_rx_src_eop,
        ep_tl_rx_src_data     => ep_tl_rx_src_data,
        ep_dl_rx_FC_cmp       => ep_dl_rx_FC_cmp,
        ep_dl_rx_rdy_cmp      => ep_dl_rx_rdy_cmp,
        ep_dl_rx_FC_p         => ep_dl_rx_FC_p,
        ep_dl_rx_rdy_p        => ep_dl_rx_rdy_p,
        ep_dl_rx_FC_np        => ep_dl_rx_FC_np,
        ep_dl_rx_rdy_np       => ep_dl_rx_rdy_np,

        ep_IO_cbus            => ep_IO_cbus,
        ep_IO_dbus            => ep_IO_dbus,
        ep_IO_abus            => ep_IO_abus            
    );


    -- Response Receiver:
    -- Flow Control instance (Rx path)
    Flow_Control_receive_inst: ENTITY WORK.VCB_RECEIVER
    GENERIC MAP (log2sizefifo => 6)
    PORT MAP(
        clk               => clk,
        rst               => rst,
        Fc_DLLPs_cmp      => ep_dl_tx_FC_cmp,
        ready_cmp         => ep_dl_tx_rdy_cmp,
        Fc_DLLPs_p        => ep_dl_tx_FC_p,
        ready_p           => ep_dl_tx_rdy_p,
        Fc_DLLPs_np       => ep_dl_tx_FC_np,
        ready_np          => ep_dl_tx_rdy_np,
        Src_data          => ep_tl_tx_src_data,
        Src_rdy_cmp       => ep_tl_tx_src_rdy_cmpl,
        Src_rdy_p         => ep_tl_tx_src_rdy_p,
        Src_rdy_np        => ep_tl_tx_src_rdy_np,
        Dst_rdy           => ep_tl_tx_dst_rdy,
        Src_sop           => ep_tl_tx_src_sop,
        Src_eop           => ep_tl_tx_src_eop,
        tl_rx_src_data    => tl_rx_src_data_2,
        tl_rx_src_rdy_cmp => OPEN,
        tl_rx_src_rdy_p   => OPEN,
        tl_rx_src_rdy_np  => OPEN,
        tl_rx_dst_rdy     => OPEN,
        tl_rx_src_sop     => OPEN,
        tl_rx_src_eop     => OPEN
        );


end Behavioral;
