L ?= sbcl
O ?= /tmp/demo
.PHONY:build
$(O):;mkdir -p $@
clean:;rm -rf out *.fasl;cargo clean
build:;scripts/build.ros
docs:;scripts/docs.ros
test:;scripts/test.ros
pack:;scripts/pack.ros
check:;scripts/check.ros
ci:clean build docs test pack;
