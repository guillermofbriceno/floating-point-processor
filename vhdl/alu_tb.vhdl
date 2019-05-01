library ieee;
use ieee.std_logic_1164.all;

entity alu_tb is
end alu_tb;

architecture test of alu_tb is
	component alu
		port (
		A:	in	std_logic_vector(31 downto 0);
		B:	in	std_ulogic_vector(31 downto 0);
		func:	in	std_logic_vector(3 downto 0);
		outp:	out	std_logic_vector(31 downto 0);
		neg:	out	std_ulogic;
		zero: out std_ulogic
				 );
	end component;

	signal A, B, outp: std_logic_vector(31 downto 0);
	signal func: std_logic_vector(3 downto 0);
	signal neg: std_ulogic;
	signal zero: std_ulogic;

begin
	ALU1: alu port map(A => A, B => B, func => func, outp => outp, neg => neg, zero => zero);

	process begin
		B <= "01000000010010010000111111011011";
		func <= "1001";

		A <= "00111101111110111110011101101101";
	       	wait for 1 ns;

		A <= "10111101111110111110011101101101";
	       	wait for 1 ns;

		A <= "01000001001001000000000000000000";
		wait for 1 ns;

		A <= "11000001001001000000000000000000";
		wait for 1 ns;

		assert false report "Reached end of test";
		wait;

	end process;
end test;





