FROM debian:bookworm-slim

# 1. 安装基础工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx curl xz-utils ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. 安装 s6-overlay (版本 3.1.6.2)
# 注意：根据你的服务器架构选择，这里以 x86_64 为例
ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.6.2/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.6.2/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz && \
    rm /tmp/*.tar.xz

# 3. 设置系统时区为北京时间
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 4. 【关键】处理网页文件 (dist 目录)
# 先清理默认文件，再拷贝你本地生成的 dist 内容
RUN rm -rf /var/www/html/*
COPY dist/ /var/www/html/

# 5. 【关键】处理 s6 服务配置 (s6-config 目录)
# 将你本地的 s6-config 拷贝到 s6 指定的配置目录
COPY s6-config/ /etc/s6-overlay/s6-rc.d/

# 6. 设置权限
# 赋予 s6 运行脚本执行权限
RUN chmod +x /etc/s6-overlay/s6-rc.d/*/run
# 确保 Nginx 目录权限正确
RUN chown -R www-data:www-data /var/www/html

# 7. 启用服务 (假设你的服务名是 nginx-srv 和 timer-srv)
RUN mkdir -p /etc/s6-overlay/s6-rc.d/user/contents.d && \
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/nginx-srv && \
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/timer-srv

EXPOSE 80
ENTRYPOINT ["/init"]