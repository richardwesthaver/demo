(defsystem :examples
  :depends-on (:user)
  :components 
  ((:module "clos"
    :components ((:file "pkg")
                 (:file "sealed")
                 (:file "stealth")
                 ;; (:file "fast-def")
                 ;; (:file "fast")
                 (:file "filtered")))
   (:file "vegadat")
   (:file "mbdump")
   (:module "db"
    :components ((:file "cl-simple-example-raw")
                 (:file "mini-redis")
                 (:file "tao")
                 (:file "mbdb")))
   (:module "net"
    :components ((:file "yoctochat")))
   (:module "app"
    :components ((:file "mpk")))))

