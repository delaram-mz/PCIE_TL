--*****************************************************************************/
--	Filename:		PCIE_EP_TL_TB.vhd
--	Project:		MCI-PCH
--  Version:		2.000
--	History:		-
--	Date:			26 Febuary 2023
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
-- Testbench for End Point (Transanction Layer)
-- Modules Under Test: 
        -- EndPoint
        -- Timer
        -- Interrupt Controller

--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

ENTITY PCIE_EP_TL_TB IS
END ENTITY PCIE_EP_TL_TB;

ARCHITECTURE test OF PCIE_EP_TL_TB IS
    -- TLP Creator Signals (Tx path)
	SIGNAL clk : STD_LOGIC := '0';
    SIGNAL rst : STD_LOGIC := '0';

	SIGNAL tl_rx_dst_rdy_2 : STD_LOGIC := '0';
    SIGNAL tl_rx_src_rdy_2 : STD_LOGIC := '0';
    SIGNAL tl_rx_src_sop_2 : STD_LOGIC := '0';
    SIGNAL tl_rx_src_eop_2 : STD_LOGIC := '0';

    SIGNAL tl_rx_src_rdy_cmpl_2 : STD_LOGIC;
    SIGNAL tl_rx_src_rdy_p_2 : STD_LOGIC;
    SIGNAL tl_rx_src_rdy_np_2 : STD_LOGIC;
    SIGNAL tl_rx_src_data_2 : STD_LOGIC_VECTOR (31 DOWNTO 0);

    -- connections to outside
	SIGNAL ep_tl_tx_dst_rdy : STD_LOGIC := '0';
    SIGNAL ep_tl_tx_src_rdy_cmpl : STD_LOGIC := '0';
    SIGNAL ep_tl_tx_src_rdy_p : STD_LOGIC := '0';
    SIGNAL ep_tl_tx_src_rdy_np : STD_LOGIC := '0';
    SIGNAL ep_tl_tx_src_sop : STD_LOGIC := '0';
    SIGNAL ep_tl_tx_src_eop : STD_LOGIC := '0';
    SIGNAL ep_tl_tx_src_data : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');

    SIGNAL ep_tl_rx_dst_rdy : STD_LOGIC := '0';
    SIGNAL ep_tl_rx_src_rdy_cmpl : STD_LOGIC := '0';
    SIGNAL ep_tl_rx_src_rdy_p : STD_LOGIC := '0';
    SIGNAL ep_tl_rx_src_rdy_np : STD_LOGIC := '0';
    SIGNAL ep_tl_rx_src_sop : STD_LOGIC := '0';
    SIGNAL ep_tl_rx_src_eop : STD_LOGIC := '0';
    SIGNAL ep_tl_rx_src_data : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');


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

    --Test Mem signal
    SIGNAL test_readMEM   : STD_LOGIC;
    SIGNAL test_writeMEM  : STD_LOGIC;
    SIGNAL test_writeData : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL test_readData  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL test_readyMEM  : STD_LOGIC;
    SIGNAL test_memAddr   : STD_LOGIC_VECTOR (9 dOWNTO 0);
 
    -- Added by Tina
    SIGNAL CSBAR,OUT1,OUT2,OUT0 : STD_LOGIC;
    SIGNAL INTA, CS_bar_intrp, INT : STD_LOGIC;
    SIGNAL IR_sig                  : STD_LOGIC_VECTOR(7 DOWNTO 0);



