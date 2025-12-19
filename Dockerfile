# 使用最稳定的基础镜像
FROM debian:bookworm-slim

# 1. 安装基础工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx curl xz-utils ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. 安装 s6-overlay (版本 3.1.6.2)
# 注意：这里根据你的服务器架构选择 x86_64 或 aarch64
ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.6.2/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.6.2/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz && \
    rm /tmp/*.tar.xz

# 3. 设置容器时区为 UTC+8 (系统层级)
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 4. 拷贝 HTML 文件 (从你指定的目录)
COPY html/ /var/www/html/

# 5. 拷贝 s6 服务配置
COPY s6-config/ /etc/s6-overlay/s6-rc.d/
RUN chmod +x /etc/s6-overlay/s6-rc.d/*/run

# 6. 启用服务 (nginx-srv 和 timer-srv)
RUN mkdir -p /etc/s6-overlay/s6-rc.d/user/contents.d && \
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/nginx-srv && \
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/timer-srv

# 声明端口
EXPOSE 80

# 使用 s6 作为入口点
ENTRYPOINT ["/init"]