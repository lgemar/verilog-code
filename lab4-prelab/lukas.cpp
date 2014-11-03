#include <fstream>
#include <iostream>
#include <string>
#include <cstring>
#include <map>
#include <vector>
#include <assert.h>

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

static string_map Registers = {{"$0", 0}, {"$zero", 0}, {"$at", 1}, {"$v0", 2}, 
							   {"$v1", 3}, {"$a0", 4}, {"$a1", 5}, 
							   {"$a2", 6}, {"$a3", 7}, {"$t0", 8}, 
							   {"$t1", 9}, {"$t2", 10}, {"$t3", 11}, 
							   {"$t4", 12}, {"$t5", 13}, {"$t6", 14}, 
							   {"$t7", 15}, {"$s0", 16}, {"$s1", 17},
							   {"$s2", 18}, {"$s3", 19}, {"$s4", 20},
							   {"$s5", 21}, {"$s6", 22}, {"$s7", 23},
							   {"$t8", 24}, {"$t9", 25}, {"$k0", 26}, 
							   {"$k1", 27}, {"$gp", 28}, {"$sp", 29}, 
							   {"$fp", 30}, {"$ra", 31}}; 

static string_map R_commands = {{"add", 32}, {"sub", 34}, {"and", 36}, 
								{"or", 37}, {"xor", 38}, {"nor", 39}, 
								{"slt", 42}, {"sll", 0}, {"sra", 3}, 
								{"srl", 2}};

static string_map I_commands = {{"addi", 8}, {"andi", 12}, {"ori", 13}, 
								{"xori", 14}, {"slti", 10}, {"beq", 4}, 
								{"bne", 5}, {"lw", 35}, {"sw", 43}, {"nop", 0}};

static string_map J_commands = {{"j", 2}, {"jal", 3}, {"jr", 8}};

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
	if( Registers.find(s) != Registers.end() ) {
		return Registers[s];
	}
	else if ( labels.find(s) != labels.end() ) {
		return labels[s];
	}
	else {
		unsigned ret = std::stoi(s);
		ret |= 1 << 15;
		return ret;
	}
}

unsigned lookup(unsigned u) {return u;};

bool is_shift(std::string s) {
	return (s == "sll" || s == "sra" || s == "srl" );
}

void flush_commands(std::ofstream& output) {
	std::cout << "I am flushing commands" << std::endl;
	std::cout <<  "There are " << instructions.size() << " instructions" << std::endl;
	for(auto it = instructions.begin(); it != instructions.end(); ++it) {
		string_map::iterator pos;
		unsigned result = 0;
		std::string the_command = (*it)[0];
		if( the_command == "nop" )
			continue;
		else if( (pos = R_commands.find(the_command)) != R_commands.end() ) {
			assert( (*it).size() == 4 );
			std::string the_command = (*it)[0];
			result |= (*pos).second << 26;
			if( is_shift( the_command) ) {
				result |= lookup((*it)[2]) << 6;
			}
			else
				result |= lookup((*it)[2]) << 21;
			result |= lookup((*it)[1]) << 11;
			result |= lookup((*it)[3]) << 16;
			result |= 32;

		}
		else if( (pos = I_commands.find(the_command)) != I_commands.end() ) {
			result |= (*pos).second << 26;
			if( the_command == "lw" || the_command == "sw") {
				;// do nothing
			}
			else {
				result |= lookup((*it)[1]) << 21;
				result |= lookup((*it)[2]) << 16;
				result = (int) lookup((*it)[3]);
			}
		}
		else if( (pos = J_commands.find(the_command)) != J_commands.end() ) {
			result |= (*pos).second << 26;
			std::string the_command = (*it)[0];
		}
		else {
			output << "There was an error in the assembly" << std::endl;
		}
		std::cout << "A new instruction: ";
		std::cout << std::hex << result << std::endl;
	}
}
