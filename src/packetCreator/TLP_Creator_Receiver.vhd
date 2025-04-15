--*****************************************************************************/
--	Filename:		TLP_Creator_Receiver.vhd
--	Project:		MCI-PCH
--  Version:		2.000
--	History:		-
--	Date:		    13 September 2023
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
--  Controller, Datapath and Top module of TLP Creator (Transmitter path)

--*****************************************************************************/

-- -------------------------------------------------------------
-- Controller
-- -------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY TLP_Creator_Receiver_Controller IS 
PORT(
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;

    -- DP INTERFACE:
    -- Rx Buffer:
    rx_buff_pop   : OUT STD_LOGIC;
    rx_buff_empty : IN STD_LOGIC;
    rx_address_cnt_rst : OUT STD_LOGIC;
    rx_address_cnt_en : OUT STD_LOGIC;
    rx_address_eq : IN STD_LOGIC;
    -- Registers:
    rx_hdr_1_ld     : OUT STD_LOGIC;
    rx_hdr_2_ld     : OUT STD_LOGIC;
    rx_hdr_3_ld     : OUT STD_LOGIC;
    rx_hdr_1_out    : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

    -- Interface with TX:
    start_tx          : OUT STD_LOGIC;
    tx_done           : IN STD_LOGIC;
    cmpl              : OUT STD_LOGIC;
    p                 : OUT STD_LOGIC;
    np                : OUT STD_LOGIC;

    -- Tx Registers interface
    tx_Hdr1_ld : OUT STD_LOGIC;
    tx_Hdr2_ld : OUT STD_LOGIC;
    tx_Hdr3_ld : OUT STD_LOGIC;
    
    --Memory Interface:
    get_data_from_mem : OUT STD_LOGIC;
    got_data_from_mem : IN STD_LOGIC;
    writeMEM : OUT STD_LOGIC;
    
    --IO Signals
    IO_cbus : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
    get_data_from_IO : OUT STD_LOGIC;
    IO_dbus_en : OUT STD_LOGIC;
    IO_abus_en : OUT STD_LOGIC;
    
    --Config_RF
    get_data_from_cfg : OUT STD_LOGIC;
    writeRF : OUT STD_LOGIC;
    capID	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    mask 	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    send_error_allowed : IN STD_LOGIC;
    send_err_msg : IN STD_LOGIC;
    err_msg_sent : OUT STD_LOGIC;
    flush_fifo : OUT STD_LOGIC;

    pm_req : IN STD_LOGIC;
    pm_msg_sent : OUT STD_LOGIC;
    queue_pm_msg : OUT STD_LOGIC;

    incoming_pm_msg_flag : OUT STD_LOGIC;
    pm_msg_received : IN STD_LOGIC

    
    );
END ENTITY TLP_Creator_Receiver_Controller;

ARCHITECTURE Controller_ARC OF TLP_Creator_Receiver_Controller IS
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

CONSTANT TLP_ERR_MSG  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00110000"; -- Error MSG with no data

CONSTANT TLP_PM_Active_State_Nack  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00110100"; 
CONSTANT TLP_PM_PME  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00110000";
CONSTANT TLP_PM_Turn_Off  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00110011";
CONSTANT TLP_PM_TO_Ack  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00110101";

CONSTANT EH_capID : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10100000"; -- not a correct value

-- PM MSG Controller (could be changed to phy interface controller for further support)
TYPE PM_STATE IS (wait_for_req, send_msg, done);
SIGNAL PM_PSTATE, PM_NSTATE : PM_STATE;

--STATE:
TYPE STATE IS (idle ,pop1, pop2, decide, Mrd1, Mrd2, MWr1, IOWr1, IORd1, CfgRd0, CfgWr0, EH_MSG0, EH_MSG1, PM_MSG0, PM_MSG1, wait_for_tx);

SIGNAL PSTATE, NSTATE : STATE;
SIGNAL TLP : STD_LOGIC_VECTOR (7 DOWNTO 0);

BEGIN
    TLP <= rx_hdr_1_out(31 DOWNTO 24);
--proccesses:
    NEXT_STATE:   PROCESS (clk , rst) BEGIN
        IF rst = '1' THEN
            PSTATE<= idle;
        ELSIF clk = '1' AND clk'EVENT THEN 
            PSTATE <= NSTATE;
        END IF;
    END PROCESS;

    PM_NEXT_STATE:   PROCESS (clk , rst) BEGIN
        IF rst = '1' THEN
            PM_PSTATE<= wait_for_req;
        ELSIF clk = '1' AND clk'EVENT THEN 
            PM_PSTATE <= PM_NSTATE;
        END IF;
    END PROCESS;
