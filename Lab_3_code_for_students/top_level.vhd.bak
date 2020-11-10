library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
 
entity top_level is
    Port ( clk                           : in  STD_LOGIC;
           reset_n                       : in  STD_LOGIC;
		   SW                            : in  STD_LOGIC_VECTOR (9 downto 0);
		   --PB2							 : in std_logic; -- uncomment once the mux is tested
           LEDR                          : out STD_LOGIC_VECTOR (9 downto 0);
           HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 : out STD_LOGIC_VECTOR (7 downto 0)
          );
           
end top_level;

architecture Behavioral of top_level is

Signal Num_Hex0, Num_Hex1, Num_Hex2, Num_Hex3, Num_Hex4, Num_Hex5 : STD_LOGIC_VECTOR (3 downto 0):= (others=>'0');   
Signal DP_in, Blank:  STD_LOGIC_VECTOR (5 downto 0);
Signal switch_inputs: STD_LOGIC_VECTOR (12 downto 0);
Signal bcd:           STD_LOGIC_VECTOR(15 DOWNTO 0);

--- changed s, in3, in4 for mux
signal s:             STD_LOGIC_VECTOR(1 downto 0);
signal mux_out:       STD_LOGIC_VECTOR(15 DOWNTO 0);
signal in2:           STD_LOGIC_VECTOR(15 DOWNTO 0);

--uncomment once the mux is tested
--signal in3: 		  STD_LOGIC_VECTOR(15 DOWNTO 0); --:= "9999";
--signal in4: 		  STD_LOGIC_VECTOR(15 DOWNTO 0); --:= "5A5A";

-- NEW SIGNALS ADDED
signal SW_int:		  STD_LOGIC_VECTOR(9 downto 0);

-- ADDED COMPONENT DECLARATION
Component Synchronizer is
	port(
			SW_ext : in std_logic_vector (9 downto 0);
			clk    : in std_logic;
			SW_int : out std_logic_vector (9 downto 0)
			);
End Component;

-- Component debounce is
	-- GENERIC(
		-- clk_freq    : INTEGER := 50_000_000;
		-- stable_time : INTEGER := 30
		   -- );        
	  -- PORT(
		-- clk     : IN  STD_LOGIC;  --input clock
		-- reset_n : IN  STD_LOGIC;  --asynchronous active low reset
		-- button  : IN  STD_LOGIC;  --input signal to be debounced
		-- result  : OUT STD_LOGIC   --debounced signal
		  -- ); 
-- End Component;

Component SevenSegment is
    Port( Num_Hex0,Num_Hex1,Num_Hex2,Num_Hex3,Num_Hex4,Num_Hex5 : in  STD_LOGIC_VECTOR (3 downto 0);
          Hex0,Hex1,Hex2,Hex3,Hex4,Hex5                         : out STD_LOGIC_VECTOR (7 downto 0);
          DP_in,Blank                                           : in  STD_LOGIC_VECTOR (5 downto 0)
			);
End Component ;

Component MUX4TO1 is
    Port(
		 in1       : in  std_logic_vector(15 downto 0);
		 in2       : in  std_logic_vector(15 downto 0);
		 in3	   : in  std_logic_vector(15 downto 0);
		 in4	   : in  std_logic_vector(15 downto 0);
		 s         : in  std_logic_vector(1 downto 0);
		 mux_out   : out std_logic_vector(15 downto 0)
	    );
End Component ;

Component binary_bcd is
   port(
      clk     : IN  STD_LOGIC;                      --system clock
      reset_n : IN  STD_LOGIC;                      --active low asynchronus reset_n
      binary  : IN  STD_LOGIC_VECTOR(12 DOWNTO 0);  --binary number to convert
      bcd     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)   --resulting BCD number
		);           
END Component;

begin
   Num_Hex0 <= mux_out(3  downto  0); 
   Num_Hex1 <= mux_out(7  downto  4);
   Num_Hex2 <= mux_out(11 downto  8);
   Num_Hex3 <= mux_out(15 downto 12);
   Num_Hex4 <= "0000";
   Num_Hex5 <= "0000";   
   DP_in    <= "000000"; -- position of the decimal point in the display (1=LED on,0=LED off)
   Blank    <= "110000"; -- blank the 2 MSB 7-segment displays (1=7-seg display off, 0=7-seg display on)

Synchronizer_ins: Synchronizer
	port map(
		SW_ext => SW,
		clk => clk,
		SW_int => SW_int
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
	  in1      => bcd,
      in2      => in2,
	  in3 	   => "1111"&"1111"&"1111"&"1111",
	  in4	   => "0101"&"1010"&"0101"&"1010"
      );	
                
SevenSegment_ins: SevenSegment  
  PORT MAP( Num_Hex0 => Num_Hex0,
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
			DP_in    => DP_in,
					 Blank    => Blank
		  );
                         
-- is this much logic okay in top level?						 
LEDR(9 downto 0) <=SW_int(9 downto 0); -- gives visual display of the switch inputs to the LEDs on board
switch_inputs <= "00000" & SW_int(7 downto 0);
in2 <= "000" & switch_inputs(12 downto 0);
s <=SW_int(9 downto 8);

binary_bcd_ins: binary_bcd                               
   PORT MAP(
      clk      => clk,                          
      reset_n  => reset_n,                                 
      binary   => switch_inputs,    
      bcd      => bcd         
      );
		
end Behavioral;