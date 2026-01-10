#include "two.h"
#include "tools/cpp/runfiles/runfiles.h"
#include <iostream>
#include <string>

using bazel::tools::cpp::runfiles::Runfiles;

int main(int argc, char** argv) {
   std::string error;
   std::unique_ptr<Runfiles> runfiles(Runfiles::Create(argv[0], &error));
   if (runfiles == nullptr) {
      std::cerr << "Failed to create runfiles: " << error << std::endl;
      return 1;
   }

   // Find the path to liblibone.so in the runfiles
   // Note: _solib_k8 is platform-specific (k8 = x86_64)
   // On other platforms it could be _solib_darwin_arm64, etc.
   std::string libonePath = runfiles->Rlocation("_main/_solib_k8/liblibone.so");

   std::cout << "Path to liblibone.so: " << libonePath << std::endl;

   return two() - 2;
}
