library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

ENTITY xadc IS
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
  END xadc ;
  
ARCHITECTURE rtl OF xadc IS

    COMPONENT xadc_wiz_0
    PORT(daddr_in        : IN   STD_LOGIC_VECTOR (6 DOWNTO 0) ;     
         den_in          : IN   STD_LOGIC ;                        
         di_in           : IN   STD_LOGIC_VECTOR (15 DOWNTO 0) ;    
         dwe_in          : IN   STD_LOGIC ;                         
         do_out          : OUT  STD_LOGIC_VECTOR (15 DOWNTO 0) ;   
         drdy_out        : OUT  STD_LOGIC ;                       
         dclk_in         : IN   STD_LOGIC ;                     
         reset_in        : IN   STD_LOGIC ;                     
         vauxp4          : IN   STD_LOGIC ;                        
         vauxn4          : IN   STD_LOGIC ;
         vauxp12         : IN   STD_LOGIC ;                        
         vauxn12         : IN   STD_LOGIC ;
         busy_out        : OUT  STD_LOGIC ;                     
         channel_out     : OUT  STD_LOGIC_VECTOR (4 DOWNTO 0) ;    
         eoc_out         : OUT  STD_LOGIC ;                       
         eos_out         : OUT  STD_LOGIC ;                      
         alarm_out       : OUT  STD_LOGIC ;                      
         vp_in           : IN   STD_LOGIC ;                
         vn_in           : IN   STD_LOGIC );
    END COMPONENT ;
    
    SIGNAL den           : STD_LOGIC ;
    SIGNAL do_out        : STD_LOGIC_VECTOR (15 DOWNTO 0) ;
    SIGNAL drdy_out      : STD_LOGIC ;
    SIGNAL busy_out      : STD_LOGIC ;
    SIGNAL alarm_out     : STD_LOGIC ; 
    SIGNAL channel_out   : STD_LOGIC_VECTOR (4 DOWNTO 0) ;
    SIGNAL eoc_out       : STD_LOGIC ;
    SIGNAL eos_out       : STD_LOGIC ;
    SIGNAL vp_in         : STD_LOGIC := '0' ;
    SIGNAL vn_in         : STD_LOGIC := '0' ;
    SIGNAL tri_state     : STD_LOGIC ; 
    SIGNAL reset_in      : STD_LOGIC ;
    
    TYPE states IS (s0, s1) ;
    SIGNAL state     : states ;
    SIGNAL nxt_state : states ;
 
 BEGIN
    myxadcwiz:xadc_wiz_0
    PORT MAP(daddr_in        => a ,                    
             den_in          => den ,                   
             di_in           => "0000000000000000" ,   
             dwe_in          => we ,                 
             do_out          => do_out ,                    
             drdy_out        => drdy_out ,      
             dclk_in         => clk ,                 
             reset_in        => reset_in ,              
             vauxp4          => vauxp4 ,               
             vauxn4          => vauxn4 , 
             vauxp12         => vauxp12 ,             
             vauxn12         => vauxn12 , 
             busy_out        => busy_out ,                    
             channel_out     => channel_out ,                    
             eoc_out         => eoc_out ,                      
             eos_out         => eos_out ,                     
             alarm_out       => alarm_out ,     
             vp_in           => vp_in ,  
             vn_in           => vn_in );   

    d <= busy_out & "000000000000000" & do_out WHEN (tri_state = '1') ELSE (OTHERS => 'Z') ;

    clkd: PROCESS (clk)
    BEGIN
        IF (clk'EVENT AND clk = '1') THEN
            IF (reset_l = '0') THEN
                state <= s0 ;
                reset_in <= '0' ;
            ELSE
                state <= nxt_state ;
            END IF ;
        END IF ;
    END PROCESS clkd ;
    
    state_trans: PROCESS(state, ce, oe, drdy_out)
    BEGIN
        nxt_state <= state ;
        CASE state IS 
            WHEN s0 =>
                IF (ce = '1' AND oe = '1') THEN
                    nxt_state <= s1 ;
                END IF ;
            WHEN s1 =>
                IF (drdy_out = '1') THEN
                    nxt_state <= s0 ;
                END IF ;
        END CASE ;
    END PROCESS state_trans ;
    
    output: PROCESS(state, ce, oe, drdy_out)
    BEGIN
        den <= '0' ;
        tri_state <= '0' ;
        done <= '0' ;
        CASE state IS 
            WHEN s0 => 
                IF (ce = '1' AND oe = '1') THEN
                    den <= '1' ;
                END IF ;
            WHEN s1 => 
                IF (drdy_out = '1') THEN 
                    tri_state <= '1' ;
                    done <= '1' ;
                END IF ;
        END CASE ;
    END PROCESS output ;
END rtl;
