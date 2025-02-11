
--*****************************************************************************/
--	Filename:		CONTROLER.vhd
--	Project:		MCI-PCH
--  Version:		1.000
--	History:		-
--	Date:			27 June 2023
--	Authors:	 	Javad
--	Fist Author:    Javad
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

--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY Mux2to1 IS
	PORT (
		in0, in1   : IN STD_LOGIC_VECTOR;
		sel0, sel1 : IN STD_LOGIC;
		out_P      : OUT STD_LOGIC_VECTOR
	);
END ENTITY Mux2to1;

ARCHITECTURE behaviour OF Mux2to1 IS
BEGIN
	out_P <= in0 WHEN sel0 = '1' ELSE
			  in1 WHEN sel1 = '1' ELSE 
			  (Out_P'RANGE =>'0');
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY Mux4to1 IS
	PORT (
		in0, in1, in2, in3     : IN STD_LOGIC_VECTOR;
		sel0, sel1, sel2, sel3 : IN STD_LOGIC;
		out_P                 : OUT STD_LOGIC_VECTOR
	);
END ENTITY Mux4to1;

ARCHITECTURE behaviour OF Mux4to1 IS
BEGIN
	out_P <=  in0 WHEN sel0 = '1' ELSE
			  in1 WHEN sel1 = '1' ELSE 
			  in2 WHEN sel2 = '1' ELSE 
			  in3 WHEN sel3 = '1' ELSE 
			  (Out_P'RANGE =>'0');
END ARCHITECTURE behaviour;
-----------------------------------------------------------------------------------------------

--modified
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY Mux3to1 IS
	PORT (
		in0, in1, in2     : IN STD_LOGIC_VECTOR;
		sel0, sel1, sel2  : IN STD_LOGIC;
		out_P             : OUT STD_LOGIC_VECTOR
	);
END ENTITY Mux3to1;

ARCHITECTURE behaviour OF Mux3to1 IS
BEGIN
	out_P <=  in0 WHEN sel0 = '1' ELSE
			  in1 WHEN sel1 = '1' ELSE 
			  in2 WHEN sel2 = '1' ELSE 
			  (Out_P'RANGE =>'0');
END ARCHITECTURE behaviour;
-----------------------------------------------------------------------------

LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY COUNTER_V2 IS
    GENERIC(inputbit:INTEGER:=4);
    port (clk:IN STD_LOGIC;
    rst:IN STD_LOGIC;
    EN:IN STD_LOGIC;
    LOAD:IN STD_LOGIC;
    INP:IN STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0);
    OUTP:OUT STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0)
    );
END COUNTER_V2 ;
ARCHITECTURE ARCH OF COUNTER_V2  IS
    SIGNAL oup:STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0);
BEGIN
    PROCESS( clk,rst )
    BEGIN
        IF(rst='1') THEN
            oup<=(OTHERS=>'0');
        ELSIF(clk='1' AND clk'EVENT) THEN 
            IF(LOAD='1') THEN
                oup<=INP;
            ELSIF(EN='1') THEN
                oup<=oup+1;
            END IF;
        END IF;
    END PROCESS;
    OUTP<=oup;
end ARCHITECTURE;

-------------------------------------------------------------------------------------------------
LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY COUNTER IS
    GENERIC(inputbit:INTEGER:=4);
    port (
    clk:IN STD_LOGIC;
    rst:IN STD_LOGIC;
    en:IN STD_LOGIC;
    cnt_output:OUT STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0));
END COUNTER ;
ARCHITECTURE ARCH OF COUNTER  IS
    SIGNAL oup:STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0);
BEGIN
    identifier : PROCESS( clk,rst )
    BEGIN
        IF(rst='1') THEN
            oup<=(OTHERS=>'0');
        ELSIF(clk='1' AND clk'EVENT) THEN 
            IF(en='1') THEN
                oup<=oup+'1';
            END IF;
        END IF;
    END PROCESS ;
    cnt_output<=oup;
end ARCHITECTURE;

-- ---------------------------------------------------------------------
LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY COUNTER_Sclr IS
    GENERIC(inputbit:INTEGER:=4);
    port (
        clk:IN STD_LOGIC;
        rst:IN STD_LOGIC;
        clr:IN STD_LOGIC;
        en:IN STD_LOGIC;
        cnt_output:OUT STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0));
END COUNTER_Sclr ;
ARCHITECTURE ARCH OF COUNTER_Sclr  IS
    SIGNAL oup:STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0);
BEGIN
    identifier : PROCESS( clk,rst )
    BEGIN
        IF(rst='1') THEN
            oup<= (OTHERS=>'0');
        ELSIF(clk='1' AND clk'EVENT) THEN 
            IF(clr='1') THEN
                oup<= (OTHERS=>'0');
            ELSIF(en='1') THEN
                oup<= oup + 1;
            END IF;
        END IF;
    END PROCESS ;
    cnt_output<=oup;
end ARCHITECTURE;
-------------------------------------------------------------------------------------------------
LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY COUNTER_init IS
    GENERIC(inputbit:INTEGER:=4);
    port (clk:IN STD_LOGIC;
    rst			:IN STD_LOGIC;
    en			:IN STD_LOGIC;
    init		:IN STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0);
    cnt_output	:OUT STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0));
