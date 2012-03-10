#include <vector>
#include <unistd.h>
#include "driver.hh"

namespace
{
  std::vector<std::string>*
  get_args (int argc, char** argv)
  {
    std::vector<std::string>* files = new std::vector<std::string> ();

    for (int i = 1; i < argc; i++)
      files->push_back (std::string (argv[i]));

    return files;
  }
}

int
main (int argc, char** argv)
{
  std::vector<std::string>* files = get_args (argc, argv);
  Driver d;

  if (!isatty (0))
    d.parse_stdin ();

  for (unsigned i = 0; i < files->size (); i++)
    d.parse_file ((*files)[i]);

  return 0;
}
