;;; demo.asd
(defsystem "demo"
  :version "0.1.0"
  :author "Richard Westhaver <richard.westhaver@gmail.com>"
  :maintainer "Richard Westhaver <richard.westhaver@gmail.com>"
  :description "comp demo system"
  :homepage "https://rwest.io/demo"
  :bug-tracker "https://vc.compiler.ocmpany/demo/issues"
  :source-control (:hg "https://vc.compiler.company/demo")
  :license "WTF"
  :depends-on (:user)
  :components ((:file "pkg")))

(defmethod perform :after ((op load-op) (c (eql (find-system :demo))))
  (pushnew :demo *features*))
