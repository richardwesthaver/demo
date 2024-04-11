(in-package :cl-user)

(load "tools/prepare-image.lisp")

(defvar *image-load-hook-contents* (uiop:read-file-string "tools/init.lisp"))
(defvar *hook-loaded-p* nil)

(defun image-load-hook ()
  ;; On MacOS, the TMPDIR variable can change between sessions.
  (uiop:setup-temporary-directory)
  ;; If we used this image to deliver another image, we don't
  ;; want to load the same hook twice
  (unless *hook-loaded-p*
    (load (make-string-input-stream *image-load-hook-contents*))
    (setf *hook-loaded-p* t)))

(compile 'image-load-hook)

(pushnew 'image-load-hook sb-ext:*init-hooks*)

(format t "Got command line arguments: ~S" (uiop:raw-command-line-arguments))

(sb-ext:save-lisp-and-die
 (namestring
  (make-pathname
   #+win32 :type #+win32 "exe"
   :defaults #P"build/sbcl-console"))
 :executable t)
