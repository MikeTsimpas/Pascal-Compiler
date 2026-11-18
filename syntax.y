%{

    #include <stdio.h>
    #include <stdlib.h>
    #include "hashtbl.h"

    extern FILE *yyin;
    extern int yylex();
    extern void yyerror(const char* err);

    HASHTBL *hashtbl;       // Tokens was in a different file
    int scope = 0;

%}

%define parse.error verbose

        
%union{
    int     intval;
    float   floatval;
    char    charval;
    char*   strval;
}


%token PROGRAM          "programm"
%token CONST            "const"
%token TYPE             "type"
%token ARRAY            "array"
%token LIST             "list"
%token RECORD           "record"
%token OF               "of"
%token VAR              "var"
%token INTEGER          "integer"
%token REAL             "real"
%token BOOLEAN          "boolean"
%token CHAR             "char"
%token STRING           "string"
%token FORWARD          "forward"
%token FUNCTION         "function"
%token PROCEDURE        "procedure"
%token BEGIN_KW         "begin"
%token END              "end"
%token IF               "if"
%token THEN             "then"
%token ELSE             "else"
%token WHILE            "while"
%token DO               "do"
%token FOR              "for"
%token DOWNTO           "downto"
%token TO               "to"
%token WITH             "with"
%token READ             "read"
%token WRITE            "write"
%token LENGTH           "length"
%token RELOP            "> or >= or < or <="               
%token ADDOP            "+ or -" 
%token OROP             "||"  
%token MULDIVANDOP      "* or / or mod or div or and"       
%token NOTOP            "!"
%token LPAREN           "("  
%token RPAREN           ")" 
%token SEMI             ";" 
%token DOT              "."
%token COMMA            ","    
%token EQU              "== or !="
%token COLON            "[]"   
%token LBRACK           "}"  
%token RBRACK           "{" 
%token ASSIGN           ":=" 
%token DOTDOT           ".." 
%token NUMBER           "number"
%token <strval>         ID              "id"
%token <intval>         ZERO            "zero"
%token <intval>         ICONST          "iconst"
%token <floatval>       RCONST          "rconst"
%token BCONST           "bconst"
%token <charval>        CCONST          "cconst"
%token <strval>         SCONST          "sconst"
%token LISTFUNC         "list_function"

%token EOFF     0       "End_of_file"

%type <strval> program header declarations constdefs constandefs expression variable expressions constant
%type <strval> listexpression typedefs type_defs type_def dims limits limit typename standard_type fields
%type <strval> field identifiers vardefs variable_defs subprograms subprogram sub_header formal_parameters
%type <strval> parameter_list pass comp_statement statements statement assignment if_statement if_tail
%type <strval> while_statement for_statement iter_space with_statement subprogram_call io_statement
%type <strval> read_list read_item write_list write_item

%left           EQU
%left           RELOP
%left           OROP
%left           ADDOP
%left           MULDIVANDOP
%nonassoc       NOTOP
%left           DOT
%left           COLON
%left           LPAREN RPAREN
%nonassoc       LOWER_THAN_ELSE
%nonassoc       ELSE

%start program

%%

/* Terminals -> Caps | Non terminal -> lowercase */

program:                header declarations subprograms comp_statement DOT  { hashtbl_get(hashtbl, scope); scope--; } /* For cleanup */
						;
header:                 PROGRAM ID SEMI                         { hashtbl_insert(hashtbl, $2, NULL, scope); scope++; }
						;
declarations:           constdefs typedefs vardefs
						;
constdefs:              CONST constandefs SEMI
                        | %empty                                { }
						;
constandefs:            constandefs SEMI ID EQU expression      { hashtbl_insert(hashtbl, $3, NULL, scope); }   // Saving everytime onhashtbl
                        | ID EQU expression                     { hashtbl_insert(hashtbl, $1, NULL, scope); }   // Null = zero value
						;
expression:             expression RELOP expression
                        | expression EQU expression
                        | expression OROP expression
                        | expression ADDOP expression
                        | expression MULDIVANDOP expression
                        | ADDOP expression
                        | NOTOP expression
                        | variable
                        | ID LPAREN expressions RPAREN          { hashtbl_insert(hashtbl, $1, NULL, scope); }
                        | LENGTH LPAREN expression RPAREN
                        | constant
                        | LPAREN expression RPAREN
                        | listexpression
						;
variable:               ID                                      { hashtbl_insert(hashtbl, $1, NULL, scope); }
                        | variable DOT ID                       { hashtbl_insert(hashtbl, $3, NULL, scope); }
                        | variable LBRACK expressions RBRACK
                        | LISTFUNC LPAREN expression RPAREN
						;
expressions:            expressions COMMA expression
                        | expression
						;
constant:               ICONST
                        | RCONST
                        | BCONST
                        | CCONST
                        | SCONST
						;
listexpression:         LBRACK expressions RBRACK
                        | LBRACK RBRACK
						;
typedefs:               TYPE type_defs SEMI
                        | %empty                                { }
						;
type_defs:              type_defs SEMI ID EQU type_def          { hashtbl_insert(hashtbl, $3, NULL, scope); }
                        | ID EQU type_def                       { hashtbl_insert(hashtbl, $1, NULL, scope); }
						;
