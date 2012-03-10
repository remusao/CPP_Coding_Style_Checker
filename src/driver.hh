
#ifndef DRIVER_HH_
# define DRIVER_HH_

# include <stdio.h>
# include <iostream>
# include <string>

/* Location type */
typedef struct
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} YYLTYPE;

/* Token type */
typedef enum
{
  OTHER,
  PRIVATE,
  PROTECTED,
  PUBLIC
} YYSTYPE;

/* Prototype of the yylex function*/
# define YY_DECL              \
  int yylex (Driver& driver)

/* Forward declaration of the class for yylex prototype */
class Driver;

/* Declare the prototype of yylex */
YY_DECL;



class Driver
{
  public:
    Driver ();
    ~Driver ();

    int parse_stdin ();
    int parse_file (std::string& file);

    void par_count_inc () { par_count_++; }
    void par_count_dec () { par_count_ = (par_count_ > 0 ? par_count_ - 1 : 0);}
    unsigned par_count_get () { return par_count_; }

    void scope_count_inc () { scope_count_++; }
    void scope_count_dec () { scope_count_ = (scope_count_ > 0 ? scope_count_ - 1 : 0);}
    unsigned scope_count_get () { return scope_count_; }

    void source_set (std::string* source) { source_ = source; }
    std::string* source_get () { return source_; }

    void public_set (bool s) { is_in_public_ = s; }
    bool public_get ()  { return is_in_public_; }

    void protected_set (bool s) { is_in_protected_ = s; }
    bool protected_get ()  { return is_in_protected_; }

    void private_set (bool s) { is_in_private_ = s; }
    bool private_get ()  { return is_in_private_; }

    void state_set (unsigned s) { current_state_ = s; }
    unsigned state_get () { return current_state_; }

    void class_set (bool s) { is_in_class_ = s; }
    unsigned class_get () { return is_in_class_; }

    void preproc_inc () { preproc_depth_++; }
    void preproc_dec () { preproc_depth_ = (preproc_depth_ > 0 ? preproc_depth_ - 1 : 0); }
    int  preproc_get () { return preproc_depth_; }

    void preproc_in_set (bool s) { preproc_in_ = s;}
    bool preproc_in_get () { return preproc_in_; }

    bool brace_get () { return brace_on_line_; }
    void brace_set (bool s) { brace_on_line_ = s; }

    void colon_set (bool s) { colon_on_line_ = s; }
    bool colon_get () { return colon_on_line_;}

    bool something_get () { return something_on_line_; }
    void something_set (bool s) { something_on_line_ = s; }

  public:

    YYLTYPE*    yylloc;

  private:

    void reset_ ();
    void print_header_ (std::string& header);

    std::string*  source_;
    unsigned      par_count_;
    unsigned      scope_count_;

    bool  colon_on_line_;
    bool  is_in_class_;
    bool  is_in_public_;
    bool  is_in_protected_;
    bool  is_in_private_;
    unsigned current_state_;

    bool  preproc_in_;
    int   preproc_depth_;

    bool brace_on_line_;
    bool something_on_line_;
};


# include "driver.hxx"

#endif /* !DRIVER_HH_ */
