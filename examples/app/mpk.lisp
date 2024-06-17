;;; examples/app/mpk.lisp --- MPK demo

;;

;;; Code:
(in-package :user)
(defpkg mpk (:use :cl :std :dat :net :obj :log :rdb :packy))
(in-package :mpk)

(defvar *mpc*)

(defun mpc-init ()
  (let* ((conn (mpd:connect))
         (status (mpd:status conn)))
    (setq mpk::*mpc* conn)
    (format t "mpd state: ~A~%" (mpd:state conn))
    (values conn status)))

(defun play () (mpd:play *mpc*))
(defun stop () (mpd:stop *mpc*))
(defun pause () (mpd:pause *mpc*))

#+nil (mpc-init)
