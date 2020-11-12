library IEEE;

use IEEE.STD_LOGIC_1164.ALL;

USE ieee.numeric_std.all;

entity blank_edit is

port ( blank_in             : in  std_logic_vector(5 downto 0);
       value_in             : in  std_logic_vector(15 downto 0);
		 s                    : in  std_logic_vector(1 downto 0);
       blank_out            : out std_logic_vector(5 downto 0)
      );
end blank_edit;

architecture BEHAVIOR of blank_edit is
signal  leading_int : integer;


begin
leading_int <=  to_integer(unsigned(value_in));
  
  Process (leading_int,s,blank_in)
  begin  
		if (s = "10") then
			blank_out<=blank_in;
		else
			Case leading_int is                            
				when 0            => blank_out(5 downto 0)<="111110";
				when 1 to 15      => blank_out(5 downto 0)<="111110";
				when 16 to 255    => blank_out(5 downto 0)<="111100";
				when 256 to 4095  => blank_out(5 downto 0)<="111000";
				when others=> blank_out<=blank_in;
			end Case;
		end if;
end Process;				   
end BEHAVIOR; -- can also be written as "end;"