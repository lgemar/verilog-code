#include <fstream>
#include <iostream>
#include <string>
#include <regex>
#include <cstring>

typedef typename std::vector<std::pair<std::string, int>> label_table;
typedef typename std::vector<std::string> string_array;
typedef typename std::vector<string_array> instruction_table;
static label_table labels;
static instruction_table instructions;
static int PC = 0;

bool is_label(const char* token);
string_array parse_command(std::string line);

int main(int argc, char** argv) {
	if(argc != 3)
		std::cout << "USAGE assemble input_file output_file" << std::endl;

	// Store the names and locations of the labels
	std::set<std::pair<std::string, int>> labels;

	std::ifstream input_file (argv[1]);
	std::ofstream output_file (argv[2]);

	std::string line;
	while( std::getline(input_file, line) ) {
		string_array command;

		command = parse_command(line);
	}
	input_file.close();
	output_file.close();
	return 0;
}

/* Returns true if the command line is labelled */
bool is_label(const char* token) {
	std::string str (token);
	return (str.back() == ':');
}

label_table find_labels(std::ifstream input_file) {
}

/* Returns the integer command represented by the line */
string_array parse_command(std::string line) {
	// Convert the std::string line to a char* 
	char* cstr = new char[line.length() + 1];
	strcpy(cstr, line.c_str());

	// Make a new command array
	string_array command_array;

	// Parse the input
	char* pch = strtok(cstr, " \t,");
	while( pch != NULL && *pch != '#') {
		std::cout << pch << std::endl;
		if( is_label( pch ) ) {
			const std::string s (pch);
			labels.push_back(std::make_pair(std::string(pch), PC));
			PC += 4;
		}
		else
			(command_array).push_back(std::string(pch));
		pch = strtok(NULL, " \t,");
	}
	return command_array;
}
