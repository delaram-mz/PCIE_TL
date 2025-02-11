LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY DOWN_CNT IS
    GENERIC(inputbit:INTEGER:=4);
    port (
        clk                 :IN STD_LOGIC;
        rst                 :IN STD_LOGIC;
        cnt_en              :IN STD_LOGIC;
        ld_len_cnt          :IN STD_LOGIC;
        cnt_input           :IN STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0);
        co_len              :OUT STD_LOGIC
        );
END DOWN_CNT ;
ARCHITECTURE ARCH OF DOWN_CNT  IS
    SIGNAL oup:STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0);
BEGIN
    identifier : PROCESS( clk,rst )
    BEGIN
        IF(rst='1') THEN
            oup<=(OTHERS=>'0');
        ELSIF rising_edge(clk) THEN 
            IF(ld_len_cnt='1') THEN
                oup<=cnt_input;
            ELSIF (cnt_en='1' and oup /= "0000" ) THEN
                oup<=oup-1;
            END IF;
        END IF;
    END PROCESS ;
    co_len<= '1' WHEN (oup = "0000") ELSE '0';
END ARCHITECTURE;
