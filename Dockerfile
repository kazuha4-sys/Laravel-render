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

# Copia os arquivos
COPY . .

# Garante .env (senão o Laravel morre)
RUN cp .env.example .env || true

# APP_KEY fake só pro build não quebrar
ENV APP_KEY=base64:67f46728fbb9abfc3fda26967cbe1aa2

# Garante pastas críticas
RUN mkdir -p storage/logs bootstrap/cache database

# Permissões
RUN chmod -R 777 storage bootstrap/cache database

# Instala dependências PHP (AGORA FUNCIONA)
RUN composer install --no-dev --optimize-autoloader

# Frontend (Breeze)
RUN npm install && npm run build

EXPOSE 10000

CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=10000
