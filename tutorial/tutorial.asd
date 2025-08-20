;;; ~/comp/demo/tutorial/tutorial.asd --- Tutorial Sytem Definitions
(defsystem :tutorial
  :depends-on (:std :log)
  :components ((:file "intro")))
