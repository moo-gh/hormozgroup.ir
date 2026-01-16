# Stage 1: Build
FROM php:7.4-fpm-alpine AS builder

# Install build dependencies
RUN docker-php-ext-install pdo pdo_mysql sockets

# Use Composer 1 for compatibility with Laravel 7
COPY --from=composer:1 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/hormozgroup.ir

# Copy only composer files first for better layer caching
COPY composer.json composer.lock ./

# Install production dependencies without generating autoloader
# (This avoids errors about missing directories like database/seeds)
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN composer install --no-dev --no-scripts --no-autoloader --ignore-platform-reqs

# Copy the rest of the application
COPY . .

# Generate optimized autoload files (skip scripts to avoid discovery errors during build)
RUN composer dump-autoload --optimize --no-scripts

# Stage 2: Production
FROM php:7.4-fpm-alpine

# Install runtime extensions
RUN docker-php-ext-install pdo pdo_mysql sockets

WORKDIR /var/www/hormozgroup.ir

# Copy application from builder stage
COPY --from=builder /var/www/hormozgroup.ir /var/www/hormozgroup.ir

# Ensure storage and bootstrap/cache are writable
RUN chmod -R 775 storage bootstrap/cache && \
    chown -R www-data:www-data storage bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]
