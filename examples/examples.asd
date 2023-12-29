(defsystem :examples
  :depends-on (:std :cli :obj :dat :net :rdb)
  :components 
  ((:file "vegadat")
   (:module "db"
    :components ((:file "cl-simple-example")
                 (:file "mini-redis")
                 (:file "tao")))))

