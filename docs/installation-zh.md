# OpenClaw 安装指南

## 快速安装

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/openclaw-easy-deploy/main/install.sh | bash
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

如果端口 18789 被占用，可以修改配置：

```bash
export OPENCLAW_PORT=18790
./install.sh
```

### Docker 未启动

macOS 用户需要确保 Docker Desktop 已启动。

### Node.js 版本过低

脚本会自动安装 Node.js 22+，如果失败请手动安装：

```bash
# macOS
brew install node@22

# Linux (使用 nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install 22
nvm use 22
```

## 卸载

```bash
# 停止服务
docker compose -f ~/.openclaw/docker-compose.yml down

# 删除数据（可选）
rm -rf ~/.openclaw
```

## 获取帮助

- 查看日志: `~/.openclaw/install.log`
- 提交 Issue: https://github.com/YOUR_USERNAME/openclaw-easy-deploy/issues
- 官方文档: https://docs.openclaw.ai

