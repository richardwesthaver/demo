(in-package :cl-user)

;; For SBCL, if you don't have SBCL_HOME set, then we won't be able to require this later.
#+sbcl
(require 'sb-introspect)

(when (probe-file "tools/asdf.lisp")
  (format t "Compiling asdf..~%")
  (let ((output (compile-file "tools/asdf.lisp" :verbose nil :print nil)))
    (load output))
  (provide "asdf"))

(require "asdf")

#+sbcl
(require "sb-sprof")

#+nil
(push (pathname (format nil "~a/local-projects/poiu/" (namestring (uiop:getcwd))))
      asdf:*central-registry*)

(defvar *asdf-root-guesser* nil)

(defparameter *cwd* (merge-pathnames
               *default-pathname-defaults*
               (uiop:getcwd)))

(defun update-output-translations (root)
  "This function is called dynamically from deliver-utils/common.lisp!"
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

(defun %read-version (file)
  (let ((key "version: "))
   (loop for line in (uiop:read-file-lines file)
         if (string= key line :end2 (length key))
           return (subseq line (length key)))))

(defun init-quicklisp ()
  (let ((version (%read-version "quicklisp/dists/quicklisp/distinfo.txt")))
    (let ((quicklisp-loc (ensure-directories-exist
                          (merge-pathnames
                           (format nil "build/quicklisp/~a/" version)
                           *cwd*)))
          (src (merge-pathnames
                "quicklisp/"
                *cwd*)))
      (flet ((safe-copy-file (path &optional (dest path))
               (let ((src (merge-pathnames
                           path
                           "quicklisp/"))
                     (dest (merge-pathnames
                            dest
                            quicklisp-loc)))
                 (format t "Copying: ~a to ~a~%" src dest)

                 (when (equal src dest)
                   (error "Trying to overwrite the same file"))
                 (unless (uiop:file-exists-p dest)
                   (uiop:copy-file
                    src
                    (ensure-directories-exist
                     dest))))))
        (loop for name in
                       (append (directory
                                (merge-pathnames
                                 "quicklisp/quicklisp/*.lisp"
                                 *cwd*))
                               (directory
                                (merge-pathnames
                                 "quicklisp/quicklisp/*.asd"
                                 *cwd*)))
              do (safe-copy-file name
                                 (format nil "quicklisp/~a.~a"
                                         (pathname-name name)
                                         (pathname-type name))))
        (loop for name in (directory
                           (merge-pathnames
                            "quicklisp/*.lisp"
                            *cwd*))
              do (safe-copy-file name
                                 (format nil "~a.lisp"
                                         (pathname-name name))))
        (safe-copy-file "setup.lisp")
        (safe-copy-file "quicklisp/version.txt")
        (safe-copy-file "dists/quicklisp/distinfo.txt")
        (safe-copy-file "dists/quicklisp/enabled.txt")
        (safe-copy-file "dists/quicklisp/preference.txt"))
      (load (merge-pathnames
             "setup.lisp"
             quicklisp-loc)))))

(init-quicklisp)

#+nil
(ql:update-all-dists :prompt nil)

;; is the package name already loaded as a feature? uhh look it up
(pushnew :demo *features*)

(defun update-project-directories (cwd)
  (flet ((push-src-dir (name)
           (let ((dir (pathname (format nil "~a~a/" cwd name))))
             (when (probe-file dir)
               (push dir ql:*local-project-directories*)))))
    #-demo
    (push-src-dir "local-projects")
    (push-src-dir "src")
    (push-src-dir "third-party")
    (push-src-dir "lisp")))


(defun update-root (cwd)
  (update-output-translations cwd)
  (update-project-directories cwd))

(update-project-directories *cwd*)

(defun maybe-asdf-prepare ()
  (when *asdf-root-guesser*
    (update-root (funcall *asdf-root-guesser*))))

(compile 'maybe-asdf-prepare)

(defun unprepare-asdf (root-guesser)
  "This function is called dynamically from deliver-utils/common.lisp!"
  (setf *asdf-root-guesser* root-guesser))

(defun maybe-configure-proxy ()
  (let ((proxy (uiop:getenv "HTTP_PROXY")))
    (when (and proxy (> (length proxy) 0))
      (setf ql:*proxy-url* proxy))))

(maybe-configure-proxy)


(ql:quickload "log4cl")
(ql:quickload "prove-asdf")

(log:info "*local-project-directories: ~S" ql:*local-project-directories*)

;; (ql:quickload :cl-ppcre)
;; make sure we have build asd
#+nil
(push (pathname (format nil "~a/build-utils/" *cwd*))
      asdf:*central-registry*)
(ql:register-local-projects)
