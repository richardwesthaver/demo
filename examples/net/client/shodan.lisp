;;; shodan.lisp --- Shodan API

;; https://developer.shodan.io/api

;;; Code:
(defpkg :examples/net/client/shodan
  (:nicknames :client/shodan)
  (:use :cl :std :net :obj :log :uri)
  (:export))

(in-package :client/shodan)

(defvar *shodan-api* (uri "https://api.shodan.io"))

(definline shodan-path (&rest paths) 
  (merge-uris 
   (namestring (reduce (lambda (x y) (merge-pathnames y (directory-path x))) paths))
   *shodan-api*))

(definline make-shodan-client () (make-instance 'http-client))

(defmethod make-client ((self (eql :shodan)) &key)
  (make-shodan-client))
