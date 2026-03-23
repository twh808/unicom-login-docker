# 基础镜像：PHP7.4+Apache ARM64 原生支持
FROM php:7.4-apache

# 工作目录
WORKDIR /var/www/html

# 安装依赖 + PHP扩展（修复了语法错误）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libssl-dev \
        libonig-dev && \
    docker-php-ext-install curl openssl mbstring && \
    a2enmod rewrite && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 复制代码
COPY login.php /var/www/html/

# 权限
RUN chown -R www-data:www-data /var/www/html && \
    chmod 755 /var/www/html/login.php

EXPOSE 80

CMD ["apache2-foreground"]
