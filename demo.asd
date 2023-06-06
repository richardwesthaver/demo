;;; demo.asd
(in-package #:asdf-user)

(defsystem "demo/sys"
  :components ((:file "src/package")))

(defsystem "demo"
  :version "0.1.0"
  :author "ellis <ellis@rwest.io>"
  :maintainer "ellis <ellis@rwest.io>"
  :description ""
  :homepage "https://rwest.io/p/demo"
  :bug-tracker "https://lab.rwest.io/otom8/demo/issues"
  :source-control (:hg "https://lab.rwest.io/otom8/demo")
  :license "WTFPL"
  :depends-on ("demo/sys" :cl-dbi :sxql :log4cl :verbose :bordeaux-threads :clingon :clog)
  :in-order-to ((test-op (test-op "src/test")))
  :build-pathname "demo")

(defmethod perform :after ((op load-op) (c (eql (find-system :demo))))
  (pushnew :demo *features*))

(defsystem "demo/tests"
  :depends-on ("demo" "fiveam")
  :components ((:module "src/tests"
		:serial t
		:components
		((:file "package")
		 (:file "utils")
		 (:module "clients"
		  :serial t
		  :components
		  ((:file "cli")
		   (:file "web"))))))
  :perform (test-op (op component)
		    (uiop:symbol-call '#:demo-tests '#:run-tests)))
