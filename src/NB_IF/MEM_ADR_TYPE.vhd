library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity MEM_ADR_TYPE is
Port ( 	  
	adr_in                  : IN STD_LOGIC_VECTOR (31 downto 0);
	data_in0                : IN STD_LOGIC_VECTOR (31 downto 0);
	data_in1                : IN STD_LOGIC_VECTOR (31 downto 0);
	data_in2                : IN STD_LOGIC_VECTOR (31 downto 0);
	data_in3                : IN STD_LOGIC_VECTOR (31 downto 0);
	data_in4                : IN STD_LOGIC_VECTOR (31 downto 0);
    CF8_flag_out            : OUT STD_LOGIC;
    CFC_flag_out            : OUT STD_LOGIC;
    MMIO_flag_out           : OUT STD_LOGIC;
    DRAM_flag_out           : OUT STD_LOGIC;
    CnfgSpace_flag_out      : OUT STD_LOGIC
	);
end MEM_ADR_TYPE;

architecture Behavioral of MEM_ADR_TYPE is
    signal DRAM_flag    : STD_LOGIC;
    signal CF8_flag     : STD_LOGIC;
    signal CFC_flag     : STD_LOGIC;
	signal COMP2_lt     : STD_LOGIC;
	signal COMP3_lt     : STD_LOGIC;
	signal COMP3_gt     : STD_LOGIC;
	signal COMP4_gt     : STD_LOGIC;

begin

    -- COMP0
    COMP0: entity work.comparator	
    GENERIC MAP( BITS => 32 )
    PORT MAP(
        in1         => adr_in,
        in2         => data_in0,
        bg          => open,
        eq          => CF8_flag,
        ls          => open
    );

    -- COMP1
    COMP1: entity work.comparator	
    GENERIC MAP( BITS => 32 )
    PORT MAP(
        in1         => adr_in,
        in2         => data_in1,
        bg          => open,
        eq          => CFC_flag,
        ls          => open
    );

    -- COMP2
    COMP2: entity work.comparator	
    GENERIC MAP( BITS => 32 )
    PORT MAP(
        in1         => adr_in,
        in2         => data_in2,
        bg          => DRAM_flag,
        eq          => open,
        ls          => COMP2_lt
    );

    -- COMP3
    COMP3: entity work.comparator	
    GENERIC MAP( BITS => 32 )
    PORT MAP(
        in1         => adr_in,
        in2         => data_in3,
        bg          => COMP3_gt,
        eq          => open,
        ls          => COMP3_lt
    );

    -- COMP4
    COMP4: entity work.comparator	
    GENERIC MAP( BITS => 32 )
    PORT MAP(
        in1         => adr_in,
        in2         => data_in4,
        bg          => COMP4_gt,
        eq          => open,
        ls          => open
    );


    CF8_flag_out            <= CF8_flag;
    CFC_flag_out            <= CFC_flag;
    DRAM_flag_out           <= DRAM_flag when (CF8_flag='0' and CFC_flag='0' ) else '0';
    MMIO_flag_out           <= COMP2_lt and COMP3_gt when (CF8_flag='0' and CFC_flag='0' ) else '0';
    CnfgSpace_flag_out      <= COMP3_lt and COMP4_gt when (CF8_flag='0' and CFC_flag='0' ) else '0';

end Behavioral;

