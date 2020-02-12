FROM php:7.3-fpm
ARG TIMEZONE=Europe/Paris

MAINTAINER Stéphane RATHGEBER <stephane.kiora@gmail.com>

RUN mkdir -p /usr/share/man/man1 && \
    apt-get update && apt-get install -y \
    pdftk \
    zlib1g-dev \
    libicu-dev \
    libxml2-dev \
    libzip-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libmemcached-dev \
    libpq-dev \
    wget \
    ghostscript \
    xfonts-base \
    xfonts-75dpi \
    fontconfig

# Set timezone
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone \
 && printf '[PHP]\ndate.timezone = "%s"\n', ${TIMEZONE} > /usr/local/etc/php/conf.d/tzone.ini \
 && "date"

# Type docker-php-ext-install to see available extensions
RUN docker-php-ext-configure intl \
    && docker-php-ext-install pdo pdo_mysql intl zip soap bcmath pdo_pgsql pgsql \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-configure gd \
    && pecl install memcached \
    && docker-php-ext-enable memcached

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

RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
 && dpkg -i wkhtmltox_0.12.5-1.stretch_amd64.deb \
 && apt install -y -f \
 && rm wkhtmltox_0.12.5-1.stretch_amd64.deb

#https://blog.rkl.io/en/blog/docker-based-php-7-symfony-4-development-environment
# disbale xdebug for composer
#RUN mkdir /usr/local/etc/php/conf.d.noxdebug \
#  && ln -s /usr/local/etc/php/conf.d/* /usr/local/etc/php/conf.d.noxdebug/ \
#  && unlink /usr/local/etc/php/conf.d.noxdebug/docker-php-ext-xdebug.ini \
#  && echo "alias composer='PHP_INI_SCAN_DIR=/etc/php.d.noxdebug/ /usr/local/bin/composer'" >> /etc/bashrc

WORKDIR /var/www