-- --------------------------- MAIN CTRL ---------------------------
    MAIN_CRTL_STATE_TRANSITION:   PROCESS (PSTATE ,rx_buff_empty, got_data_from_mem, tx_done, TLP, rx_address_eq, send_err_msg, send_error_allowed, queue_pm_msg, pm_msg_received) BEGIN
        NSTATE<=idle; --INACTIVE VALUE

        CASE PSTATE IS
            WHEN idle =>
            IF(send_err_msg = '1') THEN
                NSTATE <= EH_MSG0;
            ELSIF (queue_pm_msg = '1') THEN
                NSTATE <= PM_MSG0;
            ELSE
                IF (rx_buff_empty='1') THEN 
                    NSTATE <= idle;
                ELSE
                    NSTATE <= pop1;
                END IF;
            END IF;

            WHEN pop1 =>
                IF (rx_buff_empty='1') THEN 
                    NSTATE <= pop1;
                ELSE
                    NSTATE <= pop2;
                END IF;

            WHEN pop2 =>
                IF (rx_buff_empty='1') THEN 
                    NSTATE <= pop2;
                ELSE
                    NSTATE <= decide;
                END IF;

            WHEN decide =>
                CASE (TLP) IS
                    WHEN TLP_MRd =>
                        NSTATE <= Mrd1;
                    WHEN TLP_MWr =>
                        NSTATE <= MWr1;
                    WHEN TLP_IOWr =>
                        NSTATE <= IOWr1;
                    WHEN TLP_IORd =>
                        NSTATE <= IORd1;
                    WHEN TLP_CfgWr0 =>
                        NSTATE <= CfgWr0;
                    WHEN TLP_CfgRd0 =>
                        NSTATE <= CfgRd0;
                    WHEN TLP_PM_Active_State_Nack => 
                        NSTATE <= PM_MSG1;
                    WHEN TLP_PM_PME => 
                        NSTATE <= PM_MSG1;
                    WHEN TLP_PM_Turn_Off => 
                        NSTATE <= PM_MSG1;
                    WHEN TLP_PM_TO_Ack => 
                        NSTATE <= PM_MSG1;

                    WHEN OTHERS=>
                        NSTATE <= EH_MSG0;
                END CASE;
    
            WHEN Mrd1 =>
                -- IF ( cmpld_hdr_rdy = '0') THEN
                --     NSTATE <= Mrd1;
                -- ELSE
                NSTATE <= Mrd2;
                -- END IF;

            WHEN MWr1 =>
                -- has to stay here for the length of the data to write
                IF(send_err_msg = '1') THEN
                    NSTATE <= EH_MSG0;
                ELSE
                    IF (rx_address_eq = '1') THEN
                        NSTATE <= idle;
                    ELSE
                        NSTATE <= Mwr1;
                    END IF;
                END IF;
            
            WHEN Mrd2 =>
                IF (got_data_from_mem = '0') THEN
                    NSTATE <= Mrd2;
                ELSE
                    NSTATE <= wait_for_tx;
                END IF;

            WHEN IOWr1 =>
                NSTATE <= wait_for_tx;

            WHEN IORd1 =>
                NSTATE <= wait_for_tx;

            WHEN CfgWr0 =>
                NSTATE <= wait_for_tx;

            WHEN CfgRd0 =>
                NSTATE <= wait_for_tx;

            WHEN EH_MSG0 =>
                IF (send_err_msg = '0') THEN 
                    NSTATE <= EH_MSG0;
                ELSE
                    IF (send_error_allowed = '1') THEN
                        NSTATE <= EH_MSG1;
                    else
                        NSTATE <= idle;
                    END IF;
                END IF;

            WHEN PM_MSG0 =>
                NSTATE <= wait_for_tx;

            WHEN PM_MSG1 =>
                IF(pm_msg_received = '0') THEN
                    NSTATE <= PM_MSG1;
                ELSE 
                    NSTATE <= idle;
                END IF;

            WHEN EH_MSG1 =>
                NSTATE <= wait_for_tx;

        
            WHEN wait_for_tx =>
                IF (tx_done = '0') THEN
                    NSTATE <= wait_for_tx;
                ELSE
                    NSTATE <= idle;
                END IF;

            WHEN OTHERS=>
        END CASE;
    END PROCESS;

    MAIN_CTRL_OUTPUTS:   PROCESS (PSTATE, rx_buff_empty, rx_address_eq, tx_done) BEGIN
        --INITIALIZATION TO INACTIVE VALUES:
        rx_buff_pop       <= '0';
        get_data_from_mem <= '0';
        start_tx          <= '0';
        cmpl              <= '0';
        p                 <= '0';
        np                <= '0';
        rx_hdr_1_ld       <= '0';
        rx_hdr_2_ld       <= '0';
        rx_hdr_3_ld       <= '0';

        tx_Hdr1_ld        <= '0';
        tx_Hdr2_ld        <= '0';
        tx_Hdr3_ld        <= '0';
    
        IO_dbus_en        <= '0';
        IO_abus_en        <= '0';
        IO_cbus           <= "ZZ";
        get_data_from_IO  <= '0';

        writeMEM          <= '0';
        rx_address_cnt_rst <= '0';
        rx_address_cnt_en <= '0';

        writeRF           <= '0';
        get_data_from_cfg <= '0';
        

        err_msg_sent <= '0';
        flush_fifo <= '0';

        capID <= "00000000";
        mask <= (OTHERS => '1');

        incoming_pm_msg_flag <= '0';


        CASE PSTATE IS
            WHEN idle =>
                IF (rx_buff_empty='0') THEN 
                    rx_hdr_1_ld <= '1';
                    rx_buff_pop <= '1';
                END IF;

            
            WHEN pop1 =>
                IF (rx_buff_empty='0') THEN 
                    rx_hdr_2_ld <= '1';
                    rx_buff_pop <= '1';
                END IF;

            WHEN pop2 =>
                IF (rx_buff_empty='0') THEN 
                    rx_hdr_3_ld <= '1';
                    rx_buff_pop <= '1';
                END IF;


            WHEN decide =>
                rx_address_cnt_rst <= '1';
            
            WHEN Mrd1 =>
                tx_Hdr1_ld <= '1';
                tx_Hdr2_ld <= '1';
                tx_Hdr3_ld <= '1';
                get_data_from_mem <= '1';
                cmpl <= '1';
                p <= '0';
                np <= '0';

            WHEN Mrd2 =>
                get_data_from_mem <= '1';
                cmpl <= '1';
                p <= '0';
                np <= '0';
                -- NEW:
                start_tx <= '1';

            WHEN MWr1 =>  
                IF (rx_buff_empty='0') THEN  
                    writeMEM <= '1';
                    rx_address_cnt_en <= '1';
                    rx_buff_pop <= '1';
                END IF;

            WHEN IOWr1 =>
                tx_Hdr1_ld <= '1';
                tx_Hdr2_ld <= '1';
                tx_Hdr3_ld <= '1';
                cmpl <= '1';
                p <= '0';
                np <= '0';
                IO_dbus_en <= '1';
                IO_abus_en <= '1';
                rx_buff_pop <= '1';
                IO_cbus <= "10"; -- RW : active low

            WHEN IORd1 =>
                tx_Hdr1_ld <= '1';
                tx_Hdr2_ld <= '1';
                tx_Hdr3_ld <= '1';
                cmpl <= '1';
                p <= '0';
                np <= '0';
                IO_abus_en <= '1';
                IO_cbus <= "01"; -- RW : active low
                get_data_from_IO <= '1';

            WHEN CfgWr0 =>
                tx_Hdr1_ld <= '1';
                tx_Hdr2_ld <= '1';
                tx_Hdr3_ld <= '1';
                cmpl <= '1';
                p <= '0';
                np <= '0';
                IF (rx_buff_empty='0') THEN
                    rx_buff_pop <= '1';
                    writeRF <= '1';
                END IF;

            WHEN CfgRd0 =>
                tx_Hdr1_ld <= '1';
                tx_Hdr2_ld <= '1';
                tx_Hdr3_ld <= '1';
                cmpl <= '1';
                p <= '0';
                np <= '0';
                get_data_from_cfg <= '1';
            
            WHEN EH_MSG0 => -- setting the status register 
                flush_fifo <= '1';
                capID <= EH_capID;
                mask <= "00000000000011110000000000000000";
                writeRF <= '1';
                IF (send_error_allowed = '0') THEN
                    err_msg_sent <= '1'; -- so that it wouldn't get stuck, but no msg is actually sent
                END IF;

            WHEN EH_MSG1 =>
                tx_Hdr1_ld <= '1';
                tx_Hdr2_ld <= '1';
                tx_Hdr3_ld <= '1';
                cmpl <= '0';
                p <= '1';
                np <= '0';
            
            WHEN PM_MSG0 =>
                tx_Hdr1_ld <= '1';
                tx_Hdr2_ld <= '1';
                tx_Hdr3_ld <= '1';
                cmpl <= '0';
                p <= '1'; -- u sure?
                np <= '0';

            WHEN PM_MSG1 =>
                incoming_pm_msg_flag <= '1';
                

            WHEN wait_for_tx =>
                start_tx <= '1';
                IF (tx_done = '1') THEN
                    err_msg_sent <= '1';
                END IF;
                IF (send_err_msg = '1') THEN
                    cmpl <= '0';
                    p <= '1';
                    np <= '0';
                ELSE 
                    cmpl <= '1';
                    p <= '0';
                    np <= '0';
                END IF;

            WHEN OTHERS=>
    
        END CASE;
    END PROCESS;



    -- --------------------------- PM CTRL ---------------------------
    PM_CRTL_STATE_TRANSITION:   PROCESS (PM_PSTATE, pm_req, tx_done) BEGIN
        PM_NSTATE<=wait_for_req; --INACTIVE VALUE

        CASE PM_PSTATE IS
            WHEN wait_for_req =>
                IF (pm_req = '1') THEN
                    PM_NSTATE <= send_msg;
                ELSE
                    PM_NSTATE <= wait_for_req;
                END IF;

            WHEN send_msg =>
                IF (tx_done = '1') THEN
                    PM_NSTATE <= done;
                ELSE
                    PM_NSTATE <= send_msg;
                END IF;


            WHEN done =>
                IF (pm_req = '1') THEN
                    PM_NSTATE <= done;
                ELSE
                    PM_NSTATE <= wait_for_req;
                END IF;

            WHEN OTHERS=>
        END CASE;
    END PROCESS;

    PM_CTRL_OUTPUTS:   PROCESS (PM_PSTATE) BEGIN
        --INITIALIZATION TO INACTIVE VALUES:
        queue_pm_msg <= '0';
        pm_msg_sent <= '0';

        CASE PM_PSTATE IS
        WHEN wait_for_req =>

        WHEN send_msg =>
            queue_pm_msg <= '1';

        WHEN done =>
            pm_msg_sent <= '1';

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

