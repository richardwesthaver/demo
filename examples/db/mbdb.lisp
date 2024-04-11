;;; examples/mbdb.lisp --- MusicBrainz Database import and analysis

;; This example show how to migrate a set of complex JSON objects to
;; RocksDB using a dump from the MusicBrainz database
;; (https://musicbrainz.org/). The files are hosted at
;; https://packy.compiler.company/data/mbdump

;;; Code:
(defpackage :examples/mbdb
  (:use :cl :std :dat/json :net/fetch :obj/id :rdb :cli/clap :obj/uuid)
  (:import-from :log :info! :debug!)
  (:import-from :rocksdb :load-rocksdb)
  (:export :main))

(in-package :examples/mbdb)

(load-rocksdb t)

(declaim (type pathname *mbdb-path*))
(defvar *mbdb-path* #P"/tmp/mbdb/")
(defvar *mbdb* (create-db *mbdb-path* :opts (default-rdb-opts)))

(defvar *mbdump-base-url* "https://packy.compiler.company/data/mbdump/"
  "Remote location of MusicBrainz JSON data files.")

(defvar *mbdump-files*
  (mapcar (lambda (f) (make-pathname :name f :type "json" :directory *mbdump-base-url*))
          (list "area" "artist" "event" "instrument"
                "label" "place" "recording" "release"
                "release-group" "series" "work")))

(defun extract-columns (obj)
  "Extract fields from a JSON-OBJECT, returning a vector of
  uninitialized column-families which can be created with CREATE-CFS.

Returns multiple values: the list of columns, the id, and type-id if present."
  (values
   (mapcar #'car (json-object-members obj))
   (make-uuid-from-string (json-getf obj "id"))
   (when-let ((tid (json-getf obj "type-id")))
     (make-uuid-from-string tid))))

(defmain ()
  (let ((*default-pathname-defaults* (ensure-directories-exist *mbdb-path* :verbose t)))
    (log:info! "Welcome to MBDB")
    (with-db (db *mbdb*)
      (open-db db)
      (close-db db))))