END COUNTER_init ;
ARCHITECTURE ARCH OF COUNTER_init  IS
    SIGNAL oup:STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0);
BEGIN
    identifier : PROCESS( clk,rst,init)
    BEGIN
        IF(rst='1') THEN
            oup <= init;
        ELSIF(clk='1' AND clk'EVENT) THEN 
            IF(en='1') THEN
                oup <= oup + 1;
            END IF;
        END IF;
    END PROCESS ;
    cnt_output <= oup;
end ARCHITECTURE;

-- ---------------------------------------------------------------------
LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY COUNTER_rst IS
    GENERIC(inputbit:INTEGER:=4);
    port (clk	:IN STD_LOGIC;
    rst			:IN STD_LOGIC;
    en			:IN STD_LOGIC;
	cntrrst 	:IN STD_LOGIC;
    CntrInint	: IN STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0);
    cnt_output	:OUT STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0));
END COUNTER_rst ;
ARCHITECTURE ARCH OF COUNTER_rst  IS
    SIGNAL oup:STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0);
BEGIN
    identifier : PROCESS( clk,rst )
    BEGIN
        IF(rst='1') THEN
            oup<=(OTHERS=>'0');
        ELSIF(clk='1' AND clk'EVENT) THEN 
            IF(cntrrst='1') THEN
                oup <= CntrInint;
			ELSIF(en='1') THEN
                oup<=oup+1;
            END IF;
        END IF;
    END PROCESS ;
    cnt_output<=oup;
end ARCHITECTURE;

-----------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter2bit is
    Port (
        clk    : in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        enable : in  STD_LOGIC;
        count  : out STD_LOGIC_VECTOR(1 downto 0);
        cout   : out STD_LOGIC
    );
end counter2bit;

architecture Behavioral of counter2bit is
    signal cnt: unsigned(1 downto 0) := (others => '1');
begin
    process(clk, reset)
    begin
        if reset = '1' then
            cnt <= (others => '0');
        elsif (clk'event and clk='1') then
            if enable = '1' then
                if cnt = "10" then  
                    cnt <= (others => '0');
                    --cout <= '1';
                else
                    cnt <= cnt + 1;
                    --cout <= '0';
                end if;
            end if;
        end if;
    end process;

    count <= STD_LOGIC_VECTOR(cnt);
    --cout  <= '1' when cnt = "10" else '0';
	cout  <= '1' when (cnt = "10" and enable = '1')  else '0';



end Behavioral;
-- ---------------------------------------------------------------------
----
LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY COUNTER_L IS
    GENERIC(inputbit:INTEGER:=4);
    port (clk:IN STD_LOGIC;
    rst:IN STD_LOGIC;
    en:IN STD_LOGIC;
    ld:IN STD_LOGIC;
    inp:IN STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0);
    cnt_output:OUT STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0));
END COUNTER_L ;
ARCHITECTURE ARCH OF COUNTER_L  IS
    SIGNAL oup:STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0);
BEGIN
    identifier : PROCESS( clk,rst )
    BEGIN
        IF(rst='1') THEN
            oup<=(OTHERS=>'0');
        ELSIF(clk='1' AND clk'EVENT) THEN 
            IF(ld='1') THEN
                oup<=inp;
            ELSIF(en='1') THEN 
                oup<=oup+1;
            END IF;
        END IF;
    END PROCESS ;
    cnt_output<=oup;
end ARCHITECTURE;
-- ---------------------------------------------------------------------

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
-- GENERIC BIT REGISTER
ENTITY GENERIC_REG IS 
GENERIC (N : INTEGER );
PORT( clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;--reset
    ld : IN STD_LOGIC;--load 
    reg_in : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
    reg_out : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0));
END ENTITY GENERIC_REG;

ARCHITECTURE GENERIC_REG_ARC OF GENERIC_REG IS
SIGNAL temp_reg : STD_LOGIC_VECTOR (N-1 DOWNTO 0);
BEGIN
reg_out <= temp_reg;
P3: PROCESS(clk , rst)
BEGIN
    IF rst = '1' THEN
        temp_reg <= (OTHERS => '0');
    ELSIF clk = '1' AND clk'EVENT THEN  
        IF ld = '1' THEN
        temp_reg <= reg_in;
        END IF;
    ELSE
    END IF;
END PROCESS;
END ARCHITECTURE GENERIC_REG_ARC;
--------------------------------------------------------------------------

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
-- GENERIC BIT REGISTER
ENTITY GENERIC_REG_v2 IS 
GENERIC (N : INTEGER );
PORT( clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;--reset
    ld  : IN STD_LOGIC;--load 
    clr : IN STD_LOGIC;--clr 
    reg_in : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
    reg_out : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0));
END ENTITY GENERIC_REG_v2;