ENTITY TLP_Creator_Receiver_DP IS
    GENERIC(Fifo_size : INTEGER :=8);
    PORT(
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;

    tl_rx_dst_rdy  : OUT STD_LOGIC;
    tl_rx_src_rdy  : IN STD_LOGIC;
    tl_rx_src_sop  : IN STD_LOGIC;
    tl_rx_src_eop  : IN STD_LOGIC;
    tl_rx_src_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

    data_length   : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
    base_address  : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
    rx_buff_pop   : IN STD_LOGIC;
    rx_buff_empty : OUT STD_LOGIC;

    --CONTROLLER INTERFACE:
    rx_hdr_1_ld     : IN STD_LOGIC;
    rx_hdr_2_ld     : IN STD_LOGIC;
    rx_hdr_3_ld     : IN STD_LOGIC;
    rx_hdr_1_out    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

    tx_Hdr1_in  : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    tx_Hdr2_in  : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    tx_Hdr3_in  : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

    --Mem
    writeMem : IN STD_LOGIC;
    writeData : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    rx_memAddr : OUT STD_LOGIC_VECTOR (9 dOWNTO 0);
    rx_address_cnt_rst : IN STD_LOGIC;
    rx_address_cnt_en : IN STD_LOGIC;
    rx_address_eq : OUT STD_LOGIC;

    IO_dbus_en : IN STD_LOGIC;
    IO_abus_en : IN STD_LOGIC;
    IO_dbus : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    IO_abus : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

    writeRF : IN STD_LOGIC;
    cfg_writeData : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    cfg_rx_memAddr : OUT STD_LOGIC_VECTOR (9 dOWNTO 0);

    capID	: IN STD_LOGIC_VECTOR(7 DOWNTO 0);

    maxPayload : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
    send_err_msg : OUT STD_LOGIC;
    err_msg_sent : IN STD_LOGIC;
    flush_fifo : IN STD_LOGIC;
    pm_msg_type : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
    queue_pm_msg : IN STD_LOGIC;
    incoming_pm_msg_type : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
    
   );
