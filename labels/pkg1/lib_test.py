from lib import foo
from lib_extra import foo as foo_extra

assert foo() == foo_extra()
