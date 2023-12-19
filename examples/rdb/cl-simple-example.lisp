;;; cl-simple-example.lisp --- Common Lisp port of rocksdb/example/c_simple_example.c

;; https://github.com/facebook/rocksdb/blob/main/examples/c_simple_example.c

;;; Code:
(defpackage :examples/rdb/cl-simple-example
  (:nicknames :cl-simple-example)
  (:use :cl :std :cli :rdb)
  (:export :main))

(in-package :cl-simple-example)

(defmain ())
