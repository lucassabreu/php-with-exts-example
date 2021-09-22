from php:8.0-apache

run apt-get update \
    && apt-get install -y --no-install-recommends \
        wget supervisor librabbitmq-dev zlib1g zlib1g-dev libzip4 libzip-dev zip unzip libpng-dev \
        libc-client-dev libkrb5-dev libxslt-dev \
    && rm -rf /var/lib/apt/lists/*

run a2enmod rewrite unique_id

run docker-php-ext-configure gd \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && apt-get install -y && docker-php-ext-install -j$(nproc) bcmath gd pdo_mysql calendar exif gettext shmop soap sockets intl pcntl xsl imap

run pecl install redis && docker-php-ext-enable redis

run apt-get update && apt-get install -y -f librabbitmq-dev libssh-dev \
    && docker-php-source extract \
    && mkdir /usr/src/php/ext/amqp \
    && curl -L https://github.com/php-amqp/php-amqp/archive/master.tar.gz | tar -xzC /usr/src/php/ext/amqp --strip-components=1 \
    && docker-php-ext-install amqp \
    && docker-php-ext-enable amqp

run curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
    && mkdir /var/www/.composer && chown -R www-data:www-data /var/www/.composer

user www-data
workdir "/var/www/html"
expose 8080
