#include <fstream>
#include <iostream>
#include <string>
#include <cstring>
#include <map>
#include <vector>
#include <assert.h>
#define JMASK 0x03ffffff
#define TEXT_START 0x400000

enum { SHIFT_OP = 26, SHIFT_RS = 21, SHIFT_RT = 16, 
       SHIFT_RD = 11, SHIFT_SHMT = 6, SHIFT_OFFSET = 16 };

typedef typename std::map<std::string, unsigned> string_map;
typedef typename std::vector<std::string> string_array;
typedef typename std::vector<string_array> instruction_table;
static string_map labels;
static instruction_table instructions;
static unsigned PC = 0;

bool is_label(const char* token);
string_array parse_command(std::string line);
bool has_only_whitespace(const std::string& str);
void flush_commands(std::ofstream& output);

static string_map Str2Reg = {
			{"$0", 0}, {"$zero", 0}, {"$at", 1}, {"$v0", 2}, {"$v1", 3}, 
			{"$a0", 4}, {"$a1", 5}, {"$a2", 6}, {"$a3", 7}, {"$t0", 8}, 
			{"$t1", 9}, {"$t2", 10}, {"$t3", 11}, {"$t4", 12}, {"$t5", 13}, 
			{"$t6", 14}, {"$t7", 15}, {"$s0", 16}, {"$s1", 17}, {"$s2", 18}, 
			{"$s3", 19}, {"$s4", 20}, {"$s5", 21}, {"$s6", 22}, {"$s7", 23}, 
			{"$t8", 24}, {"$t9", 25}, {"$k0", 26}, {"$k1", 27}, {"$gp", 28}, 
			{"$sp", 29}, {"$fp", 30}, {"$ra", 31}}; 
static string_map Rtype = {
			{"add", 32}, {"sub", 34}, {"and", 36}, {"or", 37}, {"xor", 38}, 
			{"nor", 39}, {"slt", 42},};
static string_map Shifttype =  { {"sll", 0}, {"sra", 3}, {"srl", 2} };
static string_map Itype = {{"addi", 8}, {"andi", 12}, {"ori", 13}, 
								{"xori", 14}, {"slti", 10},{"nop", 0}};
static string_map Jtype = {{"j", 2}, {"jal", 3}, {"jr", 8}};
static string_map MemoryOps = { {"lw", 35}, {"sw", 43} };
static string_map Branchtype = { {"beq", 4}, {"bne", 5} };

int main(int argc, char** argv) {
	if(argc != 3)
		std::cout << "USAGE assemble input_file output_file" << std::endl;

	std::ifstream input_file (argv[1]);
	std::ofstream output_file (argv[2]);

	std::string line;
	while( std::getline(input_file, line) ) {
		string_array command;
		command = parse_command(line);
		if(!command.empty())
			instructions.push_back(command);
	}
	std::cout << "There are " << instructions.size() << " instructions" << std::endl;
	std::cout << "There are " << labels.size() << " labels" << std::endl;
	std::cout << "Program counter is at " << std::hex << PC << std::endl;
	flush_commands(output_file);
	input_file.close();
	output_file.close();
	return 0;
}

/* Returns true if the command line is labelled */
bool is_label(const char* token) {
	std::string str (token);
	return (str.back() == ':');
}

bool has_only_whitespace(const std::string& str) {
	return str.find_first_not_of (" \t\n") == std::string::npos;
}

/* Returns the integer command represented by the line */
string_array parse_command(std::string line) {
	// Make a new command array
	string_array command_array;

	// Convert the std::string line to a char* 
	char* cstr = new char[line.length() + 1];
	strcpy(cstr, line.c_str());

	// Parse the input
	char* pch = strtok(cstr, " \t,");

	// Make sure that this line is not only whitespace or is comment
	if( has_only_whitespace(line) || *pch == '#' )
		return command_array; // return an empty command array

	while( pch != NULL && *pch != '#') {
		std::cout << pch << std::endl;
		if( is_label( pch ) ) {
			std::cout << "Adding a new label" << std::endl;
			std::string s (pch);
			s.erase( s.end() - 1 );
			labels[s] = PC;
			std::cout << "Size of labels " << labels.size() << std::endl;
		}
		else {
			command_array.push_back(std::string(pch));
		}
		pch = strtok(NULL, " \t,");
	}
	PC += 4;
	return command_array;
}

