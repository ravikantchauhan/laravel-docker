# Base image
FROM ubuntu:22.04

# Set the ARG for non-interactive installations
ARG DEBIAN_FRONTEND=noninteractive

# Update package list and install dependencies
RUN apt-get update -y

# Install NGINX
RUN apt-get install -y nginx

# Install PHP 8.2 and required extensions
RUN apt-get -y install software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get -y install php8.2 php8.2-fpm php8.2-bcmath php8.2-xml php8.2-mysql \
        php8.2-zip php8.2-intl php8.2-ldap php8.2-gd php8.2-cli php8.2-bz2 \
        php8.2-curl php8.2-mbstring php8.2-pgsql php8.2-opcache php8.2-soap php8.2-cgi \
        php8.2-sqlite3 \
        nano 

# Configure PHP-FPM to work with NGINX
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.2/fpm/php.ini && \
    service php8.2-fpm start

# Install Composer
RUN apt-get update && apt-get -y install php-cli unzip curl && \
    curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php && \
    HASH=$(curl -sS https://composer.github.io/installer.sig) && \
    php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('/tmp/composer-setup.php'); } echo PHP_EOL;" && \
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Copy the Laravel app into the NGINX web root
COPY ./laravel11-app/ /var/www/html

# Set correct permissions for Laravel
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# NGINX configuration for Laravel
COPY ./nginx-conf/default /etc/nginx/sites-available/default

# Expose port 80 for NGINX
EXPOSE 80

# Start NGINX and PHP-FPM
CMD service php8.2-fpm start && nginx -g 'daemon off;'
