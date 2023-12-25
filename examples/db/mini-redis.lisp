;;; examples/db/mini-redis.lisp --- Mini-Redis client/server

;; based on https://github.com/no-defun-allowed/concurrent-hash-tables/blob/master/Examples/phony-redis.lisp

;;; Code:
(require 'sb-concurrency)
(defpackage :examples/mini-redis
  (:use :cl :std :net :obj :cli :sb-concurrency :sb-thread)
  (:export))

(in-package :examples/mini-redis)

(defun make-server ()
  (make-castable :test #'equal))

(defstruct conn tx rx)

(defun connect-to-server (server)
  (let ((tx (make-mailbox))
        (rx (make-mailbox)))
    (make-thread 
     (lambda ()
       (let ((msg (receive-message tx)))
         (loop do
           (case (car msg)
             (:quit (return))
             (:get 
              (multiple-value-bind (val p)
                  (obj/hash:cgethash (cdr msg) server)
                (if p
                    (send-message rx `(:found ,val))
                    (send-message rx `(:not-found)))))
             (:put
              (setf (cgethash (cadr msg) server)
                    (copy-seq (caddr msg)))
              (send-message rx '(:ok)))
             (t (return))))))
     :name "mini-redis-conn")
    (make-conn :tx tx :rx rx)))

(defun find-val (conn name)
  (send-message
   (conn-tx conn)
   `(:get ,name))
  (let ((rx (receive-message (conn-rx conn))))
    (case (car rx)
      (:found
       (values (cdr rx) t))
      (:not-found
       (values nil nil)))))

(defun (setf find-val) (val conn name)
  (send-message
   (conn-tx conn)
   `(:put ,name ,val))
  (receive-message
   (conn-rx conn)))

(defun close-conn (conn)
  (send-message
   (conn-tx conn)
   `(:quit)))

(defun worker (n server
               ready start
               writer-proportion names)
  (declare (optimize (speed 3))
           (single-float writer-proportion))
  (let ((name (elt names n))
        (bitmap (make-array 100
                            :element-type '(unsigned-byte 8)
                            :initial-element 0))
        (conn (connect-to-server server)))
    (dotimes (i 100)
      (setf (aref bitmap i)
            (if (< (random 1.0) writer-proportion)
                1
                0)))
    (signal-semaphore ready)
    (wait-on-semaphore start)
    (let ((position 0))
      (dotimes (o (the fixnum *ops*))
        (if (zerop (aref bitmap position))
            (find-val conn name)
            (setf (find-val conn name)
                  #(1)))
        (setf position (mod (1+ position) 100))))
    (close-conn conn)))

(defparameter *worker-count* 8)
(defparameter *writer-proportion* 0.5)
(defvar *keys*
  (loop for n below 130 by 2
        collect (format nil "~r" n)))
(defvar *other-keys*
  (loop for n from 1 below 128 by 2
        collect (format nil "~r" n)))
(defvar *ops* 10000000)

(defun run (&optional (worker-count *worker-count*)
              (writer-proportion *writer-proportion*)
              (keys *keys*))
  (let* ((ready (make-semaphore :name "ready-threads"))
         (start (make-semaphore :name "start-threads"))
         (server (make-server))
         (workers (loop for n below worker-count
                        collect (let ((n n))
                                  (make-thread
                                   (lambda ()
                                     (worker n server
                                             ready start
                                             writer-proportion
                                             keys)))))))
    (dotimes (n worker-count)
      (wait-on-semaphore ready))
    (let ((start-time (get-internal-real-time)))
      (signal-semaphore start worker-count)
      (mapc #'join-thread workers)
      (let* ((time (float (/ (- (get-internal-real-time) start-time)
                             internal-time-units-per-second)))
             (throughput (/ (* *ops* worker-count) time)))
        (format t "~&~20@a: ~$ seconds (~d transactions/second)"
                "mini-redis" time (round throughput))))))

(defmain ()
  (run 4 1.0 *keys*))
