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

	signal reg_write: std_logic := '0';

	--program counter datapaths
	signal pc_input_addr	:	std_logic_vector(9 downto 0) := "0000000000"; --pc address bus
	signal pc_output_addr	:	std_logic_vector(9 downto 0) := "0000000000";
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


	--PIPELINE--

	--Pipeline fetch/decode
	signal fetch_inst 	:	std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal fetch_imm_set	:	std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

	--Pipeline decode/execute
	signal dec_x_out	:	std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal dec_y_out	:	std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal dec_imm_set	:	std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal dec_alu_op	:	std_logic_vector(3 downto 0) := "0000";
	signal dec_bn		:	std_logic;
	signal dec_bz		:	std_logic;
	signal dec_branch_addr	:	std_logic_vector(9 downto 0);


	signal dec_imm_ctrl	: 	std_logic := '0';
	signal dec_mem_store	: 	std_logic := '0';
	signal dec_wb_load	: 	std_logic := '0';
	signal dec_rdata_addr	:	std_logic_vector(3 downto 0) := "0000";
	signal dec_rdata_wrt	:	std_logic := '0';
	
	--Pipeline execute/mem
	signal ex_alu_out	:	std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal ex_mem_addr	:	std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal ex_imm_ctrl	: 	std_logic := '0';
	signal ex_store		: 	std_logic := '0';

	signal ex_wb_load	: 	std_logic := '0';
	signal ex_rdata_addr	:	std_logic_vector(3 downto 0) := "0000";
	signal ex_rdata_wrt	:	std_logic := '0';

	--Pipeline mem/write-back
	signal mem_alu_out	:	std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal mem_data_out	:	std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal mem_load		: 	std_logic := '0';
	signal mem_rdata_addr	:	std_logic_vector(3 downto 0) := "0000";
	signal mem_rdata_wrt	:	std_logic := '0';

	signal clk_del  	:	std_logic := '0';
	signal clk_del_two  	:	std_logic := '0';

	--Hazard detection
	signal hazard_detected  : 	boolean := false;

	signal possible_dec_hazard: boolean;
	signal possible_ex_hazard:  boolean;
	signal possible_mem_hazard: boolean;

	signal possible_dec_hazard_two: boolean;
	signal possible_ex_hazard_two:  boolean;
	signal possible_mem_hazard_two: boolean;

	signal possible_dec_hazard_one: boolean;
	signal possible_ex_hazard_one:  boolean;
	signal possible_mem_hazard_one: boolean;
