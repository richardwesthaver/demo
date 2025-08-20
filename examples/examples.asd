(defsystem :examples
  :depends-on (:core/user)
  :components 
  ((:file "vegadat")
   (:file "mbdump")
   (:module "db"
    :components ((:file "cl-simple-example-raw")
                 (:file "tao")
                 (:file "mbdb")))
   (:module "net"
    :components ((:file "yoctochat")
                 (:module "client"
                  :components 
                  ((:file "nws")
                   (:file "shodan")
                   (:file "kraken")))))))
