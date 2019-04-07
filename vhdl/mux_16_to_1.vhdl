library ieee;
use ieee.std_logic_1164.all;

entity mux_16_to_1 is
	port(in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15:	in	std_logic_vector(31 downto 0);
	sel:	in	std_logic_vector(3 downto 0);
	o:	out	std_logic_vector(31 downto 0)
	);
end mux_16_to_1;

architecture behave of mux_16_to_1 is
begin
process(all) is begin
		case sel is
			when "0000" => o <= in0;
			when "0001" => o <= in1;
			when "0010" => o <= in2;
			when "0011" => o <= in3;
			when "0100" => o <= in4;
			when "0101" => o <= in5;
			when "0110" => o <= in6;
			when "0111" => o <= in7;
			when "1000" => o <= in8;
			when "1001" => o <= in9;
			when "1010" => o <= in10;
			when "1011" => o <= in11;
			when "1100" => o <= in12;
			when "1101" => o <= in13;
			when "1110" => o <= in14;
			when "1111" => o <= in15;
			when others => o <= (others => 'X');
		end case;
	end process;
end behave;

