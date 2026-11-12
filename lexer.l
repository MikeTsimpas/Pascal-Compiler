%{
    
    #define FLEX_DEGUN 1
    #include "syntax.tab.h"
    #include <stdio.h>
    #include <stdlib.h>

    char string_buffer[10000];
    int error_counter = 0;

    void token_print(int token_id);
    int string_to_int(char *str);
    float string_to_float(char *str);
    char arithmos_me_backslash(char *str);

    extern int yylineno;
    void yyerror(const char * err);

%}

%option noyywrap
%option case-insensitive
%option yylineno
/* Kanoume exclusive state gia ta strings */
%x STRING
%x SINGLE_LINE_COMMENT  

/* Isodinamies klaseon, gia efkolia, gia na mhn ta bazo ston kodika */
LETTER              [a-zA-Z]
DIGIT               [0-9]
ALFARITHMITIKO      [a-zA-Z0-9]
/* O kato arithmos einai gia na mhn ksekinaei me 0 */
ARITHMOS            [1-9][0-9]*|0
ANAGNORISTIKO       [a-zA-Z]([a-zA-Z0-9_]*[a-zA-Z0-9])?
/* Gia tis entoles IICONST kanoume ta parakato gia kathe sistima */
ZERO                0
DECIMINAL           [1-9][0-9]*
HEX                 0H[1-9A-F][0-9A-F]*
OCTA                0O[1-7][0-7]*
BINARY              0B1[01]*
/* Gia tis entoles RCONST kanoume prota to akeraio meros pou mas zitaei */
DEC_INT             (0|{DECIMINAL})
HEX_INT             (0|[1-9A-F][0-9A-F]*)
OCTA_INT            (0|[1-7][0-7]*)
BIN_INT             (0|1[01]*)
/* Kai meta kanoyme to klasmatiko me 0 h na exei >=1 non-zero psifia */
FRAC_DEC            (0|1[01]*)
FRAC_HEX            (0|[0-9A-F]*[1-9A-F][0-9A-F]*)
FRAC_OCTA           (0|[0-7]*[1-7][0-7]*)
FRAC_BIN            (0|[01]*1[01]*)
/* Gia ton ektheti */
EXP_NUM             (0|{DECIMINAL})
EXPONENT            E([+\-]?{EXP_NUM})
/* To sinoliko RCONST einai ola ta parapano mazi */
RCONST              ({DEC_INT}?\.{FRAC_DEC}{EXPONENT}?)|({DEC_INT}{EXPONENT})|(0H{HEX_INT}?\.{FRAC_HEX})|(0O{OCTA_INT}?\.{FRAC_OCTA})|(0B{BIN_INT}?\.{FRAC_BIN})
CCONST              ('[a-zA-Z0-9]')|('[!@#$%^&*()]')|('\\[nftrbv]')|('\\')|([' ']*)|('\\')
LISTFUNC            C(AD*|D+)R

%%

"PROGRAM"                               { token_print(PROGRAM); return PROGRAM; }    
"CONST"                                 { token_print(CONST); return CONST; }
"TYPE"                                  { token_print(TYPE); return TYPE; }
"ARRAY"                                 { token_print(ARRAY); return ARRAY; }
"LIST"                                  { token_print(LIST); return LIST; }
"RECORD"                                { token_print(RECORD); return RECORD; }    
"OF"                                    { token_print(OF); return OF; }
"VAR"                                   { token_print(VAR); return VAR; }
"INTEGER"                               { token_print(INTEGER); return INTEGER; }    
"REAL"                                  { token_print(REAL); return REAL; }
"BOOLEAN"                               { token_print(BOOLEAN); return BOOLEAN; }    
"CHAR"                                  { token_print(CHAR); return CHAR; }
"STRING"                                { token_print(STRING); return STRING; }    
"FORWARD"                               { token_print(FORWARD); return FORWARD; }    
"FUNCTION"                              { token_print(FUNCTION); return FUNCTION; }    
"PROCEDURE"                             { token_print(PROCEDURE); return PROCEDURE; }    
"BEGIN_KW"                              { token_print(BEGIN_KW); return BEGIN_KW; }
"END"                                   { token_print(END); return END; }
"IF"                                    { token_print(IF); return IF; }
"THEN"                                  { token_print(THEN); return THEN; }
"ELSE"                                  { token_print(ELSE); return ELSE; }
"WHILE"                                 { token_print(WHILE); return WHILE; }
"DO"                                    { token_print(DO); return DO; }
"FOR"                                   { token_print(FOR); return FOR; }
"DOWNTO"                                { token_print(DOWNTO); return DOWNTO; }    
"TO"                                    { token_print(TO); return TO; }
"WITH"                                  { token_print(WITH); return WITH; }
"READ"                                  { token_print(READ); return READ; }
"WRITE"                                 { token_print(WRITE); return WRITE; }
"LENGTH"                                { token_print(LENGTH); return LENGTH; }  

