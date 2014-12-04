#include <fstream>
#include <iostream>
#include <string>
#include <cstring>
#include <map>
#include <vector>
#include <assert.h>
#define JMASK 0x03ffffff
#define TEXT_START 0x00000000

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
	{"$0", 0}, {"$1", 1}, {"$2", 2}, {"$3", 3}, {"$4", 4}, {"$5", 5}, {"$6", 6}, 
	{"$7", 7}, {"$8", 8}, {"$9", 9}, {"$10", 10}, {"$11", 11}, {"$12", 12}, 
	{"$13", 13}, {"$14", 14}, {"$15", 15}, {"$16", 16}, {"$17", 17}, {"$18", 18},
	{"$19", 19}, {"$20", 20}, {"$21", 21}, {"$22", 22}, {"$23", 23}, {"$24", 24},
	{"$25", 25}, {"$26", 26}, {"$27", 27}, {"$28", 28}, {"$29", 29}, {"$30", 30},
	{"$31", 31}, {"$zero", 0}, {"$at", 1}, {"$v0", 2}, {"$v1", 3}, 
	{"$a0", 4}, {"$a1", 5}, {"$a2", 6}, {"$a3", 7}, {"$t0", 8}, 
	{"$t1", 9}, {"$t2", 10}, {"$t3", 11}, {"$t4", 12}, {"$t5", 13}, 
	{"$t6", 14}, {"$t7", 15}, {"$s0", 16}, {"$s1", 17}, {"$s2", 18}, 
	{"$s3", 19}, {"$s4", 20}, {"$s5", 21}, {"$s6", 22}, {"$s7", 23}, 
	{"$t8", 24}, {"$t9", 25}, {"$k0", 26}, {"$k1", 27}, {"$gp", 28}, 
	{"$sp", 29}, {"$fp", 30}, {"$ra", 31}}; 
static string_map Rtype = {
	{"add", 32}, {"sub", 34}, {"and", 36}, {"or", 37}, {"xor", 38}, 
	{"nor", 39}, {"slt", 42}, {"jr", 8}};
static string_map Shifttype =  { {"sll", 0}, {"sra", 3}, {"srl", 2} };
static string_map Itype = {
	{"addi", 8}, {"andi", 12}, {"ori", 13}, {"xori", 14}, {"slti", 10},
	{"nop", 0}, {"lui", 15}};
static string_map Jtype = {{"j", 2}, {"jal", 3}};
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
		if( is_label( pch ) ) {
			std::string s (pch);
			s.erase( s.end() - 1 );
			labels[s] = PC;
		}
		else {
			command_array.push_back(std::string(pch));
		}
		pch = strtok(NULL, " \t,");
	}
	PC += 4;
	return command_array;
}

void shorten(unsigned& num) {
	num <<= 16;
	num >>= 16;
}

unsigned lookup(std::string s) {
	unsigned ret = 0;
	if( Str2Reg.find(s) != Str2Reg.end() ) {
		ret = Str2Reg[s];
		return ret;
	}
	else if ( labels.find(s) != labels.end() ) {
		ret = labels[s];
		return ret;
	}
	else {
		unsigned ret = 0;
		ret = std::stoi(s);
		shorten(ret);
		return ret;
	}
}

/** Returns the 32-bit r-type command specifier built from a command array
 * @pre The size of @a s, the command array, must be 2 or 4, corresponding
 * 	to 1 instruction plus 1 or 3 arguments
 * @pre The r-type command is in the form [<fn>, <rd>, <rs>, <rt>]
 */
unsigned build_r(string_array s) {
	unsigned result = 0;
	std::string command = s[0];
	result |= Rtype[command];
	// If this is a jr command
	if( s.size() == 2 ) {
		unsigned rs = lookup(s[1]);
		return result | rs << SHIFT_RS; 
	}
	else {
		assert(s.size() == 4);
		unsigned rd = lookup(s[1]);
		unsigned rs = lookup(s[2]);
		unsigned rt = lookup(s[3]);
		return result|(rs << SHIFT_RS)|(rt << SHIFT_RT)|(rd << SHIFT_RD);
	}
}

/** Returns the 32-bit i-type command specifier built from a command array
 * @pre The size of @a s, the command array, must be 4, corresponding
 * 	to 1 instruction plus 3 arguments
 * @pre The i-type command is in the form [<fn>, <rt>, <rs>, <imm>]
 */
unsigned build_i(string_array s) {
	unsigned result = 0;
	std::string command = s[0];
	result |= Itype[command] << SHIFT_OP;
	if( command == "lui" ) {
		result |= lookup(s[1]) << SHIFT_RT;
		result |= lookup(s[2]);
	}
	else {
		result |= lookup(s[1]) << SHIFT_RT;
		result |= lookup(s[2]) << SHIFT_RS;
		result |= lookup(s[3]);
	}
	return result;
}

unsigned build_shift(string_array s) {
	unsigned result = 0;
	std::string command = s[0];
	result |= Shifttype[command];
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
	shorten(offset);
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
	PC = 0;
	for(auto it = instructions.begin(); it != instructions.end(); ++it) {
		unsigned result = 0;
		std::string command = (*it)[0];
		PC += 4;
		if( command == "nop" ) {
			// output << "nop-type: "; 
			result = 0;
		}
		else if( Rtype.find(command) != Rtype.end() ) {
			// output << "r-type: "; 
			result = build_r( *it );
		}
		else if( Shifttype.find(command) != Shifttype.end() ) {
			// output << "shift-type: "; 
			result = build_shift( *it );
		}
		else if( Itype.find(command) != Itype.end() ) {
			// output << "i-type: "; 
			result = build_i( *it );
		}
		else if( MemoryOps.find(command) != MemoryOps.end() ) {
			// output << "memory-type: "; 
			result = build_memoryop( *it );
		}
		else if ( Branchtype.find(command) != Branchtype.end() ) {
			// output << "branch-type: "; 
			result = build_branch( *it );
		}
		else if( Jtype.find(command) != Jtype.end() ) {
			// output << "j-type: "; 
			result = build_jump( *it );
		}
		else
			output << "There was an error in the assembly" << std::endl;
		output << std::hex << result << std::endl;
	}
}
