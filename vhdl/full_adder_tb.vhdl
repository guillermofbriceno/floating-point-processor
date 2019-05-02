library ieee;
use ieee.std_logic_1164.all;

entity full_adder_tb is
end full_adder_tb;

architecture test of full_adder_tb is
	component full_adder
		port (
		A:	in	std_ulogic;
		B:	in	std_ulogic;
		cin:	in	std_ulogic;
		sum:	out	std_ulogic;
		cout:	out	std_ulogic
				 );
	end component;

	signal A, B, cin, sum, cout : std_ulogic;

begin
	fulladder: full_adder port map(A => A, B => B, cin => cin, sum => sum, cout => cout);

	process begin
		A <= 'X';
		B <= 'X';
		cin <= 'X';
		wait for 1 ns;

		A <= '1';
		B <= '0';
		cin <= '0';
		wait for 1 ns;

		A <= '1';
		B <= '0';
		cin <= '0';
		wait for 1 ns;

		A <= '0';
		B <= '1';
		cin <= '0';
		wait for 1 ns;

		A <= '1';
		B <= '1';
		cin <= '0';
		wait for 1 ns;

		A <= '0';
		B <= '0';
		cin <= '1';
		wait for 1 ns;

		A <= '1';
		B <= '0';
		cin <= '1';
		wait for 1 ns;

		A <= '0';
		B <= '1';
		cin <= '1';
		wait for 1 ns;

		A <= '1';
		B <= '1';
		cin <= '1';
		wait for 1 ns;

		assert false report "Reached end of test";
		wait;

	end process;
end test;
