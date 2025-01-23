import foo


def check(value: int) -> None:
    assert value == foo.echo(value)
