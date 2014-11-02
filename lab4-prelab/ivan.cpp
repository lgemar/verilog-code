#include <iostream>
#include <fstream>
#include <vector>
#include <set>
#include <cstring>

#define WHITESPACE " \t\n"

using namespace std;
typedef unsigned int inst;

static set<string> rtype = { "add", "sub", "and", "or", "xor", "sll", 
                             "sra", "srl", "slt", "jr", "nop" };
static set<string> itype = { "beq", "bne", "addi", "andi", "ori", 
                             "xori", "slti", "lw", "sw", "lui" };
static set<string> jtype = { "j", "jal" };

static const unsigned first_addr = 4194304;
static unsigned pc = 0;

inst make_inst(string const line);
void assemble(set<pair<string, int> >& table, ifstream& asmfile, ofstream& machine);
inst process_instr(string instr, string rest);
bool is_comment(char *field);
bool is_label(string field);
pair<string, int> process_label(string const line);
set<pair<string, int> > get_labels(ifstream& asmfile);
string extract_code(string const line);

bool has_only_spaces(const string& str) {
    return str.find_first_not_of(WHITESPACE) == string::npos;
}

int main(int argc, char *argv[]) {
    (void)first_addr;

    if (argc != 2) return 1;

    set<pair<string, int> > symbol_table;

    ifstream asmfile (argv[1]);
    if (!asmfile.is_open()) return 2;

    symbol_table = get_labels(asmfile);

    asmfile.clear();
    asmfile.seekg(0, ios::beg);

    ofstream machine ("out.machine", ofstream::binary);
    if (!machine.is_open()) { 
        asmfile.close(); 
        return 3;
    }

    assemble(symbol_table, asmfile, machine);

    asmfile.close(); 
    machine.close(); 

    return 0;
}

set<pair<string, int> > get_labels(ifstream& asmfile) {
    set<pair<string, int> > symbol_table;

    string line;
    while (getline(asmfile, line)) {
        pair<string, int> label = process_label(line); 
        if (label.first.empty()) continue;
        symbol_table.insert(label);
        pc = pc + 4;
    }
    return symbol_table;
}

pair<string, int> process_label(string const line) {
    if (line.empty() || has_only_spaces(line))
        return make_pair("", 0);

    char const *cln = line.c_str();
    char ln[strlen(cln) +1];
    strcpy(ln, cln);
    
    char *field = strtok(ln, WHITESPACE); 
    if (field != NULL && is_label(string(field)))
        return make_pair(string(field), pc);
    return make_pair("", 0);
}

bool is_label(string field) {
    if (field[0] == '#') return false;
    return field.find(':') != string::npos && field[field.size() -1] == ':';
}

void assemble(set<pair<string, int> >& table, ifstream& asmfile, ofstream& machine) {
    string line;
    while (getline(asmfile, line)) {
        inst instr = make_inst(line);
        if (instr == 0) continue;
        //machine.write((const char *)(&instr), sizeof(instr));
    }
}

inst make_inst(string const line) {
    string extracted = extract_code(line);
    if (extracted.empty()) { 
        cout << "empty" << endl;
        return 0;
    }

    char const *cln = extracted.c_str();
    char ln[strlen(cln) +1];
    strcpy(ln, cln);

    char *saveptr;
    char *field = strtok_r(ln, WHITESPACE, &saveptr); 
    return process_instr(string(field), (saveptr == NULL) ? string("") 
                                                          : string(saveptr));
}

string extract_code(string const line) {
    string ln = line;

    size_t colon_idx = line.find(':');
    if (colon_idx != string::npos) 
        ln = line.substr(colon_idx + 1);

    size_t comment_idx = ln.find('#');
    if (comment_idx != string::npos) 
        ln = ln.substr(0, comment_idx);
    
    return ln;
}

inst process_instr(string instr, string rest) {
    cout << "Instr: " << instr << " Rest: " << rest << endl;
    return 0;
}

