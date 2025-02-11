--*****************************************************************************/
--	Filename:		TLP_Creator_Transmitter.vhd
--	Project:		MCI-PCH
--  Version:		1.000
--	History:		-
--	Date:			13 September 2023
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

ENTITY TLP_creator_Transmitter_Controller IS 
PORT(
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;

    -- controller signals
    get_data_from_mem : IN STD_LOGIC;
    got_data_from_mem : OUT STD_LOGIC;
    get_data_from_IO: IN STD_LOGIC;
    mem_data_sel : OUT STD_LOGIC;
    IO_data_sel : OUT STD_LOGIC;

    -- datapath signals
    address_eq : IN STD_LOGIC;
    tx_address_cnt_rst : OUT STD_LOGIC;
    tx_address_cnt_en : OUT STD_LOGIC;

    -- Mem Interface
    readMem : OUT STD_LOGIC;

    -- tx buffer interface
    tx_buff_full : IN STD_LOGIC;
    tx_buff_push : OUT STD_LOGIC;

    --cfg Interface
    cfg_RF_en : OUT STD_LOGIC;
    get_data_from_cfg : IN STD_LOGIC;
    cfg_data_sel : OUT STD_LOGIC;
    readRF : OUT STD_LOGIC

    );
END ENTITY TLP_creator_Transmitter_Controller;

ARCHITECTURE Controller_ARC OF TLP_creator_Transmitter_Controller IS
--STATE:
TYPE CPLD_DATA_STATE IS (CPLD_DATA_idle ,get_data, wait_till_not_full, done, IO_Data, cfg_Data);


SIGNAL CPLD_DATA_PSTATE, CPLD_DATA_NSTATE : CPLD_DATA_STATE;


BEGIN
--proccesses:
    NEXT_STATE:   PROCESS (clk , rst) BEGIN
        IF rst = '1' THEN
            CPLD_DATA_PSTATE <= CPLD_DATA_idle;

        ELSIF clk = '1' AND clk'EVENT THEN 
            CPLD_DATA_PSTATE <= CPLD_DATA_NSTATE;

        END IF;
    END PROCESS;

