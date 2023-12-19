;;; cl-simple-example.lisp --- Common Lisp port of rocksdb/example/c_simple_example.c

;; ref: https://github.com/facebook/rocksdb/blob/main/examples/c_simple_example.c

;;; Usage: 

;; To compile and run from the shell:
#|
sbcl --eval '(ql:quickload :rdb)' \
     --eval '(ql:quickload :cli)' \
     --eval '(compile-file "cl-simple-example.lisp")' \
     --eval '(load "cl-simple-example.fasl")' \
     --eval "(sb-ext:save-lisp-and-die \"cl-simple-example\" :toplevel #'cl-simple-example::main :executable t)"

time ./cl-simple-example

# real	0m0.030s
# user	0m0.012s
# sys	0m0.017s
|#

;; Compare to C:
#|
# in rocksdb/examples
gcc -lrocksdb c_simple_example.c -oc_simple_example

time ./c_simple_example

# real	0m0.021s
# user	0m0.006s
# sys	0m0.015s
|#

;;; Code:
(defpackage :examples/rdb/cl-simple-example
  (:nicknames :cl-simple-example)
  (:use :cl :std :cli :rdb :sb-alien :rocksdb)
  (:export :main))

(rocksdb:load-rocksdb :save t)

(in-package :cl-simple-example)

(in-readtable :std)

(defvar *num-cpus* (alien-funcall (extern-alien "sysconf" (function long integer)) sb-unix:sc-nprocessors-onln)
  "CPU count.")

(defparameter *db-path* "/tmp/rocksdb-cl-simple-example")

(defparameter *db-backup-path* "/tmp/rocksdb-cl-simple-example-backup")

(defmain ()
  ;; open Backup Engine that we will use for backing up our database
  (let ((options 
          (make-rocksdb-options 
                  (lambda (opt)
                    (rocksdb-options-increase-parallelism opt *num-cpus*) ;; set # of online cores
                    (rocksdb-options-optimize-level-style-compaction opt 0)
                    (rocksdb-options-set-create-if-missing opt 1)))))
  (with-open-backup-engine-raw (be *db-backup-path* options)
    ;; open DB
    (with-open-db-raw (db *db-path* options)
      ;; put key-value
      (put-kv-str-raw db "key" "value")
      ;; get value
      (string= (get-kv-str-raw db "key") "value")
      ;; create new backup in a directory specified by *db-backup-path*
      (create-new-backup-raw be db))
    ;; if something is wrong, you might want to restore data from last backup
    (restore-from-latest-backup-raw be *db-path* *db-backup-path*))))
