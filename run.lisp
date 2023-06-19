(defparameter *cwd* (asdf:system-source-directory :demo))
(load (merge-pathnames "tools/build-image.lisp" *cwd*))
