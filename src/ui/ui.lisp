(in-package :demo-ui)

(defparameter ui-server-port 8080)
(defparameter ui-server-host "0.0.0.0")

(defclass ui-element (clog-element) ()
  (:documentation "UI Element Object."))

(defgeneric create-ui-element (obj &key hidden class id mode)
  (:documentation "Create a new ui-element as a child of OBJ."))
(defmethod create-ui-element ((obj clog:clog-obj)
			      &key (class nil)
				(hidden nil)
				(id nil)
				(mode 'auto))
  (let ((new (clog:create-div obj
			      :class class
			      :hidden hidden
			      :id id
			      :mode mode)))
    (clog:set-geometry new :width 200 :height 100)
    (change-class new 'ui-element)))
			      
(defun on-new-window (body)
  "Handle new window event."
  (clog:debug-mode body)
  (let ((elt (clog:create-child body "<h1>foobar</h1>")))
    (clog:set-on-click
     elt
     (lambda (o)
       (setf (clog:color elt) "green")))))

(defun start-ui ()
  "Start the UI."
  (clog:initialize #'on-new-window
		   :extended-routing t
		   :host ui-server-host
		   :port ui-server-port)
  (clog:open-browser))

(defun stop-ui ()
  "Stop the UI."
  (clog:shutdown))
