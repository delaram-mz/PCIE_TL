LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY VCB_TO_NB IS
	PORT
	(
		input_clk              	: IN  STD_LOGIC;
		input_rst              	: IN  STD_LOGIC;
		-- Input (From CPU to NB)
		output_RS_ready_to_cpu 	: OUT STD_LOGIC;
		output_RS_signals      	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		input_RS_ready         	: IN  STD_LOGIC;
		input_RS_cpu           	: IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		input_req_cpu          	: IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
		output_req_to_cpu      	: OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		input_adr_cpu          	: IN  STD_LOGIC_VECTOR(32 DOWNTO 0);
		output_adr_to_cpu      	: OUT STD_LOGIC_VECTOR(32 DOWNTO 0);
		input_attr_cpu         	: IN  STD_LOGIC_VECTOR(32 DOWNTO 0);
		output_attr_to_cpu     	: OUT STD_LOGIC_VECTOR(32 DOWNTO 0);
		input_datain_cpu       	: IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
		output_dataout_to_cpu  	: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
		input_empty            	: IN  STD_LOGIC;
		output_pop             	: OUT STD_LOGIC;
		input_full             	: IN  STD_LOGIC;
		output_push            	: OUT STD_LOGIC;
		input_start_cpu        	: IN  STD_LOGIC;
		output_ready_to_cpu    	: OUT STD_LOGIC;
		output_start_to_cpu    	: OUT STD_LOGIC;
		input_ready_cpu        	: IN  STD_LOGIC;
		input_DEN              	: IN  STD_LOGIC;
		input_hit              	: IN  STD_LOGIC;
		input_hitm             	: IN  STD_LOGIC;
		------------------ Rx -----------------------
			-- TL
		output_rx_dst_rdy      	: OUT STD_LOGIC;
		input_rx_src_rdy_cmpl 	: IN STD_LOGIC;
		input_rx_src_rdy_p    	: IN STD_LOGIC;
		input_rx_src_rdy_np   	: IN STD_LOGIC;
		input_rx_src_sop      	: IN STD_LOGIC;
		input_rx_src_eop      	: IN STD_LOGIC;
		input_rx_src_data     	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			-- DL
		output_rx_FC_cmp  		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		output_rx_rdy_cmp 		: OUT STD_LOGIC;
		output_rx_FC_p    		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		output_rx_rdy_p   		: OUT STD_LOGIC;
		output_rx_FC_np   		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		output_rx_rdy_np  		: OUT STD_LOGIC;
		------------------ Tx ---------------------
        	-- TL
		input_tx_dst_rdy      	: IN STD_LOGIC;
		output_tx_src_rdy_cmpl 	: OUT STD_LOGIC;
		output_tx_src_rdy_p    	: OUT STD_LOGIC;
		output_tx_src_rdy_np   	: OUT STD_LOGIC;
		output_tx_src_sop      	: OUT STD_LOGIC;
		output_tx_src_eop      	: OUT STD_LOGIC;
		output_tx_src_data     	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		----- Vivado --------------------
		--dataout_to_nb			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		----------------------------------
			-- DL
		input_tx_FC_cmp  		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		input_tx_rdy_cmp 		: IN STD_LOGIC;
		input_tx_FC_p    		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		input_tx_rdy_p   		: IN STD_LOGIC;
		input_tx_FC_np   		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		input_tx_rdy_np  		: IN STD_LOGIC

	);
END VCB_TO_NB;

ARCHITECTURE Behavioral OF VCB_TO_NB IS

	-- signals for conecting NB to IF
	SIGNAL push_send_fifo,pop_receive_fifo 		: STD_LOGIC:='0';
	SIGNAL ready_pch			 				: STD_LOGIC:='0';
	SIGNAL dataout_to_pch 						: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ready_to_pch           				: STD_LOGIC;

	-- signals for conecting IF to VCB or NB
    SIGNAL r3_NBtoPCH,r3_PCHtoNB                                : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL datain_to_pch,datain_from_pch			        	: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ready_to_IF,sop_to_pch,eop_to_pch  					: STD_LOGIC;
	SIGNAL start_pch 											: STD_LOGIC;
	SIGNAL alaki1  							  					: STD_LOGIC;
	SIGNAL alaki2                      		  					: STD_LOGIC_VECTOR(31 DOWNTO 0);

------------------------ Vivado ------------------------------
	SIGNAL  dataout_to_nb :STD_LOGIC_VECTOR (31 DOWNTO 0);
--------------------------------------------------------------


