
-- **************************************************************************************
-- Filename: Northbridge_Datapath.vhd
-- Project: Northbridge
-- Version: 1.0
-- Date:
--
-- Module Name: Northbridge_Datapath
-- Description:
--
-- Dependencies:
--
-- File content description:
-- datapath for Northbridge
--
-- *************************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity Northbridge_Datapath is
port (
    clk : in std_logic;
    rst : in std_logic;

------------------- CPU --------------------------------
    
    out_RS_signals                          : out std_logic_vector(7 downto 0);
            
    in_req_cpu                              : in std_logic_vector(9 downto 0);
    out_req_to_cpu                          : out std_logic_vector(9 downto 0);
            
    in_adr_cpu                              : in std_logic_vector(32 downto 0);
    out_adr_to_cpu                          : out std_logic_vector(32 downto 0);
            
    in_attr_cpu                             : in std_logic_vector(32 downto 0);
    out_attr_to_cpu                         : out std_logic_vector(32 downto 0);
            
    in_datain_cpu                           : in std_logic_vector(63 downto 0);
    out_dataout_to_cpu                      : out std_logic_vector(63 downto 0);
           
    in_DEN                                  : in std_logic;

------------------- PCH --------------------------------
    out_dataout_to_pch                      : out std_logic_vector(31 downto 0);
    in_datain_from_pch                      : in std_logic_vector(31 downto 0);

    out_shutdown                            : out std_logic;

---------------- Controller -----------------------------
    -- signals for RS_MUX(ResponseStatus Mux) : select the correct RS_signals to sent to CPU 
        in_sel_RS_cpu                           : in std_logic;
        in_sel_RS_pch                           : in std_logic;
        in_sel_RS_defer                         : in std_logic;
        in_RS_from_cntrl                        : in std_logic_vector(2 downto 0);

    -- signals for DID_MUX : select the correct DID(Deferred ID) to place in ATTR register for Deferred Reply request
        in_sel_RequestBuffer_DID                : in std_logic;
        in_sel_DeferredResponse_DID             : in std_logic;
        in_sel_cpu_DID                          : in std_logic;

    -- signals for REQUEST_BUFFER module : save the information of outstanding transactions and check specific
        in_RequestBuffer_write                  : in std_logic;
        in_RequestBuffer_erase                  : in std_logic;
        out_in_order_exist                      : out std_logic;
        out_valid                               : out std_logic;
        out_is_deferred                         : out std_logic;
    
    -- signals for ShAddr_MUX(ShiftAddress Mux) and Shift_address_register
        in_sel_ShiftAddr_RequestBuffer          : in std_logic;  
        in_sel_ShiftAddr_DeferredResponse       : in std_logic;  
        in_sel_ShiftAddr_cpu                    : in std_logic;  
        in_ld_shift_addr                        : in std_logic;      
        out_Response_shift_addr                 : out std_logic;

    -- signals for Deferred_Response fifo
        in_sel_data_to_DeferredResponse         : in std_logic;
        in_sel_header_to_DeferredResponse       : in std_logic;
        in_pop_DeferredResponse                 : in std_logic;
        in_push_DeferredResponse                : in std_logic;
        out_DeferredResponse_empty              : out std_logic;
        out_DR_rd                               : out std_logic;
        out_DR_wr                               : out std_logic;

    -- signals for Header_MUX
        in_sel_hdr0                             : in std_logic;
        in_sel_hdr1                             : in std_logic;
        in_sel_hdr2                             : in std_logic;

    -- signals for TO_PCH_MUX
        in_sel_hdr_to_pch                       : in std_logic;
        in_sel_cpu_to_pch                       : in std_logic;
        in_sel_pch_to_pch                       : in std_logic;

    -- signals for HDR0_MUX, HDR1_MUX and HDR2_MUX
        in_sel_hdr0_cpu                         : in std_logic;
        in_sel_hdr0_pch                         : in std_logic;
        in_sel_hdr1_cpu                         : in std_logic;
        in_sel_hdr1_pch                         : in std_logic;
        in_sel_hdr2_cpu                         : in std_logic;
        in_sel_hdr2_pch                         : in std_logic;

    -- signals for HDR0 register, HDR1 register and HDR2 register
        in_ld_hdr0                              : in std_logic;
        in_ld_hdr1                              : in std_logic;
        in_ld_hdr2                              : in std_logic;

    -- signals for CPU_REQ_DECODER module
        out_special                             : out std_logic;    
        out_mem                                 : out std_logic;
        out_io                                  : out std_logic;
        out_cpu_rd                              : out std_logic;
        out_cpu_wr                              : out std_logic;

    --  signals for WR_RD_Reg register
        out_cpu_defer_rd                        : out std_logic; 
        out_cpu_defer_wr                        : out std_logic; 
        in_ld_wr_rd_reg                         : in std_logic;

    -- signals for LEN_MUX
        in_sel_len_cpu                          : in std_logic;
        in_sel_len_pch                          : in std_logic;
        in_sel_len_defer                        : in std_logic;

    -- signals for Length register
        in_ld_length                            : in std_logic;
        out_Length0                             : out std_logic;

    -- signals for LEN_DOWN_CNT module
        in_ld_len_cnt                           : in std_logic;
        in_cnt_en                               : in std_logic;
        out_co_len                              : out std_logic;

    -- signals for BE_DECODE module
        in_special_sig                          : in std_logic;

    -- signals for PCH_REQ_DECODER module
        out_is_cmpl                             : out std_logic;    
        out_with_data                           : out std_logic;

    -- signals for REQ_MUX, ADR_MUX and ATTR_MUX
        in_sel_defer_req                        : in std_logic;
        in_sel_cpu_req                          : in std_logic;
        in_sel_defer_adr                        : in std_logic;
        in_sel_cpu_adr                          : in std_logic;
        in_sel_defer_attr                       : in std_logic;
        in_sel_cpu_attr                         : in std_logic;

    -- signals for REQ register, ADR register and ATTR register
        in_ld_req                               : in std_logic;
        in_ld_adr                               : in std_logic;
        in_ld_attr                              : in std_logic;

    -- signals for DATA_To_CPU_MUX
        in_sel_data_from_DR_fifo                : in std_logic;
        in_sel_data_from_pch                    : in std_logic;
        in_sel_data_cnfg_mem                    : in std_logic;

    -- signals for Data_cotroller_64and32 module
        in_sel_data_first_part                  : in std_logic;
        in_sel_data_second_part                 : in std_logic;
        in_sel_data_full_part                   : in std_logic;
        in_ld_read_register                     : in std_logic;

    -- signals for CONFIG_MEM module and Cnfg_Addr
        out_CNFG_Addr31                         : out std_logic;
        in_ld_Cnfg_addr                         : in std_logic;
        out_cnfg_itself                         : out std_logic;
        in_cnfg_en                              : in std_logic;
        in_cnfg_rd_wr                           : in std_logic;
        out_CF8_flag                            : out std_logic;
        out_CFC_flag                            : out std_logic;
        out_MMIO_flag                           : out std_logic;
        out_DRAM_flag                        : out std_logic;
        out_CnfgSpace_flag                      : out std_logic


);
end entity;

