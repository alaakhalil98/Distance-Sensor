library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX4TO1 is
port ( in1     : in  std_logic_vector(15 downto 0);
       in2     : in  std_logic_vector(15 downto 0);
	   in3	   : in  std_logic_vector(15 downto 0);
	   in4	   : in  std_logic_vector(15 downto 0);
		--s0 :	in std_logic;
		--s1 : in std_logic;
       s       : in  std_logic_vector(1 downto 0);
       mux_out : out std_logic_vector(15 downto 0)
      );
end MUX4TO1;

architecture BEHAVIOR of MUX4TO1 is
begin

--	process(s1, s0)
--	begin
--
--		if (s1 = '0') and (s0 = '0') then
--			mux_out <= in1;
--		elsif (s1 = '0') and (s0 = '1') then
--			mux_out <= in2;
--		elsif (s1 = '1') and (s0 = '0') then
--			mux_out <= in3;
--		else
--			mux_out <= in4;
--		end if;
--
--	end process;

	with s select
		 mux_out <= in1 when "00", -- when s = 00 then mux_out becomes in1
						in2 when "01", -- when s = 01 then mux_out becomes in2
						in3 when "10", -- when s = 10 then mux_out becomes in3
						in4 when "11";	-- when s = 11 then mux_out becomes in4
					   
end BEHAVIOR; -- can also be written as "end;"
