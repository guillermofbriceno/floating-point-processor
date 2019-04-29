library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity cpu is
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
end cpu;

architecture behave of cpu is
	--control unit control signals
	signal halt	: std_logic;
	signal ctrl_reg_write: std_logic;
	signal alu_op	: std_logic_vector(3 downto 0);
	signal ctrl_mem_store: std_logic;
	signal imm	: std_logic;
	signal bn	: std_logic;
	signal bz	: std_logic;
	signal b	: std_logic;
	signal load	: std_logic;

	signal reg_write: std_logic;
	signal actual_write_mem: std_logic;

	--program counter datapaths
	signal pc_input_addr	:	std_logic_vector(9 downto 0) := "0000000000"; --pc address bus
	signal pc_output_addr	:	std_logic_vector(9 downto 0) := "0000000000";
	signal pc_addr_plus_one	: 	std_logic_vector(9 downto 0); --incremented address
	signal do_branch	: 	std_logic := '0'; --final OR branch control line

	--ALU component and datapaths
	component alu
		port(
			A:	in	std_logic_vector(31 downto 0);
			B:	in	std_logic_vector(31 downto 0);
			func:	in	std_logic_vector(3 downto 0);
			outp:	out	std_logic_vector(31 downto 0);
			neg:	out	std_ulogic;
			zero: 	out 	std_ulogic
		);
	end component alu;
	
	signal alu_output	:	std_logic_vector(31 downto 0);
	signal alu_zero		:	std_ulogic;
	signal alu_neg		:	std_ulogic;
	signal x_alu_in		:	std_logic_vector(31 downto 0);
	signal y_alu_in		:	std_logic_vector(31 downto 0);

	--Register File component and datapaths
	component register_file
		port(
			rs1_sel:	in	std_logic_vector(3 downto 0);
			rs2_sel:	in	std_logic_vector(3 downto 0);
			rd_sel:		in	std_logic_vector(3 downto 0);
			value_in:	in	std_logic_vector(31 downto 0);
			rs1_out:	out	std_logic_vector(31 downto 0);
			rs2_out:	out	std_logic_vector(31 downto 0);
			clk_write: 	in std_ulogic
		);
	end component register_file;
	
	signal ry_out_to_mux	:	std_logic_vector(31 downto 0);

	--Data Memory
	signal data_writeback 	:	std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	
