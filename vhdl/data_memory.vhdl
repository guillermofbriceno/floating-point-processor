library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is
	port (
		addr: in std_logic_vector(31 downto 0);
		data_out: out std_logic_vector(31 downto 0);
		data_in: in std_logic_vector(31 downto 0);
		store: in std_logic
		);
end data_memory;

architecture behave of data_memory is
	type memory_array is array (0 to 1023) of std_logic_vector(31 downto 0);
	signal mem: memory_array;
	signal integer_address: std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal outp_address2: std_logic_vector(31 downto 0);
begin
	read_data: process(all)
	begin
		if to_integer(unsigned(integer_address)) < 1024 then
			data_out <= mem(to_integer(unsigned(integer_address)));
		else
			data_out <= "00000000000000000000000000000000";
		end if;
	end process;	

	conv_address: process(addr)
	begin
		--Converts the floating point address to an integer assuming it's non-negative, and has no fractional part
		integer_address(23 downto 0) <= std_logic_vector( unsigned('1' & addr(22 downto 0)) srl ( (127 - to_integer(unsigned(addr(30 downto 23)))) + 23  ));
	end process;	

	store_data: process(store)
	begin
		if falling_edge(store) then
			mem(to_integer(unsigned(integer_address))) <= data_in;
		end if;
	end process store_data;

	outp_address2 <= mem(2);
end behave;
