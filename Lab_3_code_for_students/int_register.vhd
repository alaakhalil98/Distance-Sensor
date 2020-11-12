library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity INT_REG is
	port(
			D			    : in integer;
			RST, EN, clk : in std_logic;
			Q			    : out integer
		);
end INT_REG;

architecture BEHAVIOUR of INT_REG is
begin
	process (clk, RST)
	begin
		if (RST = '0') then
			Q <= 0;
		elsif rising_edge(clk) then
			if (EN = '0') then
				Q <= D;
			end if;
		end if;
	end process;
end BEHAVIOUR;