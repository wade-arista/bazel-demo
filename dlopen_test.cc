// Copyright (c) 2025 Arista Networks, Inc.  All rights reserved.
// Arista Networks, Inc. Confidential and Proprietary.

#include <cassert>
#include <cstdlib>
#include <dlfcn.h>
#include <iostream>
#include <unistd.h>
#include <filesystem>
#include <linux/limits.h>
#include <errno.h>
#include <cstring>

using namespace std;
using namespace std::filesystem;

int main( int argc, char **argv ){
   char buf[PATH_MAX];

   for ( int i = 0; i < 2; i++ ) {
      path p( getcwd( buf, sizeof( buf ) ) );
      cout << "getcwd: " << p << endl;
      cout << "LD_LIBRARY_PATH: " << getenv( "LD_LIBRARY_PATH" ) << endl;
      auto lib = dlopen( "bar.so", RTLD_LAZY | RTLD_GLOBAL );
      if ( lib == nullptr ) {
         cout << "dlopen: " << dlerror() << endl;
         return 1;
      }
      cout << "lib: " << lib << endl;
      dlclose( lib );
      cout << "chdir(/)" << endl;
      chdir( "/" );
   }
   return 0;
}
