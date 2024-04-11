(defsystem :examples
  :depends-on (:prelude)
  :components 
  ((:file "vegadat")
   (:module "db"
    :components ((:file "cl-simple-example-raw")
                 (:file "mini-redis")
                 (:file "tao")
                 (:file "mbdb" :depends-on nil)))))

