(in-package :demo)

(define-foreign-library demo_ffi
  (:win32 (:default "demo"))
  (t (:default "libdemo")))

;; (use-foreign-library "./target/release/libdemo_ffi.dylib")
