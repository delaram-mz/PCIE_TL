onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/clk
add wave -noupdate -divider FC_RX_OUT
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/ep_tl_rx_src_rdy_cmpl
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/ep_tl_rx_src_rdy_np
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/ep_tl_rx_src_rdy_p
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/ep_tl_rx_src_sop
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/ep_tl_rx_src_eop
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/ep_tl_rx_dst_rdy
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/ep_tl_rx_src_data
add wave -noupdate -divider RX_HS
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/PSTATE
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/NSTATE
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/malformed_flag_clr
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/malformed_flag_ld
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/malformed_flag_in
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/exceed_maxPayload
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/undefinedType
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/malformed_flag_out
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/send_err_msg_clr
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/send_err_msg_ld
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/send_err_msg_out
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/err_msg_sent
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/maxPayload
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/len_reg_ld
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/pl_cnt_en
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/pl_cnt_rst
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/typ_reg_in
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/typ_reg_out
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/typ_reg_ld
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/len_reg_out
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/expct_len
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/len_reg_in
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/Controller/pl_cnt_out
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/tx_Hdr1_in
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/tx_Hdr2_in
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/tx_Hdr3_in
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/send_err_msg
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/TLP
add wave -noupdate -divider RX_PATH
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/rx_buffer_inst/rst
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/RX_HS_inst/rx_buff_push
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/rx_buffer_inst/data_in
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/rx_buffer_inst/mem
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/flush_fifo
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/rx_hdr_1_out_wire
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/rx_hdr_2_out_wire
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/rx_hdr_3_out_wire
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/clk
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/tl_rx_dst_rdy
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/tl_rx_src_rdy
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/tl_rx_src_sop
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/tl_rx_src_eop
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/tl_rx_src_data
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/Controller/PSTATE
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/Controller/NSTATE
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/base_address
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/data_length
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/rx_address_cnt_en
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/rx_address_cnt_out
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/rx_address_cnt_rst
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/rx_address_eq
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/rx_memAddr
add wave -noupdate -divider TX_PATH
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/tx_Hdr1_in
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/tx_Hdr2_in
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/DataPath/tx_Hdr3_in
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/tx_Hdr1_ld
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/tx_Hdr2_ld
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/tx_Hdr3_ld
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Transmitter_inst/DataPath/start_tx
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Transmitter_inst/DataPath/tx_done
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Transmitter_inst/DataPath/TX_HS_inst/Controller/PSTATE
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Transmitter_inst/DataPath/TX_HS_inst/Controller/NSTATE
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/EP1_Instance/tl_tx_dst_rdy
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_sop
add wave -noupdate -radix hexadecimal -childformat {{/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(31) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(30) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(29) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(28) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(27) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(26) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(25) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(24) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(23) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(22) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(21) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(20) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(19) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(18) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(17) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(16) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(15) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(14) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(13) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(12) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(11) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(10) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(9) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(8) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(7) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(6) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(5) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(4) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(3) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(2) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(1) -radix unsigned} {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(0) -radix unsigned}} -subitemconfig {/pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(31) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(30) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(29) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(28) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(27) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(26) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(25) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(24) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(23) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(22) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(21) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(20) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(19) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(18) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(17) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(16) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(15) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(14) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(13) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(12) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(11) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(10) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(9) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(8) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(7) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(6) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(5) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(4) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(3) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(2) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(1) {-height 15 -radix unsigned} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data(0) {-height 15 -radix unsigned}} /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_data
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_eop
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_rdy
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_rdy_cmpl
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_rdy_np
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/EP1_Instance/tl_tx_src_rdy_p
add wave -noupdate -divider FC_TX_OUT
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/ep_tl_tx_dst_rdy
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/ep_tl_tx_src_data
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/ep_tl_tx_src_eop
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/ep_tl_tx_src_rdy_cmpl
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/ep_tl_tx_src_rdy_np
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/ep_tl_tx_src_rdy_p
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/ep_tl_tx_src_sop
add wave -noupdate -divider MEMORY
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/EP_MEM/readData
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/EP_MEM/readMEM
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/EP_MEM/readAddr
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/EP_MEM/writeAddr
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/EP_MEM/writeData
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/EP_MEM/writeMEM
add wave -noupdate -divider {IO Interface}
add wave -noupdate -radix unsigned /pcie_ep_tl_tb/clk
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/ep_IO_abus
add wave -noupdate -radix hexadecimal -childformat {{/pcie_ep_tl_tb/ep_IO_dbus(31) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(30) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(29) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(28) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(27) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(26) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(25) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(24) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(23) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(22) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(21) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(20) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(19) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(18) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(17) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(16) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(15) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(14) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(13) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(12) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(11) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(10) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(9) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(8) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(7) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(6) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(5) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(4) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(3) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(2) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(1) -radix hexadecimal} {/pcie_ep_tl_tb/ep_IO_dbus(0) -radix hexadecimal}} -subitemconfig {/pcie_ep_tl_tb/ep_IO_dbus(31) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(30) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(29) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(28) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(27) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(26) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(25) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(24) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(23) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(22) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(21) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(20) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(19) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(18) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(17) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(16) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(15) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(14) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(13) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(12) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(11) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(10) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(9) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(8) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(7) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(6) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(5) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(4) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(3) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(2) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(1) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/ep_IO_dbus(0) {-height 15 -radix hexadecimal}} /pcie_ep_tl_tb/ep_IO_dbus
add wave -noupdate /pcie_ep_tl_tb/ep_IO_cbus
add wave -noupdate -divider config_RF
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/clk
add wave -noupdate -expand -group PORTS -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/ep_cfg_readData
add wave -noupdate -expand -group PORTS -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/ep_cfg_readRF
add wave -noupdate -expand -group PORTS -radix unsigned /pcie_ep_tl_tb/EP1_Instance/ep_cfg_rx_memAddr
add wave -noupdate -expand -group PORTS -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/ep_cfg_tx_memAddr
add wave -noupdate -expand -group PORTS -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/ep_cfg_writeData
add wave -noupdate -expand -group PORTS -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/ep_cfg_writeRF
add wave -noupdate -group {Made Accessible} -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Config_RF/status
add wave -noupdate -group {Made Accessible} -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Config_RF/command
add wave -noupdate -group {Made Accessible} -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Config_RF/BAR0
add wave -noupdate -group {Made Accessible} -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Config_RF/BAR1
add wave -noupdate -group {Made Accessible} -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Config_RF/BAR2
add wave -noupdate -group {Made Accessible} -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Config_RF/BAR3
add wave -noupdate -group {Made Accessible} -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Config_RF/BAR4
add wave -noupdate -group {Made Accessible} -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Config_RF/BAR5
add wave -noupdate -group {Made Accessible} -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Config_RF/capPtr
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Config_RF/capID
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Config_RF/mask
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Config_RF/send_error_allowed
add wave -noupdate -expand -group Target -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Config_RF/read_target_hdr
add wave -noupdate -expand -group Target -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Config_RF/write_target_hdr
add wave -noupdate -expand -group Target /pcie_ep_tl_tb/EP1_Instance/Config_RF/PM_read_target_cap
add wave -noupdate -expand -group Target /pcie_ep_tl_tb/EP1_Instance/Config_RF/PM_write_target_cap
add wave -noupdate -expand -group {Capability Access} -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeAddr
add wave -noupdate -expand -group {Capability Access} -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_readAddr
add wave -noupdate -expand -group {Capability Access} -radix hexadecimal -childformat {{/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(31) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(30) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(29) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(28) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(27) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(26) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(25) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(24) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(23) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(22) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(21) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(20) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(19) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(18) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(17) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(16) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(15) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(14) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(13) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(12) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(11) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(10) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(9) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(8) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(7) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(6) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(5) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(4) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(3) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(2) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(1) -radix hexadecimal} {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(0) -radix hexadecimal}} -subitemconfig {/pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(31) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(30) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(29) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(28) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(27) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(26) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(25) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(24) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(23) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(22) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(21) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(20) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(19) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(18) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(17) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(16) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(15) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(14) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(13) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(12) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(11) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(10) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(9) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(8) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(7) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(6) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(5) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(4) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(3) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(2) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(1) {-height 15 -radix hexadecimal} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData(0) {-height 15 -radix hexadecimal}} /pcie_ep_tl_tb/EP1_Instance/Config_RF/cap_writeData
add wave -noupdate -radix hexadecimal /pcie_ep_tl_tb/EP1_Instance/Config_RF/current_cap
add wave -noupdate -divider PHY_PM_Interface
add wave -noupdate /pcie_ep_tl_tb/ep_phy_send_pm_msg
add wave -noupdate /pcie_ep_tl_tb/ep_phy_pm_msg_sent
add wave -noupdate /pcie_ep_tl_tb/ep_phy_incoming_pm_msg
add wave -noupdate /pcie_ep_tl_tb/ep_phy_pm_msg_received
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/Controller/pm_req
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/Controller/pm_msg_sent
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/Controller/queue_pm_msg
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/Controller/PM_PSTATE
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/Controller/PM_NSTATE
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/incoming_pm_msg_flag
add wave -noupdate /pcie_ep_tl_tb/EP1_Instance/Receiver_inst/incoming_pm_msg_type
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {95000 ps} 0} {{Cursor 2} {451116 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 224
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {38114 ps} {155889 ps}
