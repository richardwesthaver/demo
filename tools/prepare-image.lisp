(in-package :cl-user)

;; For SBCL, if you don't have SBCL_HOME set, then we won't be able to require this later.
#+sbcl
(require 'sb-introspect)
#-sbcl
(require "asdf")

#+sbcl
(require "sb-sprof")

(defvar *cwd* (uiop:getcwd))

(defun update-output-translations (root)
  (asdf:initialize-output-translations
   `(:output-translations
     :inherit-configuration
     (,(namestring root)
      ,(format nil "~abuild/asdf-cache/~a/" root
               (uiop:implementation-identifier))))))

(update-output-translations *cwd*)

#+sbcl
(progn
  (require :sb-rotate-byte)
  (require :sb-cltl2)
  (asdf:register-preloaded-system :sb-rotate-byte)
  (asdf:register-preloaded-system :sb-cltl2))

(ql:update-all-dists :prompt nil)

;; is the package name already loaded as a feature? uhh look it up
(pushnew :demo *features*)

(defun update-project-directories (cwd)
  (flet ((push-src-dir (name)
           (let ((dir (pathname (format nil "~a~a/" cwd name))))
             (when (probe-file dir)
               (push dir ql:*local-project-directories*)))))
    #-demo
    (push-src-dir ".")
    (push-src-dir "vendor")))

(update-project-directories *cwd*)

(defun maybe-configure-proxy ()
  (let ((proxy (uiop:getenv "HTTP_PROXY")))
    (when (and proxy (> (length proxy) 0))
      (setf ql:*proxy-url* proxy))))

(maybe-configure-proxy)

(ql:quickload "log4cl")
(ql:quickload "prove-asdf")

(log:info "*local-project-directories: ~S" ql:*local-project-directories*)

(ql:register-local-projects)
