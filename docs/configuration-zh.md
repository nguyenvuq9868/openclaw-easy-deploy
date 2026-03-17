# 配置指南

> [English Configuration Guide](./configuration.md)

---

## 配置文件位置

```
~/.openclaw/
├── config.json       # 主配置文件
├── install.log       # 安装日志
└── manager.log       # Manager 操作日志
```

所有配置均存储在本地，**不会上传到任何服务器**。

---

## 主要配置项

配置通过 `openclaw onboard` 向导设置，也可了解以下环境变量：

| 变量 | 默认値 | 说明 |
|--------|--------|---------|
| `OPENCLAW_PORT` | `18789` | Gateway 端口 |
| `OPENCLAW_BRIDGE_PORT` | `18790` | Bridge 端口 |

自定义端口：

```bash
export OPENCLAW_PORT=19000
openclaw onboard --install-daemon
```

---

## AI 模型配置

onboard 向导会引导你选择 AI 平台和模型，设置完成后可随时重新运行修改：

```bash
openclaw onboard
```

支持的 AI 平台：

| 平台 | 常用模型 |
|------|-----------|
| Anthropic | claude-3-5-sonnet-latest |
| OpenAI | gpt-4o |
| Google | gemini-1.5-pro |
| xAI | grok-beta |
| DeepSeek | deepseek-chat |

---

## 渠道配置

```bash
# 查看已配置渠道
openclaw channels list

# 添加 Telegram
openclaw channels add --channel telegram --token <BOT_TOKEN>

# 添加 Discord
openclaw channels add --channel discord --token <BOT_TOKEN>

# 登录 WhatsApp
openclaw channels login --channel whatsapp

# 移除渠道
openclaw channels remove --channel telegram
```

---

## Gateway 配置

```bash
# 查看 Gateway 状态
openclaw gateway status

# 查看实时日志
openclaw gateway logs --follow
```

---

## 守护进程配置

```bash
# 安装并启动守护进程（开机自启）
openclaw onboard --install-daemon

# 手动启动 / 停止
openclaw daemon start
openclaw daemon stop
```

---

## 日志配置

| 日志文件 | 说明 |
|----------|---------|
| `~/.openclaw/install.log` | 安装过程日志 |
| `~/.openclaw/manager.log` | openclaw-manager 操作日志 |

查看 Gateway 日志：

```bash
openclaw gateway logs
openclaw gateway logs --follow   # 实时跟踪
```

---

## 完整重设配置

```bash
# 重新运行向导（更换模型 / API Key / 端口等）
openclaw onboard

# 或强制重设
openclaw daemon stop
rm -rf ~/.openclaw
openclaw onboard --install-daemon
```

---

更多配置选项请参阅官方文档：https://docs.openclaw.ai
