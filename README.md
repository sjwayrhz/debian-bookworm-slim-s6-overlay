# Docker Debian S6 Nginx Time Monitor (AJAX Version)

这是一个基于 **Debian Bookworm** 的 Docker 项目示例。它演示了如何使用 **S6 Overlay** 管理多个进程，并通过 **AJAX 轮询** 实现前后端分离的数据更新，避免了页面整体刷新。  

- v1.0 完成了nginx和时间监控同时的启动

## 🏗️ 架构说明

1. **Nginx**: 作为一个静态 Web 服务器运行，托管 `index.html` 和数据文件。
2. **Time Monitor (Backend)**: 一个 Bash 脚本，每秒获取系统时间并将其写入 `/usr/share/nginx/html/time.txt`。
3. **Frontend**: `index.html` 包含一段 JavaScript，使用 `fetch` API 每秒读取一次 `time.txt` 并更新 DOM。

这种设计使得页面加载平滑，无闪烁。

## 📂 目录结构

```text
.
├── Dockerfile          # 镜像构建文件
├── README.md           # 说明文档
└── rootfs/             # 容器文件系统覆盖层
    ├── etc/
    │   ├── nginx/      # Nginx 配置文件
    │   └── services.d/ # S6 服务定义目录
    │       ├── nginx/
    │       └── time-monitor/
    └── usr/
        └── share/
            └── nginx/
                └── html/
                    └── index.html  # 静态前端页面
```

## 🚀 快速开始

### 1. 构建镜像

```bash
docker build -t my-time-monitor .
```

### 2. 运行容器

```bash
docker run -d -p 8080:80 --name time-app my-time-monitor
```

### 3. 查看效果

浏览器访问 [http://localhost:8080](http://localhost:8080)。

你会看到时间在跳动，但浏览器的刷新按钮并没有在转圈，这就是 AJAX 的魔力。

## 🛠️ 关键代码解析

### 后台脚本 (rootfs/etc/services.d/time-monitor/run)

这个脚本不再生成 HTML，而是生成纯文本数据：

```bash
while true; do
  date +"%Y-%m-%d %H:%M:%S" > /usr/share/nginx/html/time.txt
  sleep 1
done
```

### 前端逻辑 (rootfs/usr/share/nginx/html/index.html)

JavaScript 定时获取数据：

```javascript
setInterval(async () => {
    const res = await fetch('time.txt?t=' + Date.now()); // 防止缓存
    document.getElementById('display').innerText = await res.text();
}, 1000);
```