END ENTITY TLP_Creator_Receiver_DP;

ARCHITECTURE DP_ARC OF TLP_Creator_Receiver_DP IS

CONSTANT Hdrs_size  : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";

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

CONSTANT TLP_ERR_MSG  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00110000"; -- Error MSG with no data

CONSTANT TLP_PM_Active_State_Nack  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00110100"; 
CONSTANT TLP_PM_PME  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00110000";
CONSTANT TLP_PM_Turn_Off  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00110011";
CONSTANT TLP_PM_TO_Ack  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00110101";
CONSTANT PM_MSG_CODE_Active_State_Nack : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00010100";
CONSTANT PM_MSG_CODE_PME : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00011000";
CONSTANT PM_MSG_CODE_Turn_Off : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00011001";
CONSTANT PM_MSG_CODE_TO_Ack : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00011011";
-- power management message types
CONSTANT PM_Active_State_Nack : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
CONSTANT PM_PME : STD_LOGIC_VECTOR(1 DOWNTO 0) := "01";
CONSTANT PM_Turn_Off : STD_LOGIC_VECTOR(1 DOWNTO 0) := "10";
CONSTANT PM_TO_Ack : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";


CONSTANT ERR_CORR   : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00110000";
CONSTANT ERR_NONFATAL   : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00110001";
CONSTANT ERR_FATAL  : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00110011";

CONSTANT COMPL_STAT_SC  : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
CONSTANT COMPL_STAT_UR  : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";
CONSTANT COMPL_STAT_CRS : STD_LOGIC_VECTOR(2 DOWNTO 0) := "010";
CONSTANT COMPL_STAT_CA  : STD_LOGIC_VECTOR(2 DOWNTO 0) := "100";

-- CONSTANT COMPLETER_ID   : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0F0F";
CONSTANT BUS_NUMBER : STD_LOGIC_VECTOR(7 DOWNTO 0) := X"0F";
CONSTANT DEVICE_NUMBER : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00001";
CONSTANT FUNCTION_NUMBER : STD_LOGIC_VECTOR(2 DOWNTO 0) := "111";


--SIGNAL DECLARATIONS:
SIGNAL rx_hdr_1_out_wire : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL rx_hdr_2_out_wire : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL rx_hdr_3_out_wire : STD_LOGIC_VECTOR (31 DOWNTO 0); 

SIGNAL rx_buff_data_out_wire : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL rx_buff_full_wire : STD_LOGIC;
SIGNAL rx_buff_push_wire : STD_LOGIC;
SIGNAL rx_address_cnt_out : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL TLP : STD_LOGIC_VECTOR (7 DOWNTO 0);
SIGNAL COMPLETER_ID   : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL REQUESTER_ID   : STD_LOGIC_VECTOR(15 DOWNTO 0);

CONSTANT STATUS_ERROR_USUPPORTED_REQUEST : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1000";
CONSTANT STATUS_ERROR_FATAL : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100";
CONSTANT STATUS_ERROR_NON_FATAL : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100";
CONSTANT STATUS_ERROR_CORRECTABLE : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0001";

CONSTANT EH_capID : STD_LOGIC_VECTOR (7 DOWNTO 0) := "10100000"; -- not a correct value

------------ Vivado ----------------------
SIGNAL sig_data_length : STD_LOGIC_VECTOR (9 DOWNTO 0);
SIGNAL sig_base_address : STD_LOGIC_VECTOR (9 DOWNTO 0);
-------------------------------------------
    
