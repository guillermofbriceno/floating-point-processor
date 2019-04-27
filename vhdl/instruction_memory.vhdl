library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

entity instruction_memory is
	port (
	addr: in std_logic_vector(9 downto 0);
	inst: out std_logic_vector(31 downto 0)
	next_inst_from_mem: out std_logic_vector(31 downto 0)
	     );
end instruction_memory;

architecture behave of instruction_memory is
	type memory_array is array (0 to 1023) of std_logic_vector(31 downto 0);
	impure function init_memory (mem_file_name : in string) return memory_array is
		file instruction_file: text is in mem_file_name;
		variable instruction: line;
		variable mem: memory_array;
	begin
		for i in memory_array'range loop
			readline(instruction_file, instruction);
			hread(instruction, mem(i));
		end loop;
		return mem;
	end function;

	signal mem: memory_array := init_memory("program.data");
begin
	inst <= mem(to_integer(unsigned(addr)));
	next_inst_from_mem(to_integer(unsigned(addr)) + 1);
end behave;
