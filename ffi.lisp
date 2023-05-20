(in-package :demo)
(defparameter quiche-lib-path #p"./ffi/libquiche.dylib")
(defparameter rocksdb-lib-path #p"./ffi/librocksdb.dylib")
(defparameter demo-lib-path (find-rs-cdylib "libdemo.dylib"))
(defmacro find-rs-cdylib (name &optional debug)
  "Find the rust dll specified by NAME."
  (cond
    ((uiop:directory-exists-p (merge-pathnames *cargo-target* "release"))
     `,(mkstr "./target/release/" name))
    ((uiop:directory-exists-p  (merge-pathnames *cargo-target* "debug"))
     `,(mkstr "./target/debug/" name))
    (t `(progn
	 ,(uiop:run-program '("cargo" "build" (unless debug "--release")) :output t)
	 (find-rs-cdylib ,name ,debug)))))

(define-foreign-library demo
  (:win32 (:default "demo"))
  (t (:default "libdemo")))
(define-foreign-library quiche
  (:win32 (:default "quiche"))
  (t (:default "libquiche")))
(define-foreign-library rocksdb
  (:win32 (:default "rocksdb"))
  (t (:default "librocksdb")))

(defun load-libdemo () (load-foreign-library (find-rs-cdylib "libdemo.dylib")))
(defun install-quiche-lib (&optional path) (load-foreign-library (or path quiche-lib-path)))
(defun install-rocksdb-lib (&optional path) (load-foreign-library (or path rocksdb-lib-path)))
