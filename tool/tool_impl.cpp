// Copyright (c) 2024 Arista Networks, Inc.  All rights reserved.
// Arista Networks, Inc. Confidential and Proprietary.

#include <cerrno>
#include <cstring>
#include <dlfcn.h>
#include <fstream>
#include <iostream>
#include <limits.h>
#include <unistd.h>

using namespace std;

static void
show_pwd()
{
  char buffer[PATH_MAX];

  // Get the current working directory
  if (getcwd(buffer, sizeof(buffer)) != nullptr) {
    cerr << "Current working directory: " << buffer << endl;
  } else {
    cerr << "getcwd: " << strerror(errno) << endl;
  }
}

static int
call_plugin()
{
  auto handle = dlopen("compilerplugin.so", RTLD_LAZY);
  if (handle == NULL) {
    cerr << "dlopen: " << dlerror() << endl;
    exit(1);
  }
  dlerror();

  int (*plugin)();
  plugin = (int (*)())dlsym(handle, "plugin");
  if (plugin == NULL) {
    cerr << "dlsym: " << dlerror() << endl;
    exit(1);
  }

  auto ret = plugin();
  dlclose(handle);
  return ret;
}

int
main(int argc, char** argv)
{
  if (argc < 2) {
    cerr << "Usage: " << argv[0] << " OUT-FILE [IN-FILE...]" << endl;
    return 2;
  }

  show_pwd();

  ofstream outf;
  auto out_fn = argv[1];
  cerr << "output filename: " << out_fn << endl;
  outf.open(out_fn, fstream::out | fstream::trunc);
  if (not outf.is_open()) {
    cerr << "Error opening output file: " << strerror(errno) << endl;
    return 1;
  }

  for (int p = 2; p < argc; p++) {
    ifstream inf;
    auto in_fn = argv[p];
    cerr << "input filename: " << in_fn << endl;
    inf.open(in_fn);
    if (not inf.is_open()) {
      cerr << "Error opening input file: " << strerror(errno) << endl;
      return 1;
    }

    outf << inf.rdbuf();
    if (inf.fail() or outf.fail()) {
      cerr << "Error writing output file: " << strerror(errno) << endl;
      return 1;
    }
    outf.flush();
    inf.close();
  }

  outf << "plugin says: " << call_plugin() << endl;
  if (outf.fail()) {
    cerr << "Error writing output file: " << strerror(errno) << endl;
    return 1;
  }
  outf.close();
}