-- --------------------------- CPLD DATA CTRL ---------------------------
    CPLD_DATA_CRTL_STATE_TRANSITION:   PROCESS (CPLD_DATA_PSTATE, get_data_from_mem, tx_buff_full, address_eq, get_data_from_IO, get_data_from_cfg) BEGIN
        CPLD_DATA_NSTATE<=CPLD_DATA_idle; --INACTIVE VALUE
        CASE CPLD_DATA_PSTATE IS
            WHEN CPLD_DATA_idle =>
                IF (get_data_from_cfg = '1') THEN
                    CPLD_DATA_NSTATE <= cfg_Data;
                ELSIF (get_data_from_IO = '1') THEN
                    CPLD_DATA_NSTATE <= CPLD_DATA_idle;
                ELSIF (get_data_from_mem = '0' OR tx_buff_full = '1') THEN 
                    CPLD_DATA_NSTATE <= CPLD_DATA_idle;
                ELSIF (get_data_from_mem = '1' AND tx_buff_full = '0') THEN
                    CPLD_DATA_NSTATE <= get_data;
                END IF;
            
            WHEN IO_Data =>
                CPLD_DATA_NSTATE <= CPLD_DATA_idle;
            
            WHEN cfg_Data =>
                CPLD_DATA_NSTATE <= CPLD_DATA_idle;

            WHEN get_data =>
                IF (address_eq = '1' AND tx_buff_full = '0') THEN
                    CPLD_DATA_NSTATE <= done;
                ELSIF (address_eq = '1' AND tx_buff_full = '1') THEN
                    CPLD_DATA_NSTATE <= wait_till_not_full;
                ELSIF (address_eq = '0' AND tx_buff_full = '1') THEN
                        CPLD_DATA_NSTATE <= wait_till_not_full;
                ELSIF (address_eq = '0' AND tx_buff_full = '0') THEN
                        CPLD_DATA_NSTATE <= get_data;
                END IF;

            WHEN wait_till_not_full =>
                IF (address_eq = '1' AND tx_buff_full = '0') THEN
                    CPLD_DATA_NSTATE <= get_data;
                ELSIF (address_eq = '1' AND tx_buff_full = '1') THEN
                    CPLD_DATA_NSTATE <= wait_till_not_full;
                ELSIF (address_eq = '0' AND tx_buff_full = '0') THEN
                    CPLD_DATA_NSTATE <= get_data;
                ELSIF (address_eq = '0' AND tx_buff_full = '1') THEN
                    CPLD_DATA_NSTATE <= wait_till_not_full;
                END IF;

            WHEN done =>
                IF (get_data_from_mem = '1') THEN
                    CPLD_DATA_NSTATE <= done;
                ELSE
                    CPLD_DATA_NSTATE <= CPLD_DATA_idle;
                END IF;

            WHEN OTHERS=>

        END CASE;
    END PROCESS;

    CPLD_DATA_CRTL_OUTPUTS:   PROCESS (CPLD_DATA_PSTATE, address_eq, tx_buff_full, get_data_from_IO) BEGIN
        --INITIALIZATION TO INACTIVE VALUES:
        tx_address_cnt_rst <= '0'; tx_address_cnt_en <= '0';
        tx_buff_push <= '0';
        readMem <= '0';
        got_data_from_mem <= '0';
        mem_data_sel <= '0';
        IO_data_sel <= '0';
        cfg_data_sel <= '0';
        cfg_RF_en <= '0';
        readRF <= '0';


        CASE CPLD_DATA_PSTATE IS
            WHEN CPLD_DATA_idle =>
                tx_address_cnt_rst <= '1';
                IF (get_data_from_IO = '1') THEN
                    IO_data_sel <= '1';
                    tx_buff_push <= '1';  
                END IF;

            WHEN IO_Data =>
                IO_data_sel <= '1';
                tx_buff_push <= '1';  

            WHEN cfg_Data =>
                cfg_data_sel <= '1';
                tx_buff_push <= '1';
                cfg_RF_en <= '1'; 
                readRF <= '1'; 

            WHEN get_data =>
                tx_address_cnt_en <= '1';
                mem_data_sel <= '1';
                tx_buff_push <= '1';
                readMem <= '1';

            WHEN wait_till_not_full =>
                IF (address_eq = '1' AND tx_buff_full = '0') THEN
                        tx_address_cnt_en <= '1';
                        mem_data_sel <= '1';
                        tx_buff_push <= '1';
                        readMem <= '1';
                ELSIF (address_eq = '0' AND tx_buff_full = '0') THEN
                        tx_address_cnt_en <= '1';
                        mem_data_sel <= '1';
                        tx_buff_push <= '1';
                        readMem <= '1';
                END IF;
                

            WHEN done =>
                got_data_from_mem <= '1';

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

ENTITY TLP_creator_Transmitter_DP IS
    GENERIC(Fifo_size : INTEGER :=8);
    PORT(
    clk:IN STD_LOGIC;
    rst:IN STD_LOGIC;

    start_tx : IN STD_LOGIC;
    tx_done : OUT STD_LOGIC;

    tl_tx_dst_rdy : IN STD_LOGIC;
    tl_tx_src_rdy_cmpl: OUT STD_LOGIC;
    tl_tx_src_rdy_p: OUT STD_LOGIC;
    tl_tx_src_rdy_np: OUT STD_LOGIC;
    tl_tx_src_sop : OUT STD_LOGIC;
    tl_tx_src_eop : OUT STD_LOGIC;
    tl_tx_src_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

    cmpl_reg_in: IN STD_LOGIC;
    p_reg_in: IN STD_LOGIC;
    np_reg_in: IN STD_LOGIC;


    data_length: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
    base_address: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
    tx_address_cnt_rst, tx_address_cnt_en : IN STD_LOGIC;
    address_eq : OUT STD_LOGIC;

    mem_data_sel, IO_data_sel : IN STD_LOGIC;
    
    
    tx_hdr1_in: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    tx_hdr2_in: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    tx_hdr3_in: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    tx_hdr1_ld: IN STD_LOGIC;
    tx_hdr2_ld: IN STD_LOGIC;
    tx_hdr3_ld: IN STD_LOGIC;
    -- tx buffer interface
    tx_buff_push : IN STD_LOGIC;
    tx_buff_full : OUT STD_LOGIC;
    
    --Mem:
    readMem : IN STD_LOGIC;
    tx_memAddr : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
    readData : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

    -- IO
    IO_dbus : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);

    -- cfg
    cfg_data_sel : IN STD_LOGIC;
    cfg_RF_en : IN STD_LOGIC;
    cfg_readData : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    cfg_tx_memAddr : OUT STD_LOGIC_VECTOR (9 dOWNTO 0)

   );
