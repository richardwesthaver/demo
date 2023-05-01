;; demo.lisp
(in-package :cl-demo)

(defparameter demo-path (merge-pathnames "cl-demo" (uiop:temporary-directory)))

(defvar db-path (merge-pathnames "db" demo-path))

(defun cli-opts ()
  "Returns the top-level CLI options."
  (list
   (cli:make-option
    :string
    :description "demo app to run"
    :short-name #\x
    :long-name "app"
    :initial-value "client"
    :env-vars '("DEMO_APP")
    :key :app)))

(defun cli-handler (cmd)
  "Handler for the `demo' command."
  (let ((app (cli:getopt cmd :app)))
    (format t "running app: ~A!~%" app)))

(defun cli-cmd ()
  "Our demo command."
  (cli:make-command
   :name "demo"
   :description "A collection of demos"
   :version "1.0.0"
   :authors '("ellis <ellis@rwest.io>")
   :license "WTFPL"
   :options (demo/opts)
   :handler #'demo/handler))

(defun main ()
  "A demo of some common-lisp functionality."
  (cli:run (demo/cmd)))
