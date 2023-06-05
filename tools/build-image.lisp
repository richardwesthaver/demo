(in-package :cl-user)

(load "tools/prepare-image.lisp")

(defvar *image-load-hook-contents* (uiop:read-file-string "tools/init.lisp"))
(defvar *hook-loaded-p* nil)

(defun image-load-hook ()
  ;; On MacOS, the TMPDIR variable can change between sessions.
  (uiop:setup-temporary-directory)

  #-sbcl
  (log4cl::init-hook)

  ;; If we used this image to deliver another image, we don't
  ;; want to load the same hook twice
  (unless *hook-loaded-p*
    (load (make-string-input-stream *image-load-hook-contents*))
    (setf *hook-loaded-p* t)))

(compile 'image-load-hook)

#+sbcl
(pushnew 'image-load-hook sb-ext:*init-hooks*)

(format t "Got command line arguments: ~S" (uiop:raw-command-line-arguments))

#-sbcl
(log4cl::save-hook)

#+sbcl
(sb-ext:save-lisp-and-die
 (namestring
  (make-pathname
   #+win32 :type #+win32 "exe"
   :defaults #P"build/sbcl-console"))
 :executable t)

#+ccl
(defun ccl-toplevel-function ()
  (image-load-hook)
  (let ((file (cadr ccl:*command-line-argument-list*)))
    (if file
     (load file :verbose t)
     (loop
           (print (eval (read)))))))


#+ccl
(ccl:save-application "build/ccl-console"
                      :toplevel-function 'ccl-toplevel-function)
