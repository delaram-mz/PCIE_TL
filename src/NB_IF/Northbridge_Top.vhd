--*****************************************************************************/
--	Filename:		Northbridge_Top.vhd
--	Project:		MCI-PCH
--  Version:		1.1
--	History:		-
--	Date:			16 January 2024
--	Authors:	 	Hossein, Alireza
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

entity Northbridge_Top is
port(
    input_clk                             : in std_logic;
    input_rst                             : in std_logic;
    -- CPU
        output_RS_ready_to_cpu      : out std_logic;
        output_RS_signals           : out std_logic_vector(7 downto 0);
        input_RS_ready              : in std_logic;
        input_RS_cpu                : in std_logic_vector(2 downto 0);

        input_req_cpu               : in std_logic_vector(9 downto 0);
        output_req_to_cpu           : out std_logic_vector(9 downto 0);

        input_adr_cpu               : in std_logic_vector(32 downto 0);
        output_adr_to_cpu           : out std_logic_vector(32 downto 0);

        input_attr_cpu              : in std_logic_vector(32 downto 0);
        output_attr_to_cpu          : out std_logic_vector(32 downto 0);

        input_datain_cpu            : in std_logic_vector(63 downto 0);
        output_dataout_to_cpu       : out std_logic_vector(63 downto 0);

        input_empty                 : in std_logic;
        output_pop                  : out std_logic;
        input_full                  : in std_logic;
        output_push                 : out std_logic;

        input_start_cpu             : in std_logic;
        output_ready_to_cpu         : out std_logic;

        output_start_to_cpu         : out std_logic;
        input_ready_cpu             : in std_logic;

        input_DEN                   : in std_logic;
        input_hit                   : in std_logic;
        input_hitm                  : in std_logic;

    -- PCH
--        output_data_valid_to_pch    : out std_logic;
        output_push_send_fifo       : out std_logic;
        output_dataout_to_pch       : out std_logic_vector(31 downto 0);

        output_pop_receive_fifo     : out std_logic;
        input_datain_from_pch       : in std_logic_vector(31 downto 0);
        output_Read_ready_to_pch    : out std_logic;

        input_start_pch             : in std_logic;
        output_ready_to_pch         : out std_logic;

        --Vivado output_start_to_pch         : out std_logic;
        input_ready_pch             : in std_logic;

        output_shutdown             : out std_logic

);
end Northbridge_Top;

