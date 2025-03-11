# Inherit from the base image
FROM ubuntu_php82fpm_base_image:latest

# Install Composer
RUN curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php && \
    HASH=$(curl -sS https://composer.github.io/installer.sig) && \
    php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('/tmp/composer-setup.php'); } echo PHP_EOL;" && \
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Set the working directory for the Laravel app
WORKDIR /var/www/html

# Copy the Laravel app into the NGINX web root
COPY ./laravel11-app/ /var/www/html

# Create .env file by copying the example
COPY ./laravel11-app/.env.example /var/www/html/.env

# Create the SQLite database file and set correct permissions
RUN touch /var/www/html/database/database.sqlite && \
    chown www-data:www-data /var/www/html/database/database.sqlite && \
    chmod 664 /var/www/html/database/database.sqlite && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Copy NGINX configuration for Laravel
COPY ./nginx-conf/default /etc/nginx/sites-available/default

# Install dependencies via Composer
RUN composer install

# Run Laravel key generate command
RUN php artisan key:generate
# Run php migration to create tables 
RUN php artisan migrate

# Expose port 80 for NGINX
EXPOSE 80

# Start PHP-FPM and NGINX
CMD service php8.2-fpm start && nginx -g 'daemon off;'
