(in-package :demo)
(defun on-new-window (body)
  "Handle new window event."
  (let ((elt (clog:create-child body "<h1>foobar</h1>")))
    (clog:set-on-click
     elt
     (lambda (o)
       (setf (clog:color elt) "green")))))

(defun start-ui ()
  "Start the UI."
  (clog:initialize #'on-new-window)
  (clog:open-browser))
