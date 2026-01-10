load("@with_cfg.bzl", "with_cfg")

cc_dbg_test, _cc_dbg_test_internal = with_cfg(native.cc_test).set("compilation_mode", "dbg").build()

cc_opt_test, _cc_opt_test_internal = with_cfg(native.cc_test).set("compilation_mode", "opt").build()
