# 使用 Debian Bookworm Slim 作为基础镜像
FROM debian:bookworm-slim

# 定义 s6-overlay 版本
ARG S6_OVERLAY_VERSION=3.1.6.2

# 设置时区为亚洲/上海 (+8)
ENV TZ=Asia/Shanghai
RUN apt-get update && apt-get install -y --no-install-recommends     nginx     curl     ca-certificates     xz-utils     tzdata     && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone     && apt-get clean && rm -rf /var/lib/apt/lists/*

# 安装 s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

# 配置 Nginx 基础环境
RUN rm -rf /etc/nginx/sites-enabled/default
COPY root/ /

# 确保脚本具有执行权限
RUN chmod +x /etc/s6-overlay/s6-rc.d/nginx/run &&     chmod +x /etc/s6-overlay/s6-rc.d/time-monitor/run

# 暴露 80 端口
EXPOSE 80

# 使用 s6-overlay 作为入口
ENTRYPOINT ["/init"]