"TRUE"|"FALSE"                          { token_print(BCONST); return BCONST; }
"NOT"                                   { token_print(NOTOP); return NOTOP; }
"OR"                                    { token_print(OROP); return OROP; }
">"|">="|"<"|"<="|"<>"                  { token_print(RELOP); return RELOP; }
"+"|"-"                                 { token_print(ADDOP); return ADDOP; }
"*"|"/"|"DIV"|"MOD"|"AND"               { token_print(MULDIVANDOP); return MULDIVANDOP; }

"("                                     { token_print(LPAREN); return LPAREN; }
")"                                     { token_print(RPAREN); return RPAREN ;} 
";"                                     { token_print(SEMI); return SEMI; }
"."                                     { token_print(DOT); return DOT ;} 
","                                     { token_print(COMMA); return COMMA; }
"="                                     { token_print(EQU); return EQU; }
":"                                     { token_print(COLON); return COLON; }
"["                                     { token_print(LBRACK); return LBRACK; }
"]"                                     { token_print(RBRACK); return RBRACK; }
":="                                    { token_print(ASSIGN); return ASSIGN; }
".."                                    { token_print(DOTDOT); return DOTDOT; }
[ \t]                                   { }
\n                                      { }


{ARITHMOS}                              { token_print(NUMBER); return NUMBER; }
{LISTFUNC}                              { token_print(LISTFUNC); return LISTFUNC; }
{ANAGNORISTIKO}                         { token_print(ID); yylval.strval = strdup(yytext); return ID; }
 /* Mpainei edo gia na mhn anagnorizei lekseis kleidia. Kanonika to eixa pano apo to True, False, Not. Or & LISTFUNC alla eixa problima me ta tokens epeidi den eftane se ayta pote kai den ta egrafe */
{HEX}                                   { token_print(ICONST); yylval.intval = string_to_int(yytext); return ICONST; }
{OCTA}                                  { token_print(ICONST); yylval.intval = string_to_int(yytext); return ICONST; }
{BINARY}                                { token_print(ICONST); yylval.intval = string_to_int(yytext); return ICONST; }    
{RCONST}                                { token_print(RCONST); yylval.floatval = string_to_float(yytext); return RCONST; }
{CCONST}                                { token_print(CCONST); yylval.charval = arithmos_me_backslash(yytext); return CCONST; }

