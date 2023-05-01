L ?= sbcl
O ?= /tmp/cl-demo
.PHONY:build
$(O):;mkdir -p $@
clean:;rm -rf out *.fasl;cargo clean
build:;scripts/build.ros
docs:;scripts/docs.ros
test:;scripts/test.ros
pack:;scripts/pack.ros
ci:clean build docs test pack;
