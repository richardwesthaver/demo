M?=release
L?=sbcl
L_C=$(L) --no-userinit
L_S=$(L) --script
P?=python3
ARCH?=
A_C=ifeq ($(ARCH),x86_64) A_C=arch -$(ARCH) endif
.PHONY:
RS:Cargo.toml build.rs lib.rs obj
CL:*.asd *.lisp
deps:;
clean:;rm -rf *.fasl;cargo clean
fmt:$(RS);cargo fmt
build:$(RS) $(CL);cargo build --$(M);$L --load demo.asd \
	--eval '(ql:quickload :demo)' \
	--eval '(asdf:make :demo)' \
	--eval '(quit)'
ffi:build;cp target/$(M)/libdemo.dylib ffi;cd ffi;$(P) ffi/build.py
docs:$(RS);cargo doc
test:$(RS) $(CL);cargo test;$L tests.lisp
#pack:;scripts/pack.ros
#check:;scripts/check.ros
ci:clean fmt build ffi docs test;
