#include <iostream>
#include <fstream>
#include <vector>
#include <set>
#include <map>
#include <cstring>
#include <sstream>
#include <algorithm>

#define WHITESPACE " \t\n"

using namespace std;

enum { SHIFT_OP = 26, SHIFT_RS = 21, SHIFT_RT = 16, SHIFT_RD = 15, SHIFT_SHMT = 6 };

int make_inst(string const line);
int assemble(ifstream& asmfile, ofstream& machine);
int process_instr(string intr, string rest);
int make_rtype(string intr, string rest);
int make_itype(string intr, string rest);
int make_jtype(string intr, string rest);
int get_reg(string reg);
bool is_comment(string field);
bool is_label(string field);
bool has_only_spaces(const string& str);
pair<string, int> process_label(string const line);
map<string, int> get_labels(ifstream& asmfile);
string extract_code(string const line);
string extract_comma(string reg);
vector<string> split(string rest);
set<string> get_keys(map<string, int> m);

static string nop = "nop";

static map<string, int> str_to_reg { 
    { "$zero", 0 }, { "$0", 0 }, { "$at", 1 }, { "$v0", 2 }, { "$v1", 3 },
    { "$a0", 4 }, { "$a1", 5 }, { "a2", 6 }, { "a3", 7 }, { "$t0", 8 },
    { "t1", 9 }, { "$t2", 10 } , { "t3", 11 } , { "$t4", 12 }, { "$t5", 13 },
    { "$t6", 14 }, { "$t7", 15 }, { "$s0", 16 }, { "$s1", 17 }, { "$s2", 18 },
    { "$s3", 19 } , { "$s4", 20 }, { "$s5", 21 }, { "$s6", 22 }, { "$s7", 23 },
    { "$t8", 24 }, { "$t9", 25 }, { "$k0", 26 }, { "$k1", 27 }, { "$gp", 28 },
    { "$sp", 29 }, { "$fp", 30 }, { "$ra",  31 }
};

static map<string, int> rtype { 
    {"sll", 0}, {"sra", 3}, {"srl", 2}, {"jr", 8}, {"add", 32}, {"sub", 34}, 
    {"and", 36}, {"or", 37}, {"xor", 38}, {"nor", 39}, {"slt", 42}, 
};

static map<string, int> itype {
    {"addi", 8}, {"beq", 4}, {"bne", 5}, {"slti", 10}, {"andi", 12}, 
    {"ori", 13}, {"xori", 14},  {"lw", 35}, {"sw", 43}, 
};

static map<string, int> jtype { {"j", 2}, {"jal", 3} };

static map<string, int> symbol_table;

static int error;

static const unsigned first_addr = 4194304;
static unsigned pc = 0;

int main(int argc, char *argv[]) {
    (void)first_addr;

    if (argc != 3) return 1;

    ifstream asmfile (argv[1]);
    if (!asmfile.is_open()) return 2;

    symbol_table = get_labels(asmfile);

    asmfile.clear();
    asmfile.seekg(0, ios::beg);

    ofstream machine (argv[2], ofstream::binary);
    if (!machine.is_open()) { 
        asmfile.close(); 
        return 3;
    }

    int err = assemble(asmfile, machine);
    if (err) {
        cout << "error: " << err << " PC: " << pc << " size: " << symbol_table.size() << endl;
        machine.close();
        machine.open(argv[2], ofstream::trunc);
        machine.close();
        asmfile.close(); 
        return 4;
    }

    asmfile.close(); 
    machine.close(); 

    return 0;
}

map<string, int> get_labels(ifstream& asmfile) {
    map<string, int> symbol_table;

    string line;
    while (getline(asmfile, line)) {
        pair<string, int> label = process_label(line); 
        if (label.second == pc) {
            if (!label.first.empty()) symbol_table.insert(label);
            pc = pc + 4;
        }   
    }
    return symbol_table;
}

