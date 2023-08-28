;; demo packages.lisp

(defpackage :demo-core
  (:use :cl))

(defpackage :demo-utils
  (:use :demo-core)
  (:export
   #:source-dir
   #:random-id
   #:scan-dir
   #:*cargo-target*
   #:*rs-macros*
   #:rs-defmacro
   #:rs-macroexpand-1
   #:rs-macroexpand))

(defpackage :demo-db
  (:use :demo-core))

(defpackage :demo-ui
  (:use :demo-core)
  (:export
   #:on-new-window
   #:start-ui))

(defpackage :demo
  (:use #:cl #:demo-core #:demo-utils #:demo-db #:demo-ui)
  (:local-nicknames
   (#:bt #:bordeaux-threads)))

(defpackage :demo-cli
  (:use :demo :clingon))

(defpackage :demo-user
  (:use :demo))
