(in-package :examples/clos/fast)

(defgeneric binary-+ (x y)
  (:generic-function-class fast-generic-function))

(defmethod binary-+ ((x fixnum) (y fixnum))
  (declare (method-properties inlineable))
   (the fixnum (+ x y)))
