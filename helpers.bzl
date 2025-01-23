# Take an input shared library and remove the RUNPATH information.
def make_lib(name, src, out):
    native.genrule(
        name = name,
        srcs = [src],
        outs = [out],
        cmd = "cp -v $< $@ && chmod u+w $@ && chrpath -d $@",
    )
