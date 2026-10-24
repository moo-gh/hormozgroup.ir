#!/bin/sh
set -e

cd /var/www/hormozgroup.ir

if [ ! -f vendor/autoload.php ]; then
  echo 'vendor/ missing (common with bind mounts); installing Composer dependencies...'
  COMPOSER_ALLOW_SUPERUSER=1 composer install \
    --no-dev \
    --no-interaction \
    --ignore-platform-req=php \
    --no-scripts \
    --optimize-autoloader \
    || COMPOSER_ALLOW_SUPERUSER=1 composer update \
      --no-dev \
      --no-interaction \
      --ignore-platform-req=php \
      --no-scripts \
      --with-all-dependencies \
      --optimize-autoloader
fi

exec "$@"
