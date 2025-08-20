;;; examples/mbdump.lisp --- Prepare a sampling of mbdump JSON data

;; WIP

;;; Commentary:

;; - considering sampling 'releases.json' only. could be a really good
;;   benchmark. For now we will sample all files. Soon, we may split
;;   releases.json into separate files here which is rather trivial
;;   anyway.

;; - using uiop:read-file-line is NOT the right thing to do. This is
;;   too bad because I implemented a specialized stream class and then
;;   deleted it before committing.

;; - there are two possible solutions I can think of:

;;   - single-pass :: for each file, read the first line and calculate
;;     the minimal space needed to store a json object in a single
;;     line. Instead of incrementing over every character to find the
;;     next line, we move the position once by the minimum space, then
;;     iterate over characters until we find a newline. We walk the
;;     entire file and pick up the random indexes.

;;   - double-pass :: for each file, read each line character by
;;     character, counting new lines. At each random index calculate
;;     and collect the file position. Do a second pass which sets the
;;     file position on each iteration before reading a line.

;;; Code:
(defpackage :mbdump
  (:use :cl :std :log :dat/json :cli/clap :obj/time :sb-gray)
  (:export :main :*target*))

(in-package :mbdump)

;; Ultimately we dump the samples to this directory. It should be
;; roughly 1/10th the original size.
#| (in-readtable :shell)
du -sh data/mbdump # 242G
du -sh /tmp/mbdump # 24G
|#
(defvar *mbdump-directory* (pathname "/opt/store/data/sets/mbdump-full/"))

(defun init-mbdump-files (&optional (dir *mbdump-directory*))
  "Count the total number of lines in each file under DIR. Return a
hash-table containing filenames->line counts.

This is single-threaded so it does take some time on the full mbdump
dataset. If you run this make sure to assign the resulting value to
*MBDUMP-FILES*, otherwise use the pre-compiled value."
  (let ((files (find-files dir))
        (table (make-hash-table :test 'equal)))
    (mapc (lambda (f)
            (setf (gethash (file-namestring f) table) (count-file-lines f)))
          files)
    table))

(defvar *mbdump-files* (let ((pairs '(("area.json" . 119164)
                                      ("artist.json" . 2345810)
                                      ("event.json" . 78896)
                                      ("instrument.json" . 1046)
                                      ("label.json" . 271609)
                                      ("place.json" . 63772)
                                      ("recording.json" . 119575)
                                      ("release-group.json" . 3204634)
                                      ("release.json" . 4111554)
                                      ("series.json" . 23376)
                                      ("work.json" . 2078152)))
                             (table (make-hash-table :test 'equal)))
                         (dolist (pair pairs table)
                           (setf (gethash (car pair) table) (cdr pair)))))

(defvar *target-directory* (pathname (concatenate 'string "/tmp/mbdump-" (file-date) "/")))

(defvar *target* nil)

(defun random-line-indexes (max &optional (count 1000))
  (declare (fixnum max count))
  (let ((ret))
    (labels ((%gen () (let ((int (random max)))
                        (when (zerop int) (setf int 1))
                        (if (find int ret)
                            (%gen)
                            int))))
      (sort 
       (dotimes (i count ret)
         (setf ret (cons (%gen) ret)))
       #'<))))

(defun prep-json-file (file)
  (let* ((in-path (merge-pathnames file *mbdump-directory*))
         (out-path (merge-pathnames file *target-directory*))
         (max (gethash (namestring file) *mbdump-files*))
         (count (floor max 10))
         (lines (random-line-indexes (gethash (namestring file) *mbdump-files*)))
         (res (cons out-path count)))
    (with-open-files ((out out-path :direction :output :external-format '(:utf-8 :replacement "?"))
                      (in in-path :direction :input :external-format '(:utf-8 :replacement "?")))
      (loop for i in lines
            with line = (uiop:read-file-line in :at i)
            do (print (file-position in))
            do (write-line line out)))
    (push res *target*)))

(defmain start-mbdump ()
  (ensure-directories-exist *target-directory*)
  (let ((workers))
    (dolist (file (hash-table-keys *mbdump-files*) workers)
      (push (make-thread (lambda () (prep-json-file file)) :name (format nil "~A prep" file)) workers))
    (time (wait-for-threads workers))))

;; (prep-json-file "label.json")
