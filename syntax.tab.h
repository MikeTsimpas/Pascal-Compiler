/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_SYNTAX_TAB_H_INCLUDED
# define YY_YY_SYNTAX_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    EOFF = 0,                      /* "End_of_file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    PROGRAM = 258,                 /* "programm"  */
    CONST = 259,                   /* "const"  */
    TYPE = 260,                    /* "type"  */
    ARRAY = 261,                   /* "array"  */
    LIST = 262,                    /* "list"  */
    RECORD = 263,                  /* "record"  */
    OF = 264,                      /* "of"  */
    VAR = 265,                     /* "var"  */
    INTEGER = 266,                 /* "integer"  */
    REAL = 267,                    /* "real"  */
    BOOLEAN = 268,                 /* "boolean"  */
    CHAR = 269,                    /* "char"  */
    STRING = 270,                  /* "string"  */
    FORWARD = 271,                 /* "forward"  */
    FUNCTION = 272,                /* "function"  */
    PROCEDURE = 273,               /* "procedure"  */
    BEGIN_KW = 274,                /* "begin"  */
    END = 275,                     /* "end"  */
    IF = 276,                      /* "if"  */
    THEN = 277,                    /* "then"  */
    ELSE = 278,                    /* "else"  */
    WHILE = 279,                   /* "while"  */
    DO = 280,                      /* "do"  */
    FOR = 281,                     /* "for"  */
    DOWNTO = 282,                  /* "downto"  */
    TO = 283,                      /* "to"  */
    WITH = 284,                    /* "with"  */
    READ = 285,                    /* "read"  */
    WRITE = 286,                   /* "write"  */
    LENGTH = 287,                  /* "length"  */
    RELOP = 288,                   /* "> or >= or < or <="  */
    ADDOP = 289,                   /* "+ or -"  */
    OROP = 290,                    /* "||"  */
    MULDIVANDOP = 291,             /* "* or / or mod or div or and"  */
    NOTOP = 292,                   /* "!"  */
    LPAREN = 293,                  /* "("  */
    RPAREN = 294,                  /* ")"  */
    SEMI = 295,                    /* ";"  */
    DOT = 296,                     /* "."  */
    COMMA = 297,                   /* ","  */
    EQU = 298,                     /* "== or !="  */
    COLON = 299,                   /* "[]"  */
    LBRACK = 300,                  /* "}"  */
    RBRACK = 301,                  /* "{"  */
    ASSIGN = 302,                  /* ":="  */
    DOTDOT = 303,                  /* ".."  */
    NUMBER = 304,                  /* "number"  */
    ID = 305,                      /* "id"  */
    ZERO = 306,                    /* "zero"  */
    ICONST = 307,                  /* "iconst"  */
    RCONST = 308,                  /* "rconst"  */
    BCONST = 309,                  /* "bconst"  */
    CCONST = 310,                  /* "cconst"  */
    SCONST = 311,                  /* "sconst"  */
    LISTFUNC = 312,                /* "list_function"  */
    LOWER_THAN_ELSE = 313          /* LOWER_THAN_ELSE  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 19 "syntax.y"

    int     intval;
    float   floatval;
    char    charval;
    char*   strval;

#line 129 "syntax.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_SYNTAX_TAB_H_INCLUDED  */
