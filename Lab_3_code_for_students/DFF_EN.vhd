library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DFF_EN is
	port(
			D			 : in std_logic_vector (15 downto 0);
			RST, EN, clk : in std_logic;
			Q			 : out std_logic_vector (15 downto 0)
		);
end DFF_EN;

architecture BEHAVIOUR of DFF_EN is
begin
	process (clk, RST)
	begin
		if (RST = '0') then
			Q <= "0000"&"0000"&"0000"&"0000";
		elsif rising_edge(clk) then
			if (EN = '0') then
				Q <= D;
			end if;
		end if;
	end process;
end BEHAVIOUR;