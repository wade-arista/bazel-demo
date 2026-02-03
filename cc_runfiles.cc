#include <cassert>
#include <fstream>
#include <iostream>
#include <memory>
#include <sstream>
#include <string>

#include "rules_cc/cc/runfiles/runfiles.h"

using rules_cc::cc::runfiles::Runfiles;

int main(int argc, char** argv) {
   std::string error;
   std::unique_ptr<Runfiles> runfiles(Runfiles::Create(argv[0], &error));
   assert(runfiles != nullptr && "Failed to create runfiles");

   std::string path = runfiles->Rlocation("_main/runfile.txt");
   assert(!path.empty() && "Failed to locate runfile.txt");

   std::ifstream file(path);
   assert(file.is_open() && "Failed to open runfile.txt");

   std::stringstream buffer;
   buffer << file.rdbuf();
   std::string contents = buffer.str();

   assert(contents == "hello\n" && "Expected contents to be 'hello\\n'");

   std::cout << "Test passed: runfile.txt contains 'hello\\n'" << std::endl;
   return 0;
}
