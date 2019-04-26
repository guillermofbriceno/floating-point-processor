library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
	port(
	rs1_sel:	in	std_logic_vector(3 downto 0);
	rs2_sel:	in	std_logic_vector(3 downto 0);
	rd_sel:		in	std_logic_vector(3 downto 0);
	value_in:	in	std_logic_vector(31 downto 0);
	rs1_out:	out	std_logic_vector(31 downto 0);
	rs2_out:	out	std_logic_vector(31 downto 0);
	clk_write: 	in std_ulogic
);
end register_file;

architecture behave of register_file is
	type register_block_array is array(0 to 15) of std_logic_vector(31 downto 0);
	signal data : register_block_array;
begin

	rs1_out <= data(to_integer(unsigned(rs1_sel)));
	rs2_out <= data(to_integer(unsigned(rs2_sel)));

	write_process: process(clk_write) is
	begin
		if rising_edge(clk_write) then
			data(to_integer(unsigned(rd_sel))) <= value_in;
		end if;
	end process;
end behave;
