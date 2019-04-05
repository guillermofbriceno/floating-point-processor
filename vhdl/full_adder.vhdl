library ieee;
use ieee.std_logic_1164.all;

entity full_adder is
	port(
	A:	in	std_ulogic;
	B:	in	std_ulogic;
	cin:	in	std_ulogic;
	sum:	out	std_ulogic;
	cout:	out	std_ulogic
	);
end full_adder;

architecture behave of full_adder is
	component half_adder is
		port(a, b: in std_logic;
				o, c: out std_logic
				); 
	end component;
	signal sum1, cout1, cout2: std_logic;
begin
	H1: half_adder port map (a => A, b => B, o => sum1, c => cout1);
	H2: half_adder port map (a => cin, b => sum1, o => sum, c => cout2);
	cout <= cout1 or cout2;
end behave;
