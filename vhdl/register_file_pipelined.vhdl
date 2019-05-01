library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

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
	signal data : register_block_array := ( "00000000000000000000000000000000",
						"00000000000000000000000000000000",
						"00000000000000000000000000000000",
						"00000000000000000000000000000000",
						"00000000000000000000000000000000",
						"00000000000000000000000000000000",
						"00000000000000000000000000000000",
						"00000000000000000000000000000000",
						"00000000000000000000000000000000",
						"00000000000000000000000000000000",
						"00000000000000000000000000000000",
						"00000000000000000000000000000000",
						"00000000000000000000000000000000",
						"00000000000000000000000000000000",
						"00000000000000000000000000000000",
						"00000000000000000000000000000000");
	
	signal reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8, reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15 : std_logic_vector(31 downto 0);
begin

	rs1_out <= data(to_integer(unsigned(rs1_sel)));
	rs2_out <= data(to_integer(unsigned(rs2_sel)));

	reg_0  <= data(0);
	reg_1  <= data(1);
	reg_2  <= data(2);
	reg_3  <= data(3);
	reg_4  <= data(4);
	reg_5  <= data(5);
	reg_6  <= data(6);
	reg_7  <= data(7);
	reg_8  <= data(8);
	reg_9  <= data(9);
	reg_10 <= data(10);
	reg_11 <= data(11);
	reg_12 <= data(12);
	reg_13 <= data(13);
	reg_14 <= data(14);
	reg_15 <= data(15);

	write_process: process(clk_write) is
	begin
		if rising_edge(clk_write) then
			data(to_integer(unsigned(rd_sel))) <= value_in;
		end if;

	end process;
end behave;
