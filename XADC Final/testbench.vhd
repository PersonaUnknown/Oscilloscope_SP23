--- 2021 RSRC new "RichARDUINO" VHDL Code for CMOD A7 
--- Current file name:  testbench.vhd
--- Last Revised:  1/8/2021; 12:34 p.m.
--- Author:  WDR
--- Copyright:  William D. Richard, Ph.D.

LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL ;
use IEEE.STD_LOGIC_UNSIGNED.ALL ;
USE IEEE.STD_LOGIC_ARITH.ALL ;

ENTITY testbench IS
   PORT(clk        : IN    STD_LOGIC ;
        reset_h    : IN    STD_LOGIC ;
        serial_in  : IN    STD_LOGIC ;
        serial_out : OUT   STD_LOGIC ;
        scl        : OUT   STD_LOGIC ;
        sda        : INOUT STD_LOGIC ;
        sclk       : OUT   STD_LOGIC ;
        cs_l       : OUT   STD_LOGIC ;
        mosi       : OUT   STD_LOGIC ;
        io         : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0) ;
        vauxn4     : IN    STD_LOGIC ;
        vauxp4     : IN    STD_LOGIC ;
        vauxn12    : IN    STD_LOGIC ;
        vauxp12    : IN    STD_LOGIC ;
        test       : OUT   STD_LOGIC );
END testbench ;