architecture behaviral of Northbridge_Datapath is

    -- RS_MUX signals
        signal RS_MUX_out                   : std_logic_vector(4 downto 0);
        signal RS_MUX_in1                   : std_logic_vector(4 downto 0);
        signal RS_MUX_in2                   : std_logic_vector(4 downto 0);

    -- CPU_REQ_DECODE 
        signal cpu_rd                       : std_logic; 
        signal cpu_wr                       : std_logic;
        signal CPU_REQ_DECODE_out           : std_logic_vector(31 downto 0); 
    
    -- WR_RD_Reg
        signal WR_RD_Reg_in                : std_logic_vector(1 downto 0);
        signal WR_RD_Reg_out                : std_logic_vector(1 downto 0);

    -- DEFERRED_RESPONSE FIFO
        signal DR_fifo_out                  : std_logic_vector(31 downto 0);

    -- PCH_REQ_DECODE
        signal with_data                    : std_logic;
        signal Len_pch                      : std_logic_vector(3 downto 0);

    -- Header_1_2 
        signal Header_1_2_H1_out            : std_logic_vector(31 downto 0); 
        signal Header_1_2_H2_out            : std_logic_vector(31 downto 0);
        signal shift_address                : std_logic;

    -- HDR0_MUX, HDR1_MUX and HDR2_MUX 
        signal HDR0_MUX_out            : std_logic_vector(31 downto 0);
        signal HDR1_MUX_out            : std_logic_vector(31 downto 0);
        signal HDR2_MUX_out            : std_logic_vector(31 downto 0);
    -- HDR0, HDR1 and HDR2 registers 
        signal HDR0_out                     : std_logic_vector(31 downto 0);
        signal HDR1_out                     : std_logic_vector(31 downto 0);
        signal HDR2_out                     : std_logic_vector(31 downto 0);

    -- REQ, ADR and ATTR registers 
        signal REQ_out                      : std_logic_vector(9 downto 0);
        signal ADR_out                      : std_logic_vector(32 downto 0);
        signal ATTR_out                     : std_logic_vector(32 downto 0);

    -- REQ_MUX, ADR_MUX and ATTR_MUX
        signal REQ_MUX_out                  : std_logic_vector(9 downto 0);
        signal ADR_MUX_out                  : std_logic_vector(32 downto 0);
        signal ATTR_MUX_out                 : std_logic_vector(32 downto 0);
        signal ATTR_MUX_DID_in              : std_logic_vector(32 downto 0);

    -- Req_Buffer
        signal DID_RequestBuffer_out        : std_logic_vector(7 downto 0);
        signal RequestBuffer_shift_address  : std_logic;
        signal RequestBuffer_tag            : std_logic_vector(4 downto 0); 

    -- ShAddr_MUX
        signal ShAddr_MUX_out               : std_logic;

    -- DID_Mux
        signal DID_MUX_out                  : std_logic_vector(7 downto 0);

    -- DR_MUX
        signal DeferredResponse_header      : std_logic_vector(31 downto 0);
        signal DR_MUX_out                   : std_logic_vector(31 downto 0);

    -- MEM_ADR_TYPE
        signal MEM_ADR_TYPE_adr_in          : std_logic_vector(31 downto 0);
        signal CF8_flag                     : std_logic;
        signal CFC_flag                     : std_logic;
        signal MMIO_flag                    : std_logic;
        signal DRAM_flag                    : std_logic;
        signal CnfgSpace_flag               : std_logic;

    -- Cnfg_Addr_Reg  register
        signal cnfg_type0                   : std_logic;
        signal Cnfg_Addr_Reg_out            : std_logic_vector(31 downto 0);

    -- Header_MUX
        signal Header_MUX_out            : std_logic_vector(31 downto 0);

    -- Data_Controller_64and32
        signal Data_Controller_out_to_bridge            : std_logic_vector(31 downto 0);

    -- Len_MUX
        signal Len_MUX_out            : std_logic_vector(3 downto 0);
        
    -- Length_Reg register
        signal Length_Reg_out         : std_logic_vector(3 downto 0);

    -- DATA_TO_CPU_MUX
        signal DATA_TO_CPU_MUX_out         : std_logic_vector(31 downto 0);

    -- CONFIG_MEM
        signal CONFIG_MEM_out           : std_logic_vector(31 downto 0);
        signal CONFIG_MEM_out0          : std_logic_vector(31 downto 0);
        signal CONFIG_MEM_out1          : std_logic_vector(31 downto 0);
        signal CONFIG_MEM_out2          : std_logic_vector(31 downto 0);
        signal CONFIG_MEM_out3          : std_logic_vector(31 downto 0);
        signal CONFIG_MEM_out4          : std_logic_vector(31 downto 0);

    -- 


