library ieee;
use ieee.std_logic_1164.all;

entity half_adder is
	port(
	a:	in	std_ulogic;
	b:	in	std_ulogic;
	o:	out	std_ulogic;
	c:	out	std_ulogic
			);
end half_adder;

architecture behave of half_adder is
begin
	o <= a xor b;
	c <= a and b;
end behave;