BEGIN	
    --EP1 Instance
    EP1_Instance: ENTITY WORK.TOP
        PORT MAP(
            clk => clk,
            rst => rst,
            ep_tl_rx_src_rdy_p      => ep_tl_rx_src_rdy_p,
            ep_tl_rx_src_sop        => ep_tl_rx_src_sop,
            ep_tl_rx_src_data       => ep_tl_rx_src_data,
            ep_tl_rx_src_eop        => ep_tl_rx_src_eop,
            ep_tl_rx_src_rdy_np     => ep_tl_rx_src_rdy_np,
            ep_tl_rx_dst_rdy        => ep_tl_rx_dst_rdy,
            tl_rx_src_data_2        => tl_rx_src_data_2         
        );



    -- Memory Instance  -> for testing
    -- test_MEM : ENTITY WORK.MEM(behaviour)
        -- PORT MAP(
        --     clk       => clk, 
        --     rst       => rst, 
        --     readMEM   => test_readMEM, 
        --     writeMEM  => test_writeMEM,
        --     writeData => test_writeData, 
        --     readData  => test_readData, 
        --     readyMEM  => test_readyMEM,
        --     addr      => test_memAddr
        -- );

    -- IO Instance: TIMER
        -- TIMER_ADR_CHECKER:ENTITY WORK.CSCHECKER(ARCH)
        --     GENERIC MAP(
        --         ADR_VAL => "000000",
        --         BITS => 6)
        --     PORT MAP(
        --         ADR=>ep_IO_abus(9 DOWNTO 4),
        --         CSBAR=>CSBAR
        --         );
        -- TIMER:ENTITY WORK.TIMER(ARCH)
        --     PORT MAP(
        --         RST=>rst,
        --         D=>ep_IO_dbus(7 downto 0),
        --         RDbar=>ep_IO_cbus(1),
        --         WRbar=>ep_IO_cbus(0),
        --         CSbar=>CSBAR,
        --         A1=>ep_IO_abus(3),
        --         A0=>ep_IO_abus(2),
        --         CLK2=>clk,
        --         CLK1=>clk,
        --         CLK0=>clk,
        --         GATE2=>'1',
        --         GATE1=>'1',
        --         GATE0=>'1',
        --         OUT2=>OUT2,
        --         OUT1=>OUT1,
        --         OUT0=>OUT0
        --         );
    
    -- --IO Instance: Interrupt Controller
    --     IR_sig <= "00010101";
    --     addr_logic_inst : ENTITY WORK.addr_logic(addr_logic_arc) 
    --         GENERIC MAP(
    --             ADR_VAL1 => "00100001",
    --             ADR_VAL2 => "00100000", 
    --             BITS => 8)
    --         PORT MAP(
    --             ADR=>ep_IO_abus(7 DOWNTO 0),
    --             CSBAR=>CS_bar_intrp
    --             );
    --     pulseGen_inst : ENTITY WORK.pulseGen(pulseGen_arc) 
    --         GENERIC MAP(
    --             ADR_VAL => "00100010",
    --             BITS => 8)
    --         PORT MAP(
    --             clk=> clk,
    --             ADR=>ep_IO_abus(7 DOWNTO 0),
    --             INTA=>INTA
    --             );
    --     intrp_ctrl_inst : ENTITY WORK.PIC(PIC_arc)  
    --         PORT MAP(
    --             clk => clk,
    --             rst => rst, 
    --             INTA_bar => INTA,
    --             A0 => ep_IO_abus(0), 
    --             RD_bar => ep_IO_cbus(1),
    --             WR_bar => ep_IO_cbus(0),
    --             CS_bar => CS_bar_intrp,
    --             databus => ep_IO_dbus(7 downto 0), 
    --             IR => IR_sig, 
    --             INT => INT
    --             );

    --Clock generation:
    clk <= NOT clk AFTER 1 NS;

    PROCESS BEGIN
        rst <= '1';
        WAIT FOR 0 NS;
        WAIT FOR 3 NS;
        rst <= '0';
        WAIT FOR 30 NS;


         -- Test scenario: sending a tlp MWr to EP receiver
         ep_tl_rx_src_rdy_p <='1';
         ep_tl_rx_src_sop<='1';
         ep_tl_rx_src_data <= X"40000006"; --Hdr1: MWr, length = 6, 
         WAIT UNTIL  (clk='1' AND ep_tl_rx_dst_rdy = '1');
         ep_tl_rx_src_sop <='0';
         ep_tl_rx_src_data <= X"FFFF0000"; --Hdr2: req_ID = X"FFFF"
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"00000000"; --Hdr3: Address: 0
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"11111111"; --Data1
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"22222222"; --Data2
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"33333333"; --Data3
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"44444444"; --Data4
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"55555555"; --Data5
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"66666666"; --Data6
         ep_tl_rx_src_eop<='1';
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_eop<='0';
         ep_tl_rx_src_rdy_p <='0';
         WAIT UNTIL clk = '1';



         -- Test scenario: sending a tlp MRd to EP receiver
         ep_tl_rx_src_rdy_np <='1';
         ep_tl_rx_src_sop<='1';
         ep_tl_rx_src_data <= X"00000006"; --Hdr1: Mrd, length = 1, 
         WAIT UNTIL  (clk='1' AND ep_tl_rx_dst_rdy = '1');
         -- WAIT UNTIL clk='1';
         ep_tl_rx_src_sop <='0';
         ep_tl_rx_src_data <= X"FFFF0000"; --Hdr2: req_ID = X"FFFF"
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"00000000"; --Hdr3: Address: 0
         ep_tl_rx_src_eop<='1';
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_eop<='0';
         ep_tl_rx_src_rdy_np <='0';
         WAIT UNTIL clk = '1';

         -- Test scenario: sending a tlp MRd to EP receiver
         ep_tl_rx_src_rdy_np <='1';
         ep_tl_rx_src_sop<='1';
         ep_tl_rx_src_data <= X"00000005"; --Hdr1: Mrd, length = 5, 
         WAIT UNTIL  (clk='1' AND ep_tl_rx_dst_rdy = '1');
         -- WAIT UNTIL clk='1';
         ep_tl_rx_src_sop <='0';
         ep_tl_rx_src_data <= X"FFFF0000"; --Hdr2: req_ID = X"FFFF"
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"00000000"; --Hdr3: Address: 0
         ep_tl_rx_src_eop<='1';
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_eop<='0';
         ep_tl_rx_src_rdy_np <='0';
         WAIT UNTIL clk = '1';
        
         -- Test scenario: sending a tlp IOWr to EP receiver
         -- Interrrupt Controller
         ep_tl_rx_src_rdy_np <='1';
         ep_tl_rx_src_sop<='1';
         ep_tl_rx_src_data <= X"42000001"; --Hdr1: IOWr, length = 1, 
         WAIT UNTIL  (clk='1' AND ep_tl_rx_dst_rdy = '1');
         -- WAIT UNTIL clk='1';
         ep_tl_rx_src_sop<='0';
         ep_tl_rx_src_data <= X"FFFF0000"; --Hdr2: req_ID = X"FFFF"
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"00000000"; --Hdr3: Address: 20h << 2 
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"0000009B"; --Data1: IO Data1 : icw1
         ep_tl_rx_src_eop<='1';
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_eop<='0';
         ep_tl_rx_src_rdy_np <='0';
         WAIT UNTIL clk = '1';

         ep_tl_rx_src_rdy_np <='1';
         ep_tl_rx_src_sop<='1';
         ep_tl_rx_src_data <= X"42000001"; --Hdr1: IOWr, length = 1, 
         WAIT UNTIL  (clk='1' AND ep_tl_rx_dst_rdy = '1');
         ep_tl_rx_src_sop<='0';
         ep_tl_rx_src_data <= X"FFFF0000"; --Hdr2: req_ID = X"FFFF"
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"00000084"; --Hdr3: Address: 21h << 2
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"000000F8"; --Data1: IO Data1 :icw2 
         ep_tl_rx_src_eop<='1';
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_eop<='0';
         ep_tl_rx_src_rdy_np <='0';
         WAIT UNTIL clk = '1';
        
         ep_tl_rx_src_rdy_np <='1';
         ep_tl_rx_src_sop<='1';
         ep_tl_rx_src_data <= X"42000001"; --Hdr1: IOWr, length = 1, 
         WAIT UNTIL  (clk='1' AND ep_tl_rx_dst_rdy = '1');
         ep_tl_rx_src_sop<='0';
         ep_tl_rx_src_data <= X"FFFF0000"; --Hdr2: req_ID = X"FFFF"
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"00000084"; --Hdr3: Address: 21h << 2
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"00000008"; --Data1: IO Data1 :icw4 
         ep_tl_rx_src_eop<='1';
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_eop<='0';
         ep_tl_rx_src_rdy_np <='0';
         WAIT UNTIL clk = '1';

         ep_tl_rx_src_rdy_np <='1';
         ep_tl_rx_src_sop<='1';
         ep_tl_rx_src_data <= X"42000001"; --Hdr1: IOWr, length = 1, 
         WAIT UNTIL  (clk='1' AND ep_tl_rx_dst_rdy = '1');
         ep_tl_rx_src_sop<='0';
         ep_tl_rx_src_data <= X"FFFF0000"; --Hdr2: req_ID = X"FFFF"
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"00000084"; --Hdr3: Address: 21h << 2
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"000000C0"; --Data1: IO Data1 : ocw1 
         ep_tl_rx_src_eop<='1';
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_eop<='0';
         ep_tl_rx_src_rdy_np <='0';
         WAIT UNTIL clk = '1';

         ep_tl_rx_src_rdy_np <='1';
         ep_tl_rx_src_sop<='1';
         ep_tl_rx_src_data <= X"42000001"; --Hdr1: IOWr, length = 1, 
         WAIT UNTIL  (clk='1' AND ep_tl_rx_dst_rdy = '1');
         ep_tl_rx_src_sop<='0';
         ep_tl_rx_src_data <= X"FFFF0000"; --Hdr2: req_ID = X"FFFF"
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"00000080"; --Hdr3: Address: 20h << 2
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"000000C0"; --Data1: IO Data1 : ocw2 
         ep_tl_rx_src_eop<='1';
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_eop<='0';
         ep_tl_rx_src_rdy_np <='0';
         WAIT UNTIL clk = '1';

         ep_tl_rx_src_rdy_np <='1';
         ep_tl_rx_src_sop<='1';
         ep_tl_rx_src_data <= X"42000001"; --Hdr1: IOWr, length = 1, 
         WAIT UNTIL  (clk='1' AND ep_tl_rx_dst_rdy = '1');
         ep_tl_rx_src_sop<='0';
         ep_tl_rx_src_data <= X"FFFF0000"; --Hdr2: req_ID = X"FFFF"
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"00000080"; --Hdr3: Address: 20h << 2
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"0000000A"; --Data1: IO Data1 : ocw3 
         ep_tl_rx_src_eop<='1';
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_eop<='0';
         ep_tl_rx_src_rdy_np <='0';
         WAIT UNTIL clk = '1';

         -- Test scenario: sending a tlp IORd to intrp_ctrl
         ep_tl_rx_src_rdy_np <='1';
         ep_tl_rx_src_sop<='1';
         ep_tl_rx_src_data <= X"02000001"; --Hdr1: IORd, length = 1, 
         WAIT UNTIL  (clk='1' AND ep_tl_rx_dst_rdy = '1');
         ep_tl_rx_src_sop<='0';
         ep_tl_rx_src_data <= X"FFFF0000"; --Hdr2: req_ID = X"FFFF"
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"00000088"; --Hdr3: Address: 22h << 2 
         ep_tl_rx_src_eop<='1';
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_eop<='0';
         ep_tl_rx_src_rdy_np <='0';
         WAIT UNTIL clk = '1';

         ep_tl_rx_src_rdy_np <='1';
         ep_tl_rx_src_sop<='1';
         ep_tl_rx_src_data <= X"02000001"; --Hdr1: IORd, length = 1, 
         WAIT UNTIL  (clk='1' AND ep_tl_rx_dst_rdy = '1');
         ep_tl_rx_src_sop<='0';
         ep_tl_rx_src_data <= X"FFFF0000"; --Hdr2: req_ID = X"FFFF"
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"00000088"; --Hdr3: Address: 22h << 2 
         ep_tl_rx_src_eop<='1';
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_eop<='0';
         ep_tl_rx_src_rdy_np <='0';
         WAIT UNTIL clk = '1';

         ep_tl_rx_src_rdy_np <='1';
         ep_tl_rx_src_sop<='1';
         ep_tl_rx_src_data <= X"02000001"; --Hdr1: IORd, length = 1, 
         WAIT UNTIL  (clk='1' AND ep_tl_rx_dst_rdy = '1');
         ep_tl_rx_src_sop<='0';
         ep_tl_rx_src_data <= X"FFFF0000"; --Hdr2: req_ID = X"FFFF"
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"00000088"; --Hdr3: Address: 22h << 2 
         ep_tl_rx_src_eop<='1';
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_eop<='0';
         ep_tl_rx_src_rdy_np <='0';
         WAIT UNTIL clk = '1';

         ep_tl_rx_src_rdy_np <='1';
         ep_tl_rx_src_sop<='1';
         ep_tl_rx_src_data <= X"02000001"; --Hdr1: IORd, length = 1, 
         WAIT UNTIL  (clk='1' AND ep_tl_rx_dst_rdy = '1');
         ep_tl_rx_src_sop<='0';
         ep_tl_rx_src_data <= X"FFFF0000"; --Hdr2: req_ID = X"FFFF"
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"00000088"; --Hdr3: Address: 22h << 2 
         ep_tl_rx_src_eop<='1';
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_eop<='0';
         ep_tl_rx_src_rdy_np <='0';
         WAIT UNTIL clk = '1';
        

         -- Test scenario: sending a tlp IORd to EP receiver
         ep_tl_rx_src_rdy_np <='1';
         ep_tl_rx_src_sop<='1';
         ep_tl_rx_src_data <= X"02000001"; --Hdr1: IORd, length = 1, 
         WAIT UNTIL  (clk='1' AND ep_tl_rx_dst_rdy = '1');
         -- WAIT UNTIL clk='1';
         ep_tl_rx_src_sop<='0';
         ep_tl_rx_src_data <= X"FFFF0000"; --Hdr2: req_ID = X"FFFF"
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_data <= X"00000000"; --Hdr3: Address: 0
         ep_tl_rx_src_eop<='1';
         WAIT UNTIL clk = '1';
         ep_tl_rx_src_eop<='0';
         ep_tl_rx_src_rdy_np <='0';
         WAIT UNTIL clk = '1';

        -- Test scenario: sending a tlp CfgWr0 to EP receiver
        ep_tl_rx_src_rdy_np <='1';
        ep_tl_rx_src_sop<='1';
        ep_tl_rx_src_data <= X"44000001"; --Hdr1: CfgWr0, length = 1, 
        WAIT UNTIL  (clk='1' AND ep_tl_rx_dst_rdy = '1');
        -- WAIT UNTIL clk='1';
        ep_tl_rx_src_sop<='0';
        ep_tl_rx_src_data <= X"FFFF0000"; --Hdr2: req_ID = X"FFFF"
        WAIT UNTIL clk = '1';
        ep_tl_rx_src_data <= X"00000000"; --Hdr3: Address: 0
        WAIT UNTIL clk = '1';
        ep_tl_rx_src_data <= X"AAAAAAAA"; --Data1: IO Data1
        ep_tl_rx_src_eop<='1';
        WAIT UNTIL clk = '1';
        ep_tl_rx_src_eop<='0';
        ep_tl_rx_src_rdy_np <='0';
        WAIT UNTIL clk = '1';

        WAIT FOR 100 NS;
        -- Test scenario: sending a tlp CfgRd0 to EP receiver
        ep_tl_rx_src_rdy_np <='1';
        ep_tl_rx_src_sop<='1';
        ep_tl_rx_src_data <= X"04000001"; --Hdr1: CfgRd0, length = 1, 
        WAIT UNTIL  (clk='1' AND ep_tl_rx_dst_rdy = '1');
        -- WAIT UNTIL clk='1';
        ep_tl_rx_src_sop<='0';
        ep_tl_rx_src_data <= X"FFFF0000"; --Hdr2: req_ID = X"FFFF"
        WAIT UNTIL clk = '1';
        ep_tl_rx_src_data <= X"00000000"; --Hdr3: Address: 0
        ep_tl_rx_src_eop<='1';
        WAIT UNTIL clk = '1';
        ep_tl_rx_src_eop<='0';
        ep_tl_rx_src_rdy_np <='0';
        WAIT UNTIL clk = '1';
        WAIT;
    END PROCESS;


