(asdf:defsystem "cl-demo"
  :version "1.0.0"
  :author "ellis <ellis@rwest.io>"
  :maintainer "ellis <ellis@rwest.io>"
  :description ""
  :homepage "https://rwest.io/p/cl-demo"
  :bug-tracker "https://gitlab.rwest.io/ellis/cl-demo/issues"
  :source-control (:hg "https://gitlab.rwest.io/ellis/cl-demo")
  :license "WTFPL"
  :depends-on (:bordeaux-threads
	       #+(or ccl sbcl)
	       :clack
	       :caveman2
	       :clog
	       :cl-rocksdb
	       :verbose
	       :alexandria
	       :cl-ppcre
	       :cffi
	       :clingon)
  :serial T
  :components ((:file "pkg")
	       (:file "tk")
	       (:file "db")
	       (:file "ui")
	       (:file "demo"))
  ;; :in-order-to ((test-op (test-op "cl-demo/tests")))
  ;; :defsystem-depends-on (:deploy)
  ;; :build-operation "deploy"
  :build-pathname "cl-demo"
  :entry-point "cl-demo:main")

;; (asdf:defsystem "cl-demo:tests"
  ;; :depends-on ("cl-demo" "fiveam")
  ;; :components ((:file "tests"))
  ;; :perform (test-op (o c) (symbol-call :fiveam '#:run! :cl-demo))
  ;; )
