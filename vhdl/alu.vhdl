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
	zero: 	out 	std_ulogic
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

	signal sub_func: std_logic;
	signal fadd_out: std_logic_vector(31 downto 0);

	signal mux_out: std_logic_vector(31 downto 0);
begin
	M1: mux_16_to_1 port map (	in0  => out0, 
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
					o    => outp);

	process(A, B, func) 
		variable ceil_mask: std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
		variable zero_vec: std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
		variable exp_places: integer;

		variable exp_accumulated: float32;
	begin	

		out0  <= to_std_logic_vector(to_float(A) + to_float(B)); --not implemented (FADD)
		out1  <= to_std_logic_vector(to_float(A) - to_float(B)); --not implemented (FSUB)

		out2  <= to_std_logic_vector(to_float(A) * to_float(B));
		out3  <= to_std_logic_vector(to_float(A) / to_float(B));

		--out4  <= to_std_logic_vector(to_float(A) + to_float(B)); --not implemented (MIN)
		if to_float(A) > to_float(B) then
			out4 <= B;
			out5 <= A;
		else
			out4 <= A;
			out5 <= B;
		end if;
		
		--out5  <= to_std_logic_vector(to_float(A) + to_float(B)); --not implemented (MAX)
		out6  <= '1' & A(30 downto 0); --(NEG)

		--out8 (FLOOR)
		--out9 (CEIL)
		if (to_integer(unsigned(A(30 downto 23))) - 127) >= 0 then
			exp_places := 32 - (( to_integer(unsigned(A(30 downto 23))) - 127) + 9);
			ceil_mask(31 downto exp_places) := A(31 downto exp_places);
			if A(31) = '0' then
				out8 <= to_std_logic_vector(to_float(ceil_mask) + 1);
				out7 <= to_std_logic_vector(to_float(ceil_mask));
			else
				out7 <= to_std_logic_vector(to_float(ceil_mask) - 1);
				out8 <= to_std_logic_vector(to_float(ceil_mask));
			end if;
		else
			if A(31) = '0' then
				out8 <= "00000000000000000000000000000001";
				out7 <= zero_vec;
			else
				out8 <= zero_vec;
				out7 <= "10000000000000000000000000000001";
			end if;
		end if;


		out9 <= to_std_logic_vector(to_float(A) + to_float(B)); --not implemented (ROUND)


		out10 <= '0' & A(30 downto 0); --(ABS)
		out11 <= to_std_logic_vector(to_float(A) + to_float(B)); --not implemented (EXP)
		out12 <= to_std_logic_vector(sqrt(to_float(A)));
		out13  <= to_std_logic_vector(to_float(A) + to_float(B)); --not implemented (POW)
		--if to_integer(unsigned(B)) < 128 then
		--	if to_integer(unsigned(B)) = 0 then
		--		out13 <= to_std_logic_vector(0);
		--	else
		--		exp_accumulated := to_float(A);
		--		for i in o to to_integer(unsigned(B)) loop
		--			exp_accumulated := exp_accumulated * exp_accumulated;
		--		end loop;
		--		out13 <= to_std_logic_vector(exp_accumulated);
		--	end if;

		--end if;
		--for 
		
		out14 <= A;
		out15 <= B;

		if outp(30 downto 23) = "00000000" then
			zero <= '1';
		else
			zero <= '0';
		end if;
	end process;

	neg <= outp(31);
end behave;
