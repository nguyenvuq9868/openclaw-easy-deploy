# OpenClaw 安装指南

## 快速安装

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/JFroson0610/openclaw-easy-deploy/main/install.sh | bash
```

### 安装过程

脚本会自动完成以下步骤：

1. **检测系统环境**
   - 操作系统类型和版本
   - CPU 架构
   - 磁盘空间

2. **安装依赖**
   - Node.js 22+（如果未安装）
   - Docker 和 Docker Compose（如果未安装）

3. **配置 OpenClaw**
   - 自动生成 Gateway Token
   - 引导配置 AI 模型 API Key
   - 生成配置文件

4. **启动服务**
   - 下载 OpenClaw
   - 启动 Docker 容器
   - 验证安装

## 配置 API 密钥

### Claude API Key

1. 访问 https://console.anthropic.com/
2. 注册账号并登录
3. 创建 API Key
4. 在安装过程中输入

### OpenAI API Key

1. 访问 https://platform.openai.com/api-keys
2. 登录账号
3. 创建新的 API Key
4. 在安装过程中输入

### Gemini API Key

1. 访问 https://makersuite.google.com/app/apikey
2. 登录 Google 账号
3. 创建 API Key
4. 在安装过程中输入

## 安装后配置

### 配置聊天平台

#### WhatsApp

```bash
cd ~/.openclaw
docker compose run --rm openclaw-cli channels login
```

扫描二维码登录 WhatsApp。

#### Telegram

```bash
cd ~/.openclaw
docker compose run --rm openclaw-cli channels add --channel telegram --token YOUR_BOT_TOKEN
```

#### Discord

```bash
cd ~/.openclaw
docker compose run --rm openclaw-cli channels add --channel discord --token YOUR_BOT_TOKEN
```

## 管理服务

### 查看状态

```bash
docker compose -f ~/.openclaw/docker-compose.yml ps
```

### 查看日志

```bash
docker compose -f ~/.openclaw/docker-compose.yml logs -f
```

### 停止服务

```bash
docker compose -f ~/.openclaw/docker-compose.yml down
```

### 重启服务

```bash
docker compose -f ~/.openclaw/docker-compose.yml restart
```

### 更新

```bash
cd ~/.openclaw
./docker-setup.sh
```

## 故障排查

### 端口被占用

如果端口 18789 被其他程序占用，安装前先查看是哪个进程：

```bash
# macOS / Linux
lsof -iTCP:18789 -sTCP:LISTEN

# 然后使用其他端口运行安装脚本
OPENCLAW_PORT=18800 ./install.sh
```

### Docker 未启动

**macOS**: 打开 Launchpad 找到 Docker Desktop，或运行：

```bash
open -a Docker
# 等待约 30 秒后重试
```

**Linux**: 启动 Docker 服务：

```bash
sudo systemctl start docker
sudo systemctl enable docker  # 设置开机自启
```

### Node.js 版本过低

脚本会自动安装 Node.js 22+，如果自动安装失败，请手动安装：

```bash
# macOS (Homebrew)
brew install node@22
export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

# macOS / Linux (nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.nvm/nvm.sh
nvm install 22
nvm use 22
nvm alias default 22
```

### Docker 权限问题（Linux）

Linux 下首次安装 Docker 后，需要把用户加入 docker 组：

```bash
sudo usermod -aG docker $USER
# 必须重新登录或开新终端才能生效
newgrp docker
```

### 服务启动后健康检查失败

服务可能仍在初始化中，等待约 30 秒后手动检查：

```bash
# 检查服务状态
docker compose -f ~/.openclaw/docker-compose.yml ps

# 查看详细日志（找 ERROR 行）
docker compose -f ~/.openclaw/docker-compose.yml logs --tail=50

# 手动健康检查
curl -v http://localhost:18789/healthz
```

### 配置文件损坏或丢失

重新生成配置（会备份现有 .env）：

```bash
cd ~/.openclaw
cp .env .env.backup.$(date +%Y%m%d%H%M%S)
# 重新运行安装脚本会重新生成配置
~/openclaw-easy-deploy/install.sh
```

---

## 卸载

```bash
# 1. 停止并移除所有容器和网络
docker compose -f ~/.openclaw/docker-compose.yml down --volumes

# 2. 删除 OpenClaw 数据目录（⚠️ 不可恢复）
rm -rf ~/.openclaw

# 3. 可选：移除 Docker 镜像
docker rmi openclaw:local 2>/dev/null || true
```

---

## 获取帮助

| 途径 | 链接 |
|------|------|
| 📋 安装日志 | `~/.openclaw/install.log` |
| 🐛 提交 Issue | https://github.com/JFroson0610/openclaw-easy-deploy/issues |
| 📖 官方文档 | https://docs.openclaw.ai |
| 💬 OpenClaw 社区 | https://github.com/openclaw/openclaw/discussions |

