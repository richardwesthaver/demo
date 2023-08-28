FROM clfoundation/sbcl:latest
ENV QUICKLISP_ADD_TO_INIT_FILE=true
ENV QUICKLISP_DIST_VERSION=latest
ENV LISP=sbcl
WORKDIR /usr/src/demo
COPY . .
RUN mkdir -p ~/.config/common-lisp/source-registry.conf.d && \
    echo '(:tree "/usr/src/demo")' >  ~/.config/common-lisp/source-registry.conf.d/workspace.conf && \
    /usr/local/bin/install-quicklisp
CMD [ "make", "ci" ]