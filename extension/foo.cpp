#include <Python.h>

#include "echo.h"

int helper_function() {
   return echo_helper_function();
}

static PyMethodDef FooMethods[] = {
    {"echo",  foo_echo, METH_VARARGS, "Echo an int."},
    {NULL, NULL, 0, NULL}
};

static struct PyModuleDef foomodule = {
    PyModuleDef_HEAD_INIT,
    "foo",  /* name of module */
    NULL,   /* module documentation, may be NULL */
    -1,     /* size of per-interpreter state of the module,
               or -1 if the module keeps state in global variables. */
    FooMethods
};

PyMODINIT_FUNC
PyInit_foo(void)
{
    return PyModule_Create(&foomodule);
}