ARCHITECTURE GENERIC_REG_v2_ARC OF GENERIC_REG_v2 IS
SIGNAL temp_reg : STD_LOGIC_VECTOR (N-1 DOWNTO 0);
BEGIN
reg_out <= temp_reg;
P3: PROCESS(clk , rst)
BEGIN
    IF rst = '1' THEN
        temp_reg <= (OTHERS => '0');
    ELSIF clk = '1' AND clk'EVENT THEN  
        IF ld = '1' THEN
            temp_reg <= reg_in;
        ELSIF clr = '1' THEN
            temp_reg <= (OTHERS => '0');
        END IF;
    ELSE
    END IF;
END PROCESS;
END ARCHITECTURE GENERIC_REG_v2_ARC;

-- ---------------------------------------------------------------------
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
-- GENERIC BIT REGISTER
ENTITY REG1bit IS 
PORT( clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;--reset
    ld : IN STD_LOGIC;--load 
    reg_in : IN STD_LOGIC;
    reg_out : OUT STD_LOGIC);
END ENTITY REG1bit;

ARCHITECTURE REG1bit_ARC OF REG1bit IS
SIGNAL temp_reg : STD_LOGIC;
BEGIN
reg_out <= temp_reg;
P3: PROCESS(clk , rst)
BEGIN
    IF rst = '1' THEN
        temp_reg <= '0';
    ELSIF clk = '1' AND clk'EVENT THEN  
        IF ld = '1' THEN
        temp_reg <= reg_in;
        END IF;
    ELSE
    END IF;
END PROCESS;
END ARCHITECTURE REG1bit_ARC;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
-- One BIT REGISTER
ENTITY OneBit_REG IS 
PORT( clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;--reset
    ld : IN STD_LOGIC;--load 
    reg_in : IN STD_LOGIC;
    reg_out : OUT STD_LOGIC);
END ENTITY OneBit_REG;

ARCHITECTURE OneBit_REG_ARC OF OneBit_REG IS
SIGNAL temp_reg : STD_LOGIC;
BEGIN
reg_out <= temp_reg;
P3: PROCESS(clk , rst)
BEGIN
    IF rst = '1' THEN
        temp_reg <= '0';
    ELSIF clk = '1' AND clk'EVENT THEN  
        IF ld = '1' THEN
          temp_reg <= reg_in;
        END IF;
    ELSE
    END IF;
END PROCESS;
END ARCHITECTURE OneBit_REG_ARC;


-- ---------------------------------------------------------------------
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
-- GENERIC SHIFT REGISTER
ENTITY GENERIC_SHIFT_REG IS 
GENERIC (N : INTEGER := 4 ; active : STD_LOGIC := '1'; RL : STD_LOGIC :='1'); -- RL = '1' LSB OUT
PORT( clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;--reset
    ld : IN STD_LOGIC;--load 
    shift : IN STD_LOGIC;
    par_in : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
    par_out : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0);
    Sin : IN STD_LOGIC;
    So : OUT STD_LOGIC);
END ENTITY GENERIC_SHIFT_REG;

ARCHITECTURE GENERIC_SHIFT_REG_ARC OF GENERIC_SHIFT_REG IS
SIGNAL temp_reg : STD_LOGIC_VECTOR (N-1 DOWNTO 0);
BEGIN
P3: PROCESS(clk , rst, ld, temp_reg, Sin, par_in)
BEGIN
    IF rst = '1' THEN
        temp_reg <= (OTHERS => '0');
    ELSIF ld = '1' THEN
      temp_reg <= par_in;
    ELSIF clk = active AND clk'EVENT THEN  
        IF shift = '1' THEN
          IF RL = '1'THEN
            temp_reg <= Sin & temp_reg(N-1 DOWNTO 1);
          ELSE
            temp_reg <=  temp_reg(N-2 DOWNTO 0) & Sin;
          END IF;
        ELSE
          temp_reg <= temp_reg;
        END IF;
    END IF;
  END PROCESS;
    So <= temp_reg(0) WHEN RL = '1' ELSE temp_reg(N-1);
    par_out <= temp_reg;
END ARCHITECTURE GENERIC_SHIFT_REG_ARC;

-- ---------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY Mux2to1_OneBit IS
	PORT (
		in0, in1   : IN STD_LOGIC;
		sel0, sel1 : IN STD_LOGIC;
		out_P      : OUT STD_LOGIC
	);
END ENTITY Mux2to1_OneBit;

ARCHITECTURE behaviour OF Mux2to1_OneBit IS
BEGIN
	out_P <= in0 WHEN sel0 = '1' ELSE
			  in1 WHEN sel1 = '1' ELSE '0';
END ARCHITECTURE behaviour;
-----------------------------------------------------
LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY CSR IS
    GENERIC(Reg_num:INTEGER:=4);
    port (clk:IN STD_LOGIC;
    rst:IN STD_LOGIC;
    diff_in:IN STD_LOGIC;
    load:IN STD_LOGIC;
    shift:IN STD_LOGIC;
    initial_value:IN STD_LOGIC_VECTOR (Reg_num-1 DOWNTO 0);
    data_out:OUT STD_LOGIC_VECTOR(Reg_num-1 DOWNTO 0);
    So: OUT STD_LOGIC);
    END CSR ;
