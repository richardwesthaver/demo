(in-package :demo)

(define-foreign-library demo_ffi
  (:win32 (:default "./target/release/demo_ffi"))
  (t (:default "./target/release/libdemo_ffi")))

(use-foreign-library demo_ffi)

