FROM node:22 AS node
FROM composer:2 AS composer
FROM php:8.1-apache

LABEL maintainer="Mohamad Momeni"
ENV TZ=Asia/Tehran

RUN a2enmod rewrite
RUN a2enmod headers

RUN apt-get update && apt-get install -y \ 
   # Required for GD extension
   libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
   # Required for IMAP extension
   libc-client-dev libkrb5-dev \
   # Required for LDAP extension
   libldap2-dev \
   # Required for ZIP extension
   libzip-dev zlib1g-dev \
   # Required for Swoole extension
   libssl-dev \
   # Utilities
   ca-certificates \
   tzdata \
   nano \
   wget \
   curl \
   cron \
   supervisor \
   && rm -r /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
   && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
   && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
   && docker-php-ext-install -j$(nproc) pdo pdo_mysql gd imap ldap pcntl zip \
   && pecl install mongodb redis swoole && docker-php-ext-enable mongodb redis swoole

COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY ixed.8.1.lin /tmp/sourceguardian.so
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/bin/npm /usr/local/bin/
COPY --from=node /usr/local/bin/npx /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN mv /tmp/sourceguardian.so $(php-config --extension-dir) && echo 'extension=sourceguardian.so' > /usr/local/etc/php/conf.d/docker-php-ext-sourceguardian.ini