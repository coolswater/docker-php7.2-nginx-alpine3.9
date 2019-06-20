FROM alpine:3.9
LABEL Maintainer="Hexd<coolswater@163.com>" \
      Description="Lightweight container with Nginx 1.14 & PHP-FPM 7.2 based on Alpine Linux."

# Environments
ENV TIMEZONE            Asia/Shanghai
ENV PHP_MEMORY_LIMIT    512M
ENV MAX_UPLOAD          50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST        100M

# Install packages
RUN apk update \
    && apk upgrade \
    && apk add \
        curl \
        supervisor \
        nginx \
        tzdata \
        php7-fpm\
        php7 \
        php7-dev \
        php7-apcu \
        php7-bcmath \
        php7-xmlwriter \
        php7-ctype \
        php7-curl \
        php7-exif \
        php7-iconv \
        php7-intl \
        php7-json \
        php7-mbstring\
        php7-opcache \
        php7-openssl \
        php7-pcntl \
        php7-pdo \
        php7-mysqlnd \
        php7-mysqli \
        php7-pdo_mysql \
        php7-pdo_pgsql \
        php7-phar \
        php7-posix \
        php7-session \
        php7-xml \
        php7-simplexml \
        php7-mcrypt \
        php7-xsl \
        php7-zip \
        php7-zlib \
        php7-dom \
        php7-redis\
        php7-tokenizer \
        php7-gd \
        php7-mongodb\
        php7-fileinfo \
        php7-memcached \
        php7-xmlreader 

#配置PHP.ini
RUN sed -i "/;daemonize\s*=\s*yes/c daemonize = no/g" /etc/php7/php-fpm.conf && \
    sed -i "/listen\s*=\s*127.0.0.1:9000/c listen = 9000/g" /etc/php7/php-fpm.d/www.conf && \
    sed -i "/;date.timezone =.*/c date.timezone = ${TIMEZONE}/" /etc/php7/php.ini && \
    sed -i "/memory_limit =.*/c memory_limit = ${PHP_MEMORY_LIMIT}/" /etc/php7/php.ini && \
    sed -i "/upload_max_filesize =.*/c upload_max_filesize = ${MAX_UPLOAD}/" /etc/php7/php.ini && \
    sed -i "/max_file_uploads =.*/c max_file_uploads = ${PHP_MAX_FILE_UPLOAD}/" /etc/php7/php.ini && \
    sed -i "/post_max_size =.*/c max_file_uploads = ${PHP_MAX_POST}/" /etc/php7/php.ini && \
    sed -i "/;cgi.fix_pathinfo=1/c cgi.fix_pathinfo=0/" /etc/php7/php.ini && \
    sed -i '$a\zend_extension=opcache.so' /etc/php7/php.ini && \
    sed -i '$a\opcache.enable=1' /etc/php7/php.ini && \
    sed -i '$a\opcache.enable_cli=1' /etc/php7/php.ini && \
    sed -i '$a\opcache.file_cache=/tmp' /etc/php7/php.ini && \
    sed -i '$a\opcache.huge_code_pages=1' /etc/php7/php.ini

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /var/lib/nginx && \
    mkdir -p /var/tmp/nginx && \
    mkdir -p /var/log/nginx && \
    mkdir -p /var/www/html
	
# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/tmp/nginx && \
  chown -R nobody.nobody /var/log/nginx && \
  chown -R nobody.nobody /var/www/html

# Switch to use a non-root user from here on
USER nobody

# Expose the port nginx is reachable on
EXPOSE 80

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
