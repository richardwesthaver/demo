;;; bench.lisp --- Core Benchmarks

;; 

;;; Code:
(in-package :std-user)

(defpkg :demo/bench/ironclad
  (:nicknames :bench/ironclad)
  (:use :cl :ironclad)
  (:export :ironclad-benchmark))

(defpkg :demo/bench/tpc-h                 
  (:nicknames :tpc-h)            
  (:import-from :obj/time :date)              
  (:use :cl :std :rt :log :schema :dat)
  (:export :*tpc-h-data-directory*            
   :tpc-h-schema :tpc-h-benchmark             
   :+tpc-h-region-count+ :+tpc-h-nation-count+
   :read-nation-table :read-region-table      
   :read-part-table :read-supplier-table      
   :read-partsupp-table :read-customer-table  
   :read-orders-table :read-lineitem-table))

(defpkg :bench/lan-party
  (:use :cl :std :net/srv/udp :log :json :obj :rdb :net :graph)
  (:export :lan-party :lan-party-config :lan-node :emacs-lan-node))

(defpkg :demo/bench
  (:nicknames :bench)
  (:use :std-lisp :rt :log)
  (:export :run-benchmark))
