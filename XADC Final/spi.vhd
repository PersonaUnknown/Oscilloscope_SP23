library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

ENTITY spi IS
    PORT (clk     : IN STD_LOGIC ;
          reset_l : IN STD_LOGIC ;
          sclk    : OUT STD_LOGIC ;
          mosi    : OUT STD_LOGIC ;
          ---miso : IN STD_LOGIC ;
          cs_l    : OUT STD_LOGIC ;
          d       : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0) ;
          a       : IN STD_LOGIC_VECTOR(1 DOWNTO 0) ;
          ce      : IN STD_LOGIC ;
          oe      : IN STD_LOGIC ;
          we      : IN STD_LOGIC) ;
    END spi ;

ARCHITECTURE rtl OF spi IS
   SIGNAL tx_counter     : STD_LOGIC_VECTOR(12 DOWNTO 0) ;
   SIGNAL tx_data_sav    : STD_LOGIC_VECTOR(7 DOWNTO 0) ;
   SIGNAL tx_busy        : STD_LOGIC ;
   SIGNAL tx_start       : STD_LOGIC ;
   SIGNAL tx_data        : STD_LOGIC_VECTOR(7 DOWNTO 0) ;
BEGIN

--- THIS IS THE SPI BUS INTERFACE
   d <= "0000000000000000000000000000000" & (tx_busy) WHEN (a = "00" AND oe = '1' AND ce = '1') ELSE "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" ;
   tx_start <= '1' WHEN (a = "01" AND ce = '1' AND we = '1') ELSE '0';
   tx_data <= d(7 DOWNTO 0) ;
   
--- THIS IS THE TRANSMITTER
   trans_counter:PROCESS(clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
        IF reset_l = '0' THEN
            sclk           <= '0' ;
            tx_busy        <= '0' ;
            tx_counter     <= "0000000000000" ;
            tx_data_sav    <= "00000000" ;
            cs_l           <= '1' ;
            mosi           <= '0' ;
        ELSIF (tx_busy = '0') THEN
            IF (tx_start = '1') THEN
               tx_busy     <= '1' ; 
               tx_counter  <= tx_counter + 1 ;
               tx_data_sav <= tx_data ;
               cs_l        <= '0' ;
               mosi        <= '0' ;
            END IF ;
        ELSE
            -- Increment counter
            tx_counter <= tx_counter + 1 ;
            
            -- First bit
            IF (tx_counter = 4) THEN
                mosi <= tx_data_sav(7) ;
            END IF ;
            IF (tx_counter = 7) THEN
                sclk <= '1' ;
            END IF ;
            IF (tx_counter = 10) THEN
                sclk <= '0' ;
            END IF ;
            
            -- Second bit
            IF (tx_counter = 13) THEN
                mosi <= tx_data_sav(6) ;
            END IF ;
            IF (tx_counter = 16) THEN
                sclk <= '1' ;
            END IF ;
            IF (tx_counter = 19) THEN
                sclk <= '0' ;
            END IF ;
            
            -- Third bit
            IF (tx_counter = 22) THEN
                mosi <= tx_data_sav(5) ;
            END IF ;
            IF (tx_counter = 25) THEN
                sclk <= '1' ;
            END IF ;
            IF (tx_counter = 28) THEN
                sclk <= '0' ;
            END IF ;
            
            -- Fourth bit
            IF (tx_counter = 31) THEN
                mosi <= tx_data_sav(4) ;
            END IF ;
            IF (tx_counter = 34) THEN
                sclk <= '1' ;
            END IF ;
            IF (tx_counter = 37) THEN
                sclk <= '0' ;
            END IF ;
            
            -- Fifth bit
            IF (tx_counter = 40) THEN
                mosi <= tx_data_sav(3) ;
            END IF ;
            IF (tx_counter = 43) THEN
                sclk <= '1' ;
            END IF ;
            IF (tx_counter = 46) THEN
                sclk <= '0' ;
            END IF ;
            
            -- Sixth bit
            IF (tx_counter = 49) THEN
                mosi <= tx_data_sav(2) ;
            END IF ;
            IF (tx_counter = 52) THEN
                sclk <= '1' ;
            END IF ;
            IF (tx_counter = 55) THEN
                sclk <= '0' ;
            END IF ;
            
            -- Seventh bit
            IF (tx_counter = 58) THEN
                mosi <= tx_data_sav(1) ;
            END IF ;
            IF (tx_counter = 61) THEN
                sclk <= '1' ;
            END IF ;
            IF (tx_counter = 64) THEN
                sclk <= '0' ;
            END IF ;
            
            -- Eighth bit
            IF (tx_counter = 67) THEN
                mosi <= tx_data_sav(0) ;
            END IF ;
            IF (tx_counter = 70) THEN
                sclk <= '1' ;
            END IF ;
            IF (tx_counter = 73) THEN
                sclk    <= '0' ;
            END IF ;
            IF (tx_counter = 76) THEN
                mosi    <= '0' ;
                cs_l    <= '1' ;
                tx_busy <= '0' ;
                tx_counter <= "0000000000000" ;
            END IF ;
         END IF ;
      END IF ;
   END process;
END rtl;
