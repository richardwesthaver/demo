(in-package #:cl-demo)

(defun random-id ()
  (format NIL "~8,'0x-~8,'0x" (random #xFFFFFFFF) (get-universal-time)))

(defun scan-dir (dir filename callback)
  (dolist (path (directory (merge-pathnames (merge-pathnames filename "**/") dir)))
    (funcall callback path)))
