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

begin
	data_out <= mem(to_integer(unsigned(addr)));

	store_data: process(store)
	begin
		mem(to_integer(unsigned(addr))) <= data_in;
	end process store_data;
end behave;
