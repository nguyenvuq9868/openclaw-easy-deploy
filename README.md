# 🦞 OpenClaw Easy Deploy | OpenClaw 一键部署工具

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-blue)](https://github.com/YOUR_USERNAME/openclaw-easy-deploy)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-Compatible-green)](https://openclaw.ai)

**让 OpenClaw 部署变得简单 - 零技术门槛，一键安装**

[English](#english) | [中文](#中文)

</div>

---

## 中文

### 📖 项目简介

OpenClaw Easy Deploy 是一个社区贡献的一键部署工具，旨在解决 [OpenClaw](https://openclaw.ai) 部署过程中的各种痛点，让完全不懂技术的用户也能轻松安装和使用 OpenClaw。

**OpenClaw** 是一个强大的个人 AI 助手，可以：
- 🤖 连接多种 AI 模型（Claude、GPT、Gemini 等）
- 💬 支持多个聊天平台（WhatsApp、Telegram、Discord、Slack 等）
- 🌐 浏览器控制、文件操作、技能扩展
- 🔒 完全私有部署，数据安全

### ✨ 为什么需要这个工具？

官方 OpenClaw 部署需要：
- ❌ 手动安装 Node.js 22+
- ❌ 手动安装 Docker 和 Docker Compose
- ❌ 配置 80+ 行的 .env 文件
- ❌ 理解复杂的 600+ 行安装脚本
- ❌ 处理各种平台特定问题

**使用本工具后：**
- ✅ 一条命令完成所有安装
- ✅ 自动检测并安装依赖
- ✅ 交互式配置向导
- ✅ 智能错误诊断和修复
- ✅ 中英双语支持

### 🚀 快速开始

#### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/openclaw-easy-deploy/main/install.sh | bash
```

或者下载后执行：

```bash
wget https://raw.githubusercontent.com/YOUR_USERNAME/openclaw-easy-deploy/main/install.sh
chmod +x install.sh
./install.sh
```

#### Windows

```powershell
# 以管理员身份运行 PowerShell
irm https://raw.githubusercontent.com/YOUR_USERNAME/openclaw-easy-deploy/main/install.ps1 | iex
```

### 📋 系统要求

- **操作系统**: macOS 10.15+, Ubuntu 20.04+, Debian 10+, CentOS 8+, Windows 10+
- **CPU 架构**: x86_64 或 arm64 (Apple Silicon)
- **磁盘空间**: 至少 2GB 可用空间
- **内存**: 建议 2GB 以上

### 🎯 功能特性

#### 🔍 智能环境检测
- 自动检测操作系统和架构
- 检测已安装的 Node.js 和 Docker
- 检查磁盘空间和端口占用

#### 📦 自动依赖安装
- **Node.js 22+**: 通过 Homebrew、nvm 或包管理器自动安装
- **Docker**: 引导安装 Docker Desktop 或 Docker Engine
- **Docker Compose V2**: 自动验证和安装

#### ⚙️ 交互式配置向导
- 自动生成安全的 Gateway Token（64字符随机字符串）
- 引导配置 AI 模型 API Key（Claude、OpenAI、Gemini）
- 可选配置聊天平台（WhatsApp、Telegram、Discord 等）
- 智能默认配置，减少用户决策

#### 🛡️ 错误处理和诊断
- 三级错误处理（致命、可恢复、警告）
- 友好的错误提示和解决方案
- 详细的安装日志（`~/.openclaw/install.log`）
- 自动诊断工具

#### ♻️ 幂等性设计
- 可以安全地重复运行脚本
- 自动跳过已完成的步骤
- 保护现有配置不被覆盖

#### 🌍 多语言支持
- 完整的中英双语文档
- 中文友好的错误提示
- 针对中国用户的特殊优化（镜像源等）

### 📸 安装演示

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║       🦞  OpenClaw Easy Deploy  🦞                            ║
║                                                               ║
║       让 OpenClaw 部署变得简单 - 零技术门槛，一键安装           ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

ℹ 操作系统: macOS 14.2
ℹ CPU 架构: Apple Silicon (M1/M2/M3)
✅ Node.js: v22.1.0
✅ Docker: 24.0.7
✅ 可用磁盘空间: 50GB

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
配置 OpenClaw
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Gateway Token 已生成
是否配置 Claude API Key? (y/N): y
请输入 Claude API Key: sk-ant-xxxxx
✅ Claude API Key 已保存

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
启动 OpenClaw
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ OpenClaw 服务启动成功
✅ 健康检查通过

╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║                   🎉  安装成功！ 🎉                           ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

📍 访问地址: http://localhost:18789
🔑 Gateway Token: abc123...xyz
```

### 📚 详细文档

- [安装指南](docs/installation-zh.md) - 详细的安装步骤和说明
- [配置指南](docs/configuration-zh.md) - 配置文件详解
- [故障排查](docs/troubleshooting-zh.md) - 常见问题和解决方案
- [API 密钥获取](docs/api-keys-zh.md) - 如何获取各种 API Key
- [常见问题 FAQ](docs/faq-zh.md) - 常见问题解答

### 🔧 安装后管理

安装完成后，您可以使用以下命令管理 OpenClaw：

```bash
# 查看服务状态
docker compose -f ~/.openclaw/docker-compose.yml ps

# 查看日志
docker compose -f ~/.openclaw/docker-compose.yml logs -f

# 停止服务
docker compose -f ~/.openclaw/docker-compose.yml down

# 重启服务
docker compose -f ~/.openclaw/docker-compose.yml restart

# 更新到最新版
cd ~/.openclaw && ./docker-setup.sh
```

### 🔑 配置聊天平台

#### WhatsApp (扫码登录)

```bash
cd ~/.openclaw
docker compose run --rm openclaw-cli channels login
```

#### Telegram (Bot Token)

```bash
cd ~/.openclaw
docker compose run --rm openclaw-cli channels add --channel telegram --token YOUR_BOT_TOKEN
```

#### Discord (Bot Token)

```bash
cd ~/.openclaw
docker compose run --rm openclaw-cli channels add --channel discord --token YOUR_BOT_TOKEN
```

更多详情请查看 [官方文档](https://docs.openclaw.ai/channels)。

### 🤝 贡献

欢迎贡献！如果您发现问题或有改进建议，请：
- 提交 Issue: [GitHub Issues](https://github.com/YOUR_USERNAME/openclaw-easy-deploy/issues)
- 提交 Pull Request: [GitHub PRs](https://github.com/YOUR_USERNAME/openclaw-easy-deploy/pulls)

### 📄 许可证

MIT License - 详见 [LICENSE](LICENSE)

### 🙏 致谢

本项目基于 [OpenClaw](https://github.com/openclaw/openclaw) 构建，感谢 OpenClaw 团队的出色工作！

---

**注意**: 本项目是社区贡献的简化安装工具，不是 OpenClaw 官方项目。

