#include <iostream>

#include "two.h"

using namespace std;

int main(int argc, char **argv) {
   auto v = demo::two();
   cout << "v=" << v << endl;
   return v == 2;
}
