FROM php:8.2-cli

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libsqlite3-dev \
    nodejs \
    npm \
    && docker-php-ext-install pdo pdo_sqlite zip

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

# APP_KEY fake só pro build não quebrar
ENV APP_KEY=base64:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=

# Permissões
RUN chmod -R 777 storage bootstrap/cache database public

# PHP deps (AGORA NÃO QUEBRA)
RUN composer install --no-dev --optimize-autoloader

# Frontend
RUN npm install && npm run build

EXPOSE 10000

CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=10000
