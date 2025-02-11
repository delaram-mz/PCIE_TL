
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY CPU_REQ_Decoder IS
    PORT (
            cnfg_type0    : IN STD_LOGIC;
            MMIO_flag     : IN STD_LOGIC; 
            eq            : IN STD_LOGIC; 
            less          : IN STD_LOGIC;  
            MemCnfg       : IN STD_LOGIC;
            Req_in        : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            HEADER_0      : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            mem           : OUT STD_LOGIC;
            io            : OUT STD_LOGIC;
            special       : OUT STD_LOGIC;
            rd            : OUT STD_LOGIC;
            wr            : OUT STD_LOGIC
    );
END ENTITY CPU_REQ_Decoder;

ARCHITECTURE CPU_REQ_Decoder_arc OF CPU_REQ_Decoder IS

	
    TYPE Request_type IS (Deferred_Reply,Rsvd_0,Interrupt_Acknowledge,Special_Transactions,Rsvd_1,
                          Banch_Trace_Message,Rsvd_2,Rsvd_3,IO_Read,IO_Write,Rsvd_4,MemRead_Invalidate,Rsvd_5,
                          MemCodeRead,MemDataRead,MemWrite,MemWriteBack,Dummy);
    SIGNAL Request : Request_type:=Rsvd_0; 
    SIGNAL HDR_0 : STD_LOGIC_VECTOR(31 DOWNTO 0):=(OTHERS => '0');
    SIGNAL cnfg_type : STD_LOGIC_VECTOR (4 DOWNTO 0);
