#include <Python.h>

#include <iostream>

int helper_function();

int main(int argc, char **argv) {
   std::cout << "helper: " << helper_function() << std::endl;
   return 0;
}