BEGIN

    ------------- Vivado -----------
    data_length <= sig_data_length;
    base_address <= sig_base_address;
    ---------------------------------

    Rx_Hdr_1: ENTITY WORK.GENERIC_REG GENERIC MAP(N=>32) PORT MAP(clk=>clk, rst=>rst, ld=>rx_hdr_1_ld, reg_in=>rx_buff_data_out_wire, reg_out=>rx_hdr_1_out_wire);
    Rx_Hdr_2: ENTITY WORK.GENERIC_REG GENERIC MAP(N=>32) PORT MAP(clk=>clk, rst=>rst, ld=>rx_hdr_2_ld, reg_in=>rx_buff_data_out_wire, reg_out=>rx_hdr_2_out_wire);
    Rx_Hdr_3: ENTITY WORK.GENERIC_REG GENERIC MAP(N=>32) PORT MAP(clk=>clk, rst=>rst, ld=>rx_hdr_3_ld, reg_in=>rx_buff_data_out_wire, reg_out=>rx_hdr_3_out_wire);


    PM_MSG_TYPE_PROOCESS: PROCESS (rx_hdr_1_out_wire) BEGIN
        CASE (rx_hdr_1_out_wire(7 DOWNTO 0)) IS
            WHEN PM_MSG_CODE_Active_State_Nack =>
                incoming_pm_msg_type <= PM_Active_State_Nack;

            WHEN PM_MSG_CODE_PME =>
                incoming_pm_msg_type <= PM_PME;

            WHEN PM_MSG_CODE_Turn_Off =>
                incoming_pm_msg_type <= PM_Turn_Off;

            WHEN PM_MSG_CODE_TO_Ack =>
                incoming_pm_msg_type <= PM_TO_Ack;

            WHEN OTHERS =>
                incoming_pm_msg_type <= "00";
        END CASE;
    END PROCESS;

    TLP <= TLP_ERR_MSG WHEN (send_err_msg = '1') 
            ELSE TLP_PM_Active_State_Nack WHEN (queue_pm_msg = '1' AND pm_msg_type = PM_Active_State_Nack)
            ELSE TLP_PM_PME WHEN (queue_pm_msg = '1' AND pm_msg_type = PM_PME)
            ELSE TLP_PM_Turn_Off WHEN (queue_pm_msg = '1' AND pm_msg_type = PM_Turn_Off)
            ELSE TLP_PM_TO_Ack WHEN (queue_pm_msg = '1' AND pm_msg_type = PM_TO_Ack)
            ELSE rx_hdr_1_out_wire(31 DOWNTO 24);
    COMPLETER_ID <= BUS_NUMBER & DEVICE_NUMBER & FUNCTION_NUMBER;
    REQUESTER_ID <= BUS_NUMBER & DEVICE_NUMBER & FUNCTION_NUMBER;
    TX_Signal_Gen_process: PROCESS (TLP, rx_hdr_1_ld, rx_hdr_2_ld, rx_hdr_3_ld, rx_hdr_1_out_wire, rx_hdr_2_out_wire,COMPLETER_ID) BEGIN -- Vivado -> COMPLETER_ID
        tx_Hdr1_in <= (OTHERS => '0');
        tx_Hdr2_in <= (OTHERS => '0');
        tx_Hdr3_in <= (OTHERS => '0');
        -------- Vivado ------------
        --data_length <=(OTHERS => '0');
        sig_data_length <= (OTHERS => '0');
        ----------------------------
        CASE (TLP) IS
            WHEN TLP_MRd => --cmpld
                tx_Hdr1_in <= TLP_CmplD & rx_hdr_1_out_wire(23 DOWNTO 0);
                tx_Hdr2_in <= COMPLETER_ID & COMPL_STAT_SC & "0" & "000000000000";
                tx_Hdr3_in <= rx_hdr_2_out_wire(31 DOWNTO 8)& "00000000";
                ---------- Vivado -----------
                --data_length <= rx_hdr_1_out_wire(9 DOWNTO 0);
                sig_data_length <= rx_hdr_1_out_wire(9 DOWNTO 0); 
                -----------------------------  
            WHEN TLP_IOWr => --cmpl
                tx_Hdr1_in <= TLP_Cmpl & rx_hdr_1_out_wire(23 DOWNTO 10) & "0000000000";
                tx_Hdr2_in <= COMPLETER_ID & COMPL_STAT_SC & "0" & "000000000000";
                tx_Hdr3_in <= rx_hdr_2_out_wire(31 DOWNTO 8)& "00000000";
                 ---------- Vivado -----------
                --data_length <= (OTHERS => '0'); -- no data is needed for the cmpl
                sig_data_length <= (OTHERS => '0'); -- no data is needed for the cmpl
                ------------------------------
            WHEN TLP_IORd => -- cmpld
                tx_Hdr1_in <= TLP_CmplD & rx_hdr_1_out_wire(23 DOWNTO 0);
                tx_Hdr2_in <= COMPLETER_ID & COMPL_STAT_SC & "0" & "000000000000";
                tx_Hdr3_in <= rx_hdr_2_out_wire(31 DOWNTO 8)& "00000000";
                 ---------- Vivado -----------
                --data_length <= rx_hdr_1_out_wire(9 DOWNTO 0); 
                sig_data_length <= rx_hdr_1_out_wire(9 DOWNTO 0);
                ------------------------------ 
            WHEN TLP_MWr => -- no response
                -- tx_Hdr1_in <= TLP_CmplD & rx_hdr_1_out_wire(23 DOWNTO 0);
                -- tx_Hdr2_in <= COMPLETER_ID & COMPL_STAT_SC & "0" & "000000000000";
                -- tx_Hdr3_in <= rx_hdr_2_out_wire(31 DOWNTO 8)& "00000000";
                 ---------- Vivado -----------
                --data_length <= rx_hdr_1_out_wire(9 DOWNTO 0);
                sig_data_length <= rx_hdr_1_out_wire(9 DOWNTO 0); 
                -------------------------------
            WHEN TLP_CfgWr0 => --cmpl
                tx_Hdr1_in <= TLP_Cmpl & rx_hdr_1_out_wire(23 DOWNTO 10) & "0000000000";
                tx_Hdr2_in <= COMPLETER_ID & COMPL_STAT_SC & "0" & "000000000000";
                tx_Hdr3_in <= rx_hdr_2_out_wire(31 DOWNTO 8)& "00000000";
                 ---------- Vivado -----------
                ---data_length <= (OTHERS => '0'); -- no data is needed for the cmpl
                sig_data_length <= (OTHERS => '0'); -- no data is needed for the cmpl
                ------------------------------
            WHEN TLP_CfgRd0 => -- cmpld
                tx_Hdr1_in <= TLP_CmplD & rx_hdr_1_out_wire(23 DOWNTO 0);
                tx_Hdr2_in <= COMPLETER_ID & COMPL_STAT_SC & "0" & "000000000000";
                tx_Hdr3_in <= rx_hdr_2_out_wire(31 DOWNTO 8)& "00000000";
                 ---------- Vivado -----------
                --data_length <= rx_hdr_1_out_wire(9 DOWNTO 0); 
                sig_data_length <= rx_hdr_1_out_wire(9 DOWNTO 0); 
                ------------------------------

            WHEN TLP_ERR_MSG => -- error msg and PME have same fmt+type
                IF(send_err_msg = '1') THEN
                    tx_Hdr1_in <= TLP_ERR_MSG & "000000000000000000000000";
                    tx_Hdr2_in <= REQUESTER_ID & "00000000" & ERR_FATAL;
                    tx_Hdr3_in <= (OTHERS => '0');
                    sig_data_length <= (OTHERS => '0'); 

                ELSIF(queue_pm_msg = '1') THEN
                    tx_Hdr1_in <= TLP_PM_PME & "000000000000000000000000";
                    tx_Hdr2_in <= REQUESTER_ID & "00000000" & PM_MSG_CODE_PME;
                    tx_Hdr3_in <= (OTHERS => '0');
                    sig_data_length <= (OTHERS => '0'); 
                END IF;

            
            WHEN TLP_PM_Active_State_Nack => 
                tx_Hdr1_in <= TLP_PM_Active_State_Nack & "000000000000000000000000";
                tx_Hdr2_in <= REQUESTER_ID & "00000000" & PM_MSG_CODE_Active_State_Nack;
                tx_Hdr3_in <= (OTHERS => '0');
                sig_data_length <= (OTHERS => '0'); 

            -- WHEN TLP_PM_PME => 
            --     tx_Hdr1_in <= TLP_PM_PME & "000000000000000000000000";
            --     tx_Hdr2_in <= REQUESTER_ID & "00000000" & PM_MSG_CODE_PME;
            --     tx_Hdr3_in <= (OTHERS => '0');
            --     sig_data_length <= (OTHERS => '0'); 
            -- WHEN OTHERS=>

            WHEN TLP_PM_Turn_Off => 
                tx_Hdr1_in <= TLP_PM_Turn_Off & "000000000000000000000000";
                tx_Hdr2_in <= REQUESTER_ID & "00000000" & PM_MSG_CODE_Turn_Off;
                tx_Hdr3_in <= (OTHERS => '0');
                sig_data_length <= (OTHERS => '0'); 

            WHEN TLP_PM_TO_Ack => 
                tx_Hdr1_in <= TLP_PM_TO_Ack & "000000000000000000000000";
                tx_Hdr2_in <= REQUESTER_ID & "00000000" & PM_MSG_CODE_TO_Ack;
                tx_Hdr3_in <= (OTHERS => '0');
                sig_data_length <= (OTHERS => '0'); 

            WHEN OTHERS=>
            
        END CASE;
    END PROCESS;
            
    rx_hdr_1_out <= rx_hdr_1_out_wire;
    ---------- Vivado ----------
    --base_address <= rx_hdr_3_out_wire(11 DOWNTO 2);
    sig_base_address <= rx_hdr_3_out_wire(11 DOWNTO 2);
    ---------------------------
    
    -- IO interface tri-states
    IO_dbus <= rx_buff_data_out_wire WHEN (IO_dbus_en = '1') ELSE (OTHERS => 'Z');
    IO_abus <= ("00" &rx_hdr_3_out_wire(31 DOWNTO 2)) WHEN (IO_abus_en = '1') ELSE (OTHERS => 'Z');

    -- Config Reg interface
    cfg_writeData  <= rx_buff_data_out_wire WHEN (writeRF='1' AND capID = "00000000") ELSE
                        "000000000000"&STATUS_ERROR_FATAL&"0000000000000000" WHEN (writeRF='1' AND capID = EH_capID) 
                        ELSE (OTHERS=>'Z');
    cfg_rx_memAddr <= rx_hdr_3_out_wire(11 DOWNTO 2) WHEN (writeRF='1'AND capID = "00000000") ELSE
                        "0000000010" WHEN (writeRF='1' AND capID = EH_capID) -- offset 2 indicates statis register
                        ELSE (OTHERS=>'Z');
    
    -- Memory Interface (Wr)
    rx_address_counter: ENTITY WORK.COUNTER GENERIC MAP(inputbit=>10) 
    PORT MAP(
        clk=>clk,
        rst=>rx_address_cnt_rst, 
        en=>rx_address_cnt_en, 
        cnt_output=>rx_address_cnt_out
        );
    writeData <= rx_buff_data_out_wire WHEN (writeMem='1') ELSE (OTHERS=>'Z');
    ---------------------- Vivado ----------------------------------------
    --rx_address_eq <= '1' WHEN rx_address_cnt_out = ((data_length) -1) ELSE '0';
    rx_address_eq <= '1' WHEN rx_address_cnt_out = ((rx_hdr_1_out_wire(9 DOWNTO 0)) -1) ELSE '0';
    --rx_memAddr <= (rx_address_cnt_out + base_address) WHEN (writeMem='1') ELSE (OTHERS=>'Z');
    rx_memAddr <= (rx_address_cnt_out + sig_base_address) WHEN (writeMem='1') ELSE (OTHERS=>'Z');
    -------------------------------------------------------------------------

    RX_HS_inst : ENTITY WORK.RX_HS_TOP(TOP_ARC)
        PORT MAP(
        clk=>clk, 
        rst=>rst, 
        tl_rx_dst_rdy=>tl_rx_dst_rdy, 
        tl_rx_src_rdy=>tl_rx_src_rdy,
        tl_rx_src_sop=>tl_rx_src_sop, 
        tl_rx_src_eop=>tl_rx_src_eop,
        tl_rx_src_data=>tl_rx_src_data, 
        rx_buff_full=>rx_buff_full_wire, 
        rx_buff_push=>rx_buff_push_wire,
        send_err_msg    =>  send_err_msg,
        err_msg_sent    =>  err_msg_sent,
        maxPayload => maxPayload
        );


    rx_buffer_inst : ENTITY WORK.FIFO 
        GENERIC MAP (Fifo_size)
        PORT MAP(
        clk => clk,
        rst => rst OR flush_fifo,
        push => rx_buff_push_wire,
        pop => rx_buff_pop,
        data_in => tl_rx_src_data,
        data_top => rx_buff_data_out_wire,
        full => rx_buff_full_wire,
        empty => rx_buff_empty
        );

