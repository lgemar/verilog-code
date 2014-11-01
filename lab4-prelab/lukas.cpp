#include <fstream>
#include <iostream>
#include <string>
#include <regex>

int main(int argc, char** argv) {
	if(argc != 3)
		std::cout << "USAGE assemble input_file output_file" << std::endl;

	std::ifstream input_file (argv[1]);

	std::regex reg ("\w+\s");
	std::string line;
	while( std::getline(input_file, line) ) {
		std::cout << line << std::endl;
		if(std::regex_match(line, reg))
			std::cout << "Line is matched by the regex" << std::endl;
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
