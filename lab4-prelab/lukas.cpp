#include <fstream>
#include <iostream>

int main(int argc, char** argv) {
	if(argc != 3)
		std::cout << "USAGE assemble input_file output_file" << std::endl;

	std::ifstream input_file (argv[1]);

	std::ofstream output_file (argv[2]);

	input_file.close();
	output_file.close();
	return 0;
}
