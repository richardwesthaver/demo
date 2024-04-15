(in-package :std-user)

(defpkg :examples/clos/sealed
    (:use :cl :std :obj/meta/sealed))

;; (defpkg :examples/clos/fast
;;   (:use :cl :std :obj/meta/fast))

(defpkg :examples/clos/stealth
  (:use :cl :std :obj/meta/stealth))

(defpkg :examples/clos/filtered
  (:use :cl :std :obj/meta/filtered))

(defpkg :examples/clos
  (:use :cl :std :obj)
  (:use-reexport :examples/clos/sealed :examples/clos/stealth :examples/clos/filtered))
