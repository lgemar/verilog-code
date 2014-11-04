#include <iostream>
#include <fstream>
#include <vector>
#include <set>
#include <map>
#include <cstring>
#include <sstream>
#include <algorithm>
#include <bitset>
#include <iomanip>

#define WHITESPACE " \t\n"
#define fhex(_v) std::setw(_v) << std::hex << std::setfill('0')
#define JMASK 0x03ffffff
#define TEXT_START 0x400000

using namespace std;

enum { SHIFT_OP = 26, SHIFT_RS = 21, SHIFT_RT = 16, 
       SHIFT_RD = 11, SHIFT_SHMT = 6, SHIFT_OFFSET = 16 };

int make_inst(string const line);
int assemble(ifstream& asmfile, ofstream& machine);
int process_instr(string intr, string rest);
int make_rtype(string intr, string rest);
int make_itype(string intr, string rest);
int make_jtype(string intr, string rest);
int make_shift_type(string intr, string rest);
int make_load_store(string intr, string rest);
int make_branch(string instr, string rest);
int get_reg(string reg);
bool is_comment(string field);
bool is_label(string field);
bool has_only_spaces(const string& str);
pair<string, int> process_label(string const line);
void get_labels(ifstream& asmfile);
string extract_code(string const line);
string extract_comma(string reg);
vector<string> split(string rest);
set<string> get_keys(map<string, int> m);
string trim(const string& str, const string& whitespace = WHITESPACE);
string reverse(std::string to_reverse);
string int_to_bin(int number);

static string nop = "nop";

static map<string, int> str_to_reg { 
    { "$zero", 0 }, { "$0", 0 },    { "$at", 1 },  { "$v0", 2 },  { "$v1", 3 },
    { "$a0", 4 },   { "$a1", 5 },   { "$a2", 6 },  { "$a3", 7 },  { "$t0", 8 },
    { "$t1", 9 },   { "$t2", 10 } , { "$t3", 11 }, { "$t4", 12 }, { "$t5", 13 },
    { "$t6", 14 },  { "$t7", 15 },  { "$s0", 16 }, { "$s1", 17 }, { "$s2", 18 },
    { "$s3", 19 } , { "$s4", 20 },  { "$s5", 21 }, { "$s6", 22 }, { "$s7", 23 },
    { "$t8", 24 },  { "$t9", 25 },  { "$k0", 26 }, { "$k1", 27 }, { "$gp", 28 },
    { "$sp", 29 },  { "$fp", 30 },  { "$ra",  31 }
};

static map<string, int> rtype { {"add", 32}, {"sub", 34}, {"and", 36}, {"or", 37}, 
                                {"xor", 38}, {"nor", 39}, {"slt", 42}, {"jr", 0x8} };
static map<string, int> itype { {"addi", 0x8}, {"slti", 0xa}, {"andi", 0xc}, 
                                {"ori", 0xd}, {"xori", 0xe}, {"lui", 0xf} };
static map<string, int> jtype { {"j", 0x2}, {"jal", 0x3} };
static map<string, int> load_store { {"lw", 0x23}, {"sw", 0x2b} };
static map<string, int> shift_type { {"sll", 0x0}, {"srl", 0x2}, {"sra", 0x3} };
static map<string, int> branch_type { {"beq", 0x4}, {"bne", 0x5} };

static map<string, int> symbol_table;
static int error;
static unsigned pc = TEXT_START;

int main(int argc, char *argv[]) {
    if (argc != 3) return 1;

    ifstream asmfile (argv[1]);
    if (!asmfile.is_open()) return 2;

    get_labels(asmfile);

    asmfile.clear();
    asmfile.seekg(0, ios::beg);

    ofstream machine (argv[2]);
    if (!machine.is_open()) { 
        asmfile.close(); 
        return 3;
    }

    pc = TEXT_START;
    for(auto it = symbol_table.cbegin(); it != symbol_table.cend(); ++it)
        std::cout << "\t" << it->first << " " << it->second << "\n";

    int err = assemble(asmfile, machine);
    if (err) {
        cout << "error: " << err << " PC: " << pc << endl;
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

void get_labels(ifstream& asmfile) {
    string line;
    while (getline(asmfile, line)) {
        pair<string, int> label = process_label(line); 
        if (label.second == pc) {
            if (!label.first.empty()) symbol_table.insert(label);
            pc = pc + 4;
        }   
    }
}

pair<string, int> process_label(string const line) {
    if (line.empty() || has_only_spaces(line) || is_comment(line))
        return make_pair("", -1);

    char const *cln = line.c_str();
    char ln[strlen(cln) +1];
    strcpy(ln, cln);
    
    char *field = strtok(ln, WHITESPACE); 
    if (is_label(string(field))) {
        field[strlen(field)-1] = '\0';
        return make_pair(string(field), pc);
    }
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
        if (error) return error;
        if (inst == -1) continue;
        cout << line << " => 0x" << fhex(8) << inst << endl;
        machine.write((const char *)(&inst), sizeof(inst));
    }
    return 0;
}

int make_inst(string const line) {
    if (line.empty() || is_comment(line) || has_only_spaces(line)) return -1;
    pc = pc + 4;

    string extracted = extract_code(line);
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
        if (instr.compare(nop) != 0) error = 1; /* rest is empty, but not nop */
        return 0;
    }

    set<string> keys = get_keys(rtype);
    if (keys.find(instr) != keys.end()) return make_rtype(instr, trim(rest));

    keys = get_keys(itype);
    if (keys.find(instr) != keys.end()) return make_itype(instr, trim(rest));
    
    keys = get_keys(jtype);
    if (keys.find(instr) != keys.end()) return make_jtype(instr, trim(rest));

    keys = get_keys(load_store);
    if (keys.find(instr) != keys.end()) return make_load_store(instr, trim(rest));
    
    keys = get_keys(shift_type);
    if (keys.find(instr) != keys.end()) return make_shift_type(instr, trim(rest));

    keys = get_keys(branch_type);
    if (keys.find(instr) != keys.end()) return make_branch(instr, trim(rest));

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
    if (r == str_to_reg.end()) error = 3;  /* reg not found */
    return r->second;
}

