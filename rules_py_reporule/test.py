import importlib


def main():
    errors = []
    mod_names = (
        "foo",
        "bar",
        "baz",
    )
    mods = {}
    for name in mod_names:
        try:
            mods[name] = importlib.import_module(name)
        except ImportError as e:
            errors.append(e)

    assert not errors, f"import errors: {[str(e) for e in errors]}"

    for name in mod_names:
        print(f"{name}.name = ", mods[name].name)
        assert mods[name].name == name

if __name__ == "__main__":
    main()