--     PROCESS (clk, rst, ep_tl_rx_src_sop, ep_tl_tx_src_sop, ep_tl_tx_src_eop, ep_tl_tx_src_rdy_np, ep_tl_tx_src_rdy_p, ep_tl_tx_src_rdy_cmpl)
--     CONSTANT TLP_MRd    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
--     CONSTANT TLP_MWr    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000000";
--     CONSTANT TLP_IORd   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000010";
--     CONSTANT TLP_IOWr   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000010";
--     CONSTANT TLP_CfgRd0 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000100";
--     CONSTANT TLP_CfgWr0 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000100";
--     CONSTANT TLP_CfgRd1 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000101";
--     CONSTANT TLP_CfgWr1 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000101";
--     CONSTANT TLP_Cmpl   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00001010";
--     CONSTANT TLP_CmplD  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01001010";
--     FILE LOG_FILE : text OPEN WRITE_MODE IS "log.txt";
--     VARIABLE W_LINE : LINE;
--     VARIABLE str : string(1 TO 36);
--     VARIABLE inspector : STD_LOGIC_VECTOR (31 DOWNTO 0);
--     VARIABLE itr : INTEGER := 0;
--     VARIABLE has_data : BOOLEAN := FALSE;
--     BEGIN
--         IF (rst = '1' AND rst'EVENT) THEN
--         WRITE (W_LINE, string'("Starting the PCIE EP simulation @ "));
--         WRITE (W_LINE, NOW);
--         WRITE (W_LINE, string'(" ..."));
--         writeline(LOG_FILE, W_LINE);
--         WRITE (W_LINE, string'(""));
--         writeline(LOG_FILE, W_LINE);
--         END IF;
--         IF(clk='1' AND clk'EVENT) THEN

--             IF (ep_tl_rx_src_sop = '1') THEN
--                 WRITE (W_LINE, string'("=====================> NEW PACKET IN RX @ "));
--                 WRITE (W_LINE, NOW);
--                 writeline(LOG_FILE, W_LINE);
--                 inspector := ep_tl_rx_src_data;
--                 itr := 1;
--                 CASE inspector(31 DOWNTO 24) IS
--                     WHEN TLP_MWr =>
--                         -- has_data := TRUE;
--                         WRITE (W_LINE, string'("REQUEST TYPE: Memory Write (posted)"));
--                         writeline(LOG_FILE, W_LINE);
--                         -- WRITE (W_LINE, string'("Length: "&to_string(to_integer(unsigned((inspector(9 DOWNTO 0)))))));
--                         WRITE (W_LINE, string'("Length: "));
--                         writeline(LOG_FILE, W_LINE);
--                         WRITE (W_LINE, to_integer(unsigned((inspector(9 DOWNTO 0)))));

--                         writeline(LOG_FILE, W_LINE);
--                         WRITE (W_LINE, string'("*********************************************** "));
--                         writeline(LOG_FILE, W_LINE);
--                         WRITE (W_LINE, string'(""));
--                         writeline(LOG_FILE, W_LINE);

--                     WHEN TLP_MRd =>
--                         -- has_data := FALSE;
--                         WRITE (W_LINE, string'("REQUEST TYPE: Memory Read (non-posted)"));
--                         writeline(LOG_FILE, W_LINE);
--                         -- WRITE (W_LINE, string'("Length: "&to_string(to_integer(unsigned((inspector(9 DOWNTO 0)))))));
--                         WRITE (W_LINE, string'("Length: "));
--                         writeline(LOG_FILE, W_LINE);
--                         WRITE (W_LINE, to_integer(unsigned((inspector(9 DOWNTO 0)))));                        WRITE (W_LINE, string'(""));
--                         writeline(LOG_FILE, W_LINE);

--                     WHEN TLP_IORd =>
--                         WRITE (W_LINE, string'("REQUEST TYPE: IO Read (non-posted)"));
--                         WRITE (W_LINE, string'(""));
--                         writeline(LOG_FILE, W_LINE);

--                     WHEN TLP_IOWr =>
--                         WRITE (W_LINE, string'("REQUEST TYPE: IO Write (non-posted)"));
--                         WRITE (W_LINE, string'(""));
--                         writeline(LOG_FILE, W_LINE);

--                     WHEN TLP_CfgRd0 =>
--                         WRITE (W_LINE, string'("REQUEST TYPE: Configuration Read (non-posted)"));
--                         WRITE (W_LINE, string'(""));
--                         writeline(LOG_FILE, W_LINE);

--                     WHEN TLP_CfgWr0 =>
--                         WRITE (W_LINE, string'("REQUEST TYPE: Configuration Write (non-posted)"));
--                         WRITE (W_LINE, string'(""));
--                         writeline(LOG_FILE, W_LINE);
--                     WHEN OTHERS=>
--                 END CASE;
--             END IF;


--             -- Observing the Output(TX) Signals
--             IF (ep_tl_tx_src_sop = '1') THEN
--                 WRITE (W_LINE, string'("=========> RESPONSE PACKET IN TX @ "));
--                 WRITE (W_LINE, NOW);
--                 writeline(LOG_FILE, W_LINE);
--                 inspector := ep_tl_tx_src_data;
--                 itr := 1;
--                 CASE inspector(31 DOWNTO 24) IS
--                     WHEN TLP_CmplD =>
--                         has_data := TRUE;
--                         WRITE (W_LINE, string'("TYPE: completion with data"));
--                         writeline(LOG_FILE, W_LINE);

--                     WHEN TLP_Cmpl =>
--                         has_data := FALSE;
--                         WRITE (W_LINE, string'("TYPE: completion "));
--                         writeline(LOG_FILE, W_LINE);
--                     WHEN OTHERS=>
--                 END CASE;
--             END IF;

--             IF ((ep_tl_tx_src_rdy_np='1' OR ep_tl_tx_src_rdy_p='1' OR ep_tl_tx_src_rdy_cmpl='1')AND ep_tl_tx_dst_rdy = '1') THEN
--                 inspector := ep_tl_tx_src_data;
--                 IF (itr < 4) THEN
-- --                    WRITE (W_LINE, string'("    HEADER"&to_string(itr)&" : "));
--                    WRITE (W_LINE, string'("    HEADER"));
--                    writeline(LOG_FILE, W_LINE);
--                    WRITE (W_LINE, itr);
--                    writeline(LOG_FILE, W_LINE);
--                     itr:= itr +1;
-- --                    WRITE (W_LINE, "0x" & to_hstring(inspector));
--                     WRITE (W_LINE, inspector);
--                     writeline(LOG_FILE, W_LINE);
--                 ELSIF (itr = 4 AND has_data) THEN
--                     WRITE (W_LINE, string'(""));
--                     writeline(LOG_FILE, W_LINE);
--                     WRITE (W_LINE, string'("    DATA:"));
--                     writeline(LOG_FILE, W_LINE);
--                     --WRITE (W_LINE, "0x" & to_hstring(inspector));
--                     WRITE (W_LINE, inspector);
--                     itr := itr +1;
--                     writeline(LOG_FILE, W_LINE);
--                 ELSIF (itr > 4 AND has_data) THEN
--                     --WRITE (W_LINE, "0x" & to_hstring(inspector));
--                     WRITE (W_LINE, inspector);
--                     writeline(LOG_FILE, W_LINE);
--                 END IF;



--                 IF (ep_tl_tx_src_eop='1' AND ep_tl_tx_dst_rdy = '1') THEN
--                     WRITE (W_LINE, string'("=====================> END OF PACKET @ "));
--                     WRITE (W_LINE, NOW);
--                     writeline(LOG_FILE, W_LINE);
--                     WRITE (W_LINE, string'("*********************************************** "));
--                     writeline(LOG_FILE, W_LINE);
--                     WRITE (W_LINE, string'(""));
--                     writeline(LOG_FILE, W_LINE);
--                 END IF;
--             END IF;

--         END IF;	

--     END PROCESS;

--     -- Imitating an IO
--     -- PROCESS (clk, rst, ep_IO_abus, ep_IO_dbus, ep_IO_cbus)
--     -- BEGIN
--     --     IF (clk = '1' AND clk'EVENT) THEN
--     --         IF (ep_IO_cbus = "01") THEN
--     --             ep_IO_dbus <= X"AAAAAAAA";
--     --         ELSE
--     --             ep_IO_dbus <= (OTHERS => 'Z');
--     --         END IF;
--     --     END IF;
--     -- END PROCESS;
--     ep_IO_dbus <= X"AAAAAAAA" WHEN ep_IO_cbus = "01" ELSE (OTHERS => 'Z');
END ARCHITECTURE test;




-- LIBRARY IEEE;
--     USE IEEE.STD_LOGIC_1164.ALL;
--     USE IEEE.STD_LOGIC_UNSIGNED.ALL;
-- ENTITY Tester IS
--     GENERIC(
--         Hdr1:STD_LOGIC_VECTOR(31 DOWNTO 0);
--         Hdr2:STD_LOGIC_VECTOR(31 DOWNTO 0);
--         Hdr3:STD_LOGIC_VECTOR(31 DOWNTO 0)
--         );
--     port (clk:IN STD_LOGIC;
--     rst:IN STD_LOGIC;
--     ep_tl_rx_dst_rdy : IN STD_LOGIC;

--     ep_tl_rx_src_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
--     ep_tl_rx_src_rdy_np : OUT STD_LOGIC;
--     ep_tl_rx_src_sop : OUT STD_LOGIC;
--     ep_tl_rx_src_eop : OUT STD_LOGIC);
-- END Tester ;
-- ARCHITECTURE ARCH OF Tester  IS
-- BEGIN
--     Process begin
--         WAIT UNTIL (rst = '0' AND rst'EVENT);
--         ep_tl_rx_src_rdy_np <='1';
--         ep_tl_rx_src_sop<='1';
--         ep_tl_rx_src_data <= X"00000005"; --Hdr1: Mrd, length = 1, 
--         WAIT UNTIL ep_tl_rx_dst_rdy = '1';
--         WAIT UNTIL clk='1';
--         ep_tl_rx_src_sop <='0';
--         ep_tl_rx_src_data <= X"FFFF0000"; --Hdr2: req_ID = X"FFFF"
--         WAIT UNTIL clk = '1';
--         ep_tl_rx_src_data <= X"00000000"; --Hdr3: Address: 0
--         ep_tl_rx_src_eop<='1';
--         WAIT UNTIL clk = '1';
--         ep_tl_rx_src_eop<='0';
--         ep_tl_rx_src_rdy_np <='0';
--         WAIT UNTIL clk = '1';
--     end process;

-- end ARCHITECTURE;