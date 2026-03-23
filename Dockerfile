# 基础镜像
FROM php:7.4-apache-bullseye

# 环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

# 第一步：替换源 + 安装依赖 + 配置Apache（整合成无断裂的RUN块）
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends libcurl4-openssl-dev libonig-dev && \
    docker-php-ext-install -j$(nproc) curl mbstring && \
    a2enmod rewrite && \
    sed -i 's/Listen 80/Listen 5702/g' /etc/apache2/ports.conf && \
    sed -i 's/:80/:5702/g' /etc/apache2/sites-available/000-default.conf && \
    # 直接用echo单行写入配置（彻底避免EOF换行问题）
    echo '<Directory /var/www/html> Options Indexes FollowSymLinks AllowOverride All Require all granted </Directory>' > /etc/apache2/conf-available/000-directory.conf && \
    a2enconf 000-directory.conf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 恢复交互配置
ENV DEBIAN_FRONTEND=dialog

# 工作目录
WORKDIR /var/www/html

# 拷贝代码
COPY login.php /var/www/html/

# 设置权限
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# 暴露端口
EXPOSE 5702

# 启动命令
CMD ["apache2-foreground"]