BEGIN


	Northbridge_Top1 : ENTITY work.Northbridge_Top
		PORT MAP
		(

			input_clk                => input_clk,
			input_rst                => input_rst,
			output_RS_ready_to_cpu   => output_RS_ready_to_cpu,
			output_RS_signals        => output_RS_signals,
			input_RS_ready           => input_RS_ready,
			input_RS_cpu             => input_RS_cpu,
			input_req_cpu            => input_req_cpu,
			output_req_to_cpu        => output_req_to_cpu,
			input_adr_cpu            => input_adr_cpu,
			output_adr_to_cpu        => output_adr_to_cpu,
			input_attr_cpu           => input_attr_cpu,
			output_attr_to_cpu       => output_attr_to_cpu,
			input_datain_cpu         => input_datain_cpu,
			output_dataout_to_cpu    => output_dataout_to_cpu,
			input_empty              => input_empty,
			output_pop               => output_pop,
			input_full               => input_full,
			output_push              => output_push,
			input_start_cpu          => input_start_cpu,
			output_ready_to_cpu      => output_ready_to_cpu,
			output_start_to_cpu      => output_start_to_cpu,
			input_ready_cpu          => input_ready_cpu,
			input_DEN                => input_DEN,
			input_hit                => input_hit,
			input_hitm               => input_hitm,
			output_push_send_fifo    => push_send_fifo,
			output_dataout_to_pch    => dataout_to_pch,
			output_pop_receive_fifo  => pop_receive_fifo,
			input_datain_from_pch    => datain_from_pch, --- next version
			output_Read_ready_to_pch => open, --- next version
			input_start_pch          => start_pch, --- next version
			-- Vivado output_start_to_pch      => alaki1,   --- we don't need
			input_ready_pch          => ready_pch,
			output_shutdown          => open

		);

		Interface_NBtoPCH_Top1 : ENTITY work.Interface_NBtoPCH_Top
		PORT MAP
		(
			clk              => input_clk,
			rst              => input_rst,
			-- Northbridge interface:
			push_send_fifo   => push_send_fifo, -- FIFO 2(Recive for PCH & Send for NB)
			dataout_to_pch   => dataout_to_pch, -- FIFO 2
			ready_to_NB 	 => ready_pch,    --almost_full
			-- PCH interface:
			ready_to_IF      => ready_to_IF,
			sop_to_pch       => sop_to_pch,     -- start of packet to PCH
			eop_to_pch       => eop_to_pch,     -- end of packet to PCH
			datain_to_pch    => datain_to_pch,  --FIFO 2
			ready3           => r3_NBtoPCH          	--Posted , Non-Posted, Comletion
		);

	VCB_TRANSMITER1 : ENTITY work.VCB_TRANSMITER
		PORT MAP
	
	(
			clk   => input_clk,
			rst        => input_rst,
			Fc_DLLPs_cmp => input_tx_FC_cmp,     			 
			ready_cmp    => input_tx_rdy_cmp,     			
			Fc_DLLPs_p   =>     input_tx_FC_p,		 
			ready_p      =>   input_tx_rdy_p,   			
			Fc_DLLPs_np      =>input_tx_FC_np,
			ready_np           			=>input_tx_rdy_np,
			tl_tx_src_data     		=> datain_to_pch,
			tl_tx_src_rdy_cmpl	    =>r3_NBtoPCH(0),
			tl_tx_src_rdy_p    		=>r3_NBtoPCH(2),
			tl_tx_src_rdy_np   		=>r3_NBtoPCH(1),
			tl_tx_dst_rdy      => ready_to_IF,  
			-- Vivado tl_tx_src_sop      => sop_to_pch,
			tl_tx_src_eop      => eop_to_pch,
			Src_data           =>  output_tx_src_data,
			Src_rdy_cmp        =>  output_tx_src_rdy_cmpl,
			Src_rdy_p        	 => output_tx_src_rdy_p,
			Src_rdy_np        	=>  output_tx_src_rdy_np,
			Dst_rdy           	=>  input_tx_dst_rdy,
			Src_sop          	=>  output_tx_src_sop,
    		Src_eop           	=>  output_tx_src_eop
	);


	VCB_RECEIVER1 : ENTITY work.VCB_RECEIVER
		PORT MAP
	(
		clk  => input_clk,
		rst =>  input_rst,
		Fc_DLLPs_cmp => output_rx_FC_cmp,
		ready_cmp  =>  output_rx_rdy_cmp,
		Fc_DLLPs_p =>  output_rx_FC_p,
		ready_p    =>  output_rx_rdy_p,
		Fc_DLLPs_np => output_rx_FC_np,
		ready_np    => output_rx_rdy_np,
		Src_data    => input_rx_src_data,
		Src_rdy_cmp  => input_rx_src_rdy_cmpl,
		Src_rdy_p    =>	input_rx_src_rdy_p,
		Src_rdy_np   => input_rx_src_rdy_np,
		Dst_rdy      => output_rx_dst_rdy,
		Src_sop      => input_rx_src_sop,
		Src_eop      => input_rx_src_eop,
		tl_rx_src_data  => dataout_to_nb,
		tl_rx_src_rdy_cmp   => r3_PCHtoNB(0),
		tl_rx_src_rdy_p   =>  r3_PCHtoNB(2),
		tl_rx_src_rdy_np  =>  r3_PCHtoNB(1),
		tl_rx_dst_rdy => ready_to_pch,
		tl_rx_src_sop  => open,
		tl_rx_src_eop  => open
		);

		
	Interface_PCHtoNB_Top1 : ENTITY work.Interface_PCHtoNB_Top
		PORT MAP
	(
		clk              			 => input_clk,
		rst              			 => input_rst,
		-- Northbridge interface:
		pop_receive_fifo   			 => pop_receive_fifo,
		datain_from_pch       	 	 => datain_from_pch,
		ready3      	 			 => r3_PCHtoNB,
		-- PCH interface:
		dataout_to_nb   			 => dataout_to_nb,
		ready_to_pch         		 => ready_to_pch,
		start_pch    		 		 => start_pch
		
	);

	
END Behavioral;
