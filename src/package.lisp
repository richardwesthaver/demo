;; demo packages.lisp
(defpackage :demo-sys)
(defpackage :demo-utils
  (:use :demo-sys)
  (:export
   #:source-dir
   #:random-id
   #:scan-dir)
  (:export
   #:*cargo-target*
   #:*rs-macros*
   #:rs-defmacro
   #:rs-macroexpand-1
   #:rs-macroexpand))
(defpackage :demo-db
  (:use :demo-sys)
  (:nicknames :ddb))
(defpackage :demo-ui
  (:use :demo-sys)
  (:export
   #:on-new-window
   #:start-ui))
(defpackage :demo-cli
  (:use :demo-sys)
  (:export
   #:run-cli
   #:demo-path
   #:db-path
   #:cli-opts
   #:cli-handler
   #:cli-cmd))
(defpackage :demo
  (:use #:cl #:demo-sys #:demo-utils #:demo-db #:demo-ui #:demo-cli)
  (:local-nicknames
   (#:bt #:bordeaux-threads)
   (#:cli #:clingon)))
(defpackage :demo-user
  (:use :demo #:cl-user))
