#!/usr/local/bin/sbcl --script
(in-package :cl-user)
#-quicklisp
(let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))
(load "demo.asd")
(ql:quickload :demo)
;; (asdf:make :demo)
(sb-ext:save-lisp-and-die "out/demo" :toplevel #'demo:main :executable t)
