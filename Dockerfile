ARG OS=archlinux
ARG VERSION
ADD https://github.com/sbcl/sbcl/archive/sbcl-$VERSION.tar.gz sbcl.tar.gz

RUN set -x; \
  tar xvfz sbcl.tar.gz && rm sbcl.tar.gz && cd "sbcl-sbcl-${VERSION}" && \
  echo "\"$VERSION\"" > version.s && \

ARG BUILD_DATE
ARG VCS_REF
ARG OS
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

ENTRYPOINT ["/usr/local/bin/sbcl"]