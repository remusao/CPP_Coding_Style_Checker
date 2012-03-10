

#include "driver.hh"

extern FILE* yyin;

Driver::Driver ()
  : source_ (0),
    par_count_ (0),
    scope_count_ (0),
    colon_on_line_ (false),
    is_in_class_ (false),
    is_in_public_ (false),
    is_in_protected_ (false),
    is_in_private_ (false),
    current_state_ (OTHER),
    preproc_in_ (false),
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
  source_ = 0;
  par_count_ = 0;
  scope_count_ = 0;
}

void
Driver::print_header_ (std::string& s)
{
  std::cout
    << std::endl
    << "\033[34mFile\033[37m : " << s << std::endl
    << "\033[35m"
    << "_______________________________" << std::endl
    << "\033[37m"
    << std::endl;
}


int
Driver::parse_file (std::string& file)
{
  print_header_ (file);
  source_ = &file;
  yyin = fopen(file.c_str (), "r");
  yyparse (*this);
  reset_ ();

  return 0;
}

int
Driver::parse_stdin ()
{
  yyin = stdin;
  source_ = new std::string ("Stdin");
  yyparse (*this);
  delete source_;
  reset_ ();

  return 0;
}