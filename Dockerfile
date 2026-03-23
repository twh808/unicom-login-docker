# 基础镜像
FROM php:7.4-apache-bullseye

# 环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

# 一站式完成：换源 + 装依赖 + 改Apache配置（无任何语法断裂）
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    apt-get update && \
    # 安装必要依赖
    apt-get install -y --no-install-recommends libcurl4-openssl-dev libonig-dev && \
    # 安装PHP扩展
    docker-php-ext-install -j$(nproc) curl mbstring && \
    # 启用重写模块
    a2enmod rewrite && \
    # 修改Apache监听端口为5702
    sed -i 's/Listen 80/Listen 5702/g' /etc/apache2/ports.conf && \
    # 核心修复：直接在默认虚拟主机配置中添加目录权限（最稳定）
    sed -i '/DocumentRoot \/var\/www\/html/a \ \ \ \ <Directory \/var\/www\/html>\n \ \ \ \ \ \ Options Indexes FollowSymLinks\n \ \ \ \ \ \ AllowOverride All\n \ \ \ \ \ \ Require all granted\n \ \ \ \ <\/Directory>' /etc/apache2/sites-available/000-default.conf && \
    # 修改虚拟主机端口为5702
    sed -i 's/:80/:5702/g' /etc/apache2/sites-available/000-default.conf && \
    # 清理缓存
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 恢复交互配置
ENV DEBIAN_FRONTEND=dialog

# 工作目录
WORKDIR /var/www/html

# 拷贝业务代码
COPY login.php /var/www/html/

# 设置目录权限（递归，解决403核心）
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# 暴露端口
EXPOSE 5702

# 启动Apache
CMD ["apache2-foreground"]