begin
	clk_del     <= clk after 5 ps;
	clk_del_two <= clk after 10 ps;

	--PC and Hazard Control
	hazard_ctrl: process(fetch_inst, dec_rdata_wrt, dec_mem_store, ex_rdata_wrt, ex_store, mem_rdata_wrt, ex_rdata_addr, dec_rdata_addr, mem_rdata_addr)
	begin
		possible_dec_hazard <= dec_rdata_wrt = '1' or dec_mem_store = '1';
		possible_ex_hazard <= ex_rdata_wrt = '1' or write_mem = '1';
		possible_mem_hazard <= mem_rdata_wrt = '1'; 

		possible_dec_hazard_two <= fetch_inst(22 downto 19) = dec_rdata_addr;
		possible_ex_hazard_two  <= fetch_inst(22 downto 19) = ex_rdata_addr;
		possible_mem_hazard_two <= fetch_inst(22 downto 19) = mem_rdata_addr;

		possible_dec_hazard_one <= fetch_inst(18 downto 15) = dec_rdata_addr;
		possible_ex_hazard_one 	<= fetch_inst(18 downto 15) = ex_rdata_addr;
		possible_mem_hazard_one <= fetch_inst(18 downto 15) = mem_rdata_addr;
	end process hazard_ctrl;

	hazard_detected <= (possible_dec_hazard_two and possible_dec_hazard) or
			   (possible_ex_hazard_two  and possible_ex_hazard)  or
			   (possible_mem_hazard_two and possible_mem_hazard) or
			   (possible_dec_hazard_one and possible_dec_hazard) or
			   (possible_ex_hazard_one  and possible_ex_hazard)  or
			   (possible_mem_hazard_one and possible_mem_hazard) or
			   (dec_bz = '1') or (dec_bn = '1');

	hazard_control: process(clk_del_two)
	begin
	
		if (rising_edge(clk_del_two) and not hazard_detected) or (do_branch = '1') then
			pc_output_addr <= pc_input_addr;
		end if;
	end process hazard_control;

	pc <= pc_output_addr;

	pc_logic: process(pc_output_addr, instruction, do_branch) is
	begin
		if (do_branch = '1') and not (b = '1') then
			pc_input_addr <= dec_branch_addr(9 downto 0);
		elsif b = '1' then
			pc_input_addr <= fetch_inst(9 downto 0);
		else
			pc_input_addr <= pc_output_addr + '1';
		end if;
	end process pc_logic;

	--FETCH/DECODE
	fetch_register: process(clk_del_two, do_branch)
	begin
		if (rising_edge(clk_del_two) and not hazard_detected) then
			fetch_inst 	<= instruction;
			fetch_imm_set 	<= set_value_in;
		elsif rising_edge(do_branch) and not (b = '1') then
			fetch_inst <= "00000000000000000000000000000000";
		end if;
	end process fetch_register;

	control_unit: process(fetch_inst)
		variable opcode : std_logic_vector(4 downto 0);
	begin
		opcode := fetch_inst(31 downto 27);
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
			imm 		<= '0';
			bn 		<= '0';
			bz 		<= '0';
			b 		<= '0';
			load 		<= '1';
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
	
	registers: register_file  port map
	(
		rs1_sel 	=> fetch_inst(22 downto 19),
		rs2_sel 	=> fetch_inst(18 downto 15),
		rd_sel		=> mem_rdata_addr,
		value_in	=> data_writeback, --In writeback stage
		rs1_out 	=> x_alu_in,
		rs2_out 	=> ry_out_to_mux,
		clk_write 	=> reg_write --In writeback stage
	);

	--DECODE/EXECUTE
	decode_register: process(clk_del_two)
	begin
		if rising_edge(clk_del_two) then
			if not hazard_detected then
				dec_mem_store <= ctrl_mem_store;
				dec_wb_load <= load;
				dec_rdata_wrt <= ctrl_reg_write;
				dec_alu_op <= alu_op;
				dec_bn <= bn;
				dec_bz <= bz;
			else
				dec_mem_store <= '0';
				dec_wb_load <= '0';
				dec_rdata_wrt <= '0';
				dec_alu_op <= "0000";
				dec_bn <= '0';
				dec_bz <= '0';
			end if;

			dec_x_out <= x_alu_in;
			dec_y_out <= ry_out_to_mux;
			dec_imm_set <= fetch_imm_set;
			dec_branch_addr <= fetch_inst(9 downto 0);
			
			dec_imm_ctrl <= imm;
			dec_rdata_addr <= fetch_inst(26 downto 23);
		end if;
	end process decode_register;
	
	alu_mux: process(instruction, ry_out_to_mux, imm) is
	begin
		if dec_imm_ctrl = '0' then
			y_alu_in <= dec_y_out;
		else
			y_alu_in <= dec_imm_set; --this is where things get weird with SET, will have to redo this with POW
		end if;
	end process;

	ALU_main: alu port map
	(
		A 	=> dec_x_out,
		B    	=> y_alu_in,
		func	=> dec_alu_op,
		outp 	=> alu_output,
		neg 	=> alu_neg,
		zero 	=> alu_zero
	);

	do_branch <= (dec_bn and alu_neg) or (dec_bz and alu_zero ) or b;

	--branch_logic: process(dec_bn, dec_bz, alu_neg, alu_zero) is 
	--begin
	--	do_branch <= (dec_bn and alu_neg) or (dec_bz and alu_zero) or b;
	--	if (dec_bn and alu_neg) or (dec_bz and alu_zero) or b then
	--		fetch_inst <= "00000000000000000000000000000000";
	--	end if;
	--end process;

	--EXECUTE/MEMORY
	execute_register: process(clk_del)
	begin
		if rising_edge(clk_del) then
			ex_alu_out <= alu_output;
			write_mem <= dec_mem_store;
			ex_mem_addr <= dec_y_out;

			ex_wb_load <= dec_wb_load;
			ex_rdata_addr <= dec_rdata_addr;
			ex_rdata_wrt <= dec_rdata_wrt;
		elsif falling_edge(clk_del) then
			write_mem <= '0';
		end if;
	end process execute_register;
	
	out_mem_data <= ex_alu_out;
	mem_addr <= ex_mem_addr;

	--MEMORY/WRITEBACK
	memory_register: process(clk_del)
	begin
		if rising_edge(clk_del) then
			mem_alu_out <= ex_alu_out;
			mem_data_out <= in_mem_data;
			mem_load <= ex_wb_load;
			mem_rdata_addr <= ex_rdata_addr;
			mem_rdata_wrt <= ex_rdata_wrt;
		end if;
	end process memory_register;

	mem_alu_mux: process(mem_alu_out, mem_load, mem_data_out) is
	begin
		if mem_load = '0' then
			data_writeback <= mem_alu_out;
		else
			data_writeback <= mem_data_out;
		end if;
	end process;
	
	--WRITEBACK
	writeback: process(clk)
	begin
		if rising_edge(clk) then
			reg_write <= mem_rdata_wrt;
		elsif falling_edge(clk) then
			reg_write <= '0';
		end if;
	end process writeback;

end behave;
