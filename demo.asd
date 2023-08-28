;;; demo.asd
(defsystem "demo"
  :version "0.1.0"
  :author "ellis <ellis@rwest.io>"
  :maintainer "ellis <ellis@rwest.io>"
  :description "comp demo system"
  :homepage "https://rwest.io/demo"
  :bug-tracker "https://lab.rwest.io/otom8/demo/issues"
  :source-control (:hg "https://lab.rwest.io/otom8/demo")
  :license "WTF"
  :depends-on (:sxp :log4cl :bordeaux-threads :clog)
  :in-order-to ((test-op (test-op "demo/tests")))
  :components ((:file "src/package")
	       (:file "src/cfg")))

(defmethod perform :after ((op load-op) (c (eql (find-system :demo))))
  (pushnew :demo *features*))

(defsystem "demo/cli"
  :depends-on ("demo" "clingon")
  :components ((:module "src/cli"
		:components ((:file "cli"))))
  :in-order-to ((test-op (test-op "demo/tests")))
  :build-operation "program-op"
  :build-pathname "bin/demo")

(defsystem "demo/tests"
  :depends-on ("demo" "demo-cli" "fiveam")
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
