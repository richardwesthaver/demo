(in-package #:demo-tests)

(def-suite* :demo.utils
  :in :demo)

(defun gen-word ()
  (gen-one-element "lorem" "ipsum"))

(defun gen-text-element ()
  (let ((word (gen-word)))
    (lambda ()
      (case (random 10)
        (9 #\Newline)
        (t (funcall word))))))

(defun gen-text (&key (length (gen-integer :min 1 :max 20))
                      (element (gen-text-element)))
  (let ((elements (gen-list :length length :elements element)))
    (lambda ()
      (with-output-to-string (stream)
        (loop for previous = nil then element
              for element in (funcall elements)
              do (cond ((and previous (not (eql previous #\Newline)) (not (eql element #\Newline)))
                        (write-char #\Space stream)
                        (write-string element stream))
                       (t ; (and (eql previous #\Newline) (not (eql element #\Newline)))
                        (princ element stream))))))))

(defun gen-offset (&key (integer (gen-integer :min -10 :max 10)))
  (lambda ()
    (case (random 10)
      ((8 9 10) nil)
      (t        (funcall integer)))))

(defun gen-margin (&key (integer (gen-integer :min 1 :max 10)))
  (lambda ()
    (case (random 10)
      ((8 9 10) nil)
      (t        (funcall integer)))))

(defun gen-count (&key (integer (gen-integer :min 1 :max 10)))
  (lambda ()
    (case (random 10)
      ((8 9 10) nil)
      (t        (funcall integer)))))

