(asdf:defsystem "demo"
  :version "1.0.0"
  :author "ellis <ellis@rwest.io>"
  :maintainer "ellis <ellis@rwest.io>"
  :description ""
  :homepage "https://rwest.io/p/demo"
  :bug-tracker "https://gitlab.rwest.io/ellis/demo/issues"
  :source-control (:hg "https://gitlab.rwest.io/ellis/demo")
  :license "WTFPL"
  :depends-on (:bordeaux-threads
	       #+(or ccl sbcl)
	       :clack
	       :clog
	       :clog-web
	       :cl-rocksdb
	       :verbose
	       :alexandria
	       :cl-ppcre
	       :cffi
	       :clingon)
  :serial T
  :components ((:file "pkg")
	       (:file "ffi")
	       (:file "tk")
	       (:file "cfg")
	       (:file "db")
	       (:file "ui")
	       (:file "demo"))
  ;; :in-order-to ((test-op (test-op "demo/tests")))
  ;; :defsystem-depends-on (:deploy)
  ;; :build-operation "deploy"
  :build-pathname "demo"
  :entry-point "demo:main")

;; (asdf:defsystem "cl-demo:tests"
  ;; :depends-on ("cl-demo" "fiveam")
  ;; :components ((:file "tests"))
  ;; :perform (test-op (o c) (symbol-call :fiveam '#:run! :cl-demo))
  ;; )
