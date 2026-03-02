;;; examples/net/yoctochat.lisp --- Yoctochat Implementation

;; The tiniest (lisp) chat server on earth!

;; based on https://github.com/robn/yoctochat

;; A 'yoctochat' server will:

;; - take a single commandline argument, the port to listen on
;; - open a listening port
;; - handle multiple connections and disconnections on that port
;; - receive text on a connection, and forward it on to all ofhter connections
;; - produce simple output about what it's doing
;; - demonstrate a single IO multiplexing technique as simply as possible
;; - be well commented!

;;; Commentary:

;; This implementation is based on the yc_uring.c implementation which
;; uses io_uring. To use io_uring from Lisp, we use the high-level IO
;; package, which internally calls foreign functions defined in the
;; URING package.

;; 

;;; Code:
(defpackage :examples/yoctochat
  (:use :cl :std :net :cli :io :log :sb-alien)
  (:import-from :uring :load-uring))

(in-package :examples/yoctochat)

;; To start using the IO package we should make sure the liburing
;; shared library is properly loaded. This function takes care of that
;; and arranges for the library to be remembered when entering a saved
;; lisp image such that it will be automatically re-opened.
(load-uring t)

;; Initialize a simple logger to report on what's happening.
;; (setq *logger* (make-logger nil))

;; Define some parameters for the queue depth and maximum number of
;; connections allowed on a single server.
(defparameter *num-conns* 128)

(defparameter *queue-depth* (* 2 *num-conns*))

(defclass yc-server (server)
  ((connections :initform nil ::type sequence))
  (:documentation "The Yoctochat Server. "))

;; The main loop of our yoctochat server. The 'defmain' macro will
;; produce a function 'main' which can be saved as an executable
;; entry-point.
(defmain start-yoctochat ()
  (init-io *queue-depth*)
  (setf *io* nil))



