library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.math_real.ALL;

entity FIFO_v2 is
	GENERIC(
		depth			:	INTEGER	:=	32;
		almost			:	INTEGER	:=	3;
		word_size		:	INTEGER	:=	4;
		reged_output	:	INTEGER	:=	0);
	PORT(
		clk				:	IN	std_logic;
		rst				:	IN	std_logic;
		-- input
		push			:	IN std_logic;
		data_in			:	IN	std_logic_vector(word_size -1 DOWNTO 0);
		full			:	OUT	std_logic;
		almust_full		:	OUT	std_logic;
		-- output
		pop				:	IN	std_logic;
		data_out		:	OUT	std_logic_vector(word_size -1 DOWNTO 0);
		empty			:	OUT	std_logic;
		almust_empty	:	OUT	std_logic);
end FIFO_v2;

architecture Behavioral of FIFO_v2 is

	COMPONENT	FIFO_Controller_V2
	GENERIC(
		depth			:	INTEGER	:=	127;
		almost			:	INTEGER	:=	3);
	PORT(
		clk				:	IN	std_logic;
		rst				:	IN	std_logic;
		Push			:	IN	std_logic;
		Pop				:	IN	std_logic;
		Full			:	OUT	std_logic;
		almust_full		:	OUT	std_logic;
		Empty			:	OUT	std_logic;
		almust_empty	:	OUT	std_logic;
		write_en		:	OUT	std_logic;
		W_inc_en		:	OUT	std_logic;
		R_inc_en		:	OUT	std_logic;
		DC_clr			:	OUT	std_logic;
		DC_inc			:	OUT	std_logic;
		DC_dec			:	OUT	std_logic;
		DC_val			:	IN	std_logic_vector(integer(ceil(log2(real(depth+1))))-1 DOWNTO 0));
	END COMPONENT;
	
	
	COMPONENT	FIFO_DataPath_V2
	GENERIC(
		size			:	INTEGER	:=	8;
		depth			:	INTEGER	:=	8;
		reged_output	:	INTEGER	:=	0);
	PORT(
		clk				:	IN	std_logic;
		rst				:	IN	std_logic;
		wen				:	IN	std_logic;
		W_inc_en		:	IN	std_logic;
		R_inc_en		:	IN	std_logic;
		din				:	IN	std_logic_vector(size-1 DOWNTO 0);
		dout			:	OUT	std_logic_vector(size-1 DOWNTO 0);
		DC_clr			:	IN	std_logic;
		DC_inc			:	IN	std_logic;
		DC_dec			:	IN	std_logic;
		DC_val			:	OUT	std_logic_vector(integer(ceil(log2(real(depth+1))))-1 DOWNTO 0));
	END COMPONENT;
	
	SIGNAL	wen			:	std_logic;
	SIGNAL	W_inc_en	:	std_logic;
	SIGNAL	R_inc_en	:	std_logic;
	SIGNAL	DC_clr		:	std_logic;
	SIGNAL	DC_inc		:	std_logic;
	SIGNAL	DC_dec		:	std_logic;
	SIGNAL	DC_val		:	std_logic_vector(integer(ceil(log2(real(depth+1))))-1 DOWNTO 0);
	
begin
	
	DP					:	FIFO_DataPath_V2
		GENERIC	MAP(
			size		=>	word_size,
			depth		=>	depth,
			reged_output=>	reged_output)
		PORT	MAP(
			clk			=>	clk,
			rst			=>	rst,
			wen			=>	wen,
			W_inc_en	=>	W_inc_en,
			R_inc_en	=>	R_inc_en,
			din			=>	data_in,
			dout		=>	data_out,
			DC_clr		=>	DC_clr,
			DC_inc		=>	DC_inc,
			DC_dec		=>	DC_dec,
			DC_val		=>	DC_val);
	
	
	CU					:	FIFO_Controller_V2
		GENERIC	MAP(
			depth		=>	depth,
			almost		=>	almost)
		PORT	MAP(
			clk			=>	clk,
			rst			=>	rst,
			Push		=>	push,
			Pop			=>	pop,
			Full		=>	full,
			almust_full	=>	almust_full,
			Empty		=>	Empty,
			almust_empty=>	almust_empty,
			write_en	=>	wen,
			W_inc_en	=>	W_inc_en,
			R_inc_en	=>	R_inc_en,
			DC_clr		=>	DC_clr,
			DC_inc		=>	DC_inc,
			DC_dec		=>	DC_dec,
			DC_val		=>	DC_val);
	
end Behavioral;

