(defpackage #:demo-tests
  (:use #:demo #:fiveam)
  (:shadowing-import-from #:fiveam #:test)
  (:export #:run-tests))

(in-package #:demo-tests)

(def-suite :demo)

(defun run-tests ()
  (run! :demo))
