(load "tools/prepare-image")
(defvar *output* "demo")
#+sbcl
(sb-ext:save-lisp-and-die *output*
                          :purify t
                          :toplevel 'screenshotbot-sdk:main
                          :executable t)
#+ccl
(ccl:save-application *output*
                      :toplevel-function 'screenshotbot-sdk:main)
