#!/usr/bin/python2.7
import sys
import re
import argparse
import conversions

STARTING_ADDRESS = 0x00100000 #mips starting program counter

DESCRIPTION = """converts mips assembly files into machine code
	note: this script assumes python style comments ("#") and does not handle block comments or multiple instructions per line"""
FORMAT_HELP = """how to format the output file.  Options follow:
	memh : verilog hex memory file [default]
	memb : verilog binary memory file [untested, might not work]
	coe  : xilinx memory file, [untest, might not work]"""

parser = argparse.ArgumentParser(description = DESCRIPTION)
parser.add_argument('assembly', type=argparse.FileType('r'), help = "the assembly file to assemble")
parser.add_argument('--format', '-f', choices = ['memh', 'memb', 'coe'], help = FORMAT_HELP, default='memh')
parser.add_argument('--pad', '-p', type=int, help = "often simulators/synthesizers require the file to be padded to the full amount. use this argument to add more lines to the output file.")
parser.add_argument('--parse_codes', action="store_true", help="parses out a pythonic version of all the defined codes in a verilog file (which becomes the main argument)")
parser.add_argument('--start_address', '-s', type=int, default=STARTING_ADDRESS, help = "the number corresponding to the start of the program")

#regular expressions
re_comment1 = re.compile('(//.*)\n')
re_comment2 = re.compile('(/\*.*\*/)')
re_op_code = re.compile("`define\s+MIPS_OP_(?P<op>\w+)\s+\d+'b(?P<code>[01]+)\s*\n")
re_funct_code = re.compile("`define\s+MIPS_FUNCT_(?P<funct>\w+)\s+\d+'b(?P<code>[01]+)\s*\n")
re_offset_address = re.compile("(?P<hex>-?0x[0-9a-fA-F]+)?(?P<decimal>-?\d+)?\s*\(\s*(?P<register>[$]\w+)")
re_label = re.compile("^(?P<label>\w+):\s*")
re_instruction_type = re.compile("^(?P<type>\w+)\s*") 

#function to get python dicts out of a verilog define file containing funct/op code defines
def parse_codes(f):
	
	src = f.read()
	f.close()

	#eliminate commented out things
	src = re_comment1.sub("", src)
	src = re_comment2.sub("", src)
	
	#extract all op and funct codes
	op_codes = {}
	funct_codes = {}
	
	for m in re_op_code.finditer(src):
		op_codes[m.group('op').lower()] = m.group('code')
	for m in re_funct_code.finditer(src):
		funct_codes[m.group('funct').lower()] = m.group('code')
	return op_codes, funct_codes
op_codes = {'bltz': '000001', 'lbu': '100100', 'sw': '101011', 'blez': '000110', 'lb': '100000', 'lh': '100001', 'lw': '100011', 'jal': '000011', 'mfc0': '010000', 'lui': '001111', 'addi': '001000', 'sltiu': '001011', 'bgez': '000001', 'ori': '001101', 'xori': '001110', 'andi': '001100', 'mtc0': '010000', 'bgtz': '000111', 'addiu': '001001', 'rtype': '000000', 'j': '000010', 'slti': '001010', 'lhu': '100101', 'sh': '101001', 'bne': '000101', 'sb': '101000', 'beq': '000100'}
funct_codes = {'and': '100100', 'subu': '100011', 'mflo': '010010', 'syscall': '001100', 'mfhi': '010000', 'sltu': '101011', 'addu': '100001', 'xor': '100110', 'jalr': '001001', 'add': '100000', 'nor': '100111', 'jr': '001000', 'break': '001101', 'srav': '000111', 'divu': '011011', 'mult': '011000', 'sub': '100010', 'sra': '000011', 'slt': '101010', 'sllv': '000100', 'srl': '000010', 'sll': '000000', 'mthi': '010001', 'mtlo': '010011', 'srlv': '000110', 'div': '011010', 'or': '100101', 'multu': '011001'}

register_names = ['$zero','$at','$v0','$v1','$a0','$a1','$a2','$a3','$t0','$t1','$t2','$t3','$t4','$t5','$t6','$t7','$s0','$s1','$s2','$s3','$s4','$s5','$s6','$s7','$t8','$t9','$k0','$k1','$gp','$sp','$fp','$ra']
registers = {}
for i, name in enumerate(register_names):
	registers["$%d"%i] = conversions.bin2c(i, 5)
	registers[name] = conversions.bin2c(i, 5)
	
		