ARCHITECTURE structure OF testbench IS
  COMPONENT pins IS
  PORT (clk      : IN    STD_LOGIC ;
        reset_l  : IN    STD_LOGIC ;
        a        : IN    STD_lOGIC_VECTOR(1 DOWNTO 0) ;
        d        : INOUT STD_lOGIC_VECTOR(31 DOWNTO 0) ;
        ce       : IN    STD_LOGIC ;
        we       : IN    STD_LOGIC ;
        oe       : IN    STD_LOGIC ;
        io       : INOUT STD_lOGIC_VECTOR(31 DOWNTO 0));
   END COMPONENT ;

   COMPONENT uart IS
   PORT (clk          : IN      STD_LOGIC ;
        reset_l       : IN      STD_LOGIC ;
        serial_in     : IN      STD_LOGIC ;
        serial_out    : OUT     STD_LOGIC ;
        d             : INOUT   STD_LOGIC_VECTOR(31 DOWNTO 0) ;
        a             : IN      STD_LOGIC_VECTOR(1 DOWNTO 0) ;
        ce            : IN      STD_LOGIC ;
        oe            : IN      STD_LOGIC ;
        we            : IN      STD_LOGIC) ;
   END COMPONENT ;

   COMPONENT spi IS
   PORT (clk          : IN      STD_LOGIC ;
         reset_l      : IN      STD_LOGIC ;
         sclk         : OUT     STD_LOGIC ;
         mosi         : OUT     STD_LOGIC ;
         cs_l         : OUT     STD_LOGIC ;
         d            : INOUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
         a            : IN      STD_LOGIC_VECTOR(1 DOWNTO 0) ;
         ce           : IN      STD_LOGIC ;
         oe           : IN      STD_LOGIC ;
         we           : IN      STD_LOGIC) ;
   END COMPONENT; 

   COMPONENT i2c IS
   PORT (clk          : IN      STD_LOGIC ;
        reset_l       : IN      STD_LOGIC ;
        scl           : OUT     STD_LOGIC ;
        sda           : INOUT   STD_LOGIC ;
        d             : INOUT   STD_LOGIC_VECTOR(31 DOWNTO 0) ;
        a             : IN      STD_LOGIC_VECTOR(1 DOWNTO 0) ;
        ce            : IN      STD_LOGIC ;
        oe            : IN      STD_LOGIC ;
        we            : IN      STD_LOGIC) ;
   END COMPONENT ;

   COMPONENT xadc IS
   PORT (clk       : IN    STD_LOGIC ;
         reset_l   : IN    STD_LOGIC ;
         a         : IN    STD_LOGIC_VECTOR(6 DOWNTO 0) ;
         d         : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0) ;
         vauxn4    : IN    STD_LOGIC ;
         vauxp4    : IN    STD_LOGIC ;
         vauxn12   : IN    STD_LOGIC ;
         vauxp12   : IN    STD_LOGIC ;
         ce        : IN    STD_LOGIC ;
         oe        : IN    STD_LOGIC ;
         we        : IN    STD_LOGIC ;
         done      : OUT   STD_LOGIC);
   END COMPONENT ; 

   COMPONENT clk_wiz_0
   PORT (clk_out1 : OUT STD_LOGIC;
         clk_in1  : IN  STD_LOGIC);
   END COMPONENT ;

   COMPONENT rsrc
   PORT(clk      : IN    STD_LOGIC ;
        reset_l  : IN    STD_LOGIC ;
        d        : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0) ;
        address  : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0) ;
        read     : OUT   STD_LOGIC ;
        write    : OUT   STD_LOGIC ;
        done     : IN    STD_LOGIC) ;
   END COMPONENT ;

   COMPONENT eprom
      PORT(d        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) ;
           address  : IN  STD_LOGIC_VECTOR(9 DOWNTO 0) ;
           ce_l     : IN  STD_LOGIC ;
           oe_l     : IN  STD_LOGIC) ;
   END COMPONENT ;

   COMPONENT sram
      PORT (d        : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0) ;
            address  : IN    STD_LOGIC_VECTOR(9 DOWNTO 0) ;
            ce_l     : IN    STD_LOGIC ;
            oe_l     : IN    STD_LOGIC ;
            we_l     : IN    STD_LOGIC ;
            clk      : IN    STD_LOGIC) ;
   END COMPONENT ;           

   SIGNAL reset_l_temp : STD_LOGIC ;
   SIGNAL reset_l_sync : STD_LOGIC ;
   SIGNAL src_clk      : STD_LOGIC ;
   SIGNAL d            : STD_LOGIC_VECTOR(31 DOWNTO 0):= "00000000000000000000000000000000" ;
   SIGNAL address      : STD_LOGIC_VECTOR(31 DOWNTO 0):= "00000000000000000000000000000000" ;
   SIGNAL read         : STD_LOGIC;
   SIGNAL write        : STD_LOGIC;
   SIGNAL done         : STD_LOGIC;
   SIGNAL eprom_ce_l   : STD_LOGIC ;
   SIGNAL eprom_oe_l   : STD_LOGIC ;
   SIGNAL sram_ce_l    : STD_LOGIC ;
   SIGNAL sram_oe_l    : STD_LOGIC ;
   SIGNAL sram_we_l    : STD_LOGIC ;
   SIGNAL uart_ce      : STD_LOGIC ;
   SIGNAL uart_oe      : STD_LOGIC ;
   SIGNAL uart_we      : STD_LOGIC ;
   SIGNAL pins_ce      : STD_LOGIC ;
   SIGNAL pins_oe      : STD_LOGIC ;
   SIGNAL pins_we      : STD_LOGIC ; 
   SIGNAL spi_ce       : STD_LOGIC ;
   SIGNAL spi_oe       : STD_LOGIC ;
   SIGNAL spi_we       : STD_LOGIC ;
   SIGNAL i2c_ce       : STD_LOGIC ;
   SIGNAL i2c_oe       : STD_LOGIC ;
   SIGNAL i2c_we       : STD_LOGIC ;
   SIGNAL xadc_ce      : STD_LOGIC ;
   SIGNAL xadc_oe      : STD_LOGIC ;
   SIGNAL xadc_done    : STD_LOGIC ;
   
   -- Test Signal
   SIGNAL testcnt      : STD_LOGIC_VECTOR(14 DOWNTO 0) ;
