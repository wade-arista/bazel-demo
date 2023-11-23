#include <iostream>

#include "one.h"
#include "two.h"
#include "three.h"

using namespace std;

int main(int argc, char **argv) {
   cout << "intermediate: " << one() + two() << endl;
   cout << "result: " << three() << endl;
   return three() != one() + two();
}
