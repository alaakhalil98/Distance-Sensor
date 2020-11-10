library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
 
entity top_level is
    Port ( clk                           : in  STD_LOGIC;
           reset_n                       : in  STD_LOGIC;
		     SW                            : in  STD_LOGIC_VECTOR (9 downto 0);
		   --PB2							 : in std_logic; 
           LEDR                          : out STD_LOGIC_VECTOR (9 downto 0);
           HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 : out STD_LOGIC_VECTOR (7 downto 0)
          );
           
end top_level;

architecture Behavioral of top_level is

Signal Num_Hex0, Num_Hex1, Num_Hex2, Num_Hex3, Num_Hex4, Num_Hex5 : STD_LOGIC_VECTOR (3 downto 0):= (others=>'0');   
Signal Blank:  STD_LOGIC_VECTOR (5 downto 0);

Signal switch_inputs: STD_LOGIC_VECTOR (12 downto 0);



signal s:             STD_LOGIC_VECTOR(1 downto 0);
signal mux_out:       STD_LOGIC_VECTOR(15 DOWNTO 0);
signal in1:           STD_LOGIC_VECTOR(15 DOWNTO 0);

signal voltage      : STD_LOGIC_VECTOR (12 downto 0); -- Voltage in milli-volts
signal voltage_dec  : STD_LOGIC_VECTOR (15 downto 0);
signal distance : STD_LOGIC_VECTOR (12 downto 0); -- distance in 10^-4 cm (e.g. if distance = 33 cm, then 3300 is the value)
signal distance_dec : STD_LOGIC_VECTOR (15 downto 0);
signal ADC_raw  : STD_LOGIC_VECTOR (11 downto 0); -- the latest 12-bit ADC value
signal ADC_out  : STD_LOGIC_VECTOR (11 downto 0);  -- moving average of ADC value, over 256 samples,

-- NEW SIGNALS ADDED
signal SW_int:		  STD_LOGIC_VECTOR(9 downto 0);

-- ADDED COMPONENT DECLARATION
Component ADC_Data is
	port(
			 clk      : in STD_LOGIC;
	       reset_n  : in STD_LOGIC; -- active-low
			 voltage  : out STD_LOGIC_VECTOR (12 downto 0); -- Voltage in milli-volts
			 distance : out STD_LOGIC_VECTOR (12 downto 0); -- distance in 10^-4 cm (e.g. if distance = 33 cm, then 3300 is the value)
			 ADC_raw  : out STD_LOGIC_VECTOR (11 downto 0); -- the latest 12-bit ADC value
          ADC_out  : out STD_LOGIC_VECTOR (11 downto 0)  -- moving average of ADC value, over 256 samples,
         );   
End Component;

Component MUX4TO1 is
	port(
			in1     : in  std_logic_vector(15 downto 0);
			in2     : in  std_logic_vector(15 downto 0);
			in3	   : in  std_logic_vector(15 downto 0);
			in4	   : in  std_logic_vector(15 downto 0);
			s       : in  std_logic_vector(1 downto 0);
			mux_out : out std_logic_vector(15 downto 0)
         );   
End Component;

Component Synchronizer is
	port(
			
			SW_ext : in std_logic_vector (9 downto 0);
			clk	   : in std_logic;
			SW_int : out std_logic_vector (9 downto 0)
		);  
End Component;

Component SevenSegment is
	port( 	
				Blank                                             : in  STD_LOGIC_VECTOR (5 downto 0);
				s                                                     : in  STD_LOGIC_VECTOR (1 downto 0);
				Num_Hex0,Num_Hex1,Num_Hex2,Num_Hex3,Num_Hex4,Num_Hex5   : in  STD_LOGIC_VECTOR (3 downto 0);
				HEX0,HEX1,HEX2,HEX3,HEX4,HEX5                           : out STD_LOGIC_VECTOR (7 downto 0)
        );  
End Component;

Component binary_bcd is
	port(
      clk      :  IN    STD_LOGIC;                                
      reset_n  :  IN    STD_LOGIC;                                
      binary   :  IN    STD_LOGIC_VECTOR(12 DOWNTO 0);         
      bcd      :  OUT   STD_LOGIC_VECTOR(15 DOWNTO 0)  
         );   
End Component;
begin
	
   Num_Hex0 <= mux_out(3  downto  0); 
   Num_Hex1 <= mux_out(7  downto  4);
   Num_Hex2 <= mux_out(11 downto  8);
	Num_Hex3 <= mux_out(15 downto 12);
	Num_Hex4 <= "0000";
	Num_Hex5 <= "0000";   
   --DP_in    <= "000000"; -- position of the decimal point in the display (1=LED on,0=LED off)
   Blank    <= "110000"; -- blank the 2 MSB 7-segment displays (1=7-seg display off, 0=7-seg display on)

Synchronizer_ins: Synchronizer
	port map(
		SW_ext => SW,
		clk => clk,
		SW_int => SW_int
		);
		
ADC_Data_ins: ADC_Data
	port map(
		clk => clk,
		reset_n => reset_n,
		voltage => voltage,
		distance => distance,
		ADC_raw => ADC_raw,
		ADC_out => ADC_out
		);

Seven_seg_ins: SevenSegment
	port map(
		
		Blank => Blank,
		Num_Hex0 => Num_Hex0,
		Num_Hex1 => Num_Hex1,
		Num_Hex2 => Num_Hex2,
		Num_Hex3 => Num_Hex3,
		Num_Hex4 => Num_Hex4,
		Num_Hex5 => Num_Hex5,
		Hex0     => Hex0,
		Hex1     => Hex1,
		Hex2     => Hex2,
		Hex3     => Hex3,
		Hex4     => Hex4,
		Hex5     => Hex5,
		s        =>s
		);
		
-- debounce_ins: debounce
	-- PORT MAP(
		-- clk => clk,
		-- reset_n => reset_n,
		-- button => PB2,
		-- result => s				-- change once you know it's working
		-- );

MUX4TO1_ins: MUX4TO1                               
   PORT MAP(
      s        => s,                          
		mux_out  => mux_out,   
		in1      => in1,
		in2 	   => distance_dec,
		in3      => voltage_dec,
		in4	   => "0000" & ADC_out
      );	
                
        

LEDR(9 downto 0) <=SW_int(9 downto 0); -- gives visual display of the switch inputs to the LEDs on board
switch_inputs <= "00000" & SW_int(7 downto 0);
in1 <= "000" & switch_inputs(12 downto 0);
s <=SW_int(9 downto 8);

binary_bcd_ins: binary_bcd                               
   PORT MAP(
    clk      => clk,                          
    reset_n  => reset_n,                                 
    binary   => voltage,    
    bcd      => voltage_dec         
     );

binary_bcd_ins2: binary_bcd                               
   PORT MAP(
    clk      => clk,                          
    reset_n  => reset_n,                                 
    binary   => distance,    
     bcd      => distance_dec         
     );
		
end Behavioral;