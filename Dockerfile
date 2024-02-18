FROM php:7.4-apache

MAINTAINER Edward Allen Mercado

ENV DB_HOST="mysql-service"

RUN docker-php-ext-install mysqli

COPY . /var/www/html/

EXPOSE 80
