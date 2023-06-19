# otom8/demo makefile
MODE?=release
LISP?=sbcl
CFG?=default.cfg
L_C=$(L) --no-userinit
L_D=$(L) --load demo.asd --eval '(ql:quickload "demo")'
L_S=$(L) --script
ARCH?=
A_C=ifeq ($(ARCH),x86_64) A_C=arch -$(ARCH) endif
.PHONY:build
RS:Cargo.toml rustfmt.toml src/crates/*
CL:*/*.asd */*.lisp
deps:;
clean:;rm -rf */*.fasl;cargo clean
fmt:$(RS);cargo fmt
build:$(RS) $(CL);cargo build --$(MODE);$(L_D)
	--eval '(asdf:make "demo")' \
	--eval '(quit)'
docs:$(RS);cargo doc
test:$(RS) $(CL);cargo test;$(L_D) --eval '(asdf:test "demo")' --eval '(quit)'
#pack:;scripts/pack.ros
#check:;scripts/check.ros
ci:clean fmt build docs test;
