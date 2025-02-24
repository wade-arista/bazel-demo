#include <Python.h>
#include "echo.h"

int
echo_helper_function() {
   return 0;
}

PyObject *
foo_echo(PyObject *self, PyObject *args) {
    int input;

    if (!PyArg_ParseTuple(args, "i", &input))
        return NULL;
    return PyLong_FromLong(input + echo_helper_function());
}

