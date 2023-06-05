;; demo packages.lisp
(defpackage :demo-user
  (:use :demo))

(defpackage :demo
  (:use #:cl #:demo-ui #:demo-cli #:demo-tk #:demo-db)
  (:local-nicknames
   (#:v #:org.shirakumo.verbose)
   (#:bt #:bordeaux-threads)
   (#:cli #:clingon)))

(defpackage :demo-ui
  (:use)
  (:export
   #:on-new-window
   #:start-ui))
(defpackage :demo-tk
  (:use)
  (:export
   #:source-dir
   #:random-id
   #:scan-dir
   #:mkstr
   #:symb
   #:sbq-reader)
  (:export
   #:*cargo-target*
   #:*rs-macros*
   #:rs-defmacro
   #:rs-macroexpand-1
   #:rs-macroexpand))
(defpackage :demo-cli
  (:use)
  (:local-nick
  (:export
   #:run-cli
   #:demo-path
   #:db-path
   #:cli-opts
   #:cli-handler
   #:cli-cmd))
(defpackage :demo-db
  (:use))