int make_rtype(string instr, string rest) {
    int fn = rtype[instr];
    
    vector<string> regs = split(rest);
    if (regs.size() == 3) { 
        int rd = get_reg(regs[0]);
        int rs = get_reg(regs[1]);
        int rt = get_reg(regs[2]);
        return (rs << SHIFT_RS) | (rt << SHIFT_RT) | (rd << SHIFT_RD) | fn;
    }  

    if (regs.size() == 1) {  /* jr */
        int rs = get_reg(rest);
        return (rs << SHIFT_RS) | fn;
    } 

    error = 4;
    return -1;
}

int make_shift_type(string instr, string rest) {
    int fn = shift_type[instr];
    
    vector<string> regs = split(rest);
    if (regs.size() != 3) error = 5;

    int rd = get_reg(regs[0]);
    int rt = get_reg(regs[1]);
    int shamt = stoi(regs[2], nullptr, 10);
    return (rd << SHIFT_RD) | (rt << SHIFT_RT) | (shamt << SHIFT_SHMT) | fn;
}

/* jal, j */
int make_jtype(string instr, string rest) {
    map<string, int>::iterator label = symbol_table.find(rest);
    if (label == symbol_table.end()) error = 6;
    
    int target = ((TEXT_START + label->second) >> 2) & JMASK;
    int opcode = jtype[instr];

    return (opcode << SHIFT_OP) | target;
}

/* addi, ori, etc */
int make_itype(string instr, string rest) {
    int opcode = itype[instr];
    vector<string> regs = split(rest);
    if (regs.size() == 3) {
        int rt = get_reg(regs[0]);
        int rs = get_reg(regs[1]);
        unsigned short imm = stoi(regs[2], nullptr, 10);
        return (opcode << SHIFT_OP) | (rs << SHIFT_RS) | (rt << SHIFT_RT) | imm;
    } 
    
    if (regs.size() == 2) {
        int rt = get_reg(regs[0]);
        unsigned short imm = stoi(regs[1], nullptr, 10);
        return (opcode << SHIFT_OP) | (rt << SHIFT_RT) | imm;
    }
    
    error = 7;
    return -1;
}

/* beq bnq */
int make_branch(string instr, string rest) {
    int opcode = branch_type[instr];

    vector<string> regs = split(rest);
    if (regs.size() != 3) error = 8;

    int rs = get_reg(regs[0]);
    int rt = get_reg(regs[1]);
    
    map<string, int>::iterator label = symbol_table.find(regs[2]);

    if (label == symbol_table.end()) error = 9;
    unsigned short offset = (label->second - pc) >> 2;
    return (opcode << SHIFT_OP) | (rs << SHIFT_RS) | (rt << SHIFT_RT) | offset;
}

/* only lw, sw */
int make_load_store(string instr, string rest) {
    vector<string> regs = split(rest);
    if (regs.size() != 2) error = 10;

    int rt = get_reg(regs[0]);
    size_t idx = -1;
    unsigned short imm = stoi(regs[1], &idx, 10);

    if (idx == -1) error = 11;
    int open_paren = regs[1].find('$');
    int close_paren = regs[1].find(')');
    if (open_paren == regs[1].npos || close_paren == regs[1].npos) error = 11;
 
    int rs = get_reg(regs[1].substr(open_paren, close_paren - open_paren));

    int opcode = load_store[instr];

    return (opcode << SHIFT_OP) | (rs << SHIFT_RS) | (rt << SHIFT_RT) | imm;
}

string trim(const string& str, const string& whitespace) {
    const auto strBegin = str.find_first_not_of(whitespace);
    if (strBegin == std::string::npos)
        return ""; // no content

    const auto strEnd = str.find_last_not_of(whitespace);
    const auto strRange = strEnd - strBegin + 1;

    return str.substr(strBegin, strRange);
}