begin

    -- RS_MUX
        RS_MUX_in1 <= ( Length_Reg_out(3 downto 2) & '1' & cpu_rd & cpu_wr  );
        RS_MUX_in2 <= ( Length_Reg_out(3 downto 2) & '1' & with_data & not(with_data) );
        RS_MUX: entity work.Mux3to1_binary
        generic map ( inputbit => 5 )
        port map (
            in0         => "00100",
            in1         => RS_MUX_in1,
            in2         => RS_MUX_in2,
            sel0        => in_sel_RS_defer,
            sel1        => in_sel_RS_cpu,
            sel2        => in_sel_RS_pch,
            out_P       => RS_MUX_out
        );

    -- RS_Signals output tp CPU
    out_RS_signals <= ( RS_MUX_out & in_RS_from_cntrl );

    -- REQUEST_BUFFER module
        REQUEST_BUFFER: entity work.Req_Buffer
   	    generic map(
		size_tag => 5,
		size_register => 11,
		depth_register => 32
	    )
	    port map( 
	   	clk 					=> clk,
	   	rst 					=> rst,		
		Requester_ID 			=> Header_1_2_H1_out(31 downto 16),
      	Tag_in 					=> HDR2_out(12 downto 8),
	   	DID_in 					=> ATTR_out(23 downto 16),
	   	Shift_address_in 		=> shift_address,
	   	defer 					=> in_DEN,
	   	write_req 				=> in_RequestBuffer_write,
	   	erase_req 				=> in_RequestBuffer_erase,
	   	in_order_exist 			=> out_in_order_exist,
	   	valid 					=> out_valid,
	   	is_deferred 			=> out_is_deferred,
	   	DID_out 				=> DID_RequestBuffer_out,
	   	Shift_address_out 		=> RequestBuffer_shift_address,
	   	Tag_out 				=> RequestBuffer_tag
	    );


    -- one bit ShAddr_MUX
        ShAddr_MUX: entity work.bit_Mux3to1_binary
        port map (
        in0         => RequestBuffer_shift_address,
        in1         => DR_fifo_out(14),
        in2         => shift_address,
        sel0        => in_sel_ShiftAddr_RequestBuffer,
        sel1        => in_sel_ShiftAddr_DeferredResponse,
        sel2        => in_sel_ShiftAddr_cpu,
        out_P       => ShAddr_MUX_out
        );

    -- Shift_Address_Reg register
        Shift_Address_Reg: entity work.OneBit_REG
        port map( 
        clk     => clk,
        rst     => rst,
        ld      => in_ld_shift_addr,
        reg_in  => ShAddr_MUX_out,
        reg_out => out_Response_shift_addr
        );


    -- DID_MUX
        DID_MUX: entity work.Mux3to1_binary
        generic map ( inputbit => 8 )
        port map (
        in0         => DID_RequestBuffer_out,
        in1         => DR_fifo_out(13 downto 6),
        in2         => in_attr_cpu(23 downto 16),
        sel0        => in_sel_RequestBuffer_DID,
        sel1        => in_sel_DeferredResponse_DID,
        sel2        => in_sel_cpu_DID,
        out_P       => DID_MUX_out
        );


    -- DR_MUX
        DeferredResponse_header <= ( "00000000000000000" & RequestBuffer_shift_address 
                                    & DID_RequestBuffer_out & Len_pch 
                                    & not(with_data) & with_data );
        DR_MUX: entity work.Mux2to1_binary
        generic map ( inputbit => 32 )
        port map (
        in0         => in_datain_from_pch,
        in1         => DeferredResponse_header,
        sel0        => in_sel_data_to_DeferredResponse,
        sel1        => in_sel_header_to_DeferredResponse,
        out_P       => DR_MUX_out
        );

    -- DEFERRED_RESPONSE FIFO
        DEFERRED_RESPONSE_FIFO: entity work.FIFO_v2
	    generic map(
		depth			=>	36,
		almost			=>	3,
		word_size		=>	32,
		reged_output	=>	1
        )
	    port map(
		clk				=> clk,
		rst				=> rst,
		push			=> in_push_DeferredResponse,
		data_in			=> DR_MUX_out,
		full			=> open,
		almust_full		=> open,
		pop				=> in_pop_DeferredResponse,
		data_out		=> DR_fifo_out,
		empty			=> out_DeferredResponse_empty,
		almust_empty	=> open
        );
    out_DR_rd <= DR_fifo_out(0);
    out_DR_wr <= DR_fifo_out(1);

    -- CPU_REQ_DECODE
        CPU_REQ_DECODE: entity work.CPU_REQ_Decoder
        port map(
        cnfg_type0    => cnfg_type0,
        MMIO_flag     => MMIO_flag, 
        eq            => CFC_flag, 
        less          => DRAM_flag, 
        MemCnfg       => CnfgSpace_flag,
        Req_in        => REQ_out,
        HEADER_0      => CPU_REQ_DECODE_out,
        mem           => out_mem,
        io            => out_io,
        special       => out_special,
        rd            => cpu_rd,
        wr            => cpu_wr
        );
    out_cpu_rd <= cpu_rd;
    out_cpu_wr <= cpu_wr;

    -- WR_RD_Reg register
        WR_RD_Reg_in <= ( cpu_wr & cpu_rd );
        WR_RD_Reg: entity work.Req_Register
        generic map( size => 2 )
        port map(
        in_p        => WR_RD_Reg_in,
        ldR         => in_ld_wr_rd_reg,
        clk         => clk,
        rst         => rst,
        out_p       => WR_RD_Reg_out
        );
        out_cpu_defer_rd    <= WR_RD_Reg_out(0);
        out_cpu_defer_wr    <= WR_RD_Reg_out(1);

    -- Header_1_2
        Header_1_2: entity work.Header_1_2
        port map(
        Type_in                 => CPU_REQ_DECODE_out(28 downto 24),
        Tag_in                  => RequestBuffer_tag,
        Byte_Enable             => ATTR_out(15 downto 8),
      	Address                 => ADR_out(28 downto 0),
		Cnfg_Addr               => Cnfg_Addr_Reg_out,
        shift_address           => shift_address,
	    Header2                 => Header_1_2_H2_out,
        Header1                 => Header_1_2_H1_out
        );


    -- HDR0_MUX
        HDR0_MUX: entity work.Mux2to1_binary
        generic map ( inputbit => 32 )
        port map (
        in0         => CPU_REQ_DECODE_out,
        in1         => in_datain_from_pch,
        sel0        => in_sel_hdr0_cpu,
        sel1        => in_sel_hdr0_pch,
        out_P       => HDR0_MUX_out
        );
    -- HDR1_MUX
        HDR1_MUX: entity work.Mux2to1_binary
        generic map ( inputbit => 32 )
        port map (
        in0         => Header_1_2_H1_out,
        in1         => in_datain_from_pch,
        sel0        => in_sel_hdr1_cpu,
        sel1        => in_sel_hdr1_pch,
        out_P       => HDR1_MUX_out
        );
    -- HDR2_MUX
        HDR2_MUX: entity work.Mux2to1_binary
        generic map ( inputbit => 32 )
        port map (
        in0         => Header_1_2_H2_out,
        in1         => in_datain_from_pch,
        sel0        => in_sel_hdr2_cpu,
        sel1        => in_sel_hdr2_pch,
        out_P       => HDR2_MUX_out
        );

    -- HDR0 register
        HDR0_Reg: entity work.Req_Register
        generic map( size => 32 )
        port map(
        in_p        => HDR0_MUX_out,
        ldR         => in_ld_hdr0,
        clk         => clk,
        rst         => rst,
        out_p       => HDR0_out
        );
    -- HDR1 register
        HDR1_Reg: entity work.Req_Register
        generic map( size => 32 )
        port map(
        in_p        => HDR1_MUX_out,
        ldR         => in_ld_hdr1,
        clk         => clk,
        rst         => rst,
        out_p       => HDR1_out
        );
    -- HDR2 register
        HDR2_Reg: entity work.Req_Register
        generic map( size => 32 )
        port map(
        in_p        => HDR2_MUX_out,
        ldR         => in_ld_hdr2,
        clk         => clk,
        rst         => rst,
        out_p       => HDR2_out
        );

    -- Header_MUX
        Header_MUX: entity work.Mux3to1_binary
        generic map ( inputbit => 32 )
        port map (
        in0         => HDR0_out,
        in1         => HDR1_out,
        in2         => HDR2_out,
        sel0        => in_sel_hdr0,
        sel1        => in_sel_hdr1,
        sel2        => in_sel_hdr2,
        out_P       => Header_MUX_out
        );

    -- To_PCH_MUX
        To_PCH_MUX: entity work.Mux3to1_binary
        generic map ( inputbit => 32 )
        port map (
        in0         => Header_MUX_out,
        in1         => Data_Controller_out_to_bridge,
        in2         => in_datain_from_pch,
        sel0        => in_sel_hdr_to_pch,
        sel1        => in_sel_cpu_to_pch,
        sel2        => in_sel_pch_to_pch,
        out_P       => out_dataout_to_pch
        );

    -- Len_MUX
        Len_MUX: entity work.Mux3to1_binary
        generic map ( inputbit => 4 )
        port map (
        in0         => CPU_REQ_DECODE_out(3 downto 0),
        in1         => Len_pch,
        in2         => DR_fifo_out(5 downto 2),
        sel0        => in_sel_len_cpu,
        sel1        => in_sel_len_pch,
        sel2        => in_sel_len_defer,
        out_P       => Len_MUX_out
        );    

    -- Length_Reg register
        Length_Reg: entity work.Req_Register
        generic map( size => 4 )
        port map(
        in_p        => Len_MUX_out,
        ldR         => in_ld_length,
        clk         => clk,
        rst         => rst,
        out_p       => Length_Reg_out
        );
    out_Length0 <= Length_Reg_out(0);

    -- LEN_DOWN_CNT
        LEN_DOWN_CNT: entity work.DOWN_CNT
        generic map(inputbit => 4)
        port map(
        clk                 => clk,
        rst                 => rst,
        cnt_en              => in_cnt_en,
        ld_len_cnt          => in_ld_len_cnt,
        cnt_input           => Len_MUX_out,
        co_len              => out_co_len
        );

    -- PCH_REQ_DECODE
        PCH_REQ_DECODE: entity work.PCH_Req_Decode    
	    port map( 
		Header0 			=> HDR0_out,
		Len					=> Len_pch,
		is_cmpl 			=> out_is_cmpl,
		with_data 			=> with_data
	    );
        out_with_data <= with_data;

    -- BE_DECODE
        BE_DECODE: entity work.BE_DECODE  
        port map(
        special_signal      => in_special_sig,
        BE_input            => ATTR_out(10 downto 8),
        shutdown_out        => out_shutdown
        );


    -- REQ_MUX
        REQ_MUX: entity work.Mux2to1_binary
        generic map ( inputbit => 10 )
        port map (
        in0         => in_req_cpu,
        in1         => ("0000000000"),
        sel0        => in_sel_cpu_req,
        sel1        => in_sel_defer_req,
        out_P       => REQ_MUX_out
        );
    -- ADR_MUX
        ATTR_MUX_DID_in <= ( "000000000" & DID_MUX_out & x"0000" );
        ADR_MUX: entity work.Mux2to1_binary
        generic map ( inputbit => 33 )
        port map (
        in0         => in_adr_cpu,
        in1         => ATTR_MUX_DID_in,
        sel0        => in_sel_cpu_adr,
        sel1        => in_sel_defer_adr,
        out_P       => ADR_MUX_out
        );

    -- ATTR_MUX
        ATTR_MUX: entity work.Mux2to1_binary
        generic map ( inputbit => 33 )
        port map (
        in0         => in_attr_cpu,
        in1         => (others => '0'),
        sel0        => in_sel_cpu_attr,
        sel1        => in_sel_defer_attr,
        out_P       => ATTR_MUX_out
        );

    -- REQ register
        REQ_Reg: entity work.Req_Register
        generic map( size => 10 )
        port map(
        in_p        => REQ_MUX_out,
        ldR         => in_ld_req,
        clk         => clk,
        rst         => rst,
        out_p       => REQ_out
        );
    out_req_to_cpu      <= REQ_out;
    -- ADR register
        ADR_Reg: entity work.Req_Register
        generic map( size => 33 )
        port map(
        in_p        => ADR_MUX_out,
        ldR         => in_ld_adr,
        clk         => clk,
        rst         => rst,
        out_p       => ADR_out
        );
    out_adr_to_cpu      <= ADR_out;
    -- ATTR register
        ATTR_Reg: entity work.Req_Register
        generic map( size => 33 )
        port map(
        in_p        => ATTR_MUX_out,
        ldR         => in_ld_attr,
        clk         => clk,
        rst         => rst,
        out_p       => ATTR_out
        );
    out_attr_to_cpu     <= ATTR_out;

    -- DATA_TO_CPU_MUX
        DATA_TO_CPU_MUX: entity work.Mux3to1_binary
        generic map ( inputbit => 32 )
        port map (
        in0         => DR_fifo_out,
        in1         => in_datain_from_pch,
        in2         => CONFIG_MEM_out,
        sel0        => in_sel_data_from_DR_fifo,
        sel1        => in_sel_data_from_pch,
        sel2        => in_sel_data_cnfg_mem,
        out_P       => DATA_TO_CPU_MUX_out
        );


    -- Data_Controller_64and32
        Data_Controller_64and32: entity work.Data_Controller_64and32
        generic map(
	    cpu_data_size       => 64,
		bridge_data_size    => 32
		)
        port map( 
        clk                         => clk,
        rst                         => rst,
        datain_cpu                  => in_datain_cpu,
        data_from_bridge            => DATA_TO_CPU_MUX_out,
        sel_data_first_part         => in_sel_data_first_part,
        sel_data_second_part        => in_sel_data_second_part,
        sel_data_full_part          => in_sel_data_full_part,
        ld_read_register            => in_ld_read_register,
        dataout_to_cpu              => out_dataout_to_cpu,
        data_to_bridge              => Data_Controller_out_to_bridge
        );


    -- Cnfg_Addr_Reg register
        Cnfg_Addr_Reg: entity work.Req_Register
        generic map( size => 32 )
        port map(
        in_p        => Data_Controller_out_to_bridge,
        ldR         => in_ld_Cnfg_addr,
        clk         => clk,
        rst         => rst,
        out_p       => Cnfg_Addr_Reg_out
        );    
    out_CNFG_Addr31 <= Data_Controller_out_to_bridge(31);
    out_cnfg_itself <= not(or_reduce(Cnfg_Addr_Reg_out(23 downto 11)));
    cnfg_type0      <= not(or_reduce(Cnfg_Addr_Reg_out(23 downto 16)));

    -- CONFIG_MEM
        CONFIG_MEM: entity work.register_file
        Port map( 	  
        clk             => clk,
        rst             => rst,
        en              => in_cnfg_en,
        rd_wr           => in_cnfg_rd_wr,
        addr            => Cnfg_Addr_Reg_out(4 downto 2),
        data_in         => Data_Controller_out_to_bridge,
        data_read       => CONFIG_MEM_out,
        data_out0       => CONFIG_MEM_out0,
        data_out1       => CONFIG_MEM_out1,
        data_out2       => CONFIG_MEM_out2,
        data_out3       => CONFIG_MEM_out3,
        data_out4       => CONFIG_MEM_out4             
	    );


    -- MEM_ADR_TYPE
        MEM_ADR_TYPE_adr_in     <= ( ADR_out(31 downto 3) & shift_address & "00");
        MEM_ADR_TYPE: entity work.MEM_ADR_TYPE
        Port map( 	  
        adr_in                  => MEM_ADR_TYPE_adr_in,
        data_in0                => CONFIG_MEM_out0,
        data_in1                => CONFIG_MEM_out1,
        data_in2                => CONFIG_MEM_out2,
        data_in3                => CONFIG_MEM_out3,
        data_in4                => CONFIG_MEM_out4,
        CF8_flag_out            => CF8_flag,
        CFC_flag_out            => CFC_flag,
        MMIO_flag_out           => MMIO_flag,
        DRAM_flag_out           => DRAM_flag,
        CnfgSpace_flag_out      => CnfgSpace_flag
	    );    
    out_CF8_flag        <= CF8_flag;
    out_CFC_flag        <= CFC_flag;
    out_MMIO_flag       <= MMIO_flag;
    out_DRAM_flag       <= DRAM_flag;
    out_CnfgSpace_flag  <= CnfgSpace_flag;


end architecture;
