#include <iostream>

using namespace std;
extern "C"
{
  int plugin()
  {
    auto ret = 1;
    cout << "plugin returns " << ret << endl;
    return ret;
  }
}
