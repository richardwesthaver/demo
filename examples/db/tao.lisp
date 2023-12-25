;;; examples/db/tao.lisp --- Common Lisp implementation of the TAO data model

;; https://research.facebook.com/publications/tao-facebooks-distributed-data-store-for-the-social-graph/

;; a minimal Lisp implementation of TAO.

;;; Code:
(defpackage :examples/tao
  (:use :cl :std :cli :rdb)
  (:export :main))

(in-package :examples/tao)

(defmain ())
