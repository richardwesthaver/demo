;;; nws.lisp --- National Weather Service

;; https://www.weather.gov/documentation/services-web-api

;;; Code:
(defpkg :examples/net/client/nws
  (:nicknames :client/nws)
  (:use :cl :std :net :obj :log :json :uri)
  (:export :forecast-endpoints))
(in-package :client/nws)

(defvar *nws-api* (uri "https://api.weather.gov"))

(definline nws-path (&rest paths)
  (merge-uris 
   (namestring (reduce (lambda (x y) (merge-pathnames y (directory-path x))) paths))
   *nws-api*))

(defun nws-openapi () (deserialize (req:get (nws-path "openapi.json") :force-string t) :openapi))

(definline make-nws-client () (make-instance 'http-client))

(defmethod make-client ((self (eql :nws)) &key)
  (make-nws-client))

(definline make-point (x y) (format nil "~A,~A" x y))

(defun forecast-endpoints (x y)
  "Return the forecast endpoints for coordinates (X,Y) as three separate values:

(FORECAST FORECAST-HOURLY FORECAST-GRID-DATA)"
  (let ((props (json-getf 
                (json-decode 
                 (net/req:get 
                  (nws-path "points" (make-point x y)) 
                  :force-string t)) 
                "properties")))
    (values
     (json-getf props "forecast")
     (json-getf props "forecastHourly")
     (json-getf props "forecastGridData"))))
