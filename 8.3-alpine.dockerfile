FROM composer:2 AS composer
FROM php:8.3-cli-alpine

LABEL maintainer="Mohamad Momeni"
ENV TZ=Asia/Tehran

RUN apk add --no-cache --update \
    # Required for GD extension
    freetype-dev libjpeg-turbo-dev libpng-dev \
    # Required for IMAP extension
    imap-dev krb5-dev \
    # Required for LDAP extension
    libldap openldap-dev \
    # Required for ZIP extension
    libzip-dev zlib-dev \
    # Required for Swoole extension
    openssl-dev \
    # Utilities
    ca-certificates \
    tzdata \
    nano \
    curl \
    supervisor

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install -j$(nproc) pdo pdo_mysql gd imap ldap pcntl zip \
    && pecl install mongodb redis swoole && docker-php-ext-enable mongodb redis swoole

COPY --from=composer /usr/bin/composer /usr/local/bin/composer
COPY ixed.8.3.lin /tmp/sourceguardian.so

RUN mv /tmp/sourceguardian.so $(php-config --extension-dir) && echo 'extension=sourceguardian.so' > /usr/local/etc/php/conf.d/docker-php-ext-sourceguardian.ini