BEGIN

    -- configuration Transaction Type
    cnfg_type <= "00100" WHEN ( cnfg_type0 = '1') ELSE "00101";

    PROCESS (Req_in)

     --   mem <='0';  io <='0';  specInterrupt_Acknowledgel <='0';
       -- rd <='0'; wr <='0';         
    BEGIN

        IF Req_in(9 DOWNTO 5) = "00000" THEN
            Request <= Deferred_Reply;
        ELSIF Req_in(9 DOWNTO 5) = "00001" THEN
            Request <= Rsvd_0;
        ELSIF Req_in (9 DOWNTO 5) = "01000" THEN
            IF Req_in (1 DOWNTO 0) = "00" THEN
                Request <= Interrupt_Acknowledge;
            ELSIF Req_in (1 DOWNTO 0) = "01" THEN
                Request <= Special_Transactions;
            ELSIF Req_in(1) = '1' THEN 
                Request <= Rsvd_1;
	    ELSE 
		Request <= Dummy;
            END IF;
        ELSIF Req_in (9 DOWNTO 5) = "01001" THEN 
            IF Req_in (1 DOWNTO 0) = "00" THEN
                Request <= Banch_Trace_Message;
            ELSIF Req_in (1 DOWNTO 0) = "01" THEN
                Request <= Rsvd_2;
            ELSIF Req_in(1) = '1' THEN 
                Request <= Rsvd_3;
	    ELSE
		Request <= Dummy;
            END IF;
        ELSIF Req_in (9 DOWNTO 5) = "10000" THEN
            Request <= IO_Read;
        ELSIF Req_in (9 DOWNTO 5) = "10001" THEN
            Request <= IO_Write;
        ELSIF Req_in (9 DOWNTO 6) = "1100" THEN
            Request <= Rsvd_4;
        ELSIF Req_in (7 DOWNTO 5) = "010" THEN
            Request <= MemRead_Invalidate;
        ELSIF Req_in (7 DOWNTO 5) = "011" THEN
            Request <= Rsvd_5;
        ELSIF Req_in (7 DOWNTO 5) = "100" THEN
            Request <= MemCodeRead;
        ELSIF Req_in (7 DOWNTO 5) = "110" THEN
            Request <= MemDataRead;
        ELSIF Req_in (7 DOWNTO 5) = "101" THEN
            Request <= MemWrite;
        ELSIF Req_in (7 DOWNTO 5) = "111" THEN
            Request <= MemWriteBack;
		  ELSE
				Request <= Dummy;
        END IF;
    END PROCESS;

    -- configuration Transaction Type
   -- cnfg_type <= "00100" WHEN ( cnfg_type0 = '1') ELSE "00101";

	PROCESS (Req_in,Request,eq,less,MMIO_flag,MemCnfg,cnfg_type) BEGIN
        
       HDR_0 <= (OTHERS =>'0');  mem <='0';  io <='0';  
       rd <='0';                 wr <='0';   special <='0';
	
	
		CASE Request IS 
           -------------Deffered Reply------------------
            WHEN Deferred_Reply=>               --assumed that all the messages are routed to root complex so type will be 10000
                HDR_0 (28 DOWNTO 24) <= "10000";
            WHEN Rsvd_0 => 
                HDR_0 <= (OTHERS =>'0');
            -------------Messeages Transactions--------------------
            WHEN Interrupt_Acknowledge =>        --Interrup Acknowledge is considered a message
                HDR_0 (28 DOWNTO 24) <= "10000"; --assumed that all the messages are routed to root complex so type will be 10000
                HDR_0 (31) <= '0'; 
                HDR_0 (29) <= '1'; 
            WHEN Special_Transactions =>         --assumed that all the messages are routed to root complex so type will be 10000
                special <= '1';
                HDR_0 <= (OTHERS =>'0');
            WHEN Rsvd_1 => 
                HDR_0 <= (OTHERS =>'0');
            WHEN Banch_Trace_Message =>             --assumed that all the messages are routed to root complex so type will be 10000
                HDR_0 (28 DOWNTO 24) <= "10000"; 
                HDR_0 (31) <= '0'; 
                HDR_0 (29) <= '1';                 
            WHEN Rsvd_2 => 
                HDR_0 <= (OTHERS =>'0');
            WHEN Rsvd_3 => 
                HDR_0 <= (OTHERS =>'0');
            --------------IO Transactions---------------
            WHEN IO_Read =>
                io <= '1';
                rd <= '1';
                IF (eq='1') THEN   -- Configue Read
                    HDR_0 (28 DOWNTO 24) <= cnfg_type;     --Type
                    HDR_0 (31 DOWNTO 29) <= "000";       --FMT
                ELSIF (eq='0') THEN
                     HDR_0 (28 DOWNTO 24) <= "00010";     --Type
                     HDR_0 (31 DOWNTO 29) <= "000";        --FMT
                ELSE 
                    HDR_0 (28 DOWNTO 24) <= (OTHERS =>'0');   
                    HDR_0 (31 DOWNTO 29) <= (OTHERS =>'0');     
                END IF;
            WHEN IO_Write =>
                io <= '1';
                wr <= '1';
                IF (eq='1') THEN   -- Configue Write
                    HDR_0 (28 DOWNTO 24) <= cnfg_type;     --Type
                    HDR_0 (31 DOWNTO 29) <= "010";       --FMT
                ELSIF (eq='0') THEN
                    HDR_0 (28 DOWNTO 24) <= "00010";     --Type
		            HDR_0 (31 DOWNTO 29) <= "010";       --FMT
                ELSE 
                    HDR_0 (28 DOWNTO 24) <= (OTHERS =>'0');   
                    HDR_0 (31 DOWNTO 29) <= (OTHERS =>'0');       
                END IF;                 
            WHEN Rsvd_4 =>
                HDR_0 <= (OTHERS =>'0');
            --------------Memory Transactions---------------
            WHEN MemRead_Invalidate =>               --  Memory Read and Invalidate is considered a simple memory read
		        mem <= '1';
                rd <= '1';
                IF (MemCnfg='1') THEN   -- Configue Type0 Read
                    HDR_0 (28 DOWNTO 24) <= "00100";     --Type
		            HDR_0 (31 DOWNTO 29) <= "000";       --FMT
                ELSIF (MMIO_flag='1') THEN -- MemIO READ
                    HDR_0 (28 DOWNTO 24) <= "00000";     --Type
		            HDR_0 (31 DOWNTO 29) <= "000";       --FMT
                ELSE 
                    HDR_0 (28 DOWNTO 24) <= (OTHERS =>'0');   
                    HDR_0 (31 DOWNTO 29) <= (OTHERS =>'0');       
                END IF; 
            WHEN Rsvd_5 =>
		        --HDR_0 (30 DOWNTO 29) <= "10";        -- with data
                 HDR_0 (31 DOWNTO 10) <= (OTHERS =>'0');
            WHEN MemCodeRead =>                      -- for simplification, memory code read is assumed as a simple memory read
                mem <= '1';
                rd <= '1';
                IF (MemCnfg='1') THEN   -- Configue Type0 Read
                    HDR_0 (28 DOWNTO 24) <= "00100";     --Type
		            HDR_0 (31 DOWNTO 29) <= "000";       --FMT
                ELSIF (MemCnfg='0') THEN -- MemIO READ
                    HDR_0 (28 DOWNTO 24) <= "00010";     --Type
		            HDR_0 (31 DOWNTO 29) <= "000";       --FMT
                ELSIF (less='1') THEN   -- Memory Read
                    HDR_0 (28 DOWNTO 24) <= "00000";     --Type
		            HDR_0 (31 DOWNTO 29) <= "000";       --FMT
                ELSE 
                    HDR_0 (28 DOWNTO 24) <= (OTHERS =>'0');   
                    HDR_0 (31 DOWNTO 29) <= (OTHERS =>'0');       
                END IF;  
            WHEN MemDataRead =>                      -- for simplification, memory data read is assumed as a simple memory read
                mem <= '1';
                rd <= '1';
                IF (MemCnfg='1') THEN   -- Configue Type0 Read
                    HDR_0 (28 DOWNTO 24) <= "00100";     --Type
		            HDR_0 (31 DOWNTO 29) <= "000";       --FMT
                ELSIF (MMIO_flag='1') THEN -- MemIO READ
                    HDR_0 (28 DOWNTO 24) <= "00000";     --Type
		            HDR_0 (31 DOWNTO 29) <= "000";       --FMT
                ELSE 
                    HDR_0 (28 DOWNTO 24) <= (OTHERS =>'0');   
                    HDR_0 (31 DOWNTO 29) <= (OTHERS =>'0');    
                END IF; 
            WHEN MemWrite =>
		        mem <= '1';
                wr <= '1';
                IF (MemCnfg='1') THEN   -- Configue Type0 Write
                    HDR_0 (28 DOWNTO 24) <= "00100";     --Type
		            HDR_0 (31 DOWNTO 29) <= "000";       --FMT
                ELSIF (MMIO_flag='1') THEN -- MemIO Write
                    HDR_0 (28 DOWNTO 24) <= "00000";     --Type
                    HDR_0 (31 DOWNTO 29) <= "010";       --FMT
                ELSE 
                    HDR_0 (28 DOWNTO 24) <= (OTHERS =>'0');   
                    HDR_0 (31 DOWNTO 29) <= (OTHERS =>'0');       
                END IF; 
            WHEN MemWriteBack =>
                mem <= '1';
                wr <= '1';
                IF (MemCnfg='1') THEN   -- Configue Type0 Write
                    HDR_0 (28 DOWNTO 24) <= "00100";     --Type
		            HDR_0 (31 DOWNTO 29) <= "000";       --FMT
                ELSIF (MMIO_flag='1') THEN -- MemIO Write
                    HDR_0 (28 DOWNTO 24) <= "00010";     --Type
                    HDR_0 (31 DOWNTO 29) <= "010";       --FMT
                ELSIF (less='1') THEN    -- Memory Write
                    HDR_0 (28 DOWNTO 24) <= "00000";     --Type
		            HDR_0 (31 DOWNTO 29) <= "010";       --FMT
                ELSE 
                    HDR_0 (28 DOWNTO 24) <= (OTHERS =>'0');   
                    HDR_0 (31 DOWNTO 29) <= (OTHERS =>'0');       
                END IF; 
            WHEN OTHERS =>
                HDR_0 <= (OTHERS =>'0');  mem <='0';  io <='0';  
                rd <='0';                 wr <='0';   special <='0';
            END CASE;

            IF (Request=IO_Read OR Request=IO_Write OR MemCnfg='1') THEN -- for IO and Configuration request
                HDR_0 (9 DOWNTO 0) <= "0000000001";
            ELSE
                CASE Req_in (1 DOWNTO 0) IS 
                    WHEN "00" => HDR_0 (9 DOWNTO 0) <= "0000000010"; -- 0-8 BYTES is assumed 8 bytes (2DW)
                    WHEN "01" => HDR_0 (9 DOWNTO 0) <= "0000000100";
                    WHEN "10" => HDR_0 (9 DOWNTO 0) <= "0000001000";
                    WHEN OTHERS => HDR_0 (9 DOWNTO 0) <= "0000000000"; --Reserved
                END CASE;
            END IF;
        END PROCESS;
        HEADER_0 <= HDR_0;
END ARCHITECTURE;

-- TC (traffic class field is assumed 0). Bits [6:4] of Byte 1.
-- TLP Digest field (including ECRC) isn't considered so TD value is set to zero. Bit 7 of Byte 2.
-- Error forwarding is not indicated in this design so EP bit is set to 0. Bit 6 of Byte 2.
-- Attributes is set to 00. This means device uses Default ordering and No Snoop is disabled. Bits [5:4] of Byte 2.
-- We assume Address Type (AT) is default and is set to 0. Bits [3:2] of Byte 2.
--                                              TESTBENCH

