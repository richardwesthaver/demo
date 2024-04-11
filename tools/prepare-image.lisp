(in-package :cl-user)

(require :sb-introspect)
(require :asdf)
(require :sb-sprof)
(require :sb-rotate-byte)
(require :sb-cltl2)
(asdf:register-preloaded-system :sb-rotate-byte)
(asdf:register-preloaded-system :sb-cltl2)
(asdf:register-preloaded-system :std)
(asdf:register-preloaded-system :log)

(ql:update-all-dists :prompt nil)

(pushnew :demo *features*)

(ql:quickload :prelude)
(ql:register-local-projects)
(log:info! "*local-project-directories:" ql:*local-project-directories*)

