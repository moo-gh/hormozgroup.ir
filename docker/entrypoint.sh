#!/bin/sh
set -e

cd /var/www/hormozgroup.ir

run_composer_update() {
  echo 'Updating Composer dependencies (PHP 8 / Laravel 7.30+)...'
  COMPOSER_ALLOW_SUPERUSER=1 composer update \
    --no-dev \
    --no-interaction \
    --ignore-platform-req=php \
    --no-scripts \
    --with-all-dependencies \
    --optimize-autoloader
}

if [ ! -f vendor/autoload.php ]; then
  echo 'vendor/ missing (common with bind mounts).'
  run_composer_update
elif composer show laravel/framework 2>/dev/null | grep 'versions' | grep -qE 'v7\.(0|1|2)\.'; then
  echo 'Laravel 7.0–7.2 is not compatible with PHP 8; upgrading dependencies...'
  run_composer_update
fi

exec "$@"
