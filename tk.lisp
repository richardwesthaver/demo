(in-package #:demo)

(defvar *cargo-target* #P"/Users/ellis/dev/otom8/demo/target/")

(defmacro find-rust-dll (name &optional debug)
  "Find the rust dll specified by NAME."
  (cond
    ((uiop:directory-exists-p (merge-pathnames *cargo-target* "release"))
     `,(mkstr "./target/release/" name))
    ((uiop:directory-exists-p  (merge-pathnames *cargo-target* "debug"))
     `,(mkstr "./target/debug/" name))
    (t (progn
	 (uiop:run-program `("cargo" "build" ,(unless debug "--release")) :output t)
	 `,(find-rust-dll name debug)))))

(defun random-id ()
  (format NIL "~8,'0x-~8,'0x" (random #xFFFFFFFF) (get-universal-time)))

(defun scan-dir (dir filename callback)
  (dolist (path (directory (merge-pathnames (merge-pathnames filename "**/") dir)))
    (funcall callback path)))

(defun mkstr (&rest args)
  (with-output-to-string (s)
    (dolist (a args) (princ a s))))

(defun symb (&rest args)
  (values (intern (apply #'mkstr args))))

(defun sbq-reader (stream sub-char numarg)
  "The anaphoric sharp-backquote reader: #`((,a1))"
  (declare (ignore sub-char))
  (unless numarg (setq numarg 1))
  `(lambda ,(loop for i from 1 to numarg
		  collect (symb 'a i))
     ,(funcall
       (get-macro-character #\`) stream nil)))

(eval-when (:execute)
  (set-dispatch-macro-character
   #\# #\` #'demo:sbq-reader))