begin
	program_counter: process(clk)
	begin
		if falling_edge(clk) then
			pc_output_addr <= pc_input_addr;
		end if;
	end process program_counter;

	pc <= pc_output_addr;

	pc_logic: process(pc_output_addr, instruction, do_branch) is
	begin
		if do_branch = '1' then
			pc_input_addr <= instruction(9 downto 0);
		else
			pc_input_addr <= pc_output_addr + '1';
		end if;
	end process pc_logic;

	control_unit: process(instruction)
		variable opcode : std_logic_vector(4 downto 0);
	begin
		opcode := instruction(31 downto 27);
		if opcode = "00000" then --nop
			halt		<= '0';
			ctrl_reg_write 	<= '0';
			ctrl_mem_store 	<= '0';
			alu_op 		<= "0000";
			imm 		<= '0';
			bn 		<= '0';
			bz 		<= '0';
			b 		<= '0';
			load 		<= '0';
		elsif opcode = "00001" then --set
			halt 		<= '0';
			ctrl_reg_write 	<= '1';
			ctrl_mem_store 	<= '0';
			alu_op 		<= "1111";
			imm 		<= '1';
			bn 		<= '0';
			bz 		<= '0';
			b 		<= '0';
			load 		<= '0';
		elsif opcode = "00010" then --load
			halt 		<= '0';
			ctrl_reg_write 	<= '1';
			ctrl_mem_store 	<= '0';
			alu_op 		<= "0000";
			imm 		<= '1';
			bn 		<= '0';
			bz 		<= '0';
			b 		<= '0';
			load 		<= '0';
		elsif opcode = "00011" then --store
			halt 		<= '0';
			ctrl_reg_write 	<= '0';
			ctrl_mem_store 	<= '1';
			alu_op 		<= "1110";
			imm 		<= '0';
			bn 		<= '0';
			bz 		<= '0';
			b 		<= '0';
			load 		<= '0';
		elsif opcode = "00100" then --move
			halt 		<= '0';
			ctrl_reg_write 	<= '1';
			ctrl_mem_store 	<= '0';
			alu_op 		<= "1110";
			imm 		<= '0';
			bn 		<= '0';
			bz 		<= '0';
			b 		<= '0';
			load 		<= '0';
		elsif (unsigned(opcode) >=  5) and (unsigned(opcode) <= 17) then --math operations except POW which is opcode 18
			halt 		<= '0';
			ctrl_reg_write 	<= '1';
			ctrl_mem_store 	<= '0';
			alu_op 		<= std_logic_vector( unsigned( opcode(3 downto 0) ) - 5 );
			imm 		<= '0';
			bn 		<= '0';
			bz		<= '0';
			b 		<= '0';
			load 		<= '0';
		elsif opcode = "10010" then --POW
			halt 		<= '0';
			ctrl_reg_write 	<= '1';
			ctrl_mem_store 	<= '0';
			alu_op 		<= "1101";
			imm 		<= '1';
			bn 		<= '0';
			bz 		<= '0';
			b 		<= '0';
			load 		<= '0';
		elsif opcode = "10011" then --Unconditional branch
			halt 		<= '0';
			ctrl_reg_write 	<= '0';
			ctrl_mem_store 	<= '0';
			alu_op 		<= "0000";
			imm 		<= '0';
			bn 		<= '0';
			bz 		<= '0';
			b 		<= '1';
			load 		<= '0';
		elsif opcode = "10100" then --BZ
			halt 		<= '0';
			ctrl_reg_write 	<= '0';
			ctrl_mem_store 	<= '0';
			alu_op 		<= "1110";
			imm 		<= '0';
			bn 		<= '0';
			bz 		<= '1';
			b 		<= '0';
			load 		<= '0';
		elsif opcode = "10101" then --BN
			halt 		<= '0';
			ctrl_reg_write 	<= '0';
			ctrl_mem_store 	<= '0';
			alu_op 		<= "1110";
			imm 		<= '0';
			bn 		<= '1';
			bz 		<= '0';
			b 		<= '0';
			load 		<= '0';
		elsif opcode = "10110" then --Halt
			halt 		<= '1';
			ctrl_reg_write 	<= '0';
			ctrl_mem_store 	<= '0';
			alu_op 		<= "0000";
			imm 		<= '0';
			bn 		<= '0';
			bz 		<= '0';
			b 		<= '0';
			load 		<= '0';
		end if;
	end process control_unit;

	reg_write <= (not clk) and ctrl_reg_write after 2 ps;

	registers: register_file  port map
	(
		rs1_sel 	=> instruction(22 downto 19),
		rs2_sel 	=> instruction(18 downto 15),
		rd_sel		=> instruction(26 downto 23),
		value_in	=> data_writeback,
		rs1_out 	=> x_alu_in,
		rs2_out 	=> ry_out_to_mux,
		clk_write 	=> reg_write
	);
	
	mem_addr <= ry_out_to_mux;

	alu_mux: process(instruction, ry_out_to_mux, imm) is
	begin
		if imm = '0' then
			y_alu_in <= ry_out_to_mux;
		else
			y_alu_in <= set_value_in; --this is where things get weird with SET, will have to redo this with POW
		end if;
	end process;

	ALU_main: alu port map
	(
		A 	=> x_alu_in,
		B    	=> y_alu_in,
		func	=> alu_op,
		outp 	=> alu_output,
		neg 	=> alu_neg,
		zero 	=> alu_zero
	);
	
	write_mem <= (not clk) and ctrl_mem_store after 2 ps;
	out_mem_data <= alu_output;
	--alu_out_split: process(alu_out) is
	--begin
	--	out_mem_data <= alu_out;
	--end process;

	branch_logic: process(b, bn, bz, alu_neg, alu_zero) is 
	begin
		do_branch <= (bn and alu_neg) or (bz and alu_zero) or b;
	end process;

	mem_alu_mux: process(alu_output, load, in_mem_data) is
	begin
		if load = '0' then
			data_writeback <= alu_output;
		else
			data_writeback <= in_mem_data;
		end if;
	end process;


end behave;