END ENTITY TLP_creator_Transmitter_DP;

ARCHITECTURE DP_ARC OF TLP_creator_Transmitter_DP IS
--SIGNAL DECLARATIONS:
SIGNAL tx_address_cnt_out : STD_LOGIC_VECTOR (9 DOWNTO 0);
SIGNAL tx_address_cnt_en_gated : STD_LOGIC;

SIGNAL tx_hdr1_out, tx_hdr2_out, tx_hdr3_out, tx_buff_data_out_wire : STD_LOGIC_VECTOR (31 DOWNTO 0);

SIGNAL tx_buff_data_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL tx_buff_full_wire : STD_LOGIC;
SIGNAL tx_buff_push_wire : STD_LOGIC;
SIGNAL tx_buff_empty_wire : STD_LOGIC;
SIGNAL tx_buff_pop_wire : STD_LOGIC;
SIGNAL tx_buff_pop_wire_gated : STD_LOGIC;

------- Vivado --------
SIGNAL sig_in3 : STD_LOGIC_VECTOR(31 DOWNTO 0):= (OTHERS => 'Z');
-----------------------    
BEGIN
    tx_address_counter: ENTITY WORK.COUNTER GENERIC MAP(inputbit=>10) PORT MAP(clk=>clk, rst=>tx_address_cnt_rst, en=>tx_address_cnt_en_gated, cnt_output=>tx_address_cnt_out);
    --Mem:
    address_eq <= '1' WHEN tx_address_cnt_out = ((data_length) -1) ELSE '0';
    tx_memAddr <= (tx_address_cnt_out + base_address) WHEN (readMem='1') ELSE (OTHERS=>'Z'); -- IS THIS RIGHT???
    tx_address_cnt_en_gated <= tx_address_cnt_en AND NOT(tx_buff_full_wire);
    tx_buff_full <= tx_buff_full_wire;

    tx_buff_pop_wire_gated <= tx_buff_pop_wire AND tl_tx_dst_rdy;

    -- cfg:
    cfg_tx_memAddr <= base_address WHEN (cfg_RF_en='1') ELSE (OTHERS=>'Z');

    -- Header Registers Instance
    Hdr1_reg: ENTITY WORK.GENERIC_REG GENERIC MAP(N=>32) PORT MAP(clk=>clk, rst=>rst, ld=>tx_hdr1_ld, reg_in=>tx_hdr1_in, reg_out=>tx_hdr1_out);
    Hdr2_reg: ENTITY WORK.GENERIC_REG GENERIC MAP(N=>32) PORT MAP(clk=>clk, rst=>rst, ld=>tx_hdr2_ld, reg_in=>tx_hdr2_in, reg_out=>tx_hdr2_out);
    Hdr3_reg: ENTITY WORK.GENERIC_REG GENERIC MAP(N=>32) PORT MAP(clk=>clk, rst=>rst, ld=>tx_hdr3_ld, reg_in=>tx_hdr3_in, reg_out=>tx_hdr3_out);

    -- reading from IO, Mem, and cfg
    buff_datain_mux: ENTITY WORK.Mux4to1
    PORT MAP (
        in0 => readData,
        in1 => IO_dbus,
        in2 => cfg_readData,
        ------- Vivado ------
        in3 => sig_in3,
        ---------------------
        sel0 => mem_data_sel,
        sel1 => IO_data_sel,
        sel2 => cfg_data_sel,
        sel3 => '0',
        out_P => tx_buff_data_in
    );

    tx_buffer_inst : ENTITY WORK.FIFO 
    GENERIC MAP (Fifo_size)
    PORT MAP(
        clk => clk,
        rst => rst,
        push => tx_buff_push,
        pop => tx_buff_pop_wire_gated,
        data_in => tx_buff_data_in,
        data_top => tx_buff_data_out_wire,
        full => tx_buff_full_wire,
        empty => tx_buff_empty_wire
    );

    TX_HS_inst : ENTITY WORK.TX_HS_TOP(TOP_ARC)
    PORT MAP(clk=>clk, rst=>rst,
        start_tx=>start_tx,
        tx_done=>tx_done, 
        tl_tx_dst_rdy=>tl_tx_dst_rdy, 
        tl_tx_src_rdy_cmpl=>tl_tx_src_rdy_cmpl,
        tl_tx_src_rdy_p=>tl_tx_src_rdy_p,
        tl_tx_src_rdy_np=>tl_tx_src_rdy_np, 
        tl_tx_src_sop=>tl_tx_src_sop, 
        tl_tx_src_eop=>tl_tx_src_eop,
        tl_tx_src_data=>tl_tx_src_data, 
        tx_buff_data_out=>tx_buff_data_out_wire,
        tx_buff_pop=>tx_buff_pop_wire, 
        tx_buff_empty=>tx_buff_empty_wire,
        tx_hdr1=>tx_hdr1_out, 
        tx_hdr2=>tx_hdr2_out, 
        tx_hdr3=>tx_hdr3_out,
        data_length=>data_length,
        cmpl_reg_in=>cmpl_reg_in,
        p_reg_in=>p_reg_in,
        np_reg_in=>np_reg_in 
        );


