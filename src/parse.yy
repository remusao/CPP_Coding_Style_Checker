/*
    PROLOG
*/

%{
  /* includes  */
%}

%code requires
{
/* header and source BEFORE the Bison-generated YYSTYPE, YYLTYPE, and token. */
  #include <iostream>
  #include "driver.hh"
}

%code provides
{
/* header and source AFTER the Bison-generated YYSTYPE, YYLTYPE, and token. */

  /* Fwd declaration of the Driver class */
  class Driver;

  /* Fwd declaration of the << YYLTYPE op. To use it in the lexer to */
  std::ostream& operator<< (std::ostream& o, YYLTYPE& loc);

  /* Fwd declaration of the norme_error function */
  void norme_error (YYLTYPE* yylloc, std::string message, char* token, Driver& driver);

  /* Fwd declaration of the norme_warning function */
  void norme_warning (YYLTYPE* yylloc, std::string message, char* token, Driver& driver);

  /* Fwd declaration of the yyerror function */
  void yyerror(YYLTYPE* loc, Driver& driver, const char* msg);

  /* Fwd declaration of the yylex prototype */
  # define YY_DECL int                          \
     yylex(YYSTYPE* yylval,                     \
           YYLTYPE* yylloc,                     \
           Driver&  driver)

  /* Declare the prototype of yylex */
  YY_DECL;
}

%union
{
  int   ival;
  char* s;
}

%require "2.4"
%locations
%defines "parser.hh"
%debug
%pure-parser
%parse-param { Driver& driver }
%lex-param { Driver& driver }
%error-verbose
%verbose



/* TOKEN */
%token <s>
  SPACE           " "
  EOL             "eol"
  CLASS           "class"
  LOOP            "loop"
  BIN_OP          "bin_op"
  OP_W_SPACE      "op_w_space"
  LPAR            "("
  RPAR            ")"
  SEMI_COL        "semi-col"
  COLON           ","
  SHARP           "#"
  LBRAC           "{"
  RBRAC           "}"
  NAMESPACE       "namespace"
  USING           "using"
  TYPEDEF         "typedef"
  PROTECTED       "protected"
  PRIVATE         "private"
  PUBLIC          "public"
  DEFINE          "define"
  INTEGER         "int"
  TYPE            "type"
  UPPER_CASE_ID   "up_id"
  LOW_CASE_ID     "low_id"
  MIX_CASE_ID     "mix_id"
  PUBLIC_ATTR     "public_attr"
  PRIVATE_ATTR    "private_attr"
  STAR            "*"
  EPERLUETTE      "&"
  TOK_EOF 0           "eof"
  OTHER           "other"


%left "+" "-"
%left "*" "/" "%"



%%

start:
   "eof"
;

%%

std::ostream&
operator<< (std::ostream& o, YYLTYPE& loc)
{
  o << "\033[35m";
  o << loc.first_line << ":" << loc.first_column;
  o << "\033[37m";
  o.flush ();

  return o;
}


void
yyerror(YYLTYPE*, Driver&, const char*)
{
//  std::cerr << "\033[35m" << *driver.source_get () << "\033[37m" << ":"
//    << *loc  << " " << std::string (msg) << std::endl;
}


void
norme_error (YYLTYPE* yylloc, std::string message, char* token, Driver& driver)
{
  if (driver.source_get ())
    std::cerr << "\033[34m" << *driver.source_get () << "\033[37m : ";
  std::cerr << *yylloc << "  " << "\033[31mError \033[37m" << message;
  if (token)
    std::cerr << " : " << "\033[4;31m" << std::string (token) << "\033[0;37m";
  std::cerr << std::endl;
}

void
norme_warning (YYLTYPE* yylloc, std::string message, char* token, Driver& driver)
{
  if (driver.source_get ())
    std::cerr << "\033[34m" << *driver.source_get () << "\033[37m : ";
  std::cerr << *yylloc << "  " << "\033[33mWarning \033[37m" << message;
  if (token)
    std::cerr << " : " << "\033[4;31m" << std::string (token) << "\033[0;37m";
  std::cerr << std::endl;
}
