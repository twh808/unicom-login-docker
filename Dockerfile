# 选择兼容性更好的基础镜像（Debian 11，适配QEMU）
FROM php:7.4-apache-bullseye
# 解决QEMU交互/时区问题 + 国内源加速
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
# 替换阿里云源（解决apt-get update失败）
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list
# 安装依赖（仅保留必要包，移除无效的openssl扩展编译）
RUN apt-get update && \
    # 安装基础依赖（libonig-dev是mbstring必需的）
    apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libonig-dev \
        && \
    # 仅编译安装有效扩展（curl + mbstring，openssl内置）
    docker-php-ext-install -j$(nproc) curl mbstring && \
    # 启用Apache重写模块
    a2enmod rewrite && \
    # 关键：修改Apache默认监听端口为5702
    sed -i 's/Listen 80/Listen 5702/g' /etc/apache2/ports.conf && \
    sed -i 's/:80/:5702/g' /etc/apache2/sites-available/000-default.conf && \
    # 【新增】配置Apache根目录访问权限，解决403核心问题
    echo -e "<Directory /var/www/html>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride All\n\tRequire all granted\n</Directory>" > /etc/apache2/conf-available/000-directory.conf && \
    a2enconf 000-directory.conf && \
    # 清理缓存（减小镜像体积）
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# 恢复默认交互配置
ENV DEBIAN_FRONTEND=dialog
# 工作目录
WORKDIR /var/www/html
# 【关键】将本地login.php拷贝到镜像的Apache根目录（必须步骤）
COPY login.php /var/www/html/
# 【优化】递归修改目录+文件权限，确保www-data完全拥有（解决403）
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html
# 暴露端口改为5702 + 保持原有启动命令
EXPOSE 5702
CMD ["apache2-foreground"]
