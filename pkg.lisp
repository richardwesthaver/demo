#|
demo
> (demo:main)
|#
(defpackage :demo
  (:use #:cl #:cffi)
  (:local-nicknames
   ;;   (#:rdb #:cl-rocksdb)
   (#:v #:org.shirakumo.verbose)
   (#:bt #:bordeaux-threads)
   (#:cli #:clingon))
  ;; db.lisp
  ;; (:export
  ;;  #:create-options
  ;;  #:destroy-options
  ;;  #:increase-parallelism
  ;;  #:optimize-level-style-compaction
  ;;  #:set-create-if-missing
  ;;  #:create-writeoptions
  ;;  #:destroy-writeoptions
  ;;  #:create-readoptions
  ;;  #:destroy-readoptions
  ;;  #:open-db
  ;;  #:close-db
  ;;  #:cancel-all-background-work
  ;;  #:put-kv
  ;;  #:put-kv-str
  ;;  #:get-kv
  ;;  #:get-kv-str
  ;;  #:create-iter
  ;;  #:destroy-iter
  ;;  #:move-iter-to-first
  ;;  #:move-iter-forward
  ;;  #:move-iter-backword
  ;;  #:valid-iter-p
  ;;  #:iter-key
  ;;  #:iter-key-str
  ;;  #:iter-value
  ;;  #:iter-value-str
  ;;  #:with-open-db
  ;;  #:with-iter)
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
   #:source-dir
   #:random-id
   #:scan-dir
   #:mkstr
   #:symb
   #:sbq-reader)
  ;; rs.lisp
  (:export
   #:*cargo-target*
   #:*rs-macros*
   #:rs-defmacro
   #:rs-macroexpand-1
   #:rs-macroexpand)
  ;; ffi.lisp
  ;; (:export
  ;;  #:quiche-lib-path
  ;;  #:rocksdb-lib-path
  ;;  #:demo-lib-path
  ;;  #:find-rs-cdylib
  ;;  #:install-demo-lib
  ;;  #:install-quiche-lib
  ;;  #:install-rocksdb-lib)
  )
