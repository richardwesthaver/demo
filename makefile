M ?= release #mode
L ?= sbcl #lisp
P ?= python3 #python
RS:Cargo.toml build.rs lib.rs obj fig
CL:*.asd *.lisp
clean:;rm -rf *.fasl;cargo clean
fmt:$(RS);cargo fmt
build:$(RS) $(CL);cargo build --$(M);$L --script install.lisp
ffi:build;cp target/$(M)/libdemo.dylib ffi;cd ffi;$(P) ffi/build.py
docs:$(RS);cargo doc
test:$(RS) $(CL);cargo test;$L tests.lisp
#pack:;scripts/pack.ros
#check:;scripts/check.ros
ci:clean fmt build ffi docs test;
.PHONY:build