END ARCHITECTURE DP_ARC;

-- -------------------------------------------------------------
--  Top Module
-- -------------------------------------------------------------

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.Numeric_Std.all;


ENTITY TLP_Creator_Transmitter_TOP IS 
GENERIC(Fifo_size : INTEGER :=8);
PORT(
    clk:IN STD_LOGIC;
    rst:IN STD_LOGIC;

    start_tx : IN STD_LOGIC;
    tx_done : OUT STD_LOGIC;

    tl_tx_dst_rdy : IN STD_LOGIC;
    tl_tx_src_rdy_cmpl: OUT STD_LOGIC;
    tl_tx_src_rdy_p: OUT STD_LOGIC;
    tl_tx_src_rdy_np: OUT STD_LOGIC;
    tl_tx_src_sop : OUT STD_LOGIC;
    tl_tx_src_eop : OUT STD_LOGIC;
    tl_tx_src_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

    tx_hdr1_in: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    tx_hdr2_in: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    tx_hdr3_in: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    get_data_from_mem: IN STD_LOGIC;
    got_data_from_mem: OUT STD_LOGIC;
    data_length: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
    base_address : IN STD_LOGIC_VECTOR (9 DOWNTO 0);

    cmpl_reg_in: IN STD_LOGIC;
    p_reg_in: IN STD_LOGIC;
    np_reg_in: IN STD_LOGIC;


    get_data_from_IO : IN STD_LOGIC;

    -- Memory Interface
    tx_memAddr : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
    readData : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    readMem  : OUT STD_LOGIC;
    readyMEM : IN STD_LOGIC;

    tx_hdr1_ld: IN STD_LOGIC;
    tx_hdr2_ld: IN STD_LOGIC;
    tx_hdr3_ld: IN STD_LOGIC;

    --IO
    IO_dbus : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);

    --cfg
    get_data_from_cfg : IN STD_LOGIC;
    cfg_readData : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    cfg_tx_memAddr : OUT STD_LOGIC_VECTOR (9 dOWNTO 0);
    readRF : OUT STD_LOGIC
    );
