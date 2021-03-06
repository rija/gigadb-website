ARG PHP_VERSION=7.0
FROM php:${PHP_VERSION}-fpm-jessie

# Problem with Debian repos - adding official LTS repos to use below
RUN echo "deb http://deb.debian.org/debian/ jessie main contrib non-free" | tee /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian/ jessie main contrib non-free" | tee -a /etc/apt/sources.list && \
    echo "deb http://security.debian.org/ jessie/updates main contrib non-free" | tee -a /etc/apt/sources.list && \
    echo "deb-src http://security.debian.org/ jessie/updates main contrib non-free" | tee -a /etc/apt/sources.list && \
# the two repo below are the problematic ones, so commenting them out until debian fix them
#    echo "deb http://deb.debian.org/debian/ jessie-updates main contrib non-free" | tee -a /etc/apt/sources.list && \
#    echo "deb-src http://deb.debian.org/debian/ jessie-updates main contrib non-free" | tee -a /etc/apt/sources.list && \
# basic dependencies
    apt-get update -yq && \
    apt-get install -y --no-install-recommends \
        curl \
        libmemcached-dev \
        libz-dev \
        libpq-dev \
        libjpeg-dev \
        libpng12-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev \
        bc

RUN docker-php-ext-install mcrypt

# Install the PHP pdo_pgsql extention
RUN docker-php-ext-install pdo_pgsql

# Install the PHP bcmath extention
RUN docker-php-ext-install bcmath

# Install the PHP gd library
RUN docker-php-ext-install gd && \
    docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

# always run apt update when start and after add new source list, then clean up at end.
RUN apt-get update -yqq && \
    apt-get install -y apt-utils && \
    pecl channel-update pecl.php.net


ARG INSTALL_OPCACHE=false

RUN if [ ${INSTALL_OPCACHE} = true ]; then \
    docker-php-ext-install opcache \
;fi

# Copy opcache configration
#COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini
# not done here, host-mounted upon instantiation

ARG INSTALL_INTL=false

RUN if [ ${INSTALL_INTL} = true ]; then \
    # Install intl and requirements
    apt-get update -yq && \
    apt-get install -y zlib1g-dev libicu-dev g++ && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl \
;fi


ARG INSTALL_PGSQL=false

RUN if [ ${INSTALL_PGSQL} = true ]; then \
    # Install the pgsql extension
    docker-php-ext-install pgsql \
;fi

ARG INSTALL_PG_CLIENT=false
ARG PG_CLIENT_VERSION=10.5

RUN if [ ${INSTALL_PG_CLIENT} = true ]; then \
    # Create folders if not exists (https://github.com/tianon/docker-brew-debian/issues/65)
    mkdir -p /usr/share/man/man1 && \
    mkdir -p /usr/share/man/man7 && \
    # Install the pgsql client
    apt-get update -yq && \
    apt-get install -y postgresql-client-${PG_CLIENT_VERSION} \
;fi


ARG INSTALL_XDEBUG=false

RUN if [ ${INSTALL_XDEBUG} = true ]; then \
  # Install the xdebug extension
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
    pecl install xdebug-2.5.5; \
  else \
    pecl install xdebug-2.9.8; \
  fi && \
  docker-php-ext-enable xdebug \
;fi


ARG INSTALL_NETCAT_JQ=false

RUN if [ ${INSTALL_NETCAT_JQ} = true ]; then \
    # Create folders if not exists (https://github.com/tianon/docker-brew-debian/issues/65)
    mkdir -p /usr/share/man/man1 && \
    mkdir -p /usr/share/man/man7 && \
    # Install netcat-openbsd and jq
    apt-get update -yq && \
    apt-get install -y netcat-openbsd jq \
;fi

ARG INSTALL_GRAPHVIZ=false

RUN if [ ${INSTALL_GRAPHVIZ} = true ]; then \
    apt-get update -yq && \
    apt-get install -y graphviz \
;fi

ARG INSTALL_COMPOSER=false
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
RUN if [ ${INSTALL_COMPOSER} = true ]; then \
    docker-php-ext-install zip \
    && apt-get update -yq \
    && apt-get install -y unzip wget \
    && EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)" \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && ACTUAL_SIGNATURE="$(php -r "echo hash_file('SHA384', 'composer-setup.php');")" \
    && test $EXPECTED_SIGNATURE = $ACTUAL_SIGNATURE  \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer --quiet \
    && rm composer-setup.php \
    && composer config --global repo.packagist composer https://packagist.org \
;fi

ARG INSTALL_TIDEWAYS_XHPROF=false

RUN if [ ${INSTALL_TIDEWAYS_XHPROF} = true ]; then \
    curl -o tideways-xhprof.tar.gz -s -L https://github.com/tideways/php-xhprof-extension/archive/v4.1.6.tar.gz && \
    tar xzvf tideways-xhprof.tar.gz && \
    cd php-xhprof-extension* && \
    phpize && \
    ./configure && \
    make && \
    make install && \
    echo "extension=tideways.so" >  /usr/local/etc/php/conf.d/tideways_xhprof.ini && \
    pecl install mongodb && docker-php-ext-enable mongodb && \
    curl -o /usr/local/src/xhgui.tar.gz -s -L https://github.com/perftools/xhgui/archive/0.8.1.tar.gz && \
    cd /usr/local/src/ && \
    tar xzvf /usr/local/src/xhgui.tar.gz && \
    cd xhgui-0.8.1 && \
    apt-get install -y git && \
    composer install && \
    echo "auto_prepend_file=/usr/local/src/xhgui-0.8.1/external/header.php" > /usr/local/etc/php/conf.d/xhgui.ini \
;fi

ARG INSTALL_LIBSODIUM=false

RUN if [ ${INSTALL_LIBSODIUM} = true ]; then \
    # Problem with using http://ftp.debian.org/debian for installing libsodium
    # Might be related to https://lists.debian.org/debian-devel-announce/2019/03/msg00006.html
    # Using archive repo instead
    echo 'Acquire::Check-Valid-Until "0";' | tee -a /etc/apt/apt.conf.d/apt.conf && \
    echo "deb http://archive.debian.org/debian jessie-backports main" | tee -a /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y -t jessie-backports libsodium-dev && \
    pecl install libsodium && \
    echo "extension=sodium.so" >  /usr/local/etc/php/conf.d/libsodium.ini \
;fi

ARG INSTALL_GIT=false
RUN if [ ${INSTALL_GIT} = true ]; then \
    apt-get update -yq && \
    apt-get install -y git \
;fi

ARG INSTALL_APCU=false
ARG APCU_VERSION=5.1.8

RUN if [ ${INSTALL_APCU} = true ]; then \
    pecl install apcu-${APCU_VERSION} && \
    echo "extension=apcu.so" >  /usr/local/etc/php/conf.d/apcu.ini && \
    echo 'apc.shm_size="64M"' | tee -a /usr/local/etc/php/conf.d/apcu.ini \
;fi

ARG INSTALL_MAILPARSE=false
RUN if [ ${INSTALL_MAILPARSE} = true ]; then \
    # Install mailparse extension
    pecl install mailparse && \
    docker-php-ext-enable mailparse \
;fi

ARG INSTALL_CSSLINT_JSHINT=false
RUN if [ ${INSTALL_CSSLINT_JSHINT} = true ]; then \
    # To fix public key not found error when running nodesource_setup.sh
    curl --silent https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt-get install -y nodejs && \
    rm nodesource_setup.sh && \
    npm install -g csslint jshint \
;fi

RUN usermod -u 1000 www-data

WORKDIR /var/www

CMD ["php-fpm"]

EXPOSE 9000
