%top{

/* Includes */
#include "parser.hh"  
#include <iostream>

/* Defines */
#define yyterminate() return TOK_EOF;

/* Location maccros */
#define SHADOW_STEP()                               \
  do {                                              \
    yylloc->first_line = yylloc->last_line;	    \
    yylloc->first_column = yylloc->last_column;	    \
  } while (0)

#define STEP()                                              \
  do {                                                      \
    if (yytext && !(yytext[0] == ' '                        \
        || yytext[0] == '\t' || yytext[0] == '\n'))         \
    {                                                       \
      if (driver.something_get () && driver.brace_get ())   \
        ERROR ("Braces must be on their own lines", 0);     \
      driver.something_set (true);                          \
    }                                                       \
    yylloc->first_line = yylloc->last_line;	            \
    yylloc->first_column = yylloc->last_column;	            \
  } while (0)


#define COL(Col)				    \
  yylloc->last_column += (Col)


#define LINE(Line)				                \
  do{						                \
    if (/*yylloc->first_column > 81 ||*/ yylloc->last_column > 81)  \
      ERROR ("Line exceed 80 characters", 0);                   \
    driver.brace_set (false);                                   \
    driver.something_set (false);                               \
    driver.colon_set (false);                                   \
    yylloc->last_column = 1;		  	                \
    yylloc->last_line += (Line);		                \
 } while (0)


#define YY_USER_ACTION				    \
  COL(yyleng);                                      \
  //std::cout << std::string (yytext) << std::endl;


#define ERROR(message, tok)                         \
  do {                                              \
    if (tok) {                                      \
      norme_error (yylloc, message, yytext, driver);\
    }                                               \
    else {                                          \
      norme_error (yylloc, message, 0, driver);     \
    }                                               \
  } while (0)

#define WARNING(message, tok)                       \
  do {                                              \
    if (tok) {                                      \
      norme_warning (yylloc, message, yytext, driver);\
    }                                               \
    else {                                          \
      norme_warning (yylloc, message, 0, driver);     \
    }                                               \
  } while (0)
}


%option outfile="scan.cc"
/* Specify the output header */
%option header-file="scan.hh"
/* Specify that tables shouldn't be reduced */
/*%option fast*/
/* Function read used instead of higher-level functions */
%option read
/* Memory alignement */
%option align
/* Stop at the EOF */
%option noyywrap
/* The lexer never takes its inputs from stdin  */
%option never-interactive
%option batch
/* This function won't appear in code */
%option nounput
%option noinput
/* Enable the use of context stacks */
%option stack


%x SC_C_COMMENT SC_CPP_COMMENT SC_STRING SC_LOOP_DEC SC_LOOP_EMPTY SC_CLASS_DEC SC_NAMESPACE
%x SC_DEFINE SC_TYPEDEF SC_IF_PREPROC SC_VARDEC


/**

    REGEXP

*/

integer         [0-9]+
char_const      '[^']'

forbiden_type_name  [suet]_[a-zA-Z_-]+

low_case_id       [a-z]+
upper_case_id     [A-Z]+
mix_case_id       [a-zA-Z]+
macro             ([A-Z][A-Z_]*[A-Z])|([A-Z]+)

bad_name          _[a-zA-Z]+

public_attr       ([a-z][a-z_]*[a-z])|{low_case_id}
private_attr      {public_attr}_
typedef_suffix    [a-z]+[a-z_]*_type
def_file          [A-Z][A-Z_]*[A-Z]_[H]+_


id                [a-zA-Z_-]+

loop          ("while"|"for")

CRLF          ("\r\n")+

