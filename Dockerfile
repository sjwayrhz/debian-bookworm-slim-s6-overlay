FROM debian:bookworm-slim

# 1. 安装 Nginx 和 s6 依赖
RUN apt-get update && apt-get install -y nginx curl xz-utils && \
    rm -rf /var/lib/apt/lists/*

# 2. 安装 s6-overlay 
# 这里的版本号建议去官网看最新的
ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.6.2/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.6.2/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

# 3. 准备网页目录并确保权限
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

# 4. 拷贝配置并强制修复执行权限 
COPY s6-config/ /etc/s6-overlay/s6-rc.d/
RUN chmod +x /etc/s6-overlay/s6-rc.d/nginx-srv/run && \
    chmod +x /etc/s6-overlay/s6-rc.d/timer-srv/run

# 5. 激活服务
RUN mkdir -p /etc/s6-overlay/s6-rc.d/user/contents.d && \
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/nginx-srv && \
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/timer-srv

ENTRYPOINT ["/init"]