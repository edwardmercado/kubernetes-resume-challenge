FROM php:7.4-apache

MAINTAINER Edward Allen Mercado

ARG DB_HOST="mysql-service"
ENV DB_HOST $DB_HOST

RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli && \
    service apache2 restart

COPY /app /var/www/html/

# Configure Web
RUN sed -i 's/index.html/index.php/g' /etc/apache2/apache2.conf

# Configure DB
RUN sed -i 's/172.20.1.101/'${DB_HOST}'/g' /var/www/html/index.php

EXPOSE 80
