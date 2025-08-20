;;; kraken.lisp --- Kraken public API

;; 

;;; Code:
(defpkg :examples/net/client/kraken
  (:nicknames :client/kraken)
  (:use :cl :std :net :obj :log :json :uri)
  (:export :*kraken-api*))

(in-package :client/kraken)

(defvar *kraken-api* (uri "https://api.kraken.com/0/public"))

(definline make-kraken-client () (make-instance 'http-client))

(defmethod make-client ((self (eql :kraken)) &key)
  (make-kraken-client))
