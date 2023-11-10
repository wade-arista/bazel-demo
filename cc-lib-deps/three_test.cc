#include <iostream>

#include "three.h"

using namespace std;

int main(int argc, char **argv) {
   auto v = demo::three();
   cout << "v=" << v << endl;
   return v == 3;
}
