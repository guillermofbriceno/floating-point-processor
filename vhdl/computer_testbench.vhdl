library ieee;
use ieee.std_logic_1164.all;

entity computer_testbench is
end computer_testbench;

architecture test of computer_testbench is
	component computer
		port (
		clock:	in	std_logic
	);
	end component computer;

	signal clk: std_logic;

begin
	fp_cpu: computer port map(
		clock => clk
	);
	process begin

		clk <= '0';
		for i in 0 to 100 loop
			wait for 1 ns;
			clk <= '1';
			wait for 1 ns;
			clk <='0';
		end loop;

		assert false report "Reached end of test";
		wait;

	end process;
end test;





