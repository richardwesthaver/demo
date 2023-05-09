L ?= sbcl
O ?= /tmp/demo
.PHONY:build
$(O):;mkdir -p $@
clean:;rm -rf *.fasl;scriipts/clean.ros
fmt:;scripts/fmt.ros
build:;scripts/build.ros
docs:;scripts/docs.ros
test:;scripts/test.ros
pack:;scripts/pack.ros
check:;scripts/check.ros
ci:clean fmt build docs test pack;
