FROM php:7.4-apache

MAINTAINER Edward Allen Mercado

ENV DB_HOST mysql-service
ENV DB_USER ecomuser
ENV DB_PASSWORD ecompassword
ENV DB_NAME ecomdb
ENV PHP_FPM_CLEAR_ENV no
# Set Apache log directory
ENV APACHE_LOG_DIR /var/log/apache2
# Set PHP log directory
ENV PHP_LOG_DIR /var/log/php

RUN a2enmod env

# Optionally, you can configure Apache to pass all environment variables to PHP
RUN echo "PassEnv *" >> /etc/apache2/apache2.conf

# Configure Logging
# Update Apache configuration for logging
RUN sed -i 's/ErrorLog .*/ErrorLog ${APACHE_LOG_DIR}\/error.log/' /etc/apache2/apache2.conf && \
    sed -i 's/CustomLog .*/CustomLog ${APACHE_LOG_DIR}\/access.log combined/' /etc/apache2/apache2.conf

# Update PHP configuration for logging
RUN { \
        echo 'error_log = /var/log/php/php_errors.log'; \
    } > /usr/local/etc/php/conf.d/error-log.ini

# Create log directories
RUN mkdir -p ${APACHE_LOG_DIR} && \
    mkdir -p ${PHP_LOG_DIR}

# Ensure Apache user has permissions
RUN chown -R www-data:www-data ${APACHE_LOG_DIR} ${PHP_LOG_DIR}

# Optionally, you can set custom permissions on log directories
RUN chmod -R 755 ${APACHE_LOG_DIR} ${PHP_LOG_DIR}

# Install MySqli
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli && \
    service apache2 restart

COPY /app /var/www/html/

# Configure Web
RUN sed -i 's/index.html/index.php/g' /etc/apache2/apache2.conf

# # Configure DB
# RUN sed -i 's/172.20.1.101/'${DB_HOST}'/g' /var/www/html/index.php

EXPOSE 80