unsigned lookup(std::string s) {
	std::cout << "looking up " << s << std::endl;
	if( Str2Reg.find(s) != Str2Reg.end() ) {
		return Str2Reg[s];
	}
	else if ( labels.find(s) != labels.end() ) {
		return labels[s];
	}
	else {
		int ret = 0;
		ret = std::stoi(s);
		if( ret < 0 )
			ret |= 1 << 15;
		return ret;
	}
}

unsigned build_r(string_array s) {
	unsigned result = 0;
	std::string command = s[0];
	result |= Rtype[command] << SHIFT_OP;
	unsigned rd = lookup(s[1]);
	unsigned rs = lookup(s[2]);
	unsigned rt = lookup(s[3]);
	return result | (rs << SHIFT_RS) | (rt << SHIFT_RT) | (rd << SHIFT_RD);
}

unsigned build_i(string_array s) {
	unsigned result = 0;
	std::string command = s[0];
	result |= Itype[command] << SHIFT_OP;
	result |= lookup(s[1]) << SHIFT_RT;
	result |= lookup(s[2]) << SHIFT_RS;
	result |= (int) lookup(s[3]);
	return result;
}

unsigned build_shift(string_array s) {
	unsigned result = 0;
	std::string command = s[0];
	result |= Shifttype[command] << SHIFT_OP;
	unsigned rd = lookup(s[1]);
	unsigned rt = lookup(s[2]);
	unsigned shamt = lookup(s[3]);
    return result | (rd << SHIFT_RD) | (rt << SHIFT_RT) | (shamt << SHIFT_SHMT);
}
unsigned build_branch(string_array s) {
	unsigned result = 0;
	std::string command = s[0];
	result |= Branchtype[command] << SHIFT_OP;
	unsigned rs = lookup(s[1]);
	unsigned rt = lookup(s[2]);
	unsigned label_code = lookup(s[3]);
	unsigned offset = (label_code - PC) >> 2;
	return result | (rs << SHIFT_RS) | (rt << SHIFT_RT) | offset;
}
unsigned build_memoryop(string_array s) {
	unsigned result = 0;
	std::string command = s[0];
	result |= MemoryOps[command] << SHIFT_OP;

	unsigned rt = lookup(s[1]);
	std::string memory_code = s[2];

	// Convert the std::string line to a char* 
	char* cstr = new char[memory_code.length() + 1];
	strcpy(cstr, memory_code.c_str());

	// Parse the input
	char* pch = strtok(cstr, "()");
	unsigned imm = lookup(std::string(pch));
	
	// Check for error
	if( pch == NULL )
		assert(false);

	// Parse the second part of input: the register
	pch = strtok(NULL, "()");
	unsigned rs = lookup(std::string(pch));

	// Check for error
	if( pch == NULL )
		assert(false);
	
	return result | (rs << SHIFT_RS) | (rt << SHIFT_RT) | imm;
}

unsigned build_jump(string_array s) {
	unsigned result = 0;
	std::string command = s[0];
	result |=  Jtype[command] << SHIFT_OP;
	unsigned target = ((TEXT_START + lookup(s[1])) >> 2) & JMASK;
	return result | target;
}

void flush_commands(std::ofstream& output) {
	std::cout << "I am flushing commands" << std::endl;
	std::cout <<  "There are " << instructions.size() << " instructions" << std::endl;
	for(auto it = instructions.begin(); it != instructions.end(); ++it) {
		unsigned result = 0;
		std::string command = (*it)[0];
		if( command == "nop" ) {
			continue;
		}
		else if( Rtype.find(command) != Rtype.end() )
			result = build_r( *it );
		else if( Shifttype.find(command) != Shifttype.end() )
			result = build_shift( *it );
		else if( Itype.find(command) != Itype.end() )
			result = build_i( *it );
		else if( MemoryOps.find(command) != MemoryOps.end() )
			result = build_memoryop( *it );
		else if ( Branchtype.find(command) != Branchtype.end() )
			result = build_branch( *it );
		else if( Jtype.find(command) != Jtype.end() )
			result = build_jump( *it );
		else
			output << "There was an error in the assembly" << std::endl;
		std::cout << "A new instruction: ";
		std::cout << std::hex << result << std::endl;
	}
}
