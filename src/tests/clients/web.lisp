(in-package #:demo-tests)

(def-suite* :demo.web
  :in :demo)

(test web.index
      (is (= 2 2)))
