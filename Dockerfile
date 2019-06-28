FROM php:7.2-fpm
ARG TIMEZONE=Europe/Paris

MAINTAINER Stéphane RATHGEBER <stephane_rathgeber@hotmai.com>

RUN apt-get update && apt-get install -y \
    pdftk \
    zlib1g-dev \
    libicu-dev \
    libxml2-dev

# Set timezone
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "%s"\n', ${TIMEZONE} > /usr/local/etc/php/conf.d/tzone.ini
RUN "date"

# Type docker-php-ext-install to see available extensions
RUN docker-php-ext-configure intl \
    && docker-php-ext-install pdo pdo_mysql intl zip soap bcmath

# install xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=\"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini


#https://blog.rkl.io/en/blog/docker-based-php-7-symfony-4-development-environment
# disbale xdebug for composer
#RUN mkdir /usr/local/etc/php/conf.d.noxdebug \
#  && ln -s /usr/local/etc/php/conf.d/* /usr/local/etc/php/conf.d.noxdebug/ \
#  && unlink /usr/local/etc/php/conf.d.noxdebug/docker-php-ext-xdebug.ini \
#  && echo "alias composer='PHP_INI_SCAN_DIR=/etc/php.d.noxdebug/ /usr/local/bin/composer'" >> /etc/bashrc



WORKDIR /var/www