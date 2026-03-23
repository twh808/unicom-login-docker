# 基础镜像：PHP7.4+Apache，原生支持ARM64/v8架构，适配树莓派等ARM设备
FROM php:7.4-apache
# 工作目录，固定为apache默认根目录
WORKDIR /var/www/html

# 安装项目必须的依赖扩展：curl、openssl、mbstring（RSA加密/字符编码/网络请求）
RUN apt-get update && apt-get install -y --no-install-recommends \
    && docker-php-ext-install curl openssl mbstring \
    && a2enmod rewrite \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 复制GitHub仓库的login.php到镜像的apache根目录
COPY login.php /var/www/html/

# 赋予apache用户文件权限，避免访问报错
RUN chown -R www-data:www-data /var/www/html \
    && chmod 755 /var/www/html/login.php

# 暴露80端口（apache默认端口，后续容器映射用）
EXPOSE 80

# 容器启动命令，固定启动apache服务
CMD ["apache2-foreground"]