END ARCHITECTURE DP_ARC;

-- -------------------------------------------------------------
--  Top Module
-- -------------------------------------------------------------

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.Numeric_Std.all;

ENTITY TLP_Creator_Receiver_TOP IS 
GENERIC(Fifo_size : INTEGER :=8);
PORT(
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;

    -- Interface with outside
    tl_rx_dst_rdy  : OUT STD_LOGIC;
    tl_rx_src_rdy  : IN STD_LOGIC;
    tl_rx_src_sop  : IN STD_LOGIC;
    tl_rx_src_eop  : IN STD_LOGIC;
    tl_rx_src_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

    -- Other controllers interface:
    start_tx : OUT STD_LOGIC;
    tx_done : IN STD_LOGIC;
    
    get_data_from_mem : OUT STD_LOGIC;
    got_data_from_mem : IN STD_LOGIC;
    data_length : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
    base_address : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
    
    cmpl : OUT STD_LOGIC;
    p : OUT STD_LOGIC;
    np : OUT STD_LOGIC;

    -- Memory interface
    writeMEM : OUT STD_LOGIC;
    writeData : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    rx_memAddr : OUT STD_LOGIC_VECTOR (9 dOWNTO 0);
    
    -- Tx Registers interface
    tx_Hdr1_ld : OUT STD_LOGIC;
    tx_Hdr2_ld : OUT STD_LOGIC;
    tx_Hdr3_ld : OUT STD_LOGIC;
    tx_Hdr1_in  : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    tx_Hdr2_in  : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    tx_Hdr3_in  : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

    -- IO
    get_data_from_IO : OUT STD_LOGIC;
    IO_cbus : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
    IO_dbus : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    IO_abus : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

    -- Config_RF
    get_data_from_cfg : OUT STD_LOGIC;
    writeRF : OUT STD_LOGIC;
    cfg_writeData : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    cfg_rx_memAddr : OUT STD_LOGIC_VECTOR (9 dOWNTO 0);

    maxPayload : IN STD_LOGIC_VECTOR (2 DOWNTO 0);

    send_error_allowed : IN STD_LOGIC;
    capID	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    mask    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

    --PHY interface
    send_pm_msg : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
    pm_msg_sent : OUT STD_LOGIC;
    incoming_pm_msg : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
    pm_msg_received : IN STD_LOGIC
    );