\"                                      { strcpy(string_buffer, ""); BEGIN(STRING); }
<STRING>\"                              { BEGIN(INITIAL); printf("Found word: %s\n",string_buffer); yylval.strval = strdup(string_buffer); return SCONST; }
<STRING>(\\\n|\\\r\n)                   { } 
<STRING>(\\.|[^"\\])                    { 
                                            if(strlen(yytext) == 2){
                                                if(strcmp(yytext, "\\n") == 0){
                                                    strcat(string_buffer, "\n");
                                                } else if (strcmp(yytext, "\\t") == 0){
                                                    strcat(string_buffer, "\t");
                                                } else if (strcmp(yytext, "\\r") == 0){
                                                    strcat(string_buffer, "\r");
                                                } else if (strcmp(yytext, "\\f") == 0){
                                                    strcat(string_buffer, "\f");
                                                } else if (strcmp(yytext, "\\r") == 0){
                                                    strcat(string_buffer, "\r");
                                                } else if (strcmp(yytext, "\\b") == 0){
                                                    strcat(string_buffer, "\b");
                                                } else if (strcmp(yytext, "\\v") == 0){
                                                    strcat(string_buffer, "\v");
                                                } else {
                                                    strcat(string_buffer, &yytext[1]);
                                                }
                                            }else{
                                                strcat(string_buffer, yytext);
                                            }
                                        }          /* Opiadipote leksi h ektos apoo " kai \\ */
<STRING>(\n|\r\n)                       { yyerror("New line found without \\"); }               /* \n gia mac \r\n windows */
<STRING><<EOF>>                         { yyerror("String not closed"); }
<STRING>.                               { yyerror("Uknown Character"); }

"{"                                     { printf("Comment found\n"); BEGIN(SINGLE_LINE_COMMENT); }
<SINGLE_LINE_COMMENT>("}")              { printf("Comment ended\n");BEGIN(INITIAL); } /* Etsi tha kleinei to sxolio */
<SINGLE_LINE_COMMENT>.                  { }

.                                       { yyerror("Unkown character\n"); }
<<EOF>>                                 { return 0; }

%%



/* --- SINARTISEIS ---*/

void token_print(int token_id){
    if (FLEX_DEGUN == 0){
        return;
    }

    if(token_id == ICONST){
        printf("[LINE %d] INTEGER TOKEN \'%s\' (%d). Base 10:%d\n", yylineno, yytext, token_id, string_to_int(yytext));
    }else if(token_id == RCONST){
        printf("[LINE %d] FLOAT TOKEN \'%s\' (%d). Base 10:%f\n", yylineno, yytext, token_id, string_to_float(yytext));
    }else{
        printf("[LINE %d] TOKEN \'%s\' (%d)\n", yylineno, yytext, token_id);
    }
}

int string_to_int(char *str){
    if(strncmp(str, "0o", 2) == 0){
        return (int) strtoll(&str[2], NULL, 8);         /* Gia oktadiko sistima */
    }else if(strncmp(str, "0B", 2) == 0){
        return (int) strtoll(&str[2], NULL, 2);         /* Gia diadiko sistima */
    }else if(strncmp(str, "0X", 2) == 0){
        return (int) strtoll(&str[2], NULL, 16);        /* Gia dekaeksadiko sistima */
    }else{
        return (int) strtoll(&str[2], NULL, 10);        /* Gia degadiko sistima */
    }
}

float string_to_float(char *str){
    if(strncmp(str, "0h", 2) == 0 || strncmp(str, "0H", 2) == 0){
        return (float) strtof(str, NULL);  /* Gia Hex float */
    }else if(strncmp(str, "0O", 2) == 0 || strncmp(str, "0O", 2) == 0){
        return (float) strtof(str, NULL);  /* Gia Octal float */
    }else if(strncmp(str, "0B", 2) == 0 || strncmp(str, "0B", 2) == 0){
        return (float) strtof(str, NULL);  /* Gia Binary float */
    }else{
        return (float) strtof(str, NULL);  /* Gia Decimal float */
    }
}

void yyerror(const char* err){
    error_counter ++;
    printf("[An error occured in line: %d] %s\n", yylineno, err);

    if (error_counter == 10){
        printf("Maximum programm errors reached\nProgramm terminating...\n");
    }

    yyless(1);          /* Opoy den kserei gia xaraktira sbinei to gramma gia na to ksanadiavasei p.x. se int aφδγ sbinei to φ meta to δ kai to γ */
}

char arithmos_me_backslash(char *str) {
    if (yytext[1] == '\\') {
        switch (yytext[2]) {
            case 'n':  return '\n';
            case 't':  return '\t';
            case 'r':  return '\r';
            case 'f':  return '\f';
            case 'b':  return '\b';
            case 'v':  return '\v';
            case '\\': return '\\';
            case '\'': return '\'';
            case '0':  return '\0';
            case '$':  return '$';
            case ' ':  return ' ';
            default:   return yytext[2]; /* agnosto escape → tha krathsoyme to gramma */
        }
    }
    return yytext[1]; /* an einai kanonikos xarakthras 'a', 'x', '$', ' ' */
}