architecture Behavioral of Northbridge_Top is

	-- just to compelete the circuit and is without effect in semulation
	-- Vivado signal other_flag                          :  std_logic;

    -- Datapath and Controller connections
        -- signals for RS_MUX(ResponseStatus Mux) 
            signal top_sel_RS_cpu                          :  std_logic;
            signal top_sel_RS_pch                          :  std_logic;
            signal top_sel_RS_defer                        :  std_logic;
            signal top_RS_from_cntrl                       :  std_logic_vector(2 downto 0);

        -- signals for DID_MUX 
            signal top_sel_RequestBuffer_DID               :  std_logic;
            signal top_sel_DeferredResponse_DID            :  std_logic;
            signal top_sel_cpu_DID                         :  std_logic;

        -- signals for REQUEST_BUFFER module 
            signal top_RequestBuffer_write                 :  std_logic;
            signal top_RequestBuffer_erase                 :  std_logic;
            signal top_in_order_exist                      :  std_logic;
            signal top_valid                               :  std_logic;
            signal top_is_deferred                         :  std_logic;
        
        -- signals for ShAddr_MUX(ShiftAddress Mux) and Shift_address_register
            signal top_sel_ShiftAddr_RequestBuffer         :  std_logic;  
            signal top_sel_ShiftAddr_DeferredResponse      :  std_logic;  
            signal top_sel_ShiftAddr_cpu                   :  std_logic;  
            signal top_ld_shift_addr                       :  std_logic;      
            signal top_Response_shift_addr                 :  std_logic;

        -- signals for Deferred_Response fifo
            signal top_sel_data_to_DeferredResponse        :  std_logic;
            signal top_sel_header_to_DeferredResponse      :  std_logic;
            signal top_pop_DeferredResponse                :  std_logic;
            signal top_push_DeferredResponse               :  std_logic;
            signal top_DeferredResponse_empty              :  std_logic;
            signal top_DR_rd                               :  std_logic;
            signal top_DR_wr                               :  std_logic;

        -- signals for Header_MUX
            signal top_sel_hdr0                            :  std_logic;
            signal top_sel_hdr1                            :  std_logic;
            signal top_sel_hdr2                            :  std_logic;

        -- signals for TO_PCH_MUX
            signal top_sel_hdr_to_pch                      :  std_logic;
            signal top_sel_cpu_to_pch                      :  std_logic;
            signal top_sel_pch_to_pch                      :  std_logic;

        -- signals for HDR0_MUX, HDR1_MUX and HDR2_MUX
            signal top_sel_hdr0_cpu                        :  std_logic;
            signal top_sel_hdr0_pch                        :  std_logic;
            signal top_sel_hdr1_cpu                        :  std_logic;
            signal top_sel_hdr1_pch                        :  std_logic;
            signal top_sel_hdr2_cpu                        :  std_logic;
            signal top_sel_hdr2_pch                        :  std_logic;

        -- signals for HDR0 register, HDR1 register and HDR2 register
            signal top_ld_hdr0                             :  std_logic;
            signal top_ld_hdr1                             :  std_logic;
            signal top_ld_hdr2                             :  std_logic;

        -- signals for CPU_REQ_DECODER module
            signal top_special                             :  std_logic;    
            signal top_mem                                 :  std_logic;
            signal top_io                                  :  std_logic;
            signal top_cpu_rd                              :  std_logic;
            signal top_cpu_wr                              :  std_logic;

        --  signals for WR_RD_Reg register
            signal top_cpu_defer_rd                        : std_logic; 
            signal top_cpu_defer_wr                        : std_logic; 
            signal top_ld_wr_rd_reg                        : std_logic; 

        -- signals for LEN_MUX
            signal top_sel_len_cpu                         :  std_logic;
            signal top_sel_len_pch                         :  std_logic;
            signal top_sel_len_defer                       :  std_logic;

        -- signals for Length register
            signal top_ld_length                           :  std_logic;
            signal top_Length0                             :  std_logic;

        -- signals for LEN_DOWN_CNT module
            signal top_ld_len_cnt                          :  std_logic;
            signal top_cnt_en                              :  std_logic;
            signal top_co_len                              :  std_logic;

        -- signals for BE_DECODE module
            signal top_special_sig                         :  std_logic;

        -- signals for PCH_REQ_DECODER module
            signal top_is_cmpl                             :  std_logic;    
            signal top_with_data                           :  std_logic;

        -- signals for REQ_MUX, ADR_MUX and ATTR_MUX
            signal top_sel_defer_req                       :  std_logic;
            signal top_sel_cpu_req                         :  std_logic;
            signal top_sel_defer_adr                       :  std_logic;
            signal top_sel_cpu_adr                         :  std_logic;
            signal top_sel_defer_attr                      :  std_logic;
            signal top_sel_cpu_attr                        :  std_logic;

        -- signals for REQ register, ADR register and ATTR register
            signal top_ld_req                              :  std_logic;
            signal top_ld_adr                              :  std_logic;
            signal top_ld_attr                             :  std_logic;

        -- signals for DATA_To_CPU_MUX
            signal top_sel_data_from_DR_fifo               :  std_logic;
            signal top_sel_data_from_pch                   :  std_logic;
            signal top_sel_data_cnfg_mem                   :  std_logic;

        -- signals for Data_cotroller_64and32 module
            signal top_sel_data_first_part                 :  std_logic;
            signal top_sel_data_second_part                :  std_logic;
            signal top_sel_data_full_part                  :  std_logic;
            signal top_ld_read_register                    :  std_logic;

        -- signals for CONFIG_MEM module and Cnfg_Addr
            signal top_CNFG_Addr31                         :  std_logic;
            signal top_ld_Cnfg_addr                        :  std_logic;
            signal top_cnfg_itself                         :  std_logic;
            signal top_cnfg_en                             :  std_logic;
            signal top_cnfg_rd_wr                          :  std_logic;
            signal top_CF8_flag                            :  std_logic;
            signal top_CFC_flag                            :  std_logic;
            signal top_MMIO_flag                           :  std_logic;
            signal top_DRAM_flag                           :  std_logic;
            signal top_CnfgSpace_flag                      :  std_logic;