END ENTITY TLP_Creator_Receiver_TOP;

ARCHITECTURE TOP_ARC OF TLP_Creator_Receiver_TOP IS
    SIGNAL rx_buff_pop_wire : STD_LOGIC;
    SIGNAL rx_buff_empty_wire : STD_LOGIC;
    SIGNAL rx_hdr_1_out_wire : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL rx_hdr_2_out_wire : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL rx_hdr_3_out_wire : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL Hdr1_mux_sel0_wire : STD_LOGIC;
    SIGNAL Hdr1_mux_sel1_wire : STD_LOGIC;
    SIGNAL Hdr2_mux_sel0_wire : STD_LOGIC;
    SIGNAL Hdr2_mux_sel1_wire : STD_LOGIC;
    SIGNAL Hdr3_mux_sel0_wire : STD_LOGIC;
    SIGNAL Hdr3_mux_sel1_wire : STD_LOGIC;

    SIGNAL IO_dbus_en_wire : STD_LOGIC;
    SIGNAL IO_abus_en_wire : STD_LOGIC;

    SIGNAL rx_hdr_1_ld_wire : STD_LOGIC;
    SIGNAL rx_hdr_2_ld_wire : STD_LOGIC;
    SIGNAL rx_hdr_3_ld_wire : STD_LOGIC;

    SIGNAL rx_address_cnt_rst_wire : STD_LOGIC;
    SIGNAL rx_address_cnt_en_wire : STD_LOGIC;
    SIGNAL rx_address_eq_wire : STD_LOGIC;
    SIGNAL writeMem_wire : STD_LOGIC;

    SIGNAL writeRF_wire : STD_LOGIC;

    SIGNAL send_err_msg : STD_LOGIC;
    SIGNAL err_msg_sent : STD_LOGIC;
    SIGNAL flush_fifo : STD_LOGIC;

    SIGNAL capID_wire : STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL pm_req : STD_LOGIC;
    SIGNAL pm_msg_type : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL queue_pm_msg : STD_LOGIC;
    SIGNAL incoming_pm_msg_flag : STD_LOGIC;
    SIGNAL incoming_pm_msg_type : STD_LOGIC_VECTOR (1 DOWNTO 0);

    BEGIN
