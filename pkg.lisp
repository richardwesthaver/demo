;; demo packages.lisp
(defpackage :demo-int
  (:use :cl :std))

(defpackage :demo
  (:use #:cl #:demo-int))

(std:defpkg :demo-user
  (:use-reexport :demo))
