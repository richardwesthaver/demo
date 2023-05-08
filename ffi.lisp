(in-package :demo)

(define-foreign-library demo
  (:win32 (:default "demo"))
  (t (:default "libdemo")))

(use-foreign-library "./target/release/libdemo.dylib")
