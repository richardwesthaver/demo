;; (defun is-prime(n)
;;   (do ((num 2 (+ num 1)))
;;       ((> num (/ n 2)) t)
;;     (if (= 0 (mod n num))
;; 	(return-from is-prime nil))))

;; (defun kth-prime(k)
;;   (do ((candidate 2 (+ candidate 1)))
;;       ((< k 1) (- candidate 1))
;;     (when (is-prime candidate)
;;       (decf k))))

;; (time (kth-prime 10000))

;; (declaim (inline is-prime))
;; (defun is-prime (n)
;;   (loop for num of-type fixnum from 3 to (isqrt n) by 2
;;         when (zerop (mod n num))
;;         return nil
;;         finally (return t)))

;; (defun kth-prime (k)
;;   (declare (optimize (speed 3) (safety 0))
;;            (fixnum k))
;;   (if (zerop k)
;;       2
;;       (loop for candidate of-type fixnum from 3 by 2
;;             when (<= k 0) return (- candidate 2)
;;             when (is-prime candidate) do (decf k))))

;; (declaim
;;   (optimize (speed 3) (safety 0))
;;   (inline is-prime))

;; (defun is-prime(n)
;;   (declare (fixnum n))
;;   (do ((num 2 (+ num 1)))
;;       ((> num (floor n 2)) t)
;;     (declare (fixnum num))
;;     (if (= 0 (mod n num))
;;       (return-from is-prime nil))))

;; (defun kth-prime(k)
;;   (declare (fixnum k))
;;   (do ((candidate 2 (+ candidate 1)))
;;       ((< k 1) (- candidate 1))
;;     (declare (fixnum candidate))
;;     (when (is-prime candidate)
;;       (decf k))))

;; (time (kth-prime 10000))

(declaim (inline is-prime))
(defun is-prime (n)
  (loop for num of-type fixnum from 2 to (ash n -1)
        when (zerop (mod n num))
          return nil
        finally (return t)))

(defun kth-prime (k)
  (declare (optimize (speed 3) (safety 0))
           (fixnum k))
  (loop for candidate of-type fixnum from 2
        when (<= k 0) return (1- candidate)
          when (is-prime candidate) do (decf k)))

(time (kth-prime 10000))
