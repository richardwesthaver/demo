L ?= sbcl
O ?= /tmp/cl-demo
.PHONY:build
$(O):;mkdir -p $@
clean:;rm -rf out *.fasl;cargo clean
build:;ros/build.ros
docs:;ros/docs.ros
test:;ros/test.ros
pack:;ros/pack.ros
ci:clean build docs test pack;
