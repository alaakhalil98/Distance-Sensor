library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
 
entity top_level is
    Port ( clk                           : in  STD_LOGIC;
           reset_n                       : in  STD_LOGIC;
		     SW                            : in  STD_LOGIC_VECTOR (9 downto 0);
		     PB2							        : in std_logic; 
           LEDR                          : out STD_LOGIC_VECTOR (9 downto 0);
           HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 : out STD_LOGIC_VECTOR (7 downto 0)
          );
           
end top_level;

architecture Behavioral of top_level is

Signal Num_Hex0, Num_Hex1, Num_Hex2, Num_Hex3, Num_Hex4, Num_Hex5 : STD_LOGIC_VECTOR (3 downto 0):= (others=>'0');   
Signal Blank,Blank_out:  STD_LOGIC_VECTOR (5 downto 0);

Signal DP_in0, DP_in1, DP_in2, DP_in3:  STD_LOGIC_VECTOR (5 downto 0);
Signal DP_in: STD_LOGIC_VECTOR(15 DOWNTO 0);

Signal switch_inputs: STD_LOGIC_VECTOR (12 downto 0);



signal s:             STD_LOGIC_VECTOR(1 downto 0);
signal mux_out:       STD_LOGIC_VECTOR(15 DOWNTO 0);
signal in1:           STD_LOGIC_VECTOR(15 DOWNTO 0);
signal DFF_out:       STD_LOGIC_VECTOR(15 DOWNTO 0);

signal EN:            STD_LOGIC;


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
			RST	   : in std_logic;
			SW_int : out std_logic_vector (9 downto 0)
		);  
End Component;

Component SevenSegment is
	port( 	
				Blank, DP_in                                             : in  STD_LOGIC_VECTOR (5 downto 0);
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

Component blank_edit is
	port(
      blank_in       :  IN    STD_LOGIC_VECTOR(5 DOWNTO 0);
		s              :  IN  std_logic_vector(1 downto 0);
		reset_n	      :  IN std_logic;
      value_in       :  IN     STD_LOGIC_VECTOR(15 DOWNTO 0);                
      blank_out      :  OUT   STD_LOGIC_VECTOR(5 DOWNTO 0)       
         );   
End Component;

Component debounce is
	Generic(
		clk_freq    : INTEGER := 50_000_000;
		stable_time : INTEGER := 30					 -- set to 30ms for the required stable threshold time
		   );        
	Port(
		clk     : IN  STD_LOGIC; 
		reset_n : IN  STD_LOGIC;
		button  : IN  STD_LOGIC;
		result  : OUT STD_LOGIC
		); 
End Component;

Component DFF_EN is
	Port(
		D			    : in std_logic_vector (15 downto 0);
		RST, EN, clk : in std_logic;
		Q			    : out std_logic_vector (15 downto 0)
		);
End Component;

begin
	
   Num_Hex0 <= DFF_out(3  downto  0); 
   Num_Hex1 <= DFF_out(7  downto  4);
   Num_Hex2 <= DFF_out(11 downto  8);
	Num_Hex3 <= DFF_out(15 downto 12);
	Num_Hex4 <= "0000";
	Num_Hex5 <= "0000";   
 
   Blank     <= "110000"; -- blank the 2 MSB 7-segment displays (1=7-seg display off, 0=7-seg display on)
	
	DP_in0    <= "000000";
	DP_in1    <= "000100";
	DP_in2    <= "001000";
	DP_in3    <= "000000";
	
Synchronizer_ins: Synchronizer
	port map(
		SW_ext => SW,
		clk => clk,
		RST=>reset_n,
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
		
		Blank => Blank_out,
		DP_in => DP_in(5 DOWNTO 0),
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
		Hex5     => Hex5
	
		);
		
debounce_ins: debounce
	generic map (clk_freq   => 50_000_000,
	            stable_time   => 30
					 )
	PORT MAP(
		clk     => clk,
		reset_n => reset_n,
		button  => PB2,
		result  => EN -- connects to EN signal of DFF_EN
		);

DFF_EN_ins: DFF_EN
	PORT MAP(
		D   => mux_out, -- when enabled, DFF will output the currently displayed value
		RST => reset_n,
		EN  => not EN, --when the button is pressed, we freeze the displayed value
		clk => clk,
		Q   => DFF_out
		);
		
blank_edit_ins:blank_edit
	PORT MAP(
		Blank_in   => Blank,
		s          => s,
		reset_n    => reset_n,
		value_in   => DFF_out,
		blank_out  => blank_out 
		);
		
MUX4TO1_ins: MUX4TO1                               
   PORT MAP(
      s        => s,                          
		mux_out  => mux_out,   
		in1      => in1,
		in2 	   => distance_dec,
		in3      => voltage_dec,
		in4	   => "0000" & ADC_out
      );	
                
MUX4TO1_ins2: MUX4TO1
	PORT MAP(
		s        => s,                          
		mux_out  => DP_in,   
		in1      => "0000"&"0000"&"00"& DP_in0,
		in2 	   => "0000"&"0000"&"00"& DP_in1,
		in3      => "0000"&"0000"&"00"& DP_in2,
		in4	   => "0000"&"0000"&"00"& DP_in3
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