M ?= release
L ?= sbcl
P ?= python3

RS:Cargo.toml build.rs lib.rs obj fig
CL:*.asd *.lisp
.PHONY:build
clean:;rm -rf *.fasl;cargo clean
fmt:;cargo fmt
build:$(RS) $(CL);cargo build --$(M);$L install.lisp
ffi:build;cp target/$(M)/libdemo.dylib ffi;cd ffi;$(P) ffi/build.py
docs:$(RS);cargo doc
test:$(RS);cargo test
#pack:;scripts/pack.ros
#check:;scripts/check.ros
ci:clean fmt build ffi docs test;
