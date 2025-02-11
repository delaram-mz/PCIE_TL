LIBRARY IEEE;
	USE IEEE.STD_LOGIC_1164.ALL;

ENTITY BE_DECODE IS
    PORT (
        special_signal      :IN STD_LOGIC;
        BE_input            :IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        shutdown_out        :OUT STD_LOGIC
        );
END BE_DECODE ;
ARCHITECTURE ARCH OF BE_DECODE  IS

BEGIN
    PROCESS( BE_input, special_signal )
    BEGIN
        shutdown_out <= '0';
		    IF (special_signal='1') THEN
			    case (BE_input) IS
					WHEN "001" =>               -- Shutdown
						 shutdown_out <= '1';
					WHEN "010" =>               -- Flush
						 shutdown_out <= '0';    -- output signal must change
					WHEN "011" =>               -- Halt
						 shutdown_out <= '0';    -- output signal must change
					WHEN "100" =>              -- Sync
						 shutdown_out <= '0';    -- output signal must change     
					WHEN "101" =>               -- Flush Acknowledge
						 shutdown_out <= '0';    -- output signal must change
					WHEN "110" =>               -- Stop Garnt Acknowledge
						 shutdown_out <= '0';    -- output signal must change
					WHEN "111" =>               -- SMI Acknowledge
						 shutdown_out <= '0';    -- output signal must change
					WHEN OTHERS =>              -- Reserved
						 shutdown_out <= '0';    -- output signal must change
			    END CASE;
			ELSE
				shutdown_out <= '0';
			END IF;
    END PROCESS ;

END ARCHITECTURE;
