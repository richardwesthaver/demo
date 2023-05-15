;; demo.lisp
(in-package :demo)

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
    :key :app)
   (cli:make-option
    :string
    :description "path to config"
    :short-name #\c
    :long-name "config"
    :initial-value "$DEMO_PATH/.fig"
    :env-vars '("DEMO_CONFIG"))))

(defun cli-handler (cmd)
  "Handler for the `demo' command."
  (let ((app (cli:getopt cmd :app)))
    (format t "running: ~A!~%" app)))

(defun cli-cmd ()
  "Our demo command."
  (cli:make-command
   :name "demo"
   :description "A collection of demos"
   :version "1.0.0"
   :authors '("ellis <ellis@rwest.io>")
   :license "WTFPL"
   :options (cli-opts)
   :handler #'cli-handler))

(defun main ()
  "A demo of some common-lisp functionality."
  (cli:run (cli-cmd)))
