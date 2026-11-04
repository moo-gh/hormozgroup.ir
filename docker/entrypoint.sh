#!/bin/sh
set -e

cd /var/www/hormozgroup.ir

# Bind mounts overwrite image vendor/; refresh when missing.
if [ ! -f vendor/autoload.php ]; then
  echo 'vendor/ missing (common with bind mounts). Running composer install...'
  COMPOSER_ALLOW_SUPERUSER=1 composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-scripts
fi

exec "$@"
