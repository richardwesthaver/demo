(in-package :demo-utils)

(defun mkstr (&rest args)
  (with-output-to-string (s)
    (dolist (a args) (princ a s))))

(defun symb (&rest args)
  (values (intern (apply #'mkstr args))))

(defun random-id ()
  (format NIL "~8,'0x-~8,'0x" (random #xFFFFFFFF) (get-universal-time)))

(defun scan-dir (dir filename callback)
  (dolist (path (directory (merge-pathnames (merge-pathnames filename "**/") dir)))
    (funcall callback path)))

(defun sbq-reader (stream sub-char numarg)
  "The anaphoric sharp-backquote reader: #`((,a1))"
  (declare (ignore sub-char))
  (unless numarg (setq numarg 1))
  `(lambda ,(loop for i from 1 to numarg
		  collect (symb 'a i))
     ,(funcall
       (get-macro-character #\`) stream nil)))

(eval-when (:load-toplevel)
  (set-dispatch-macro-character
   #\# #\` #'sbq-reader))
