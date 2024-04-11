;;; examples/db/tao.lisp --- Common Lisp implementation of the TAO data model

;; https://research.facebook.com/publications/tao-facebooks-distributed-data-store-for-the-social-graph/

;; a minimal Lisp implementation of TAO.

;;; Code:
(defpackage :examples/tao
  (:use :cl :std :rdb :log :obj/db :obj/graph :obj/id)
  (:export :run-tao))

(in-package :examples/tao)

(rdb::load-rocksdb)

(defvar *tao-directory* "/tmp/tao/")

(defvar *tao-log-dir*)
(defvar *tao-db-dir*)
(defvar *tao-cfs*
  (vector (make-rdb-cf "nodes")
          (make-rdb-cf "edges")))

(defun tao-path (path &optional (root *tao-directory*))
  (merge-pathnames path root))

(defclass tao-node (id)
  (key val))

(defclass tao-edge (edge) ())

(defclass tao-graph (graph) ())

(defclass tao-db (database)
  ((db :type rdb)))

(defclass tao (tao-db tao-graph)
  ((dir :initarg :dir)))

(defun ensure-tao-directories (&optional (root *tao-directory*))
  (setf *tao-log-dir* (ensure-directories-exist (tao-path "log/" root) :verbose t))
  root)

(defun init-tao-db (&optional (root *tao-directory*))
  (let ((db-dir (tao-path "db/" root)))
    (setf *tao-db-dir* db-dir)
    (create-db db-dir :cfs *tao-cfs*)))

(defun make-tao (&key (dir *tao-directory*))
  (make-instance 'tao
    :dir (setf *tao-directory* (ensure-tao-directories dir))
    :db (init-tao-db dir)))

(defun run-tao ()
  (let ((opts (default-rdb-opts))) ;; configure database options
    (set-opt opts "error-if-exists" 0)
    (set-opt opts "db-log-dir" "/tmp/log")
    (push-sap* opts)
    (let ((db (create-db "tao"
                         :opts opts
                         ;; :cfs (vector (make-rdb-cf "nodes")
                         ;;              (make-rdb-cf "edges"))
                         :open t)))
      (with-db (db db)
        (flush-db db)
        (let ((metadata (get-metadata db)))
          (info!
           (rdb::rocksdb-column-family-metadata-get-name metadata)
           (rdb::rocksdb-column-family-metadata-get-size metadata)
           (rdb::rocksdb-column-family-metadata-get-file-count metadata)
           (rdb::rocksdb-column-family-metadata-get-level-count metadata))
          (let ((lmeta (rdb::rocksdb-column-family-metadata-get-level-metadata metadata 0)))
            (info!
             (rdb::rocksdb-level-metadata-get-level lmeta)
             (rdb::rocksdb-level-metadata-get-size lmeta)
             (rdb::rocksdb-level-metadata-get-file-count lmeta))
            ;; TODO: requires file-count > 0
            ;; (let ((smeta (rdb::rocksdb-level-metadata-get-sst-file-metadata lmeta 0)))
            ;;   (info!
            ;;    (rdb::rocksdb-sst-file-metadata-get-directory smeta)
            ;;    (rdb::rocksdb-sst-file-metadata-get-relative-filename smeta)
            ;;    (rdb::rocksdb-sst-file-metadata-get-size smeta)
            ;;    (rdb::rocksdb-sst-file-metadata-get-smallestkey smeta)
            ;;    (rdb::rocksdb-sst-file-metadata-get-largestkey smeta))
            ;;   (rdb::rocksdb-sst-file-metadata-destroy smeta))
            (rdb::rocksdb-level-metadata-destroy lmeta))
          (rdb::rocksdb-column-family-metadata-destroy metadata))
        (info! (get-prop db "rocksdb.stats"))
        (close-db db))))
  (info! "TAO OK"))
