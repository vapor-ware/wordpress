FROM bitnami/wordpress as build

ENV PHP_AUTOCONF=/usr/bin/autoconf
ENV PHP_PREFIX=/opt/bitnami/php

# Extensions were installed from source per:
# https://docs.bitnami.com/general/apps/wordpress/configuration/install-modules-php/#memcached-using-libmemcached

RUN apt-get update && apt-get install -y build-essential libtool autoconf unzip wget git pkg-config zlib1g-dev
RUN cd /tmp && wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz && \
    tar -zxf libmemcached-1.0.18.tar.gz && \
    cd libmemcached-1.0.18  && \
    ./configure --prefix=/opt/bitnami/common && \
    make && \
    make install
RUN cd /tmp && wget https://github.com/php-memcached-dev/php-memcached/archive/v3.1.3.tar.gz && \
    tar xvfz v3.1.3.tar.gz && \
    cd php-memcached-3.1.3 && \
    /opt/bitnami/php/bin/phpize && \
    ./configure --enable-memcached --with-libmemcached-dir=/opt/bitnami/common --with-php-config=/opt/bitnami/php/bin/php-config --disable-memcached-sasl && \
    make && \
    make install
RUN echo 'extension=memcached.so' | tee -a /opt/bitnami/php/etc/php.ini

FROM bitnami/wordpress
COPY --from=build /opt/bitnami /opt/bitnami

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="vaporio/wordpress" \
      org.label-schema.vcs-url="https://github.com/vapor-ware/wordpress" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vendor="Vapor IO" \
      org.label-schema.version=$BUILD_VERSION \
      maintainer="vapor@vapor.io"
