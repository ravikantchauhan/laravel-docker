# Base image: Ubuntu with PHP and NGINX
FROM ubuntu:22.04

# Update package list and install dependencies
RUN apt-get update -y && \
    apt-get install -y nginx software-properties-common curl unzip

# Install PHP 8.2 and required extensions
RUN add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y php8.2 php8.2-fpm php8.2-bcmath php8.2-xml php8.2-mysql \
        php8.2-zip php8.2-intl php8.2-ldap php8.2-gd php8.2-cli php8.2-bz2 \
        php8.2-curl php8.2-mbstring php8.2-pgsql php8.2-opcache php8.2-soap php8.2-cgi \
        php8.2-sqlite3 nano

# Configure PHP-FPM
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.2/fpm/php.ini

# Start PHP-FPM
CMD ["php-fpm", "-F"]