if __name__ == "__main__":
	args = parser.parse_args()
	if args.parse_codes:
		op_codes, funct_codes = parse_codes(args.assembly)
		sys.stderr.write( "op_codes = " + op_codes.__repr__() + "\n" )
		sys.stderr.write( "funct_codes = " + funct_codes.__repr__() + "\n" )
		sys.exit(0)
	radix = 16
	if args.format == 'memb':
		radix = 2

	
	labels = {}
	parsed_lines = []
	address = 0
	line_count = 0
	for line in args.assembly:
		line_count = line_count + 1
		parsed_line = {}
		line = line.strip()
		line = re.sub('\s*#.*', '', line)  #remove comments
		if line:
			parsed_line['line_number'] = line_count
			#find labels, if they exist
			match = re_label.search(line)
			if match:
				labels[match.group('label')] = address
				line = line[match.end():]
			match = re_instruction_type.search(line)
			if not match:
				raise Exception("error on line %d (no instruction type)"%line_count)
			parsed_line['instruction'] = match.group('type')
			line = line[match.end():]
			parsed_line['args'] = [x.strip() for x in line.split(",")]
			parsed_lines.append(parsed_line)
			address = address + 1
	args.assembly.close()
	machine_code = []
	for line in parsed_lines:
		machine = ""
		if line['instruction'] == 'nop':
			machine = 8*'0'
		elif line['instruction'] in funct_codes.keys():
			machine += op_codes['rtype']
			if line['instruction'] == 'jr':
				rs = line['args'][0]
				rt = '$zero'
				rd = '$zero'
				shamt = '00000'
				#machine = "000000" + rs + conversions.bin2c(8, 21)
			else:
				if(len(line['args']) != 3):
					raise Exception("line %d : not right number of args"%line['line_number'])

				if line['instruction'] in ['sll', 'srl', 'sra']:
					rd, rt, shamt = line['args']
					shamt = conversions.bin2c(shamt, 5)
					rs = '$0'
				else:
					rd, rs, rt = line['args']
					shamt = '00000'
			#machine = '000000' + registers[rs] + registers[rt] + registers[rd] + shamt + funct_codes[line['instruction']]
			machine = "".join(['000000',registers[rs],registers[rt],registers[rd],shamt,funct_codes[line['instruction']]])
		else:
			machine = op_codes[line['instruction']]
			if line['instruction'] in ['jal', 'j']:
				machine += conversions.bin2c(labels[line['args'][0]]+args.start_address, 26)
			elif line['instruction'] in ['sw', 'lw']:
				rt, full_offset = line['args']
				match = re_offset_address.match(full_offset)
				if not match:
					raise Exception("%s on line %d is bad"%(line['instruction'], line['line_number']))
				offset = match.group('hex') or match.group('decimal')
				base = 10
				if match.group('hex'):
					base = 16
				offset = int(offset,base)
				rs = match.group('register')
				
				machine += registers[rs] + registers[rt] + conversions.bin2c(offset, 16)
				#sys.stderr.write("%s assembly: rs = %s, rt = %s, offset = %d, binary = \n\t%s\n"%(line['instruction'], rs, rt, offset, machine))
			else:
				#branches
				if line['instruction'] in ['beq', 'bne']:
					rs, rt, offset = line['args']
					rs = registers[rs]
					rt = registers[rt]
					offset = labels[offset] - line['line_number']
					sys.stderr.write("%s branch: offset = %d, rs = %s, rt = %s\n"%(line['instruction'], offset, rs, rt) )
					offset = conversions.bin2c(offset, 16)
					machine += rs + rt + offset #names are wrong but this is a quick fix
				else:
					rt, rs, offset = line['args']
					rs = registers[rs]
					rt = registers[rt]
					offset = conversions.bin2c(offset, 16)
					machine += rs + rt + offset
		machine_code.append(machine)
	if args.pad:
		if len(machine_code) > args.pad:
			raise Exception("Error: machine code had %d lines but needed to fit within %d"%(len(machine_code), args.pad))
		machine_code.extend([32*"0"]*(args.pad-len(machine_code)))
	for line in machine_code:
		if radix == 16:
			sys.stdout.write( conversions.bin_to_hex(line, 32) + "\n")
		else:
			sys.stdout.write( line + "\n")
