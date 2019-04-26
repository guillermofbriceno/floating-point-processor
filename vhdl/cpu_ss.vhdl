library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
	port(
	out_mem_data:	out	std_logic_vector(31 downto 0);
	in_mem_data:	in	std_logic_vector(31 downto 0);
	mem_addr:	out	std_logic_vector(31 downto 0);
	instruction:	in	std_logic_vector(31 downto 0);
	pc:		out	std_logic_vector(9  downto 0);
	write_mem: 	out  	std_ulogic;
	clk: 		in  	std_ulogic;
	next_inst:	in	std_logic_vector(31 downto 0); --this is not a hardware implementation, only for the SET inst.
);
end cpu;

architecture behave of cpu is
	--control unit control signals
	signal halt	: std_logic;
	signal reg_write: std_logic;
	signal alu_op	: std_logic_vector(3 downto 0);
	signal mem_store: std_logic;
	signal imm	: std_logic;
	signal bn	: std_logic;
	signal bz	: std_logic;
	signal b	: std_logic;
	signal load	: std_logic;
	--signal opcode	: std_logic_vector(4 downto 0); --input opcode

	--program counter datapaths
	signal pc_addr:	std_logic_vector(9 downto 0); --pc address bus
	signal pc_addr_plus_one: std_logic_vector(9 downto 0); --incremented address
	signal do_branch: std_logic; --final OR branch control line

	component ALU
	port(
		A:	in	std_logic_vector(31 downto 0);
		B:	in	std_logic_vector(31 downto 0);
		func:	in	std_logic_vector(3 downto 0);
		outp:	out	std_logic_vector(31 downto 0);
		neg:	out	std_ulogic;
		zero: out std_ulogic
	);
	end component ALU;

begin

	program_counter: process(clk) is
	begin
		if falling_edge(clk) then
			pc <= pc_addr;
		end if;
	end process;

	control_unit: process(instruction) is
	begin
		variable opcode := instruction(31 downto 26);
		if opcode = "00000" then --nop
			halt		<= 0;
			reg_write 	<= 0;
			mem_store 	<= 0;
			alu_op 		<= "0000";
			imm 		<= 0;
			bn 		<= 0;
			bz 		<= 0;
			b 		<= 0;
			load 		<= 0;
		elsif opcode = "00001" then --set
			halt 		<= 0;
			reg_write 	<= 1;
			mem_store 	<= 0;
			alu_op 		<= "1111";
			imm 		<= 1;
			bn 		<= 0;
			bz 		<= 0;
			b 		<= 0;
			load 		<= 0;
		elsif opcode = "00010" then --load
			halt 		<= 0;
			reg_write 	<= 1;
			mem_store 	<= 0;
			alu_op 		<= "0000";
			imm 		<= 1;
			bn 		<= 0;
			bz 		<= 0;
			1b 		<= 0;
			load 		<= 0;
		elsif opcode = "00011" then --store
			halt 		<= 0;
			reg_write 	<= 0;
			mem_store 	<= 1;
			alu_op 		<= "1110";
			imm 		<= 0;
			bn 		<= 0;
			bz 		<= 0;
			b 		<= 0;
			load 		<= 0;
		elsif opcode = "00100" then --move
			halt 		<= 0;
			reg_write 	<= 1;
			mem_store 	<= 0;
			alu_op 		<= "1110";
			imm 		<= 0;
			bn 		<= 0;
			bz 		<= 0;
			b 		<= 0;
			load 		<= 0;
		elsif (unsigned(opcode) >=  5) and (unsigned(opcode) <= 17) then --math operations except POW which is opcode 18
			halt 		<= 0;
			reg_write 	<= 1;
			mem_store 	<= 0;
			alu_op 		<= std_logic_vector( unsigned( opcode(3 downto 0) - 5 ) );
			imm 		<= 0;
			bn 		<= 0;
			bz		<= 0;
			b 		<= 0;
			load 		<= 0;
		elsif opcode = "10010" then --POW
			halt 		<= 0;
			reg_write 	<= 1;
			mem_store 	<= 0;
			alu_op 		<= "1101";
			imm 		<= 1;
			bn 		<= 0;
			bz 		<= 0;
			b 		<= 0;
			load 		<= 0;
		elsif opcode = "10011" then --Unconditional branch
			halt 		<= 0;
			reg_write 	<= 0;
			mem_store 	<= 0;
			alu_op 		<= "0000";
			imm 		<= 0;
			bn 		<= 0;
			bz 		<= 0;
			b 		<= 1;
			load 		<= 0;
		elsif opcode = "10100" then --BZ
			halt 		<= 0;
			reg_write 	<= 0;
			mem_store 	<= 0;
			alu_op 		<= "1110";
			imm 		<= 0;
			bn 		<= 0;
			bz 		<= 1;
			b 		<= 0;
			load 		<= 0;
		elsif opcode = "10101" then --BN
			halt 		<= 0;
			reg_write 	<= 0;
			mem_store 	<= 0;
			alu_op 		<= "1110";
			imm 		<= 0;
			bn 		<= 1;
			bz 		<= 0;
			b 		<= 0;
			load 		<= 0;
		elsif opcode = "10110" then --Halt
			halt 		<= 1;
			reg_write 	<= 0;
			mem_store 	<= 0;
			alu_op 		<= "0000";
			imm 		<= 0;
			bn 		<= 0;
			bz 		<= 0;
			b 		<= 0;
			load 		<= 0;
		end if;
	end process;

	pc_increment: process(pc_addr) is
	begin
		pc_addr_plus_one <= std_logic_vector(unsigned(pc_addr) + 1);
	end process

	pc_mux: process(pc_addr_plus_one, instruction, do_branch) is
	begin
		if (do_branch = 1) then
			pc_addr <= instruction(9 downto 0);
		else
			pc_addr <= pc_addr_plus_one;
		end if;
	end process

end behave;
