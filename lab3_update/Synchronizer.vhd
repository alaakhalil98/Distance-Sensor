library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Synchronizer is
	port(
		SW_ext : in std_logic_vector (9 downto 0);
		clk	 : in std_logic;
		RST    : in std_logic;
		SW_int : out std_logic_vector (9 downto 0)
		);
end Synchronizer;

architecture BEHAVIOUR of Synchronizer is

signal E : std_logic_vector (9 downto 0);

begin
	process (clk, RST)
	begin
		if (RST = '0') then
			SW_int <= "0000"&"0000"&"00";
		elsif rising_edge(clk) then
			E <= SW_ext;
			SW_int <= E;
		end if;
	end process;
	
end BEHAVIOUR;