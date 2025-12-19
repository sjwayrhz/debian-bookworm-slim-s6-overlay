FROM debian:bookworm-slim

# 自动参数，由 Docker Buildx 传入 (例如 amd64, arm64)
ARG TARGETARCH

# 设置环境变量
ENV S6_OVERLAY_VERSION=3.1.6.2 \
    TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive

# 安装必要的软件包
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nginx \
    curl \
    xz-utils \
    tzdata \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 自动判断架构并下载对应的 S6 Overlay
RUN set -x && \
    case "${TARGETARCH}" in \
        "amd64") S6_ARCH="x86_64" ;; \
        "arm64") S6_ARCH="aarch64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    curl -L -o /tmp/s6-overlay-noarch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    curl -L -o /tmp/s6-overlay-arch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-arch.tar.xz && \
    rm -rf /tmp/*

# 清理 Nginx 默认配置
RUN rm -rf /etc/nginx/sites-enabled/* && \
    rm -rf /etc/nginx/conf.d/*
# 1. 将 rootfs 文件夹内的所有内容复制到容器根目录
COPY rootfs /

# 2. 批量处理：删除 \r 换行符并赋予执行权限
RUN find /etc/s6-overlay/s6-rc.d -name run -o -name up | xargs sed -i 's/\r$//' && \
    find /etc/s6-overlay/s6-rc.d -name run -o -name up | xargs chmod +x

# 3. Nginx 日志重定向（让 K8S 性能监控能抓到日志）
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# 赋予脚本可执行权限 (包含 nginx, time-monitor 和新的 oneshot 脚本)
RUN chmod +x /etc/s6-overlay/s6-rc.d/nginx/run && \
    chmod +x /etc/s6-overlay/s6-rc.d/time-monitor/run && \
    chmod +x /etc/s6-overlay/s6-rc.d/check-network/up

# 暴露端口
EXPOSE 80

# 使用 s6-overlay 作为入口点
ENTRYPOINT ["/init"]
