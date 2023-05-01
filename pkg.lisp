#|
cl-demo

> (cl-demo:main)
|#

(defpackage #:cl-demo
  (:use #:cl)
  (:local-nicknames
   (#:rdb #:cl-rocksdb)
   (#:v #:org.shirakumo.verbose)
   (#:bt #:bordeaux-threads)
   (#:cli #:clingon))
  ;; db.lisp
  (:export
   ;; #:make-db
   ;; #:with-db
   ;; #:db
   )
  ;; demo.lisp
  (:export
   #:main
   #:demo-path
   #:db-path
   #:cli-opts
   #:cli-handler
   #:cli-cmd)
  ;; ui.lisp
  (:export
   #:on-new-window
   #:start-ui)
  ;; tk.lisp
  (:export
   #:random-id
   #:scan-dir))
