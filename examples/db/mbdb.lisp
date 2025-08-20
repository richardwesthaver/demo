;;; examples/mbdb.lisp --- MusicBrainz Database import and analysis

;; This example show how to migrate a set of complex JSON objects and
;; SQL dumps to RocksDB using data from the MusicBrainz database
;; (https://musicbrainz.org/). The files are hosted at
;; https://packy.compiler.company/data

;;; Commentary:

;; The original data is located here:
;; https://data.metabrainz.org/pub/musicbrainz/data/

;; The actual json dumps are quite large (releas.json is 208Gb!), so
;; we provide our own trimmed down sampling. Each file is sampled
;; randomly and individually, so actual linkage data is totally
;; clobbered. If you want to work do some OLAP stuff you will need the
;; full data set which is packaged as mbdump-full.tar.zst.

;; the data prep script is located at ../mbdump-prep.lisp

;; we parsed some of the database schema from the sql files here:
;; https://github.com/metabrainz/musicbrainz-server/tree/master/admin/sql

;;; Code:
(in-package :std-user)
(defpkg :examples/mbdb
  (:use :cl :std :dat/json :obj/id :rdb :cli/clap :obj/uuid
   :log :dat/csv :dat/proto :sb-thread :db :ast)
  (:import-from :obj/uuid :make-uuid-from-string)
  (:import-from :cli/progress :with-progress-bar :make-progress-bar
   :*progress-bar* :*progress-bar-enabled* :update-progress)
  (:import-from :obj/time :parse-timestring :now :timestamp)
  (:import-from :log :info! :debug!)
  (:import-from :obj/uri :parse-uri)
  (:import-from :rocksdb :load-rocksdb)
  (:export :main))

(in-package :examples/mbdb)

(load-rocksdb t)

;;; Vars
(declaim (timestamp *mbdb-epoch*))
(defvar *mbdb-epoch* (now)
  "mbdb time of birth.")

;; (defvar *mbdb-logger* (make-logger))

(declaim (type pathname *mbdb-path*))
(defvar *mbdb-path* #P"/tmp/mbdb/")

(defvar *default-mbdb-opts*
  (let ((opts (default-rdb-opts)))
    (set-db-opt opts :enable-statistics 1)
    opts))

(declaim (rdb-database *mbdb*))
(defvar *mbdb* (make-db :rdb :path *mbdb-path* :opts *default-mbdb-opts* :open nil)
  "The local MusicBrainz database. The default value is an uninitialized
instance without any columns. Before use, make sure to open the
database and on exit the database must be closed.")

(declaim (oracle *mbdb-oracle*))
(defvar *mbdb-oracle* (multiple-value-bind (id thread) (make-oracle sb-thread:*current-thread*)
                        (declare (ignore id))
                        thread)
  "The oracle assigned to the mbdb system, which should usually be the current thread.")

(defvar *mbdb-tasks* nil
  "The mbdb task pool. This object holds a queue of jobs which are
dispatched to workers. Results are collected and processed by the
oracle.")

(defvar *mbsamp-pack-url* "https://packy.compiler.company/data/mbsamp.tar.zst"
  "Remote location of MusicBrainz ZST-compressed archive filled with TSV
files.")

(defvar *mbdump-base-url* "https://packy.compiler.company/data/mbdump/"
  "Remote location of MusicBrainz JSON data files.")

(defvar *mbdump-pack-url* "https://packy.compiler.company/data/mbdump.tar.zst"
  "Remote locaton of MusicBrainz JSON dump pack.")

(defvar *mbdb-worker-dir* (merge-pathnames ".import/" *mbdb-path*))

(defvar *mbdump-pack* (merge-pathnames "mbdump.tar.zst" *mbdb-worker-dir*))

(defvar *mbsamp-pack* (merge-pathnames "mbsamp.tar.zst" *mbdb-worker-dir*))

(defvar *mbdump-files* nil) ;; set by MBDB-UNPACK

(defvar *mbsamp-files* nil) ;; set by MBDB-UNPACK

;;; Fetch Data
(defun mbdump-fetch ()
  "Download mbdump data pack."
  (unless (probe-file *mbdump-pack*)
    (req:fetch
     *mbdump-pack-url*
     *mbdump-pack*)))

(defun mbsamp-fetch ()
  (unless (probe-file *mbsamp-pack*)
    (req:fetch *mbsamp-pack-url* *mbsamp-pack*)))

(defun mbsamp-unpack ()
  ;; unpack into mbsamp
  (let ((out-dir (merge-pathnames "mbsamp/" *mbdb-worker-dir*)))
    (unless (probe-file out-dir)
      (sb-ext:run-program "tar" `("-I" "zstd" "-xf" ,(namestring *mbsamp-pack*))
                          :directory *mbdb-worker-dir*
                          :search t
                          :wait t))
    (setq *mbsamp-files* (directory "/tmp/mbdb/.import/mbsamp/*"))))

(defun mbdump-unpack ()
  ;; unpack into mbsamp
  (let ((out-dir (merge-pathnames "mbdump/" *mbdb-worker-dir*)))
    (unless (probe-file out-dir)
      (sb-ext:run-program "tar" `("-I" "zstd" "-xf" ,(namestring *mbdump-pack*))
                          :directory *mbdb-worker-dir*
                          :search t
                          :wait t))
    (setq *mbsamp-files* (directory "/tmp/mbdb/.import/mbdump/*"))))

#+nil (extract-mbsamp (car (mbsamp-fetch)))

;;; Parsing

;;;; MBSamp
(define-constant +mbsamp-null+ "\\N" :test #'string=)

(defun nullable (str)
  (unless (string= +mbsamp-null+ str)
    (unless (= (length str) 0)
      str)))

(defun proc-key (type)
  (case (sb-int:keywordicate type)
    (:id 'make-uuid-from-string)
    (:url 'parse-uri)
    (:num 'parse-integer)
    (:*  'nullable)
    (t 'identity)))

(defun nullable-int (str)
  (parse-integer str :junk-allowed t))

(defun nullable-int* (str)
  (or (ignore-errors
       (parse-integer str :junk-allowed t))
      (nullable str)))

(defun nullable-time (str)
  (obj/time:parse-timestring str :date-time-separator #\Space :fail-on-error nil))

(defun nullable-uri (str)
  (or
   (ignore-errors
    (parse-uri str :escape nil))
   (nullable str)))

(defun mbsamp-schema (name &rest list)
  (cons name list))

(defvar *mbsamp-schema-table*
  (let ((tbl (make-hash-table :test #'equal)))
    (mapc (lambda (x)
            (setf (gethash (car x) tbl) (cdr x)))
          (list
           (mbsamp-schema
            "alternative_release_type"
            #'parse-integer nil #'nullable #'parse-integer nil #'make-uuid-from-string)
           (mbsamp-schema
            "artist"
            #'parse-integer #'make-uuid-from-string nil nil
            #'nullable-int #'nullable #'nullable #'nullable #'nullable  #'nullable
            #'nullable-int #'nullable-int #'nullable nil #'parse-integer
            #'nullable-time #'nullable-int #'nullable-int #'nullable)
           (mbsamp-schema
            "track"
            #'parse-integer #'make-uuid-from-string #'parse-integer #'parse-integer
            #'parse-integer #'nullable-int* nil #'parse-integer #'nullable-int
            #'parse-integer #'nullable-time #'parse-integer)
           (mbsamp-schema
            "recording"
            #'parse-integer #'make-uuid-from-string nil #'parse-integer
            #'nullable-int #'nullable-int* #'parse-integer #'nullable-time #'parse-integer)
           (mbsamp-schema
            "release"
            #'parse-integer #'make-uuid-from-string nil nil nil nil nil nil nil nil nil nil nil #'nullable-time)
           ;; (mbsamp-schema
           ;;  "url"
           ;;  #'parse-integer #'make-uuid-from-string #'nullable-uri #'parse-integer #'nullable-time)
           (mbsamp-schema
            "url" ;; 2,3
            #'parse-integer #'make-uuid-from-string #'nullable-uri nil nil)
           (mbsamp-schema
            "url_gid_redirect"
            #'make-uuid-from-string #'parse-integer #'nullable-time)
           (mbsamp-schema
            "tag"
            #'parse-integer nil #'parse-integer)
           (mbsamp-schema
            "genre"
            #'parse-integer #'make-uuid-from-string nil nil #'parse-integer #'nullable-time)
           (mbsamp-schema
            "work"
            #'parse-integer #'make-uuid-from-string nil #'nullable-int nil #'parse-integer #'nullable-time)
           (mbsamp-schema
            "instrument"
            #'parse-integer #'make-uuid-from-string nil #'nullable-int #'parse-integer #'nullable-time nil nil)
           ))
    tbl)
  "A Hashtable containing the various MusicBrainz table schemas of interest.")

(defun get-schema (schema) (gethash schema *mbsamp-schema-table*))

(defun extract-mbsamp (schema)
  "Extract the contents of FILE which is assumed to contain Tab-separated
values. Return a 2d array of row(values)."
  (let ((file (find schema *mbsamp-files* :test #'string= :key #'pathname-name))
        (map-fns (gethash schema *mbsamp-schema-table*)))
    (when file
      (dat/csv:read-csv-file file :header nil :delimiter #\Tab :map-fns map-fns))))

(defmacro with-mbsamp-proc (table shape &body vals)
  (with-gensyms (row i)
    `(coerce
      (loop for ,row across ,table
            for ,i below (length ,table)
            collect (make-array
                     ,shape
                     :initial-contents
                     (list
                      ,@(mapcar
                         (lambda (v) `(aref ,row ,v))
                         vals))))
      'vector)))

(defmacro def-mbsamp-proc (name &rest vals)
  (with-gensyms (table)
    (let ((fn-name (symbolicate "PROC-MBSAMP-" name)))
      `(defun ,fn-name (,table)
         ,(format nil "Process rows of ~A mbsamp data." name)
         (with-mbsamp-proc ,table ,(length vals) ,@vals)))))

(defvar *mbsamp-cfs*
  (vector (make-rdb-cf "url")
          (make-rdb-cf "genre")
          (make-rdb-cf "tag")
          (make-rdb-cf "track")
          (make-rdb-cf "artist")
          (make-rdb-cf "work")
          (make-rdb-cf "recording")
          (make-rdb-cf "release")
          (make-rdb-cf "instrument")))

(def-mbsamp-proc url 0 1 2)
(def-mbsamp-proc genre 0 1 2)
(def-mbsamp-proc tag 0 1 2)
(def-mbsamp-proc track 0 1 6)
(def-mbsamp-proc artist 0 1 2)
(def-mbsamp-proc work 0 1 4 6)
(def-mbsamp-proc recording 0 1 2 7)
(def-mbsamp-proc release 0 1 2 13)
(def-mbsamp-proc instrument 0 1 2 5 7)

;;;; MBDump
(defun extract-mbdump-file (file)
  "Extract the contents of a json-dump FILE. Return a json-object."
  (with-open-file (f file)
    ;; (sb-impl::with-array-data
    (loop for x = (json-read f nil)
          while x
          collect x)))

(defun extract-mbdump-columns (obj)
  "Extract fields from a json-object, returning a vector of
  uninitialized column-families which can be created with #'create-cfs.

Returns multiple values: the list of columns, the id, and type-id if present."
  (values
   (mapcar (lambda (x) (make-rdb-cf (car x))) (ast obj))
   (make-uuid-from-string (json-getf obj "id"))
   (when-let ((tid (json-getf obj "type-id")))
     (make-uuid-from-string tid))))

;;; Tasks
(defvar *mbdb-buffer-size* 4096)

(defclass mbdb-task (task) ())

(defclass mbdb-stage (stage) ())

;;; Main
(defmain start-mbdb ()
  (let ((*default-pathname-defaults* *mbdb-path*)
        (*progress-bar-enabled* t)
        (*csv-separator* #\Tab)
        (*cpus* (num-cpus))
        (*log-timestamp* nil)
        (*log-level* :info))
    (log:info! "Welcome to MBDB")
    (ensure-directories-exist *mbdb-worker-dir* :verbose t)
    ;; prepare workers
    (setq *mbdb-oracle* (make-oracle sb-thread:*current-thread*))
    (setq *mbdb-tasks* (make-task-pool (num-cpus)))
    ;; (make-workers
    ;; (push-worker (make-thread #'?) *mbdb-tasks*)

    ;; (with-tasks ())

    ;; fetch
    ;; (let ((job (make-job (make-array 2 :fill-pointer 0 :initial-element (make-task) :element-type 'task))))
    ;;   (push-task (make-task #'mbsamp-fetch) job)
    ;;   (push-task (make-task #'mbdump-fetch) job)
    ;;   (push-job job *mbdb-tasks*))
    ;; ;; unpack
    ;; (let ((job (make-job (make-array 2 :fill-pointer 0 :initial-element (make-task) :element-type 'task))))
    ;;   (push-task (make-task #'mbsamp-unpack) job)
    ;;   (push-task (make-task #'mbdump-unpack) job)
    ;;   (push-job job *mbdb-tasks*))
    ;; (sb-thread:make-thread #'mbsamp-fetch)

    ;; prepare column family data
    
    ;; initialize database
    (with-db (db :db *mbdb*)
      (open-db db)
      (setf (rdb::columns db) *mbsamp-cfs*)
      (backfill-opts db)
      (log:info! "database initialized"))
    ;; launch tasks
    
    ;; wait
    (unwind-protect
         (progn
           (wait-for-threads (workers *mbdb-tasks*))
           ;; summarize
           (when-let ((stats (print-stats *mbdb*))) (info! "mbdb stats" stats)))
      ;; close
      (close-db *mbdb*))))

