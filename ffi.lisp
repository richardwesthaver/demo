(in-package :demo)

(define-foreign-library demo
  (:win32 (:default "demo"))
  (t (:default "libdemo")))

(defun install-demo-lib (&optional path)
  (if path
      (use-foreign-library path)
      (let ((path (rs-find-dll "libdemo.dylib")))
	(use-foreign-library path))))