BEGIN

  pins1:pins
  PORT MAP (clk      => src_clk ,
            reset_l  => reset_l_sync ,
            a        => address(3 DOWNTO 2) ,
            d        => d ,
            ce       => pins_ce ,
            we       => pins_we ,
            oe       => pins_oe ,
            io       => io) ;

   uart1:uart
   PORT MAP(clk           => src_clk ,
            reset_l       => reset_l_sync ,
            serial_in     => serial_in ,
            serial_out    => serial_out ,
            d             => d ,
            a             => address(3 DOWNTO 2) ,
            ce            => uart_ce ,
            oe            => uart_oe ,
            we            => uart_we) ;

   i2c1:i2c
   PORT MAP(clk           => src_clk ,
            reset_l       => reset_l_sync ,
            scl           => scl ,
            sda           => sda ,
            d             => d ,
            a             => address(3 DOWNTO 2) ,
            ce            => i2c_ce ,
            oe            => i2c_oe ,
            we            => i2c_we) ;

   spi1:spi
   PORT MAP(clk           => src_clk ,
            reset_l       => reset_l_sync ,
            sclk          => sclk ,
            mosi          => mosi ,
            cs_l          => cs_l ,
            d             => d ,
            a             => address(3 DOWNTO 2) ,
            ce            => spi_ce ,
            oe            => spi_oe ,
            we            => spi_we) ;

   xadc1:xadc
   PORT MAP(clk           => src_clk ,
            reset_l       => reset_l_sync ,
            a             => address(8 DOWNTO 2) ,
            d             => d ,
            vauxn4        => vauxn4 ,
            vauxp4        => vauxp4 ,
            vauxn12       => vauxn12 ,
            vauxp12       => vauxp12 ,
            ce            => xadc_ce ,
            oe            => xadc_oe ,
            we            => '0' , -- Not writing using XADC
            done          => xadc_done) ;

   mydcm1:clk_wiz_0
   PORT MAP(clk_out1 => src_clk ,
            clk_in1  => clk) ;

   syncprocess:PROCESS(src_clk)
   BEGIN
      IF (src_clk = '1' AND src_clk'event) THEN
         reset_l_temp <= NOT(reset_h) ;
         reset_l_sync <= reset_l_temp ;
      END IF;
   END PROCESS syncprocess ;

   eprom_ce_l <= '0' WHEN (address(31 DOWNTO 12) = "00000000000000000000" AND read = '1') ELSE '1' ;
   sram_ce_l  <= '0' WHEN (address(31 DOWNTO 12) = "00000000000000000001" AND (read = '1' OR write = '1')) ELSE '1' ;
   uart_ce    <= '1' WHEN (address(31 DOWNTO 4)  = "1111111111111111111111111110" AND (read = '1' OR write = '1')) ELSE '0' ;
   pins_ce    <= '1' WHEN (address(31 DOWNTO 4)  = "1111111111111111111111111111" AND (read = '1' OR write = '1')) ELSE '0' ;
   i2c_ce     <= '1' WHEN (address(31 DOWNTO 4)  = "1111111111111111111111111101" AND (read = '1' OR write = '1')) ELSE '0' ;
   spi_ce     <= '1' WHEN (address(31 DOWNTO 4)  = "1111111111111111111111111100" AND (read = '1' OR write = '1')) ELSE '0' ;
   xadc_ce    <= '1' WHEN (address(31 DOWNTO 9)  = "11111111111111111111110" AND (read = '1' OR write = '1')) ELSE '0' ;

   eprom_oe_l <= '0' WHEN read = '1' ELSE '1' ;
   sram_oe_l  <= '0' WHEN read = '1' ELSE '1' ;
   uart_oe    <= '1' WHEN read = '1' ELSE '0' ;
   pins_oe    <= '1' WHEN read = '1' ELSE '0' ;
   i2c_oe     <= '1' WHEN read = '1' ELSE '0' ;
   spi_oe     <= '1' WHEN read = '1' ELSE '0' ;
   xadc_oe    <= '1' WHEN read = '1' ELSE '0' ;
   
   sram_we_l  <= '0' WHEN write = '1' ELSE '1' ;
   uart_we    <= '1' WHEN write = '1' ELSE '0' ;
   pins_we    <= '1' WHEN write = '1' ELSE '0' ;
   i2c_we     <= '1' WHEN write = '1' ELSE '0' ;
   spi_we     <= '1' WHEN write = '1' ELSE '0' ;
   
   done <= '1' WHEN (eprom_ce_l = '0' OR sram_ce_l = '0' OR uart_ce = '1' OR pins_ce = '1' OR i2c_ce = '1' OR spi_ce = '1' OR xadc_done = '1') ELSE '0' ;

   rsrc1:rsrc      
   PORT MAP(clk       => src_clk,
            reset_l   => reset_l_sync,
            d         => d,
            address   => address,
            read      => read,
            write     => write,
            done      => done);

   eprom1:eprom    
      PORT MAP(d         => d,
               address   => address(11 DOWNTO 2),
               ce_l      => eprom_ce_l,
               oe_l      => eprom_oe_l);
 
   sram1:sram
      PORT MAP(d         => d,
               address   => address(11 DOWNTO 2),
               ce_l      => sram_ce_l,
               oe_l      => sram_oe_l,
               we_l      => sram_we_l,
               clk       => src_clk);

PROCESS(src_clk)
BEGIN
    IF (src_clk = '1' AND src_clk'event) THEN
        IF (reset_l_sync = '0') THEN
            testcnt <= "000000000000000" ;
        ELSE
            testcnt <= testcnt + 1 ;
        END IF ;
    END IF ;
END PROCESS ;
test <= testcnt(14) ;       
END structure;