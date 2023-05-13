(in-package :demo)

(defvar *cargo-target* #p"/Users/ellis/dev/otom8/demo/target/")

(defvar *rs-macros* nil)

(defun mkstr (&rest args)
  (with-output-to-string (s)
    (dolist (a args) (princ a s))))

(defun symb (&rest args)
  (values (intern (apply #'mkstr args))))

(defun random-id ()
  (format NIL "~8,'0x-~8,'0x" (random #xFFFFFFFF) (get-universal-time)))

(defun scan-dir (dir filename callback)
  (dolist (path (directory (merge-pathnames (merge-pathnames filename "**/") dir)))
    (funcall callback path)))

(defun sbq-reader (stream sub-char numarg)
  "The anaphoric sharp-backquote reader: #`((,a1))"
  (declare (ignore sub-char))
  (unless numarg (setq numarg 1))
  `(lambda ,(loop for i from 1 to numarg
		  collect (symb 'a i))
     ,(funcall
       (get-macro-character #\`) stream nil)))

(eval-when (:execute)
  (set-dispatch-macro-character
   #\# #\` #'demo:sbq-reader))

;;; RUST MACROS
(defmacro rs-find-dll (name &optional debug)
  "Find the rust dll specified by NAME."
  (cond
    ((uiop:directory-exists-p (merge-pathnames *cargo-target* "release"))
     `,(mkstr "./target/release/" name))
    ((uiop:directory-exists-p  (merge-pathnames *cargo-target* "debug"))
     `,(mkstr "./target/debug/" name))
    (t `(progn
	 ,(uiop:run-program '("cargo" "build" (unless debug "--release")) :output t)
	 (rs-find-dll ,name ,debug)))))

(defun rs-mod-form (crate &optional mods pub)
  "Generate a basic mod form (CRATE . [MODS] [PUB])"
    `(,crate ,mods ,pub))

(defmacro with-rs-env (imports &body body)
  "Generate an environment for use within a Rust generator macro."
  `(let ((imports ,(mapcar #'rs-mod-form imports)))
     (format nil "~A~&~A" imports ',body)))

(defun rs-use (crate &optional mods pub)
  "Generate a single Rust use statement."
  (concatenate
   'string
   (if pub "pub " "")
   "use " crate "::{"
   (cond
     ((consp mods)
      (reduce
       (lambda (x y) (format nil "~A,~A" x y))
       mods))
     (t mods))
   "};"))

(defun rs-mod (mod &optional pub)
  "Generate a single Rust mod statement."
  (concatenate
   'string
   (if pub "pub " "")
   "mod " mod ";"))

(defun rs-imports (&rest imports)
  "Generate a string of Rust 'use' statements."
  (cond
    ((consp imports)
     (mapcar (lambda (x) (apply #'rs-use (apply #'rs-mod-form x))) imports))
    (t imports)))

(defmacro rs-extern-c-fn (name args &optional pub unsafe no-mangle &body body)
  "Generate a Rust extern 'C' fn."
  `(concatenate
   'string
   ,(when no-mangle (format nil "#[no_mangle]~&"))
   ,(when pub "pub ")
   ,(when unsafe "unsafe ")
   "extern \"C\" fn " ,name "("
   ,(cond
      ((consp args) (reduce (lambda (x y) (format nil "~A,~A" x y)) args))
      (t args))
   ")" "{" ,@body "}"))

(defun rs-obj-impl (obj)
  "Implement Objective for give OBJ."
  (format nil "impl Objective for ~A {};" obj))

;; (defun rs-macroexpand-1 (form &optional env))

;; (defun rs-macroexpand (env &rest body)
;;   "Cbindgen is quite the menace and really doesn't like our macros used
;; to generate C FFI bindings. To compensate for this, we use a tool
;; called cargo-expand by the most excellent dtolnay which expands Rust
;; macros. The expansions are assembled into an equivalent Rust source
;; file which cbindgen won't get stuck in an infinite compile loop on.")

;;; 
