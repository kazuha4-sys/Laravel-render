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

# Diretório do app
WORKDIR /var/www/html

# Copia tudo
COPY . .

# Permissões (senão o Laravel chora)
RUN chmod -R 777 storage bootstrap/cache database

# Instala dependências PHP
RUN composer install --no-dev --optimize-autoloader

# Frontend (Breeze usa isso)
RUN npm install && npm run build

# Porta do Render
EXPOSE 10000

# Start da aplicação
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=10000
