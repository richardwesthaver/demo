;;; demo.asd
(in-package #:asdf-user)

(defsystem "demo"
  :version "0.1.0"
  :author "ellis <ellis@rwest.io>"
  :maintainer "ellis <ellis@rwest.io>"
  :description ""
  :homepage "https://rwest.io/p/demo"
  :bug-tracker "https://gitlab.rwest.io/ellis/demo/issues"
  :source-control (:hg "https://gitlab.rwest.io/ellis/demo")
  :license "WTFPL"
  :depends-on ("demo/sys" "demo/db" "demo/ui" "demo/cli")
  :in-order-to ((test-op (test-op "src/test")))
  :build-pathname "demo")

(defsystem "demo/sys"
  :depends-on (:sxql :log4cl)
  :components ((:file "src/packages")
	       (:module "tk"
		:pathname "src/tk"
		:serial t
		:components ((:file "tk")
			     (:file "rs" :depends-on ("tk"))))))

(defmethod perform :after ((op load-op) (c (eql (find-system :demo))))
  (pushnew :demo *features*))

(defsystem "demo/cli"
  :depends-on (:clingon "demo/sys" "demo/ui" "demo/db")
  :components ((:file "src/cli")))
(defsystem "demo/ui"
  :depends-on (:clog "demo/sys" "demo/db")
  :components ((:file "src/ui")))
(defsystem "demo/db"
  :depends-on (:cl-dbi "demo/sys")
  :components ((:file "src/db")))			     			     

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
