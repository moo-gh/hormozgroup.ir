# Stage 1: Build
FROM php:8.0-fpm-alpine AS builder

# Install build dependencies
RUN apk add --no-cache $PHPIZE_DEPS mariadb-dev \
    && docker-php-ext-install pdo pdo_mysql sockets exif \
    && apk del $PHPIZE_DEPS

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/hormozgroup.ir

# Copy only composer files first for better layer caching
COPY composer.json composer.lock ./

# Resolve deps for PHP 8.0 inside the image (lock file may lag until refreshed on the server).
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer update --no-dev --no-scripts --no-autoloader --with-all-dependencies --no-interaction --ignore-platform-req=php

# Copy the rest of the application
COPY . .

# Generate optimized autoload files (skip scripts to avoid discovery errors during build)
RUN composer dump-autoload --optimize --no-scripts

# Stage 2: Production
FROM php:8.0-fpm-alpine

# Install runtime extensions
RUN apk add --no-cache $PHPIZE_DEPS mariadb-dev \
    && docker-php-ext-install pdo pdo_mysql sockets exif \
    && apk del $PHPIZE_DEPS

WORKDIR /var/www/hormozgroup.ir

# Copy application from builder stage
COPY --from=builder /var/www/hormozgroup.ir /var/www/hormozgroup.ir

# Ensure storage and bootstrap/cache are writable
RUN chmod -R 775 storage bootstrap/cache && \
    chown -R www-data:www-data storage bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]
