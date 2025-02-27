// Copyright (c) 2025 Arista Networks, Inc.  All rights reserved.
// Arista Networks, Inc. Confidential and Proprietary.

#ifndef BAZEL_DEMO_HELPER_H
#define BAZEL_DEMO_HELPER_H

#include "mylib.h"

static inline int getTheValue() {
   return MyLib::myLibValue();
}

#endif // BAZEL_DEMO_HELPER_H
