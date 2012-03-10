

#include "driver.hh"

extern FILE* yyin;

Driver::Driver ()
  : yylloc (new YYLTYPE ()),
    source_ (0),
    par_count_ (0),
    scope_count_ (0),
    colon_on_line_ (false),
    is_in_class_ (false),
    is_in_public_ (false),
    is_in_protected_ (false),
    is_in_private_ (false),
    current_state_ (OTHER),
    preproc_in_ (false),
    sharp_on_line_ (false),
    preproc_depth_ (0),
    brace_on_line_ (false),
    something_on_line_ (false)
{
}

Driver::~Driver ()
{
}

void
Driver::reset_ ()
{
  yyin = stdin;

  delete yylloc;
  yylloc = new YYLTYPE ();

  source_ = 0;
  par_count_ = 0;
  scope_count_ = 0;

  colon_on_line_ = false;
  is_in_class_ = false;
  is_in_public_ = false;
  is_in_protected_ = false;
  is_in_private_ = false;
  current_state_ = OTHER;

  preproc_in_ = false;
  preproc_depth_ = 0;

  brace_on_line_ = false;
  something_on_line_ = false;

}


void
Driver::print_header_ (std::string& s)
{
  std::cout
    << std::endl
    << "\033[34mSource\033[37m : " << s << std::endl
    << "\033[35m"
    << "_______________________________" << std::endl
    << "\033[37m"
    << std::endl;
}


int
Driver::parse_file (std::string& file)
{
  source_ = &file;
  print_header_ (*source_);
  yyin = fopen(file.c_str (), "r");

  while (yylex (*this))
    ;

  reset_ ();

  return 0;
}


int
Driver::parse_stdin ()
{
  source_ = new std::string ("StdIn");
  print_header_ (*source_);

  while (yylex (*this))
    ;

  delete source_;
  reset_ ();

  return 0;
}