-- DATA PATH INSTANTIATION:
    writeMem <= writeMem_wire;
    writeRF  <= writeRF_wire;
    capID   <= capID_wire;
    pm_req <= send_pm_msg(2);
    pm_msg_type <= send_pm_msg (1 DOWNTO 0);
    incoming_pm_msg <= incoming_pm_msg_flag&incoming_pm_msg_type;
    DataPath: ENTITY WORK.TLP_Creator_Receiver_DP(DP_ARC) 
    GENERIC MAP (Fifo_size)
    PORT MAP (
        clk                => clk, 
        rst                => rst,
        rx_hdr_1_ld        => rx_hdr_1_ld_wire,
        rx_hdr_2_ld        => rx_hdr_2_ld_wire,
        rx_hdr_3_ld        => rx_hdr_3_ld_wire,
        rx_hdr_1_out       => rx_hdr_1_out_wire,
        tx_Hdr1_in         => tx_Hdr1_in, 
        tx_Hdr2_in         => tx_Hdr2_in, 
        tx_Hdr3_in         => tx_Hdr3_in,
        data_length        => data_length, 
        base_address       => base_address,
        tl_rx_dst_rdy      => tl_rx_dst_rdy, 
        tl_rx_src_rdy      => tl_rx_src_rdy,
        tl_rx_src_sop      => tl_rx_src_sop, 
        tl_rx_src_eop      => tl_rx_src_eop,
        tl_rx_src_data     => tl_rx_src_data,
        rx_buff_pop        => rx_buff_pop_wire, 
        rx_buff_empty      => rx_buff_empty_wire,
        writeMem           => writeMem_wire,
        writeData          => writeData,
        rx_memAddr         => rx_memAddr,
        rx_address_cnt_rst => rx_address_cnt_rst_wire,
        rx_address_cnt_en  => rx_address_cnt_en_wire,
        rx_address_eq      => rx_address_eq_wire,
        IO_abus            => IO_abus,
        IO_dbus            => IO_dbus,
        IO_abus_en         => IO_abus_en_wire,
        IO_dbus_en         => IO_dbus_en_wire,
        writeRF            => writeRF_wire,
        cfg_writeData      => cfg_writeData,
        cfg_rx_memAddr     => cfg_rx_memAddr,
        send_err_msg       => send_err_msg,
        err_msg_sent       => err_msg_sent,
        flush_fifo         => flush_fifo,
        capID	           => capID_wire,
        maxPayload         => maxPayload,
        pm_msg_type        => pm_msg_type,
        queue_pm_msg       => queue_pm_msg,
        incoming_pm_msg_type    => incoming_pm_msg_type

    );

-- CONTROLLER INSTANTIATION:
    Controller : ENTITY WORK.TLP_Creator_Receiver_Controller(Controller_ARC) 
    PORT MAP (
        clk                => clk, 
        rst                => rst,
        rx_buff_pop        => rx_buff_pop_wire,
        rx_buff_empty      => rx_buff_empty_wire,
        rx_hdr_1_ld        => rx_hdr_1_ld_wire,
        rx_hdr_2_ld        => rx_hdr_2_ld_wire,
        rx_hdr_3_ld        => rx_hdr_3_ld_wire,
        rx_hdr_1_out       => rx_hdr_1_out_wire,
        tx_Hdr1_ld         => tx_Hdr1_ld, 
        tx_Hdr2_ld         => tx_Hdr2_ld, 
        tx_Hdr3_ld         => tx_Hdr3_ld,
        start_tx           => start_tx, 
        tx_done            => tx_done,
        get_data_from_mem  => get_data_from_mem,
        got_data_from_mem  => got_data_from_mem,
        writeMEM           => writeMEM_wire,
        rx_address_cnt_rst => rx_address_cnt_rst_wire,
        rx_address_cnt_en  => rx_address_cnt_en_wire,
        rx_address_eq      => rx_address_eq_wire,
        cmpl               => cmpl,
        p                  => p,
        np                 => np,
        get_data_from_IO   => get_data_from_IO,
        IO_cbus            => IO_cbus,
        IO_abus_en         => IO_abus_en_wire,
        IO_dbus_en         => IO_dbus_en_wire,
        writeRF            => writeRF_wire,
        get_data_from_cfg  => get_data_from_cfg,
        send_err_msg       => send_err_msg,
        err_msg_sent       => err_msg_sent,
        flush_fifo         => flush_fifo,
        capID	           => capID_wire,
        send_error_allowed => send_error_allowed,
        mask               => mask,
        pm_req             => pm_req,
        pm_msg_sent        => pm_msg_sent,
        queue_pm_msg       => queue_pm_msg,
        incoming_pm_msg_flag    => incoming_pm_msg_flag, 
        pm_msg_received    => pm_msg_received

    );
END ARCHITECTURE TOP_ARC ;