FROM --platform=$BUILDPLATFORM php:8.2-apache

FROM mediawiki:latest
RUN \ 
apt-get update && \
apt-get install libldap2-dev -y && \
rm -rf /var/lib/apt/lists/* && \
docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
docker-php-ext-install ldap

RUN apt-get update && \
    apt-get -y install apt-transport-https git curl vim --no-install-recommends && \
    rm -r /var/lib/apt/lists/* && \
    curl -sSL -o /tmp/mo https://git.io/get-mo && \
    chmod +x /tmp/mo

# Docker build
ARG GIT_REVISION=unkown
ARG GIT_ORIGIN=unkown
ARG IMAGE_NAME=unkown
LABEL git-revision=$GIT_REVISION \
      git-origin=$GIT_ORIGIN \
      image-name=$IMAGE_NAME \
      maintainer="skapxdev <skapxdev@proton.me>"

# SimpleSAMLphp
ARG SIMPLESAMLPHP_VERSION=1.19.8
RUN curl -sSL -o /tmp/simplesamlphp.tar.gz https://github.com/simplesamlphp/simplesamlphp/releases/download/v$SIMPLESAMLPHP_VERSION/simplesamlphp-$SIMPLESAMLPHP_VERSION.tar.gz && \
    tar xzf /tmp/simplesamlphp.tar.gz -C /tmp && \
    mv /tmp/simplesamlphp-* /var/www/simplesamlphp && \
    touch /var/www/simplesamlphp/modules/ldap/enable

COPY config/simplesamlphp/config.php /var/www/simplesamlphp/config
COPY config/simplesamlphp/authsources.php /var/www/simplesamlphp/config
COPY config/simplesamlphp/saml20-sp-remote.php /var/www/simplesamlphp/metadata
COPY config/simplesamlphp/server.crt /var/www/simplesamlphp/cert/
COPY config/simplesamlphp/server.pem /var/www/simplesamlphp/cert/

RUN echo "<?php" > /var/www/simplesamlphp/metadata/shib13-sp-remote.php

# Apache
ENV HTTP_PORT 8080

COPY config/apache/ports.conf.mo /tmp
COPY config/apache/simplesamlphp.conf.mo /tmp
RUN /tmp/mo /tmp/ports.conf.mo > /etc/apache2/ports.conf && \
    /tmp/mo /tmp/simplesamlphp.conf.mo > /etc/apache2/sites-available/simplesamlphp.conf

# hadolint ignore=DL3059
RUN a2dissite 000-default.conf default-ssl.conf && \
    a2enmod rewrite && \
    a2ensite simplesamlphp.conf

# Clean up
# hadolint ignore=DL3059
RUN rm -rf /tmp/*

# Set work dir
WORKDIR /var/www/simplesamlphp

# General setup
EXPOSE ${HTTP_PORT}