FROM clfoundation/sbcl:latest
COPY . /usr/src/demo
WORKDIR /usr/src/demo
CMD [ "make", "ci" ]