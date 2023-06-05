(in-package #:demo-tests)

(def-suite* :demo.cli
  :in :demo)

(test cli.args
      (is (= 2 2)))