ARCHITECTURE ARCH OF CSR  IS
    SIGNAL So_wire, Sin_wire: STD_LOGIC;
BEGIN
  Sin_wire <= diff_in XOR So_wire;
  CSC_shr: ENTITY WORK.GENERIC_SHIFT_REG GENERIC MAP(Reg_num, '1') PORT MAP(clk=>clk, rst=>rst, ld=>load, shift=>shift, par_in=>initial_value, par_out=>data_out, Sin=>Sin_wire, So => So_wire); 
  So <= So_wire;
END ARCHITECTURE;
-------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.Std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

ENTITY FIFO IS 
GENERIC(log2size:INTEGER:=2);
PORT(
    clk: IN STD_LOGIC;
    rst: IN STD_LOGIC;
    push: IN STD_LOGIC;
    pop: IN STD_LOGIC;
    data_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    data_top: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full: OUT STD_LOGIC;
    empty: OUT STD_LOGIC
);
END FIFO;
ARCHITECTURE ARCH1 OF FIFO IS
    type MEMORY_TYPE is array (0 TO (2**log2size)-1) of STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem : MEMORY_TYPE;
    SIGNAL wr_point : STD_LOGIC_VECTOR(log2size-1 DOWNTO 0);
    SIGNAL rd_point : STD_LOGIC_VECTOR(log2size-1 DOWNTO 0);
    SIGNAL cnt : STD_LOGIC_VECTOR(log2size DOWNTO 0);
    SIGNAL full_sig : STD_LOGIC;
    SIGNAL empty_sig : STD_LOGIC;
