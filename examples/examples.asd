(defsystem :examples
  :depends-on (:prelude)
  :components 
  ((:module "clos"
    :components ((:file "pkg")
                 (:file "sealed")
                 (:file "stealth")
                 ;; (:file "fast-def")
                 ;; (:file "fast")
                 (:file "filtered")))
   (:file "vegadat")
   (:module "db"
    :components ((:file "cl-simple-example-raw")
                 (:file "mini-redis")
                 (:file "tao")
                 (:file "mbdb")))))

