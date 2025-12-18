FROM php:8.2-cli

# Dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libsqlite3-dev \
    nodejs \
    npm \
    && docker-php-ext-install pdo pdo_sqlite zip

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copia tudo
COPY . .

# Permissões
RUN chmod -R 777 storage bootstrap/cache database public

# PHP deps
RUN composer install --no-dev --optimize-autoloader

# FRONTEND (AQUI ESTÁ O PROBLEMA NORMALMENTE)
RUN npm install
RUN npm run build

# Debug rápido (opcional, mas ajuda)
RUN ls -la public && ls -la public/build || true

EXPOSE 10000

CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=10000
