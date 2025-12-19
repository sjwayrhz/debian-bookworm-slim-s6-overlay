# Debian with s6-overlay Docker Image

基于 Debian Bookworm Slim 的 Docker 镜像，集成 s6-overlay 进程管理，运行 Nginx 和实时时间监控。

## 功能特性

- **s6-overlay 进程管理**：同时管理多个服务
- **Nginx Web 服务器**：提供 HTTP 服务
- **实时时间显示**：每秒更新的北京时间（UTC+8）
- **美观界面**：渐变色背景，响应式设计

## 快速开始

### 运行镜像

```bash
docker run -d -p 8080:80 --name debian-s6 sjwayrhz/debian:latest
```

然后在浏览器中访问 `http://localhost:8080`，你会看到一个实时滚动更新的时间页面。

### 使用 Docker Compose

创建 `docker-compose.yml` 文件：

```yaml
version: '3.8'

services:
  debian-s6:
    image: sjwayrhz/debian:latest
    ports:
      - "8080:80"
    restart: unless-stopped
```

运行：

```bash
docker-compose up -d
```

## 本地构建

### 克隆仓库

```bash
git clone <your-repo-url>
cd <your-repo-name>
```

### 构建镜像

```bash
docker build -t sjwayrhz/debian:latest .
```

### 测试镜像

```bash
docker run -d -p 8080:80 sjwayrhz/debian:latest
```

## s6-overlay 服务说明

镜像中运行了两个 s6-overlay 服务：

### 1. Nginx 服务

- **路径**: `/etc/services.d/nginx/run`
- **功能**: 以非守护进程模式运行 Nginx
- **端口**: 80

### 2. 时间监控服务

- **路径**: `/etc/services.d/time-monitor/run`
- **功能**: 每秒更新 `/usr/share/nginx/html/index.html`，显示当前北京时间
- **更新频率**: 1秒

## GitHub Actions 配置

### 设置 Secrets

在你的 GitHub 仓库中设置以下 Secrets：

1. 进入仓库的 **Settings** → **Secrets and variables** → **Actions**
2. 添加以下 secrets：
   - `DOCKERHUB_USERNAME`: 你的 Docker Hub 用户名
   - `DOCKERHUB_TOKEN`: 你的 Docker Hub 访问令牌

### 触发条件

GitHub Actions 工作流会在以下情况下触发：

- **手动触发**: 在 Actions 页面点击 "Run workflow"
- **推送到 main 分支**: 自动构建并推送 `latest` 标签
- **推送 tag**: 自动构建并推送对应的标签版本

### 示例：创建新版本

```bash
# 创建并推送 tag
git tag v1.0.0
git push origin v1.0.0

# 将自动构建并推送以下镜像：
# - sjwayrhz/debian:v1.0.0
# - sjwayrhz/debian:latest (如果在 main 分支)
```

## 文件结构

```
.
├── Dockerfile
├── .github
│   └── workflows
│       └── docker-build.yml
└── README.md
```

## 技术细节

- **基础镜像**: debian:bookworm-slim
- **s6-overlay 版本**: 3.1.6.2
- **时区**: Asia/Shanghai (UTC+8)
- **架构支持**: linux/amd64, linux/arm64

## 查看日志

查看所有服务日志：

```bash
docker logs debian-s6
```

进入容器查看特定服务：

```bash
docker exec -it debian-s6 bash
```

## 停止和清理

```bash
# 停止容器
docker stop debian-s6

# 删除容器
docker rm debian-s6

# 删除镜像
docker rmi sjwayrhz/debian:latest
```

## 自定义

### 修改时区

在 Dockerfile 中修改 `TZ` 环境变量：

```dockerfile
ENV TZ=America/New_York
```

### 修改更新频率

编辑 `/etc/services.d/time-monitor/run` 中的 `sleep 1` 来调整更新间隔。

## License

MIT
