FROM php:8.2-fpm
ARG TIMEZONE=Europe/Paris

ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/

RUN chmod uga+x /usr/local/bin/install-php-extensions && sync

RUN mkdir -p /usr/share/man/man1 && \
    apt-get update && apt-get install -y \
    pdftk \
    wget \
    ghostscript \
    xfonts-base \
    xfonts-75dpi \
    fontconfig \
    wkhtmltopdf 

# Set timezone
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone \
 && printf '[PHP]\ndate.timezone = "%s"\n', ${TIMEZONE} > /usr/local/etc/php/conf.d/tzone.ini \
 && "date"

RUN install-php-extensions \
    bcmath \
    gd \
    intl \
    memcached\
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    soap \
    zip \
    xdebug \
    http \
    amqp \
    redis

# install xdebug
RUN echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
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

