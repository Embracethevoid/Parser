%{
#include <cstdio>
#include <iostream>
//#include "expr.h"
using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
extern int yylineno;
extern char* yytext;
void yyerror(const char *s);
%}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  But tokens could be of any
// arbitrary data type!  So we deal with that in Bison by defining a C union
// holding each of the types of tokens that Flex could return, and have Bison
// use that union instead of "int" for the definition of "yystype":
%union {
	int ival;
	float fval;
	char *sval;
	char *identval;
	//struct expr_val* expval;
}

// define the constant-string tokens:
%token EXTENDS CLASS WHILE IF ELSE ELIF RETURN DEF ENDL 
%token COLON SEMICOLON LP RP LB RB DOT COMMA
%token  GETS
%token MISS ILLEGAL //PLUS MINUS TIMES DIVIDE MORE ATMOST LESS ATLEAST EQUALS AND OR NOT
//%left PLUS MINUS TIMES DIVIDE
//%left MORE ATMOST LESS ATLEAST EQUALS
%left AND OR
%left NOT
%nonassoc   ATMOST MORE ATLEAST LESS
//%nonassoc    
%left PLUS MINUS 
%left TIMES DIVIDE
%nonassoc  EQUALS
%precedence NEG
%left DOT
//%token DOT
// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <ival> INT_LIT
%token <fval> FLOAT
%token <sval> STRING_LIT
%token <identval> Ident
%type <expval> R_Expr;
%%
// the first rule defined is the highest-level rule, which in our
// case is just the concept of a whole "program file":
Program:
	Classes  Statements
	;
Classes:
	|Classes Class
	;
Class:
	Class_Signature Class_Body {;}
	;
Class_Signature:
	CLASS Ident LP Formal_Args RP Extends_Ident |
	CLASS Ident LP Formal_Args RP 
	;


Formal_Args:
	|Formal_Args_First Formal_Args_Idents
	;
Formal_Args_First:
	Ident COLON Ident {;}
	;

Formal_Args_Idents:
	|Formal_Args_Idents Formal_Args_Ident  {;}
	;


Formal_Args_Ident:
	COMMA Ident COLON Ident {;}
	;

Extends_Ident:
	EXTENDS Ident {;}
	;

Class_Body:
	LB Class_Body_Content RB
	;



Class_Body_Content:
	Statements Methods
	;

Statements:
	|Statements Statement 
	;

Statement_Block:
	LB Statements RB {;}
	;
Statement:
	IF R_Expr Statement_Block Elifs Else  |
	IF R_Expr Statement_Block Elifs   |
	WHILE R_Expr Statement_Block  |
	L_Expr COLON Ident GETS R_Expr SEMICOLON  |
	L_Expr GETS R_Expr  SEMICOLON|
	R_Expr SEMICOLON  |
	RETURN R_Expr SEMICOLON|
	RETURN SEMICOLON
	;
	
Elifs:
	|Elifs Elif
	;


Elif:
	ELIF R_Expr Statement_Block
	;
Else:
	ELSE Statement_Block
	;

Methods:
	|Methods Method 
	;


Method:

	
DEF Ident LP Formal_Args RP COLON Ident Statement_Block
{;}
|

DEF Ident LP Formal_Args RP Statement_Block

{;}
	;








L_Expr:
	Ident|
	R_Expr DOT Ident 
	;

R_Expr:
	STRING_LIT {;}|
	INT_LIT {;}|
	L_Expr {;}|
	R_Expr PLUS R_Expr {;}|
	R_Expr MINUS R_Expr {;}|
	R_Expr TIMES R_Expr{;}|
	R_Expr DIVIDE R_Expr{;}|
	MINUS R_Expr %prec NEG{;}|
	LP R_Expr RP {;}|
	R_Expr EQUALS R_Expr {;}|
	R_Expr ATMOST R_Expr {;}|
	R_Expr LESS R_Expr{;}|
	R_Expr ATLEAST R_Expr{;}|
	R_Expr MORE R_Expr{;}|
	R_Expr AND R_Expr{;}|
	R_Expr OR R_Expr {;}|
	NOT R_Expr {;}|
	R_Expr DOT Ident LP Actual_Args RP {;}|
	Ident LP Actual_Args RP{;}
	;

Actual_Args:
	|R_Expr R_Exprs
	;

R_Exprs:
	|R_Exprs COMMA R_Expr
	;
	
	




	




%%

int main(int argv, char** argc) {
	// open a file handle to a particular file:
	FILE *myfile = fopen(argc[1], "r");
	// make sure it's valid:
	if (!myfile) {
		cout << "I can't open the input file!" << endl;
		return -1;
	}
	// set lex to read from it instead of defaulting to STDIN:
	yyin = myfile;
	cout<<"Being parsing"<<endl;
	// parse through the input until there is no more:
	
	do {
		yyparse();
	} while (!feof(yyin));
	cout<<"Finished parsing with 0 errors"<<endl;
}

void yyerror(const char *s) {
	
	cout << yylineno << ": " << s <<"(at '"<<yytext<<"')"<< endl;
	// might as well halt now:
	exit(-1);
}
