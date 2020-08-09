FROM php:7.4-apache

WORKDIR /var/www/html
# Install git ant and java
ARG version=2.7.1

RUN a2enmod rewrite

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    git-core \
    apt-utils \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libmemcached-dev \
    zlib1g-dev \
    imagemagick

#Install php-extensions
RUN pecl install mcrypt-1.0.3
RUN docker-php-ext-enable mcrypt

RUN docker-php-ext-install -j$(nproc) iconv pdo pdo_mysql gd mysqli
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/

#Clone omeka-s - replace with git clone...
RUN rm -rf /var/www/html/*
ADD https://github.com/omeka/Omeka/releases/download/v${version}/omeka-${version}.zip /tmp/omeka-classic.zip
RUN unzip -d /tmp/ /tmp/omeka-classic.zip && mv /tmp/omeka-${version}/* /var/www/html/ && rm -rf /tmp/omeka-classic*
#enable the rewrite module of apache
RUN a2enmod rewrite
#Create a default php.ini
COPY files/php.ini /usr/local/etc/php/

# copy over the database and the apache config
# COPY /files/.htaccess /var/www/html/.htaccess
COPY ./files/favicon.ico /var/www/html/favicon.ico
COPY ./files/db.ini /var/www/html/db.ini
COPY ./files/apache-config.conf /etc/apache2/sites-enabled/000-default.conf
COPY ./files/.htaccess /var/www/html/.htaccess
COPY ./files/imagemagick-policy.xml /etc/ImageMagick/policy.xml
# set the file-rights
RUN chown -R www-data:www-data /var/www/html/
# RUN chown -R www-data:www-data /var/www/html/files
RUN chmod -R +w /var/www/html/files
VOLUME [ "/var/www/html/files" ]
# Expose the Port we'll provide Omeka on 80
EXPOSE 80
# Running Apache in foreground
CMD ["apache2-foreground"]

# ENV DEBIAN_FRONTEND noninteractive
# RUN apt-get -qq update && apt-get -qq -y --no-install-recommends install \
#     curl \
#     unzip \
#     libfreetype6-dev \
#     libjpeg62-turbo-dev \
#     libmcrypt-dev \
#     libpng-dev \
#     libjpeg-dev \
#     libmemcached-dev \
#     zlib1g-dev \
#     imagemagick

# # install the PHP extensions we need
# RUN docker-php-ext-install -j$(nproc) iconv mcrypt \
#     pdo pdo_mysql mysqli gd
# RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

# RUN docker-php-ext-install exif && \
#     docker-php-ext-enable exif

# RUN curl -J -L -s -k \
#     'https://github.com/omeka/Omeka/releases/download/v2.6.1/omeka-2.6.1.zip' \
#     -o /var/www/omeka.zip \
# &&  unzip -q /var/www/omeka.zip -d /var/www/ \
# &&  rm /var/www/omeka.zip \
# &&  rm -rf /var/www/html \
# &&  mv /var/www/omeka-2.6.1 /var/www/html \
# &&  chown -R www-data:www-data /var/www/html

# # COPY ./favicon.ico /var/www/html/favicon.ico
# # COPY ./config.ini /var/www/html/application/config/config.ini
# # COPY ./globals.php /var/www/html/application/libraries/globals.php
# COPY ./db.ini /var/www/html/db.ini
# COPY ./.htaccess /var/www/html/.htaccess
# COPY ./imagemagick-policy.xml /etc/ImageMagick/policy.xml

# VOLUME /var/www/html

# CMD ["apache2-foreground"]
