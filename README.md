# Docker Debian S6-RC Nginx Time Monitor

这是一个基于 **Debian Bookworm** 的 Docker 项目示例。它演示了如何使用 **S6 Overlay v3** 的 **s6-rc** 模式管理服务进程，并通过 AJAX 轮询实现无刷新时间更新。

本项目完全遵循 s6-overlay v3 的最佳实践，放弃了旧版的 `/etc/services.d`，转而使用 `/etc/s6-overlay/s6-rc.d` 进行声明式服务管理。

## 🏗️ 架构说明

1.  **Nginx**: 静态 Web 服务器，定义为 `longrun` 服务。
2.  **Time Monitor**: Bash 后台脚本，定义为 `longrun` 服务，持续更新 `time.txt`。
3.  **S6-RC Bundle**: 创建了一个名为 `user` 的 bundle，将上述两个服务聚合，确保容器启动时它们被自动拉起。
4.  **Frontend**: AJAX 轮询获取时间。

## 📂 目录结构 (S6-RC)

```text
.
├── Dockerfile          # 镜像构建文件
├── README.md           # 说明文档
└── rootfs/             # 容器文件系统覆盖层
    ├── etc/
    │   ├── nginx/      # Nginx 配置文件
    │   └── s6-overlay/ # S6 配置根目录
    │       └── s6-rc.d/
    │           ├── nginx/        # Nginx 服务定义
    │           │   ├── run       # 启动脚本
    │           │   └── type      # 类型: longrun
    │           ├── time-monitor/ # 时间监控服务定义
    │           │   ├── run       # 启动脚本
    │           │   └── type      # 类型: longrun
    │           └── user/         # 用户服务组 (Bundle)
    │               ├── contents.d/
    │               │   ├── nginx
    │               │   └── time-monitor
    │               └── type      # 类型: bundle
    └── usr/
        └── ...
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

### 3. 访问

浏览器访问 [http://localhost:8080](http://localhost:8080)。