END ENTITY TLP_Creator_Transmitter_TOP;

ARCHITECTURE TOP_ARC OF TLP_Creator_Transmitter_TOP IS
    SIGNAL tx_address_cnt_rst, tx_address_cnt_en, address_eq : STD_LOGIC;

    SIGNAL tx_buff_full_wire : STD_LOGIC;
    SIGNAL tx_buff_push_wire : STD_LOGIC;
    SIGNAL mem_data_sel_wire : STD_LOGIC;
    SIGNAL IO_data_sel_wire : STD_LOGIC;
    SIGNAL cfg_data_sel_wire : STD_LOGIC;
    SIGNAL readMem_wire : STD_LOGIC;
    SIGNAL cfg_RF_en_wire : STD_LOGIC;

    BEGIN

-- DATA PATH INSTANTIATION:
    readMem <= readMem_wire; 
    DataPath: ENTITY WORK.TLP_creator_Transmitter_DP(DP_ARC) 
        GENERIC MAP (Fifo_size)
        PORT MAP (clk =>clk, rst=>rst,
        data_length=>data_length,
        base_address=>base_address,
        tx_address_cnt_rst=>tx_address_cnt_rst,
        tx_address_cnt_en=>tx_address_cnt_en,
        address_eq=>address_eq,
        tx_memAddr=>tx_memAddr,
        tx_hdr1_in=>tx_hdr1_in,
        tx_hdr2_in=>tx_hdr2_in,
        tx_hdr3_in=>tx_hdr3_in,
        tx_hdr1_ld=>tx_hdr1_ld,
        tx_hdr2_ld=>tx_hdr2_ld,
        tx_hdr3_ld=>tx_hdr3_ld,
        tx_buff_full=>tx_buff_full_wire,
        tx_buff_push=>tx_buff_push_wire,
        readData=>readData,
        start_tx=>start_tx,
        tx_done=>tx_done,
        tl_tx_dst_rdy=>tl_tx_dst_rdy, 
        tl_tx_src_rdy_cmpl=>tl_tx_src_rdy_cmpl,
        tl_tx_src_rdy_p=>tl_tx_src_rdy_p,
        tl_tx_src_rdy_np=>tl_tx_src_rdy_np, 
        tl_tx_src_sop=>tl_tx_src_sop, 
        tl_tx_src_eop=>tl_tx_src_eop,
        tl_tx_src_data=>tl_tx_src_data, 
        cmpl_reg_in=>cmpl_reg_in,
        p_reg_in=>p_reg_in,
        np_reg_in=>np_reg_in,
        readMem => readMem_wire,
        IO_dbus => IO_dbus,
        mem_data_sel => mem_data_sel_wire,
        IO_data_sel => IO_data_sel_wire,
        cfg_data_sel => cfg_data_sel_wire,
        cfg_readData => cfg_readData,
        cfg_tx_memAddr    => cfg_tx_memAddr,
        cfg_RF_en          => cfg_RF_en_wire
        );

-- CONTROLLER INSTANTIATION:
    Controller : ENTITY WORK.TLP_creator_Transmitter_Controller(Controller_ARC) 
        PORT MAP (clk =>clk, rst=>rst,
        get_data_from_mem=>get_data_from_mem,
        got_data_from_mem=>got_data_from_mem,
        address_eq=>address_eq,
        tx_address_cnt_rst=>tx_address_cnt_rst,
        tx_address_cnt_en=>tx_address_cnt_en,
        readMem=>readMem_wire,
        tx_buff_full=>tx_buff_full_wire,
        tx_buff_push=>tx_buff_push_wire,
        get_data_from_IO => get_data_from_IO,
        mem_data_sel => mem_data_sel_wire,
        IO_data_sel => IO_data_sel_wire,
        get_data_from_cfg  => get_data_from_cfg,
        cfg_data_sel => cfg_data_sel_wire,
        readRF             => readRF,
        cfg_RF_en          => cfg_RF_en_wire
        );

END ARCHITECTURE TOP_ARC ;

