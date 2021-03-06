library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity computer is
	port(
	clock: 	in  	std_logic
);
end computer;

architecture behave of computer is
	component instruction_memory
		port(
			addr: in std_logic_vector(9 downto 0);
			inst: out std_logic_vector(31 downto 0);
			set_value: out std_logic_vector(31 downto 0)
		);
	end component instruction_memory;

	component data_memory
		port(
			addr	: in std_logic_vector(31 downto 0);
			data_out: out std_logic_vector(31 downto 0);
			data_in	: in std_logic_vector(31 downto 0);
			store	: in std_logic

		    );
	end component data_memory;

	component cpu
		port(
			out_mem_data:	out	std_logic_vector(31 downto 0);
			in_mem_data:	in	std_logic_vector(31 downto 0);
			mem_addr:	out	std_logic_vector(31 downto 0);
			instruction:	in	std_logic_vector(31 downto 0);
			pc:		out	std_logic_vector(9  downto 0);
			write_mem: 	out  	std_ulogic;
			clk: 		in  	std_ulogic;
			set_value_in:	in	std_logic_vector(31 downto 0) --this is not a hardware implementation, only for the SET inst.
		    );
	end component cpu;

	signal pc_address_bus: 		std_logic_vector(9 downto 0);
	signal instruction_bus:		std_logic_vector(31 downto 0);
	signal set_value_bus: 		std_logic_vector(31 downto 0);  --for SET

	signal data_memory_address: 	std_logic_vector(31 downto 0);
	signal data_from_mem: 		std_logic_vector(31 downto 0);
	signal data_from_cpu: 		std_logic_vector(31 downto 0);
	signal data_store_bit: 		std_logic;

begin
	im: instruction_memory port map
	(
		addr 			=> pc_address_bus,
		inst 			=> instruction_bus,
		set_value 		=> set_value_bus
	);

	dm: data_memory port map
	(
		addr 		=> data_memory_address,
		data_out 	=> data_from_mem,
		data_in 	=> data_from_cpu,
		store 		=> data_store_bit
	);

	fpu: cpu port map
	(
		out_mem_data 	=> data_from_cpu,
		in_mem_data 	=> data_from_mem,
		mem_addr 	=> data_memory_address,
		instruction	=> instruction_bus,
		pc 		=> pc_address_bus,
		write_mem 	=> data_store_bit,
		clk 		=> clock,	
		set_value_in 	=> set_value_bus
	);
end behave;