begin

    Northbridge_Datapath: entity work.Northbridge_Datapath
    port map(
        clk            => input_clk,
        rst            => input_rst,
    ------------------- CPU --------------------------------
        
        out_RS_signals                          => output_RS_signals,
                
        in_req_cpu                              => input_req_cpu,
        out_req_to_cpu                          => output_req_to_cpu,
                
        in_adr_cpu                              => input_adr_cpu,
        out_adr_to_cpu                          => output_adr_to_cpu,
                
        in_attr_cpu                             => input_attr_cpu,
        out_attr_to_cpu                         => output_attr_to_cpu,
                
        in_datain_cpu                           => input_datain_cpu,
        out_dataout_to_cpu                      => output_dataout_to_cpu,
            
        in_DEN                                  => input_DEN,

    ------------------- PCH --------------------------------
        out_dataout_to_pch                      => output_dataout_to_pch,
        in_datain_from_pch                      => input_datain_from_pch,

        out_shutdown                            => output_shutdown,

    ---------------- Controller -----------------------------
        -- signals for RS_MUX(ResponseStatus Mux) : select the correct RS_signals to sent to CPU 
            in_sel_RS_cpu                           => top_sel_RS_cpu,
            in_sel_RS_pch                           => top_sel_RS_pch,
            in_sel_RS_defer                         => top_sel_RS_defer,
            in_RS_from_cntrl                        => top_RS_from_cntrl,

        -- signals for DID_MUX : select the correct DID(Deferred ID) to place in ATTR register for Deferred Reply request
            in_sel_RequestBuffer_DID                => top_sel_RequestBuffer_DID,
            in_sel_DeferredResponse_DID             => top_sel_DeferredResponse_DID,
            in_sel_cpu_DID                          => top_sel_cpu_DID,

        -- signals for REQUEST_BUFFER module : save the information of outstanding transactions and check specific
            in_RequestBuffer_write                  => top_RequestBuffer_write,
            in_RequestBuffer_erase                  => top_RequestBuffer_erase,
            out_in_order_exist                      => top_in_order_exist,
            out_valid                               => top_valid,
            out_is_deferred                         => top_is_deferred,
        
        -- signals for ShAddr_MUX(ShiftAddress Mux) and Shift_address_register
            in_sel_ShiftAddr_RequestBuffer          => top_sel_ShiftAddr_RequestBuffer, 
            in_sel_ShiftAddr_DeferredResponse       => top_sel_ShiftAddr_DeferredResponse, 
            in_sel_ShiftAddr_cpu                    => top_sel_ShiftAddr_cpu, 
            in_ld_shift_addr                        => top_ld_shift_addr,     
            out_Response_shift_addr                 => top_Response_shift_addr,

        -- signals for Deferred_Response fifo
            in_sel_data_to_DeferredResponse         => top_sel_data_to_DeferredResponse,
            in_sel_header_to_DeferredResponse       => top_sel_header_to_DeferredResponse,
            in_pop_DeferredResponse                 => top_pop_DeferredResponse,
            in_push_DeferredResponse                => top_push_DeferredResponse,
            out_DeferredResponse_empty              => top_DeferredResponse_empty,
            out_DR_rd                               => top_DR_rd,
            out_DR_wr                               => top_DR_wr,

        -- signals for Header_MUX
            in_sel_hdr0                             => top_sel_hdr0,
            in_sel_hdr1                             => top_sel_hdr1,
            in_sel_hdr2                             => top_sel_hdr2,

        -- signals for TO_PCH_MUX
            in_sel_hdr_to_pch                       => top_sel_hdr_to_pch,
            in_sel_cpu_to_pch                       => top_sel_cpu_to_pch,
            in_sel_pch_to_pch                       => top_sel_pch_to_pch,

        -- signals for HDR0_MUX, HDR1_MUX and HDR2_MUX
            in_sel_hdr0_cpu                         => top_sel_hdr0_cpu,
            in_sel_hdr0_pch                         => top_sel_hdr0_pch,
            in_sel_hdr1_cpu                         => top_sel_hdr1_cpu,
            in_sel_hdr1_pch                         => top_sel_hdr1_pch,
            in_sel_hdr2_cpu                         => top_sel_hdr2_cpu,
            in_sel_hdr2_pch                         => top_sel_hdr2_pch,

        -- signals for HDR0 register, HDR1 register and HDR2 register
            in_ld_hdr0                              => top_ld_hdr0,
            in_ld_hdr1                              => top_ld_hdr1,
            in_ld_hdr2                              => top_ld_hdr2,

        -- signals for CPU_REQ_DECODER module
            out_special                             => top_special,    
            out_mem                                 => top_mem,
            out_io                                  => top_io,
            out_cpu_rd                              => top_cpu_rd,
            out_cpu_wr                              => top_cpu_wr,

        --  signals for WR_RD_Reg register
            out_cpu_defer_rd                        => top_cpu_defer_rd,
            out_cpu_defer_wr                        => top_cpu_defer_wr,
            in_ld_wr_rd_reg                         => top_ld_wr_rd_reg,

        -- signals for LEN_MUX
            in_sel_len_cpu                          => top_sel_len_cpu,
            in_sel_len_pch                          => top_sel_len_pch,
            in_sel_len_defer                        => top_sel_len_defer,

        -- signals for Length register
            in_ld_length                            => top_ld_length,
            out_Length0                             => top_Length0,

        -- signals for LEN_DOWN_CNT module
            in_ld_len_cnt                           => top_ld_len_cnt,
            in_cnt_en                               => top_cnt_en,
            out_co_len                              => top_co_len,

        -- signals for BE_DECODE module
            in_special_sig                          => top_special_sig,

        -- signals for PCH_REQ_DECODER module
            out_is_cmpl                             => top_is_cmpl,    
            out_with_data                           => top_with_data,

        -- signals for REQ_MUX, ADR_MUX and ATTR_MUX
            in_sel_defer_req                        => top_sel_defer_req,
            in_sel_cpu_req                          => top_sel_cpu_req,
            in_sel_defer_adr                        => top_sel_defer_adr,
            in_sel_cpu_adr                          => top_sel_cpu_adr,
            in_sel_defer_attr                       => top_sel_defer_attr,
            in_sel_cpu_attr                         => top_sel_cpu_attr,

        -- signals for REQ register, ADR register and ATTR register
            in_ld_req                               => top_ld_req,
            in_ld_adr                               => top_ld_adr,
            in_ld_attr                              => top_ld_attr,

        -- signals for DATA_To_CPU_MUX
            in_sel_data_from_DR_fifo                => top_sel_data_from_DR_fifo,
            in_sel_data_from_pch                    => top_sel_data_from_pch,
            in_sel_data_cnfg_mem                    => top_sel_data_cnfg_mem,

        -- signals for Data_cotroller_64and32 module
            in_sel_data_first_part                  => top_sel_data_first_part,
            in_sel_data_second_part                 => top_sel_data_second_part,
            in_sel_data_full_part                   => top_sel_data_full_part,
            in_ld_read_register                     => top_ld_read_register,

        -- signals for CONFIG_MEM module and Cnfg_Addr
            out_CNFG_Addr31                         => top_CNFG_Addr31,
            in_ld_Cnfg_addr                         => top_ld_Cnfg_addr,
            out_cnfg_itself                         => top_cnfg_itself,
            in_cnfg_en                              => top_cnfg_en,
            in_cnfg_rd_wr                           => top_cnfg_rd_wr,
            out_CF8_flag                            => top_CF8_flag,
            out_CFC_flag                            => top_CFC_flag,
            out_MMIO_flag                           => top_MMIO_flag,
            out_DRAM_flag                           => top_DRAM_flag,
            out_CnfgSpace_flag                      => top_CnfgSpace_flag
    );


    -- controller
    Northbridge_Controller: entity work.North_Bridge_Controller
	port map(
        clk                         => input_clk,
        rst                         => input_rst,
    -- CPU
        RS_ready                    => input_RS_ready,
        empty                       => input_empty,
        full                        => input_full,
        start_cpu                   => input_start_cpu,
        ready_cpu                   => input_ready_cpu,
        DEN                         => input_DEN,
        RS_ready_to_cpu             => output_RS_ready_to_cpu,
        pop                         => output_pop,
        push                        => output_push,
        ready_to_cpu                => output_ready_to_cpu,
        start_to_cpu                => output_start_to_cpu,
        RS_cpu                      => input_RS_cpu,
    -- PCH
--        data_valid_to_pch           => output_data_valid_to_pch,
          push_send_fifo                  => output_push_send_fifo,
          pop_receive_fifo                => output_pop_receive_fifo,
--        ready_to_pch                => output_ready_to_pch,
--        start_to_pch                => output_start_to_pch,
        read_ready_to_pch           => output_Read_ready_to_pch,
        start_pch                   => input_start_pch,
        ready_pch                   => input_ready_pch,
    -- Datapath and Controller connections
        RS_controller               => top_RS_from_cntrl, 
        sel_cpu_req                 => top_sel_cpu_req,
        sel_defer_req               => top_sel_defer_req,
        ld_req                      => top_ld_req,
        sel_cpu_addr                => top_sel_cpu_adr,
        sel_defer_addr              => top_sel_defer_adr,
        ld_addr                     => top_ld_adr,
        sel_defer_attr              => top_sel_defer_attr,
        sel_cpu_attr                => top_sel_cpu_attr,
        ld_attr                     => top_ld_attr,
        sel_RS_cpu                  => top_sel_RS_cpu,
        sel_RS_pch                  => top_sel_RS_pch,
        sel_RS_defer                => top_sel_RS_defer,
        Write_to_RequestBuffer      => top_RequestBuffer_write,
        RequestBuffer_erase         => top_RequestBuffer_erase,
        in_order_exist              => top_in_order_exist,
        valid                       => top_valid,
        is_deferred                 => top_is_deferred,
        sel_RB_DID                  => top_sel_RequestBuffer_DID,
        sel_DR_DID                  => top_sel_DeferredResponse_DID,
        sel_cpu_DID                 => top_sel_cpu_DID,
        ld_length                   => top_ld_length,
        ld_len_cnt                  => top_ld_len_cnt,
        cnt_en                      => top_cnt_en,
        co_len                      => top_co_len,
        sel_len_cpu                 => top_sel_len_cpu,
        sel_len_pch                 => top_sel_len_pch,
        sel_len_defer               => top_sel_len_defer,
        length_0                    => top_Length0,
        sel_cnfg_mem                => top_sel_data_cnfg_mem,
        ld_cnfg_addr                => top_ld_Cnfg_addr,
        cnfg_en                     => top_cnfg_en,
        cnfg_rd_wr                  => top_cnfg_rd_wr,
        cnfg_addr31                 => top_CNFG_Addr31,
        sel_shift_RB                => top_sel_ShiftAddr_RequestBuffer,
        sel_shift_DR                => top_sel_ShiftAddr_DeferredResponse,
        sel_shift_cpu               => top_sel_ShiftAddr_cpu,
        ld_shift_addr               => top_ld_shift_addr,
        mem                         => top_mem,
        io                          => top_io,
        rd                          => top_cpu_rd,
        wr                          => top_cpu_wr,
        special_in                  => top_special,
        sel_data_first_part         => top_sel_data_first_part,
        sel_data_second_part        => top_sel_data_second_part,
        sel_data_full_part          => top_sel_data_full_part,
        ld_read_register            => top_ld_read_register,
        special_sig                 => top_special_sig,
        response_shift_addr         => top_Response_shift_addr,
        sel_data_from_pch           => top_sel_data_from_pch,
        sel_data_from_DR_fifo       => top_sel_data_from_DR_fifo,
        CF8_flag                    => top_CF8_flag,
        CFC_flag                    => top_CFC_flag,
        DRAM_flag                   => top_DRAM_flag,
        -- Vivado OTHERS_flag                 => other_flag,
        MMIO_flag                   => top_MMIO_flag,
        CnfgSpace_flag              => top_CnfgSpace_flag,
        is_cmpl                     => top_is_cmpl,
        with_data                   => top_with_data,          
        cnfg_itself                 => top_cnfg_itself,
        ld_hdr0                     => top_ld_hdr0,
        sel_hdr0_cpu                => top_sel_hdr0_cpu,
        sel_hdr0_pch                => top_sel_hdr0_pch,
        ld_hdr1                     => top_ld_hdr1,
        sel_hdr1_cpu                => top_sel_hdr1_cpu,
        sel_hdr1_pch                => top_sel_hdr1_pch,
        ld_hdr2                     => top_ld_hdr2,
        sel_hdr2_cpu                => top_sel_hdr2_cpu,
        sel_hdr2_pch                => top_sel_hdr2_pch,
        sel_hdr0                    => top_sel_hdr0,
        sel_hdr1                    => top_sel_hdr1,
        sel_hdr2                    => top_sel_hdr2,
        sel_hdr_to_pch              => top_sel_hdr_to_pch,
        sel_cpu_to_pch              => top_sel_cpu_to_pch,
        sel_pch_to_pch              => top_sel_pch_to_pch,
        sel_ddr_to_pch              => open ,
        sel_data_to_DR_fifo         => top_sel_data_to_DeferredResponse,
        sel_header_to_DR_fifo       => top_sel_header_to_DeferredResponse,
        pop_DR_fifo                 => top_pop_DeferredResponse,
        push_DR_fifo                => top_push_DeferredResponse,
        defer_fifo_empty            => top_DeferredResponse_empty,
        DR_rd                       => top_DR_rd,
        DR_wr                       => top_DR_wr,
        cpu_defer_rd                => top_cpu_defer_rd,
        cpu_defer_wr                => top_cpu_defer_wr,
        ld_wr_rd_reg                => top_ld_wr_rd_reg

	);		

end Behavioral;