trigraphs     "??"[\\#^\[\]\|{}~]
digraphs      "<:"|":>"|"<%"|"%>"|"%:"


int_type       ("long"|"unsigned"|"short")*"int"|"unsigned"
floating      "float"|"double"|"long double"
other         "bool"|"char"|"unsigned char"
std           "std::"[a-zA-Z:<>_-]+
type          ({int_type}|{floating}|{other}|{std})("*"|"&")?

keyword_space   "do"|"if"|"typeid"|"sizeof"|"case"|"catch"|"switch"|"template"|"throw"|"try"

op          "+"|"-"|"*"|"~"|"/"|"%"|"^"|"?"|"&"|"|"|"="|":"
bin_op      {op}|"+="|"-="|"*="|"/="|"%="|">>="|"<<="|"&="|"^="|"|="|"=="|"!="|">"|"<"|">="|"<="|"&&"|"||"|"<<"|">>"

eol         \n
trailing_ws " \n"
blank       [ \t]

preproc_if    ("if"|"ifdef"|"ifndef")
macro_forbid  "break"|"continue"|"return"|"throw"

enum_use    [a-zA-Z:]+[A-Z_]+
/**

  START TOKEN RULES

*/

%%
%{
  STEP ();
%}

<SC_C_COMMENT>
{
  "*/"          {
                  yy_pop_state ();
                  SHADOW_STEP ();
                }
  {trailing_ws} {
                  LINE (1);
                  ERROR ("Trailing whitespace", 0);
                }
  {eol}         LINE (1);
  {blank}       SHADOW_STEP ();
  .             {}
}

<SC_CPP_COMMENT>
{
  {trailing_ws} {
                  LINE (1);
                  yy_pop_state ();
                  ERROR ("Trailing whitespace", 0);
                  STEP ();
                }
  {eol}         {
                  LINE (1);
                  yy_pop_state ();
                  STEP ();
                }
  {blank}       SHADOW_STEP ();
  .             {}
}

<SC_STRING>
{
  "\""          {
                  yy_pop_state ();
                  STEP ();
                }
  {trailing_ws} {
                  LINE (1);
                  ERROR ("Trailing whitespace", 0);
                  STEP ();
                }
  {eol}         {
                  LINE (1);
                  STEP ();
                }
  {blank}       STEP ();
  .             {}
}

<SC_LOOP_DEC>
{
  "("                   {
                          driver.par_count_inc ();
                          STEP ();
                        }
  ")"                   {
                          if (!driver.par_count_get ())
                            yy_push_state (SC_LOOP_EMPTY);
                          driver.par_count_dec ();
                          STEP ();
                        }
  {trailing_ws}         {
                          LINE (1);
                          ERROR ("Trailing whitespace", 0);
                          STEP ();
                        }
  {eol}                 {
                          LINE (1);
                          STEP ();
                        }
  ";"[^ ;\n]            {
                          ERROR ("Missing white space after ';' in loop", 0);
                          STEP ();
                          if (driver.colon_get ())
                            ERROR ("You can't have more than one statement per line", 0);
                          driver.colon_set (true);
                        }
  "."|"->"|"::"         STEP ();
  {type}                {
                          STEP ();
                          yy_push_state (SC_VARDEC);
                        }
  [^ +-]{bin_op}[^ -+>] {
                          ERROR ("Binary op is not padded", 1);
                          STEP ();
                        }
  {blank}               STEP ();
  .                     {}
}

<SC_LOOP_EMPTY>
{
  "("           {
                  driver.par_count_inc ();
                  STEP ();
                }
  ")"           {
                  driver.par_count_dec ();
                  STEP ();
                }
  {trailing_ws} {
                  LINE (1);
                  yy_pop_state ();
                  yy_pop_state ();
                  ERROR ("Trailing whitespace", 0);
                  STEP ();
                }
  {eol}         {
                  LINE (1);
                  yy_pop_state ();
                  yy_pop_state ();
                  STEP ();
                }
  ";"           {
                  ERROR ("After empty loop, semi colon must be on its own line", 0);
                  STEP ();
                }
  {blank}       STEP ();
  "{"           {
                  ERROR ("Braces must be on their own lines", 0);
                  STEP ();
                }
  .             {}
}


<SC_CLASS_DEC>
{
  "{"                 {
                        ERROR ("Braces must be on their own lines", 0);
                        STEP ();
                      }
  [A-Z]+{mix_case_id} STEP ();
  {id}                {
                        ERROR ("Bad class identifier. Must be 'LikeThis', not likethis", 1);
                        STEP ();
                      }
  {trailing_ws}       {
                        LINE (1);
                        yy_pop_state ();
                        ERROR ("Trailing whitespace", 0);
                        STEP ();
                      }
  {eol}               {
                        LINE (1);
                        yy_pop_state ();
                        STEP ();
                      }
  {blank}+            STEP ();
  .                   ERROR ("Unexpected token after class declaration", 1);
}


<SC_NAMESPACE>
{
  {low_case_id} STEP ();
  {id}          {
                  ERROR ("Invalid namespace name", 1);
                  STEP ();
                }
  "; "          {
                  ERROR ("Whitespace after semi-colon", 0);
                  yy_pop_state ();
                  STEP ();
                  if (driver.colon_get ())
                    ERROR ("You can't have more than one statement per line", 0);
                  driver.colon_set (true);
                }
  ";"           {
                  yy_pop_state ();
                  STEP ();
                  if (driver.colon_get ())
                    ERROR ("You can't have more than one statement per line", 0);
                  driver.colon_set (true);
                }
  {trailing_ws} {
                  LINE (1);
                  yy_pop_state ();
                  ERROR ("Trailing whitespace", 0);
                  STEP ();
                }
  {eol}         {
                  LINE (1);
                  yy_pop_state ();
                  STEP ();
                }
  {blank}       STEP ();
  "{"           {
                  ERROR ("Braces must be on their own lines", 0);
                  STEP ();
                }
  .             ERROR ("Unexpected token", 1);
}

<SC_DEFINE>
{
  {trailing_ws}   {
                    LINE (1);
                    yy_pop_state ();
                    ERROR ("Trailing whitespace", 0);
                    STEP ();
                  }
  {eol}           {
                    LINE (1);
                    yy_pop_state ();
                    STEP ();
                  }
  {blank}         STEP ();
  {macro}         {
                    yy_pop_state ();
                    STEP ();
                  }
  {id}            {
                    ERROR ("Invalid macro name", 1);
                    yy_pop_state ();
                    STEP ();
                  }
}

<SC_TYPEDEF>
{
  {trailing_ws}     {
                      LINE (1);
                      yy_pop_state ();
                      ERROR ("Invalide typedef name", 0);
                      ERROR ("Trailing whitespace", 0);
                      STEP ();
                    }
  {eol}             {
                      LINE (1);
                      yy_pop_state ();
                      ERROR ("Invalide typedef name", 0);
                      STEP ();
                    }
  {blank}           STEP ();
  {typedef_suffix}  {
                      yy_pop_state ();
                      STEP ();
                    }
  "; "              {
                      ERROR ("Invalide typedef name", 0);
                      ERROR ("Space after semi-colon", 0);
                      yy_pop_state ();
                      STEP ();
                      if (driver.colon_get ())
                        ERROR ("You can't have more than one statement per line", 0);
                      driver.colon_set (true);
                    }
  ";"               {
                      ERROR ("Invalide typedef name", 0);
                      yy_pop_state ();
                      STEP ();
                      if (driver.colon_get ())
                        ERROR ("You can't have more than one statement per line", 0);
                      driver.colon_set (true);
                    }
  .
}

<SC_IF_PREPROC>
{
  {trailing_ws}   {
                    LINE (1);
                    ERROR ("Trailing whitespace", 0);
                    driver.preproc_in_set (true);
                    STEP ();
                  }
  {eol}           {
                    LINE (1);
                    driver.preproc_in_set (true);
                    STEP ();
                  }
  {blank}+        STEP ();
  "#"             {
                    if (yylloc->first_column > 1)
                      ERROR ("Preprocessor directive mark must appear on the first column", 1);
                    STEP ();
                  }
  {macro_forbid}  {
                    if (driver.preproc_in_get () && yylloc->first_column != driver.preproc_get () + 2)
                      ERROR ("Preproc instructions must be indented correctly", 0);
                    driver.preproc_in_set (false);
                    STEP ();
                    ERROR ("You must not break the control flow inside a macro", 1);
                  }
  {preproc_if}    {
                    if (driver.preproc_in_get () && yylloc->first_column != driver.preproc_get () + 2)
                      ERROR ("Preproc instructions must be indented correctly", 0);
                    driver.preproc_inc ();
                    driver.preproc_in_set (false);
                    STEP ();
                  }
  "endif"         {
                    if (driver.preproc_in_get () && yylloc->first_column != driver.preproc_get () + 1)
                      ERROR ("Preproc instructions must be indented correctly", 0);
                    driver.preproc_dec ();
                    if (!driver.preproc_get ())
                    {
                      yy_pop_state ();
                      driver.preproc_in_set (false);
                    }
                    else
                      driver.preproc_in_set (false);
                    STEP ();
                  }
  {id}            {
                    if (driver.preproc_in_get () && yylloc->first_column != driver.preproc_get () + 2)
                      ERROR ("Preproc instructions must be indented correctly", 0);
                    driver.preproc_in_set (false);
                    STEP ();
                  }
  .               {
                    if (driver.preproc_in_get () && yylloc->first_column != driver.preproc_get () + 2)
                      ERROR ("Preproc instructions must be indented correctly", 0);
                    driver.preproc_in_set (false);
                  }
}

<SC_VARDEC>
{
  {public_attr}   {
                    if (driver.state_get () == PRIVATE || driver.state_get () == PROTECTED)
                      WARNING ("Identifier not conform to private / protected member norme.", 1);
                    STEP ();
                    yy_pop_state ();
                  }

  {private_attr}  {
                    if (driver.state_get () == PUBLIC)
                      WARNING ("Identifier not conform to public member norme", 1);
                    STEP ();
                    yy_pop_state ();
                  }
  ("&"|"*"){public_attr}   {
                    ERROR ("Pointers and references are part of the type", 1);
                    if (driver.state_get () == PRIVATE || driver.state_get () == PROTECTED)
                      WARNING ("Identifier not conform to private / protected member norme.", 1);
                    STEP ();
                    yy_pop_state ();
                  }

  ("&"|"*"){private_attr}  {
                    ERROR ("Pointers and references are part of the type", 1);
                    if (driver.state_get () == PUBLIC)
                      WARNING ("Identifier not conform to public member norme", 1);
                    STEP ();
                    yy_pop_state ();
                  }
  {trailing_ws}   {
                    LINE (1);
                    ERROR ("Trailing whitespace", 0);
                    driver.preproc_in_set (true);
                    STEP ();
                  }
  {eol}           {
                    LINE (1);
                    driver.preproc_in_set (true);
                    STEP ();
                  }
  {blank}         STEP ();
  "("             driver.par_count_inc (); STEP ();
  ")"             driver.par_count_dec (); STEP ();
  ","{eol}      LINE (1); STEP ();

  ","[ ]?       {
                  if (!driver.par_count_get () && driver.scope_count_get ())
                    ERROR ("Separating statements with commas is forbiden", 0);
                  if (yyleng == 1)
                    ERROR ("Coma must be followed by a blank", 0);
                  STEP ();
                }

  .               yy_pop_state ();
}


"class"     {
              STEP ();
              yy_push_state (SC_CLASS_DEC);
              if (driver.class_get ())
                ERROR ("You can't declare more than one class per file", 1);
              driver.class_set (true);
            }

"try"|"do"    SHADOW_STEP ();

"//"          SHADOW_STEP (); yy_push_state (SC_CPP_COMMENT);

"/*"          SHADOW_STEP (); yy_push_state (SC_C_COMMENT);

"\""          STEP (); yy_push_state (SC_STRING);

{loop}"("             ERROR ("Whitespace missing after loop KeyWord", 1); STEP (); yy_push_state (SC_LOOP_DEC);
{keyword_space}[^ \n\t]   ERROR ("Whitespace is missige after Keyword", 1); STEP ();

{trigraphs}           ERROR ("Trigraphs are forbiden", 1); STEP ();
{digraphs}            ERROR ("Digraphs are forbiden", 1); STEP ();
{forbiden_type_name}  ERROR ("Forbiden type name prefix", 1); STEP ();

{CRLF}                ERROR ("Forbiden carriage returns", 1); LINE (1); STEP ();

("goto"|"asm")        ERROR ("Forbiden Keyword", 1); STEP ();

{loop}[ \t]+"("       STEP (); yy_push_state (SC_LOOP_DEC);

{type}                STEP (); yy_push_state (SC_VARDEC);

{integer}     STEP ();

","{eol}      LINE (1); STEP ();

","[ ]?       {
                if (!driver.par_count_get () && driver.scope_count_get ())
                  ERROR ("Separating statements with commas is forbiden", 0);
                if (yyleng == 1)
                  ERROR ("Coma must be followed by a blank", 0);
                STEP ();
              }


{char_const}  STEP ();
"."           STEP ();
"->"          STEP ();
"::"          STEP ();

"("           driver.par_count_inc (); STEP ();
")"           driver.par_count_dec (); STEP ();

";"           {
                if (driver.colon_get ())
                  ERROR ("You can't have more than one statement per line", 0);
                driver.colon_set (true);
                STEP ();
              }


"#"{preproc_if} {
                  if (yylloc->first_column > 1)
                    ERROR ("Preprocessor directive mark must appear on the first column", 1);
                  driver.preproc_inc ();
                  driver.preproc_in_set (false);
                  STEP ();
                  yy_push_state (SC_IF_PREPROC);
                }


"#"           {
                if (yylloc->first_column > 1)
                  ERROR ("Preprocessor directive mark must appear on the first column", 1);
                STEP ();
              }

"["           STEP ();
"]"           STEP ();

"++"          STEP ();
"--"          STEP ();

"!"           STEP ();

"{"           {
                if (driver.something_get ())
                  ERROR ("Braces must be on their own lines", 0);
                driver.scope_count_inc ();
                STEP ();
                driver.brace_set (true);
              }

"}"           {
                if (driver.something_get ())
                  ERROR ("Braces must be on their own lines", 0);
                driver.scope_count_inc ();
                STEP ();
                driver.brace_set (true);
              }

"include"     STEP ();

"define"      STEP (); yy_push_state (SC_DEFINE);

"public:"     {
                if (driver.protected_get ())
                  ERROR ("Public attributs must appear *BEFORE* protected attributs", 0);
                if (driver.private_get ())
                  ERROR ("Public attributs must appear *BEFORE* private attributs", 0);
                driver.public_set (true);
                driver.state_set (PUBLIC);
                STEP ();
              }

"private:"    {
                driver.private_set (true);
                driver.state_set (PRIVATE);
                STEP ();
              }

"protected"   {
                if (driver.private_get ())
                  ERROR ("Protected attributs must appear *BEFORE* private attributs", 0);
                driver.protected_set (true);
                driver.state_set (PROTECTED);
                STEP ();
              }

"typedef"       STEP (); yy_push_state (SC_TYPEDEF);

"using"         ERROR ("using namespace is forbiden", 0); STEP ();

"namespace"     {
                  STEP ();
                  yy_push_state (SC_NAMESPACE);
                }

{op}              STEP ();
{bin_op}          yylval->s = yytext;
{low_case_id}     STEP ();
{upper_case_id}   STEP ();
{mix_case_id}     STEP ();

{public_attr}     {
                    if (driver.state_get () == PRIVATE || driver.state_get () == PROTECTED)
                      WARNING ("Identifier not conform to private / protected member norme.", 1);
                    STEP ();
                  }

{private_attr}    {
                    if (driver.state_get () == PUBLIC)
                      WARNING ("Identifier not conform to public member norme", 1);
                    STEP ();
                  }

{enum_use}        STEP ();

{bad_name}        ERROR ("Bad identifier", 1); STEP ();

{trailing_ws} LINE(1); ERROR ("Trailing whitespace", 0); STEP ();
{eol}         LINE(1); STEP ();
{blank}       STEP (); /* single whitespace for padding operators */
"_"           STEP ();

.             {ERROR ("Unexpected token", 1); STEP ();}

%%