pair<string, int> process_label(string const line) {
    if (line.empty() || has_only_spaces(line) || is_comment(line))
        return make_pair("", -1);

    char const *cln = line.c_str();
    char ln[strlen(cln) +1];
    strcpy(ln, cln);
    
    char *field = strtok(ln, WHITESPACE); 
    if (field != NULL) cout << field << " " << pc << endl;
    if (field != NULL && is_label(string(field)))
        return make_pair(string(field), pc);
    return make_pair("", pc);
}

bool is_comment(string field) {
    istringstream iss(field);
    string temp;
    iss >> temp;
    return temp[0] == '#';
}

bool is_label(string field) {
    return field.find(':') != string::npos && field[field.size() -1] == ':';
}

int assemble(ifstream& asmfile, ofstream& machine) {
    string line;
    while (getline(asmfile, line)) {
        int inst = make_inst(line);
        if (error) return 1;
        machine.write((const char *)(&inst), sizeof(inst));
    }
    return 0;
}

int make_inst(string const line) {
    if (is_comment(line)) {
        cout << "comment" << endl;
        return -1;
    }

    string extracted = extract_code(line);
    if (has_only_spaces(extracted) || extracted.empty()) {
        cout << "empty" << endl;
        return -1;
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

bool has_only_spaces(const string& str) {
    return str.find_first_not_of(WHITESPACE) == string::npos;
}

int process_instr(string instr, string rest) {
    if (rest.empty()) { /* only nop is valid */
        if (instr.compare(nop) != 0) error = 1;
        return 0;
    }

    if (get_keys(rtype).find(instr) != get_keys(rtype).end()) return make_rtype(instr, rest); 
    if (get_keys(itype).find(instr) != get_keys(itype).end()) return make_itype(instr, rest); 
    if (get_keys(jtype).find(instr) != get_keys(jtype).end()) return make_jtype(instr, rest); 
    // if pseudo return

    error = 2;  /* rest is not empty, but not a valid instr */
    return -1;
}

set<string> get_keys(map<string, int> m) {
    set<string> s;
    for(map<string, int>::iterator it = m.begin(); it != m.end(); ++it)
        s.insert(it->first);
    return s;
}

vector<string> split(string rest) {
    stringstream iss(rest);
    vector<string> tokens {istream_iterator<string>{iss}, istream_iterator<string>{}};
    return tokens;
}

string extract_comma(string reg) {
    size_t comma_idx;
    if ((comma_idx = reg.find(',')) != string::npos)
       reg = reg.substr(0, comma_idx);
    return reg;
}

int get_reg(string reg) {
    reg = extract_comma(reg);
    map<string, int>::iterator r = str_to_reg.find(reg);
    if (r == str_to_reg.end()) {
        error = 3;
        return -1;
    } 
    
    return r->second;
}

int make_rtype(string instr, string rest) {
    int fn = rtype[instr];
    
    vector<string> regs = split(rest);
    if (regs.size() != 3) error = 6;

    int rd = get_reg(regs[0]);
    int rs = get_reg(regs[1]);
    int rt = get_reg(regs[2]);

    return (rs << 21) | (rt << 16) | (rd << 11) | fn;
}

int make_jtype(string instr, string rest) {
    map<string, int>::iterator label = symbol_table.find(rest);
    if (label == symbol_table.end()) goto exit;

    {
        int target = label->second + first_addr;

        map<string, int>::iterator op = jtype.find(instr);
        if (op == jtype.end()) goto exit;

        int opcode = op->second;
        return (opcode << 26) | target;
    }

exit:
    error = 5;
    return 0;
}

int make_itype(string instr, string rest) {
    map<string, int>::iterator op = itype.find(instr);
    if (op == jtype.end()) goto exit;

    {
        int opcode = op->second;
        vector<string> regs = split(rest);
        if (regs.size() != 3) error = 1;

        int rt = get_reg(regs[1]);
        int rs = get_reg(regs[0]);
        
        size_t ch_idx = -1;
        int imm = stoi(regs[3], &ch_idx, 10);
        if (ch_idx) goto exit;

        return (opcode << SHIFT_OP) | (rs << SHIFT_RS) | (rt << SHIFT_RT) | imm;
    }

exit:
    error = 1;
    return -1;
}