type_def:               ARRAY LBRACK dims RBRACK OF typename
                        | LIST OF typename
                        | RECORD fields END
                        | LPAREN identifiers RPAREN
                        | limit DOTDOT limit
						;
dims:                   dims COMMA limits
                        | limits
						;
limits:                 limit DOTDOT limit
                        | ID                                    { hashtbl_insert(hashtbl, $1, NULL, scope); }
						;
limit:                  ADDOP ICONST
                        | ADDOP ID                              { hashtbl_insert(hashtbl, $2, NULL, scope); }
                        | ICONST
                        | CCONST
                        | BCONST
                        | ID                                    { hashtbl_insert(hashtbl, $1, NULL, scope); }
						;
typename:               standard_type
                        | ID                                    { hashtbl_insert(hashtbl, $1, NULL, scope); }
						;
standard_type:          INTEGER | REAL | BOOLEAN | CHAR | STRING
						;
fields:                 fields SEMI field
                        | field
						;
field:                  identifiers COLON typename
						;
identifiers:            identifiers COMMA ID                    { hashtbl_insert(hashtbl, $3, NULL, scope); }
                        | ID                                    { hashtbl_insert(hashtbl, $1, NULL, scope); }
						;
vardefs:                VAR variable_defs SEMI
                        | %empty                                { }
						;
variable_defs:          variable_defs SEMI identifiers COLON typename
                        | identifiers COLON typename
						;
subprograms:            subprograms subprogram SEMI
                        | %empty                                { }
						;
subprogram:             sub_header SEMI FORWARD                 { hashtbl_get(hashtbl, scope); scope--; }
                        | sub_header SEMI declarations subprograms comp_statement   { hashtbl_get(hashtbl, scope); scope--; }
						;
sub_header:             FUNCTION ID formal_parameters COLON standard_type   { hashtbl_insert(hashtbl, $2, NULL, scope); scope++; }
                        | PROCEDURE ID formal_parameters                    { hashtbl_insert(hashtbl, $2, NULL, scope); scope++; }
                        | FUNCTION ID                                       { hashtbl_insert(hashtbl, $2, NULL, scope); scope++; }
						;
formal_parameters:      LPAREN parameter_list RPAREN
                        | %empty                                { }
						;
parameter_list:         parameter_list SEMI pass identifiers COLON typename
                        | pass identifiers COLON typename
						;
pass:                   VAR | %empty                            { }
						;
comp_statement:         BEGIN_KW statements END
						;
statements:             statements SEMI statement
                        | statement
						;
statement:              assignment
                        | if_statement
                        | while_statement
                        | for_statement
                        | with_statement
                        | subprogram_call
                        | io_statement
                        | comp_statement
                        | %empty                                { }
						;
assignment:             variable ASSIGN expression
						;
if_statement:           IF expression THEN statement if_tail            // Here is if
						;
if_tail:                ELSE statement
                        | %empty %prec LOWER_THAN_ELSE          { }                  // For the dangling else problem, if_tail may be empty.
						;
while_statement:        WHILE expression DO statement
						;
for_statement:          FOR ID ASSIGN iter_space DO statement           { hashtbl_insert(hashtbl, $2, NULL, scope); }
                        | error ID   ASSIGN iter_space  DO   statement  { yyerror("Wrong use of for_statement"); yyerrok; }
                        | FOR  error ASSIGN iter_space  DO   statement  { yyerror("Wrong use of for_statement"); yyerrok; }
                        | FOR   ID   error  iter_space  DO   statement  { yyerror("Wrong use of for_statement"); yyerrok; }
                        | FOR   ID   ASSIGN iter_space error statement  { yyerror("Wrong use of for_statement"); yyerrok; }
						;
iter_space:             expression TO expression
                        | expression DOWNTO expression
						;
with_statement:         WITH variable DO statement
						;
subprogram_call:        ID                                      { hashtbl_insert(hashtbl, $1, NULL, scope); }
                        | ID LPAREN expressions RPAREN          { hashtbl_insert(hashtbl, $1, NULL, scope); }
						;
io_statement:           READ LPAREN read_list RPAREN
                        | WRITE LPAREN write_list RPAREN
                        | error LPAREN write_list RPAREN        { yyerror("Wrong use of io statement"); yyerrok; }  // Error checks
                        | WRITE  error write_list RPAREN        { yyerror("Wrong use of io statement"); yyerrok; }
                        | WRITE LPAREN write_list error         { yyerror("Wrong use of io statement"); yyerrok; }
						;
read_list:              read_list COMMA read_item
                        | read_item
						;
read_item:              variable
						;
write_list:             write_list COMMA write_item
                        | write_item

						;
write_item:             expression
                        



%%

int main(int argc, char *argv[]){
    int token;

    if (!(hashtbl = hashtbl_create(10, NULL))){     /* Numbers 1-10 */
        puts("Error, failed to initialize hashtable");
        exit(EXIT_FAILURE);
    }

    if(argc > 1){
        yyin = fopen(argv[1], "r");
        if (yyin == NULL){
            perror ("Error opening file");
            return EXIT_FAILURE;
        }
    }

    yyparse();
    fclose(yyin);
    hashtbl_destroy(hashtbl);

    return 0;
}
