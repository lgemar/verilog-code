#include <fstream>
#include <iostream>
#include <string>
#include <regex>
#include <cstring>

int main(int argc, char** argv) {
	if(argc != 3)
		std::cout << "USAGE assemble input_file output_file" << std::endl;

	// Store the names and locations of the labels
	std::set<std::pair<std::string, int>> labels;

	std::ifstream input_file (argv[1]);

	std::string line;
	while( std::getline(input_file, line) ) {
		std::cout << line << std::endl;
		// Convert the std::string line to a char* 
		char* cstr = new char[line.length() + 1];
		strcpy(cstr, line.c_str());

		// Parse the input
		char* pch = strtok(cstr, " \t,");
		while( pch != NULL && *pch != '#') {
			std::cout << pch << std::endl;
			std::string str (pch);
			if( str.back() == ':' )
				std::cout << "This is a label" << std::endl;
			pch = strtok(NULL, " \t,");
		}

		std::cout << "End of command" << std::endl;
	}

	std::ofstream output_file (argv[2]);


	if( output_file.is_open() ) {
		output_file << "This is a line\n";
		output_file << "This is another line\n";
	}
		
	input_file.close();
	output_file.close();
	return 0;
}

/**
std::vector<base_class> table (add, sub, ... );

struct base_class {
	virtual int operator()(int a, int b) = 0;
};

struct add : public base_class {
	int operator()(int a, int b) {
		return a + b;
	}
};

int c = add(first, second);

struct sub {
	std::string s;
	int operator()(int a, int b) {
		return a - b;
	}
}

int d = sub(first, second);

if( str == "add" )
	add(str);
else if (str == "sub") 
	sub(str);
8?
*/
