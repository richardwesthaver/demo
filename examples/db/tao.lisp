;;; tao.lisp --- Common Lisp implementation of the TAO data model

;; https://research.facebook.com/publications/tao-facebooks-distributed-data-store-for-the-social-graph/

;;; Code:
(defpackage :examples/rdb/tao
  (:nicknames :tao)
  (:use :cl :std :cli :rdb)
  (:export :main))

(in-package :tao)

(defmain ())
