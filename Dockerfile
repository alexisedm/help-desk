FROM php:7.4-apache

# intialize the machine with required apt-get packages and php extensions
RUN apt-get update && apt-get install -y libpng-dev zip unzip wget zlib1g-dev libicu-dev libzip-dev
RUN docker-php-ext-install mysqli pdo_mysql zip exif
RUN apt-get install -y \
    libwebp-dev \
    libjpeg62-turbo-dev \
    libpng-dev libxpm-dev \
    libfreetype6-dev
RUN docker-php-ext-install gd
COPY --from=composer:1.9 /usr/bin/composer /usr/bin/composer

# copy app in full
WORKDIR /var/www/
COPY . /var/www/

# install dependencies
RUN composer global require hirak/prestissimo && composer install

EXPOSE 8080
COPY docker/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY .env.example /var/www/.env
RUN chmod 777 -R /var/www/storage/ && \
    echo "Listen 8080" >> /etc/apache2/ports.conf && \
    chown -R www-data:www-data /var/www/ && \
    a2enmod rewrite
