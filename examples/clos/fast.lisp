(in-package :examples/clos/fast)

;; (defclass foo (obj/meta/sealed:sealable-class)
;;   ((n :initform 0 :type fixnum :accessor foo-n)))

;; (defmethod binary-+ ((x foo) (y foo))
;;   (+ (foo-n x) (foo-n y)))

(defmethod binary-+ ((x fixnum) (y fixnum))
  (declare (method-properties inlineable))
  (+ x y))

(seal-domain #'binary-+ '(t t))
(binary-+ 0 0)