BEGIN
    PROCESS (clk,rst) BEGIN
        IF (rst='1') THEN
            wr_point <= (OTHERS=>'0');
		  ELSIF(clk = '1' and clk'event) THEN
          IF ( (push='1') AND (full_sig='0')) THEN
            wr_point <= wr_point + 1;
          END IF;
		  END IF;
    END PROCESS;
    PROCESS (clk,rst) BEGIN
        IF (rst='1') THEN
            rd_point <= (OTHERS=>'0');
		  ELSIF(clk = '1' and clk'event) THEN
          IF ((pop='1') AND (empty_sig='0')) THEN
            rd_point <= rd_point + 1;
          END IF;
		  END IF;
    END PROCESS;
    PROCESS (clk,rst) BEGIN
        IF (rst='1') THEN
            cnt <= (OTHERS=>'0');
		ELSIF(clk = '1' and clk'EVENT) THEN
            IF ((push='1') AND (pop='0') AND (full_sig='0')) THEN
                cnt <= cnt + 1;
            ELSIF ((pop='1') AND (push='0') AND (empty_sig='0')) THEN
                cnt <= cnt - 1;
            ELSIF ((pop='1') AND (push='0') AND (empty_sig='0')) THEN
                cnt <= cnt;
            ELSIF ((pop='1') AND (push='1') AND (empty_sig='1')) THEN
                cnt <= cnt + 1;
            END IF;
		END IF;
    END PROCESS;

    PROCESS (cnt) BEGIN
        IF(cnt=2**log2size) THEN
            full_sig <= '1';
        ELSE
            full_sig <= '0';
        END IF;
        IF(cnt="0") THEN
            empty_sig <= '1';
        ELSE
            empty_sig <= '0';
        END IF;
    END PROCESS;
    full <= full_sig;
    empty <= empty_sig;
    PROCESS (clk) BEGIN
		if(clk='1' and clk'EVENT) then
        IF ((push = '1') AND (full_sig='0')) THEN
            mem(to_integer(unsigned(wr_point))) <= data_in;
        END IF;
        --IF ((pop = '1') AND (clk = '1') AND (empty_sig='0')) THEN          -------comment for synthesis-------------
        --    mem(to_integer(unsigned(rd_point))) <= x"ffffffff"; -------comment for synthesis-------------
        --END IF; -------comment for synthesis-------------
       end if;
	 END PROCESS;
    data_top <= mem(to_integer(unsigned(rd_point)));
END ARCHITECTURE;
-----------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.Std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

ENTITY FIFO_2port IS 
GENERIC(log2size:INTEGER:=2);
PORT(
    clk: IN STD_LOGIC;
    rst: IN STD_LOGIC;
    push: IN STD_LOGIC;
    pop: IN STD_LOGIC;
    data_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    data_top: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    data_top_2: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full: OUT STD_LOGIC;
    empty: OUT STD_LOGIC
);
END FIFO_2port;
ARCHITECTURE ARCH1 OF FIFO_2port IS
    type MEMORY_TYPE is array (0 TO (2**log2size)-1) of STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem : MEMORY_TYPE;
    SIGNAL wr_point : STD_LOGIC_VECTOR(log2size-1 DOWNTO 0);
    SIGNAL rd_point : STD_LOGIC_VECTOR(log2size-1 DOWNTO 0);
    SIGNAL cnt : STD_LOGIC_VECTOR(log2size DOWNTO 0);
    SIGNAL full_sig : STD_LOGIC;
    SIGNAL empty_sig : STD_LOGIC;
BEGIN
    PROCESS (clk,rst) BEGIN
        IF (rst='1') THEN
            wr_point <= (OTHERS=>'0');
		  ELSIF(clk = '1' and clk'event) THEN
          IF ( (push='1') AND (full_sig='0')) THEN
            wr_point <= wr_point + 1;
          END IF;
		  END IF;
    END PROCESS;
    PROCESS (clk,rst) BEGIN
        IF (rst='1') THEN
            rd_point <= (OTHERS=>'0');
		  ELSIF(clk = '1' and clk'event) THEN
          IF ((pop='1') AND (empty_sig='0')) THEN
            rd_point <= rd_point + 1;
          END IF;
		  END IF;
    END PROCESS;
    PROCESS (clk,rst) BEGIN
        IF (rst='1') THEN
            cnt <= (OTHERS=>'0');
		ELSIF(clk = '1' and clk'EVENT) THEN
            IF ((push='1') AND (pop='0') AND (full_sig='0')) THEN
                cnt <= cnt + 1;
            ELSIF ((pop='1') AND (push='0') AND (empty_sig='0')) THEN
                cnt <= cnt - 1;
            ELSIF ((pop='1') AND (push='0') AND (empty_sig='0')) THEN
                cnt <= cnt;
            ELSIF ((pop='1') AND (push='1') AND (empty_sig='1')) THEN
                cnt <= cnt + 1;
            END IF;
		END IF;
    END PROCESS;

    PROCESS (cnt) BEGIN
        IF(cnt=2**log2size) THEN
            full_sig <= '1';
        ELSE
            full_sig <= '0';
        END IF;
        IF(cnt="0") THEN
            empty_sig <= '1';
        ELSE
            empty_sig <= '0';
        END IF;
    END PROCESS;
    full <= full_sig;
    empty <= empty_sig;
    PROCESS (clk) BEGIN
		if(clk='1' and clk'EVENT) then
        IF ((push = '1') AND (full_sig='0')) THEN
            mem(to_integer(unsigned(wr_point))) <= data_in;
        END IF;
        IF ((pop = '1') AND (clk = '1') AND (empty_sig='0')) THEN          -------comment for synthesis-------------
            mem(to_integer(unsigned(rd_point))) <= x"ffffffff"; -------comment for synthesis-------------
        END IF; -------comment for synthesis-------------
       end if;
	 END PROCESS;
    data_top <= mem(to_integer(unsigned(rd_point)));
    data_top_2 <= mem(to_integer(unsigned(rd_point + 1)));
END ARCHITECTURE;
-----------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.Std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

ENTITY FIFO_GEN IS 
GENERIC(log2size:INTEGER:=2; data_size : INTEGER := 2);
PORT(
    clk: IN STD_LOGIC;
    rst: IN STD_LOGIC;
    push: IN STD_LOGIC;
    pop: IN STD_LOGIC;
    data_in: IN STD_LOGIC_VECTOR(data_size-1 DOWNTO 0);
    data_top: OUT STD_LOGIC_VECTOR(data_size-1 DOWNTO 0);
    full: OUT STD_LOGIC;
    empty: OUT STD_LOGIC
);
END FIFO_GEN;
ARCHITECTURE FIFO_GEN_arc OF FIFO_GEN IS
    type MEMORY_TYPE is array (0 TO (2**log2size)-1) of STD_LOGIC_VECTOR(data_size-1 DOWNTO 0);
    SIGNAL mem : MEMORY_TYPE;
    SIGNAL wr_point : STD_LOGIC_VECTOR(log2size-1 DOWNTO 0);
    SIGNAL rd_point : STD_LOGIC_VECTOR(log2size-1 DOWNTO 0);
    SIGNAL cnt : STD_LOGIC_VECTOR(log2size DOWNTO 0);
    SIGNAL full_sig : STD_LOGIC;
    SIGNAL empty_sig : STD_LOGIC;
BEGIN
    PROCESS (clk,rst) BEGIN
        IF (rst='1') THEN
            wr_point <= (OTHERS=>'0');
		  ELSIF(clk = '1' and clk'event) THEN
          IF ( (push='1') AND (full_sig='0')) THEN
            wr_point <= wr_point + 1;
          END IF;
		  END IF;
    END PROCESS;
    PROCESS (clk,rst) BEGIN
        IF (rst='1') THEN
            rd_point <= (OTHERS=>'0');
		  ELSIF(clk = '1' and clk'event) THEN
          IF ((pop='1') AND (empty_sig='0')) THEN
            rd_point <= rd_point + 1;
          END IF;
		  END IF;
    END PROCESS;
    PROCESS (clk,rst) BEGIN
        IF (rst='1') THEN
            cnt <= (OTHERS=>'0');
		ELSIF(clk = '1' and clk'EVENT) THEN
            IF ((push='1') AND (pop='0') AND (full_sig='0')) THEN
                cnt <= cnt + 1;
            ELSIF ((pop='1') AND (push='0') AND (empty_sig='0')) THEN
                cnt <= cnt - 1;
            ELSIF ((pop='1') AND (push='0') AND (empty_sig='0')) THEN
                cnt <= cnt;
            ELSIF ((pop='1') AND (push='1') AND (empty_sig='1')) THEN
                cnt <= cnt + 1;
            END IF;
		END IF;
    END PROCESS;

    PROCESS (cnt) BEGIN
        IF(cnt=2**log2size) THEN
            full_sig <= '1';
        ELSE
            full_sig <= '0';
        END IF;
        IF(cnt="0") THEN
            empty_sig <= '1';
        ELSE
            empty_sig <= '0';
        END IF;
    END PROCESS;
    full <= full_sig;
    empty <= empty_sig;
    PROCESS (clk) BEGIN
		if(clk='1' and clk'EVENT) then
        IF ((push = '1') AND (full_sig='0')) THEN
            mem(to_integer(unsigned(wr_point))) <= data_in;
        END IF;
        IF ((pop = '1') AND (clk = '1') AND (empty_sig='0')) THEN          -------comment for synthesis-------------
            mem(to_integer(unsigned(rd_point))) <= (OTHERS => '1'); -------comment for synthesis-------------
        END IF; -------comment for synthesis-------------
       end if;
	 END PROCESS;
    data_top <= mem(to_integer(unsigned(rd_point)));
END ARCHITECTURE;
------------------------------------------------------------------------------------------------------------------------
--Ring counter
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ring_cntr IS
    PORT(
        clk        : IN STD_LOGIC;
        rst        : IN STD_LOGIC;  
        cnt_clr    : IN STD_LOGIC;
        cnt_en     : IN STD_LOGIC;
        cnt_co     : OUT STD_LOGIC;
        cnt_out    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE ring_cntr_arc OF ring_cntr IS
    SIGNAL cnt_out_sig : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
BEGIN
    PROCESS(clk, rst) BEGIN
        IF (rst = '1') THEN
            cnt_out_sig <= "0001";
        ELSIF clk = '1' AND clk'EVENT THEN 
            IF(cnt_clr = '1') THEN 
                cnt_out_sig <= "0001";
            ELSIF(cnt_en = '1') THEN 
                cnt_out_sig <= (cnt_out_sig(2 DOWNTO 0) & cnt_out_sig(3));
            END IF;
        END IF;
    END PROCESS;

    cnt_out <= cnt_out_sig;
    cnt_co <= '1' WHEN cnt_out_sig = "1000" ELSE '0';
END ARCHITECTURE;
------------------------------------------------------------------------------------------------------------------------
--Encoder
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY p_encoder IS
    port(
        in_p  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        out_p : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END ENTITY p_encoder;

ARCHITECTURE p_encoder_arc OF p_encoder IS
BEGIN
    out_p<= "00" WHEN in_p(0)='1' ELSE
            "01" WHEN in_p(1)='1' ELSE
            "10" WHEN in_p(2)='1' ELSE
            "11" WHEN in_p(3)='1' ELSE
            "00";
END ARCHITECTURE p_encoder_arc;
------------------------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.Std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;

ENTITY Adder IS
GENERIC(
    BITS:INTEGER:=32
);
PORT(
    in1 : IN STD_LOGIC_VECTOR(BITS-1 DOWNTO 0);
    in2 : IN STD_LOGIC_VECTOR(BITS-1 DOWNTO 0);
    Cin : IN STD_LOGIC;
    out1 : OUT STD_LOGIC_VECTOR(BITS DOWNTO 0)
);
END Adder;

ARCHITECTURE ARCH1 OF Adder IS

BEGIN
    out1 <= (in1(BITS-1)&in1)+(in2(BITS-1)&in2)+Cin;
END ARCHITECTURE;
------------------------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.Std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;

ENTITY Comparator IS 
GENERIC(
    BITS:INTEGER:=32
);
PORT(
    in1 : IN STD_LOGIC_VECTOR(BITS-1 DOWNTO 0);
    in2 : IN STD_LOGIC_VECTOR(BITS-1 DOWNTO 0);
    bg : OUT STD_LOGIC;
    eq : OUT STD_LOGIC;
    ls : OUT STD_LOGIC
);
END Comparator;

ARCHITECTURE ARCH1 OF Comparator IS

BEGIN
    PROCESS (in1,in2) BEGIN
        IF(in1>in2) THEN
            bg<='1';eq<='0';ls<='0';
        ELSIF(in1=in2) THEN
            bg<='0';eq<='1';ls<='0';
        ELSE 
            bg<='0';eq<='0';ls<='1';
        END IF;
    END PROCESS;
END ARCHITECTURE;
------------------------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
	
ENTITY MEM2 IS
GENERIC(
    BITS:INTEGER:=32
);
	PORT (
		clk, rst, readMEM, writeMEM : IN STD_LOGIC;
		addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		addr2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		writeData : IN STD_LOGIC_VECTOR(BITS-1 DOWNTO 0);
		readData        : OUT STD_LOGIC_VECTOR(BITS-1 DOWNTO 0);
--		rwData          : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		readyMEM        : OUT STD_LOGIC
	);
END ENTITY MEM2;

ARCHITECTURE behaviour OF MEM2 IS
	TYPE data_mem IS ARRAY (0 TO 256) OF STD_LOGIC_VECTOR(BITS-1 DOWNTO 0);
	SIGNAL memory : data_mem;
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			FOR I IN 0 TO 256 LOOP
				memory(I) <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, BITS));
			END LOOP;
		ELSIF clk = '1' AND clk'EVENT THEN
			IF writeMem = '1' THEN
				memory(TO_INTEGER(UNSIGNED(addr))) <= writeData;
--				memory(TO_INTEGER(UNSIGNED(addr))) <= rwData;
				readyMEM <= '1';
			END IF;
			
			IF readMEM = '1' THEN
				readyMEM <= '1';
			END IF;
		END IF;
	END PROCESS;

    readData <= memory(TO_INTEGER(UNSIGNED(addr2))) WHEN readMEM = '1' ELSE
--    rwData <= memory(TO_INTEGER(UNSIGNED(addr))) WHEN readMEM = '1' ELSE
			    (OTHERS => 'Z'); 
END ARCHITECTURE behaviour;


-------------------------------------------------------------------------------------------------------
-- LIBRARY IEEE;
-- USE IEEE.Std_logic_1164.all;
-- USE IEEE.std_logic_unsigned.all;
-- use ieee.numeric_std.all;
-- use ieee.math_real.all;

-- ENTITY DLLP_FIFO IS 
-- GENERIC(log2size:INTEGER:=2,BITS:INTEGER:=32);
-- PORT(
--     clk: IN STD_LOGIC;
--     rst: IN STD_LOGIC;
--     push: IN STD_LOGIC;
--     pop: IN STD_LOGIC;
--     show: IN STD_LOGIC;
--     show_rst_index: IN STD_LOGIC;
--     data_in: IN STD_LOGIC_VECTOR(BITS-1 DOWNTO 0);
--     data_top: OUT STD_LOGIC_VECTOR(BITS-1 DOWNTO 0);
--     data_show: OUT STD_LOGIC_VECTOR(BITS-1 DOWNTO 0);
--     full: OUT STD_LOGIC;
--     empty: OUT STD_LOGIC
-- );
-- END DLLP_FIFO;
-- ARCHITECTURE ARCH1 OF DLLP_FIFO IS
--     type MEMORY_TYPE is array (0 TO (2**log2size)-1) of STD_LOGIC_VECTOR(BITS-1 DOWNTO 0);
--     SIGNAL mem : MEMORY_TYPE;
--     SIGNAL wr_point : STD_LOGIC_VECTOR(log2size-1 DOWNTO 0);
--     SIGNAL rd_point : STD_LOGIC_VECTOR(log2size-1 DOWNTO 0);
--     SIGNAL show_point : STD_LOGIC_VECTOR(log2size-1 DOWNTO 0);
--     SIGNAL cnt : STD_LOGIC_VECTOR(log2size DOWNTO 0);
--     SIGNAL cnt2 : STD_LOGIC_VECTOR(log2size DOWNTO 0);
--     SIGNAL show_SIG : STD_LOGIC;
--     SIGNAL full_sig : STD_LOGIC;
--     SIGNAL full_sig2 : STD_LOGIC;
--     SIGNAL empty_sig : STD_LOGIC;
--     SIGNAL empty_sig2 : STD_LOGIC;
-- BEGIN
--     PROCESS (clk,rst) BEGIN
--         IF (rst='1') THEN
--             wr_point <= (OTHERS=>'0');
-- 		  ELSIF(clk = '1' and clk'event) THEN
--           IF ( (push='1') AND (full_sig='0')) THEN
--             wr_point <= wr_point + 1;
--           END IF;
-- 		  END IF;
--     END PROCESS;
--     show_SIG<=(show OR pop);
--     PROCESS (clk,rst) BEGIN
--         IF (rst='1') THEN
--             show_point <= (OTHERS=>'0');
--         ELSIF(clk = '1' and clk'event) THEN
--             IF (show_rst_index='1') THEN
--                 show_point <= (OTHERS=>'0');
--             ELSIF((show_SIG='1') AND (empty_sig2='0')) THEN
--                 show_point <= show_point + 1;
--             END IF;
--         END IF;
--     END PROCESS;
--     PROCESS (clk,rst) BEGIN
--         IF (rst='1') THEN
--             rd_point <= (OTHERS=>'0');
-- 		  ELSIF(clk = '1' and clk'event) THEN
--           IF ((pop='1') AND (empty_sig='0')) THEN
--             rd_point <= rd_point + 1;
--           END IF;
-- 		  END IF;
--     END PROCESS;
--     PROCESS (clk,rst) BEGIN
--         IF (rst='1') THEN
--             cnt <= (OTHERS=>'0');
--             cnt2 <= (OTHERS=>'0');
-- 		ELSIF(clk = '1' and clk'EVENT) THEN
--             IF ((push='1') AND (pop='0') AND (full_sig='0')) THEN
--                 cnt <= cnt + 1;
--                 cnt2 <= cnt2 + 1;
--             ELSIF ((pop='1') AND (push='0') AND (empty_sig='0')) THEN
--                 cnt <= cnt - 1;
--                 cnt2 <= cnt2 - 1;
--             ELSIF ((pop='1') AND (push='0') AND (empty_sig='0')) THEN
--                 cnt <= cnt;
--                 cnt2 <= cnt2;
--             ELSIF ((pop='1') AND (push='1') AND (empty_sig='1')) THEN
--                 cnt <= cnt + 1;
--                 cnt2 <= cnt2 + 1;
--             END IF;
--             IF ((show_SIG='1') AND (pop='0') AND (full_sig2='0')) THEN
--                 cnt2 <= cnt2 - 1;
--             END IF;
-- 		END IF;
--     END PROCESS;

--     PROCESS (cnt) BEGIN
--         IF(cnt=2**log2size) THEN
--             full_sig <= '1';
--         ELSE
--             full_sig <= '0';
--         END IF;
--         IF(cnt="0") THEN
--             empty_sig <= '1';
--         ELSE
--             empty_sig <= '0';
--         END IF;
--     END PROCESS;
--     PROCESS (cnt2) BEGIN
--         IF(cnt2=2**log2size) THEN
--             full_sig2 <= '1';
--         ELSE
--             full_sig2 <= '0';
--         END IF;
--         IF(cnt2="0") THEN
--             empty_sig2 <= '1';
--         ELSE
--             empty_sig2 <= '0';
--         END IF;
--     END PROCESS;
--     full <= full_sig;
--     empty <= empty_sig;
--     PROCESS (clk) BEGIN
-- 		if(clk='1' and clk'EVENT) then
--             IF ((push = '1') AND (full_sig='0')) THEN
--                 mem(to_integer(unsigned(wr_point))) <= data_in;
--             END IF;
--             IF ((pop = '1') AND (clk = '1') AND (empty_sig='0')) THEN          -------comment for synthesis-------------
--                 mem(to_integer(unsigned(rd_point))) <= x"ffffffff"; -------comment for synthesis-------------
--             END IF; -------comment for synthesis-------------
--             IF ((push = '1') AND (pop = '1') AND (full_sig='1')) THEN
--                 mem(to_integer(unsigned(rd_point))) <= data_in;
--             END IF;
--         END IF; 
-- 	 END PROCESS;
--     data_top <= mem(to_integer(unsigned(rd_point)));
--     data_show <= mem(to_integer(unsigned(show_point)));
-- END ARCHITECTURE;
-- ------------------------------------------------------------------------------------------------------------------------
--******************************************************************************
--	Filename:		SAYAC_MEM.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.900
--	History:
--	Date:			20 April 2021
--	Last Author: 	HANIEH
--  Copyright (C) 2021 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	Memory (MEM) of the SAYAC core                                 
--******************************************************************************

--LIBRARY IEEE;
--USE IEEE.std_logic_1164.ALL;
--USE IEEE.numeric_std.ALL;
--USE STD.TEXTIO.ALL;
--USE IEEE.STD_LOGIC_TEXTIO.ALL;
--	
--ENTITY MEM IS
--GENERIC(
--    BITS:INTEGER:=32
--);
--	PORT (
--		clk, rst, readMEM, writeMEM : IN STD_LOGIC;
--		addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--		addr2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--		writeData : IN STD_LOGIC_VECTOR(BITS-1 DOWNTO 0);
--		readData        : OUT STD_LOGIC_VECTOR(BITS-1 DOWNTO 0);
----		rwData          : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
--		readyMEM        : OUT STD_LOGIC
--	);
--END ENTITY MEM;
--
--ARCHITECTURE behaviour OF MEM IS
--	TYPE data_mem IS ARRAY (0 TO 256) OF STD_LOGIC_VECTOR(BITS-1 DOWNTO 0);
--	SIGNAL memory : data_mem;
--BEGIN
--	PROCESS (clk, rst)
--	BEGIN
--		IF rst = '1' THEN
--			FOR I IN 0 TO 256 LOOP
--				memory(I) <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, BITS));
--			END LOOP;
--		ELSIF clk = '1' AND clk'EVENT THEN
--			IF writeMem = '1' THEN
--				memory(TO_INTEGER(UNSIGNED(addr))) <= writeData;
----				memory(TO_INTEGER(UNSIGNED(addr))) <= rwData;
--				readyMEM <= '1';
--			END IF;
--			
--			IF readMEM = '1' THEN
--				readyMEM <= '1';
--			END IF;
--		END IF;
--	END PROCESS;
--
--    readData <= memory(TO_INTEGER(UNSIGNED(addr2))) WHEN readMEM = '1' ELSE
----    rwData <= memory(TO_INTEGER(UNSIGNED(addr))) WHEN readMEM = '1' ELSE
--			    (OTHERS => 'Z'); 
--END ARCHITECTURE behaviour;
