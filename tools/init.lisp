(defvar *demo-config*
  '(:service "weather"
    :host "localhost"
    :port 8888
    :client (:name "guest"
	     :type "docker"
	     :mode "release"
	     :theme "dark")))
