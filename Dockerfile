FROM debian:bookworm-slim

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
    && rm -rf /var/lib/apt/lists/*

# 设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 下载并安装 s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && rm /tmp/s6-overlay-noarch.tar.xz

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz && rm /tmp/s6-overlay-x86_64.tar.xz

# 创建 nginx 服务目录
RUN mkdir -p /etc/services.d/nginx

# 创建 nginx 启动脚本
RUN echo '#!/command/execlineb -P' > /etc/services.d/nginx/run && \
    echo 'nginx -g "daemon off;"' >> /etc/services.d/nginx/run && \
    chmod +x /etc/services.d/nginx/run

# 创建时间监控服务目录
RUN mkdir -p /etc/services.d/time-monitor

# 创建时间监控脚本
RUN echo '#!/bin/bash' > /etc/services.d/time-monitor/run && \
    echo 'while true; do' >> /etc/services.d/time-monitor/run && \
    echo '  current_time=$(date +"%Y-%m-%d %H:%M:%S")' >> /etc/services.d/time-monitor/run && \
    echo '  echo "<html><head><meta http-equiv=\"refresh\" content=\"1\"><meta charset=\"UTF-8\"><style>body{display:flex;justify-content:center;align-items:center;height:100vh;margin:0;font-family:Arial,sans-serif;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);}.time-container{text-align:center;color:white;}.time{font-size:4rem;font-weight:bold;text-shadow:2px 2px 4px rgba(0,0,0,0.3);}.date{font-size:1.5rem;margin-top:20px;opacity:0.9;}</style></head><body><div class=\"time-container\"><div class=\"time\">${current_time}</div><div class=\"date\">北京时间 (UTC+8)</div></div></body></html>" > /usr/share/nginx/html/index.html' >> /etc/services.d/time-monitor/run && \
    echo '  sleep 1' >> /etc/services.d/time-monitor/run && \
    echo 'done' >> /etc/services.d/time-monitor/run && \
    chmod +x /etc/services.d/time-monitor/run

# 配置 nginx
RUN echo 'server {' > /etc/nginx/sites-available/default && \
    echo '    listen 80 default_server;' >> /etc/nginx/sites-available/default && \
    echo '    listen [::]:80 default_server;' >> /etc/nginx/sites-available/default && \
    echo '    root /usr/share/nginx/html;' >> /etc/nginx/sites-available/default && \
    echo '    index index.html;' >> /etc/nginx/sites-available/default && \
    echo '    server_name _;' >> /etc/nginx/sites-available/default && \
    echo '    location / {' >> /etc/nginx/sites-available/default && \
    echo '        try_files $uri $uri/ =404;' >> /etc/nginx/sites-available/default && \
    echo '    }' >> /etc/nginx/sites-available/default && \
    echo '}' >> /etc/nginx/sites-available/default

# 创建初始 HTML 文件
RUN echo '<html><head><meta charset="UTF-8"><style>body{display:flex;justify-content:center;align-items:center;height:100vh;margin:0;font-family:Arial;background:#667eea;color:white;font-size:3rem;}</style></head><body>Loading...</body></html>' > /usr/share/nginx/html/index.html

# 暴露端口
EXPOSE 80

# 使用 s6-overlay 作为入口点
ENTRYPOINT ["/init"]