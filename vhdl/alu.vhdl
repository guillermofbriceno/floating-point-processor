library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.float_pkg.all;
use ieee.math_real.all;

entity alu is
	port(
	A:	in	std_logic_vector(31 downto 0);
	B:	in	std_logic_vector(31 downto 0);
	func:	in	std_logic_vector(3 downto 0);
	outp:	out	std_logic_vector(31 downto 0);
	neg:	out	std_ulogic;
	zero: out std_ulogic
	);
end alu;

architecture behave of alu is
	component mux_16_to_1 is
		port(
			in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15:	in	std_logic_vector(31 downto 0);
			sel:	in	std_logic_vector(3 downto 0);
			o:		out	std_logic_vector(31 downto 0)
			);
	end component;

	signal out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15: std_logic_vector(31 downto 0);

	signal mux_out: std_logic_vector(31 downto 0);
begin
	M1: mux_16_to_1 port map (in0  => out0, 
														in1  => out1,
														in2  => out2,
														in3  => out3,
														in4  => out4,
														in5  => out5,
														in6  => out6,
														in7  => out7,
														in8  => out8,
														in9  => out9,
														in10 => out10,
														in11 => out11,
														in12 => out12,
														in13 => out13,
														in14 => out14,
														in15 => out15,
														sel  => func,
														o 	 => outp);
	process(A, B, func) begin	

		out0  <= to_std_logic_vector(to_float(A) + to_float(B)); --not implemented (FADD)
		out1  <= to_std_logic_vector(to_float(A) - to_float(B)); --not implemented (FSUB)
		out2  <= to_std_logic_vector(to_float(A) * to_float(B)); --not implemented (FMULT)
		out3  <= to_std_logic_vector(to_float(A) / to_float(B)); --not implemented (FDIV)
		out4  <= to_std_logic_vector(to_float(A) + to_float(B)); --not implemented (MIN)
		out5  <= to_std_logic_vector(to_float(A) + to_float(B)); --not implemented (MAX)
		out6  <= to_std_logic_vector(to_float(A) + to_float(B)); --not implemented (POW)
		out7  <= to_std_logic_vector(to_float(A) + to_float(B)); --not implemented (NEG)
		out8  <= to_std_logic_vector(to_float(A) + to_float(B)); --not implemented (FLOOR)
		out9  <= to_std_logic_vector(to_float(A) + to_float(B)); --not implemented (CEIL)
		out10 <= to_std_logic_vector(to_float(A) + to_float(B)); --not implemented (ROUND)
		out11 <= to_std_logic_vector(to_float(A) + to_float(B)); --not implemented (ABS)
		out12 <= to_std_logic_vector(to_float(A) + to_float(B)); --not implemented (EXP)
		out13 <= to_std_logic_vector(to_float(A) + to_float(B)); --not implemented (SQRT)
		out14 <= A; --not implemented (PASS A)
		out15 <= B; --not implemented (PASS B)

		if outp(31) = '1' then
			neg <= '1';
		elsif outp(31) = '0' then
			neg <= '0';
		else
			neg <= 'X';
		end if;

		zero <= 'X';
	end process;
end behave;
