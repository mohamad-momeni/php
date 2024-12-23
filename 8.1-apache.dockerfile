FROM composer:2 AS composer
FROM php:8.1-apache

LABEL maintainer="Mohamad Momeni"

RUN a2enmod rewrite
RUN a2enmod headers

RUN apt-get update && apt-get install -y \ 
   # Required for GD extension
   libpng-dev \
   libjpeg62-turbo-dev \
   libfreetype6-dev \
   # Required for IMAP extension
   libc-client-dev \
   libkrb5-dev \
   # Required for LDAP extension
   libldap2-dev \
   # Required for pcntl extension
   libpcntl-dev \
   # Required for ZIP extension
   libzip-dev \
   zlib1g-dev \
   # Required for Swoole extension
   libssl-dev \
   # Utilities
   ca-certificates \
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

RUN mv /tmp/sourceguardian.so $(php-config --extension-dir) && echo 'extension=sourceguardian.so' > /usr/local/etc/php/conf.d/docker-php-ext-sourceguardian.ini