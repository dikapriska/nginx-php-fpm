FROM ubuntu:16.04

MAINTAINER Dika Priska <dikapriska@gmail.com>

RUN apt-get clean && apt-get -y update && apt-get install -y locales && locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' LC_ALL='en_US.UTF-8'

RUN apt-get clean && apt-get update \
    && apt-get install -y nginx curl iputils-ping zip unzip git software-properties-common nano net-tools supervisor sqlite3 libxrender1 libxext6 mysql-client libssh2-1-dev \
    && add-apt-repository ppa:ondrej/php -y \
    && apt-get clean \
    && apt-get update \
    && apt-get install -y php7.3-fpm php7.3-cli php7.3-gd php7.3-mysql \
       php7.3-imap php-memcached php7.3-mbstring php7.3-xml php7.3-curl \
       php7.3-sqlite3 php7.3-zip php7.3-pdo-dblib php7.3-bcmath php7.3-ssh2 \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && mkdir /run/php

COPY datadog-php-tracer.deb /datadog-php-tracer.deb

RUN dpkg -i datadog-php-tracer.deb

RUN update-ca-certificates;

RUN apt-get remove -y --purge software-properties-common \
	&& apt-get -y autoremove \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& echo "daemon off;" >> /etc/nginx/nginx.conf

RUN ln -sf /dev/stdout /var/log/nginx/docker.access.log \
    && ln -sf /dev/stderr /var/log/nginx/docker.error.log

COPY mycode-base/ /var/www/html/

COPY default /etc/nginx/sites-available/default

COPY php-fpm.conf /etc/php/7.3/fpm/php-fpm.conf

COPY www.conf /etc/php/7.3/fpm/pool.d/www.conf

COPY php.ini /etc/php/7.3/fpm/php.ini

EXPOSE 80

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]
