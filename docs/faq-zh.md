# 常见问题（FAQ）

> [English FAQ](./faq.md)

---

## 📦 安装相关

**Q: 支持哪些操作系统？**

A: 支持 macOS 12+、Ubuntu 20.04+/Debian 11+（Linux）以及 Windows 10/11。

---

**Q: 安装需要多少磁盘空间？**

A: 约 200-500 MB（Node.js + OpenClaw npm 包）。

---

**Q: 需要 root/管理员权限吗？**

A: 不是必须的。脚本优先使用用户级安装（nvm、~/.npm-global）。如果遇到权限问题，可以通过 nvm 安装 Node.js 完全避免 sudo。

---

**Q: 可以离线安装吗？**

A: 不可以，安装需要网络访问 npm Registry 和 GitHub。

---

**Q: 在 macOS M1/M2/M3（Apple Silicon）上可以用吗？**

A: 可以，脚本会自动检测 arm64 架构，Homebrew 和 nvm 均原生支持 Apple Silicon。

---

**Q: 安装失败了，怎么重装？**

```bash
openclaw daemon stop 2>/dev/null || true
npm uninstall -g openclaw
rm -rf ~/.openclaw
curl -fsSL https://raw.githubusercontent.com/JFroson0610/openclaw-easy-deploy/main/install.sh | bash
```

---

## 🤖 AI 模型相关

**Q: 支持哪些 AI 模型？**

A: OpenClaw 支持主流大模型，包括：
- **Anthropic Claude**（claude-3-5-sonnet 等）
- **OpenAI GPT**（gpt-4o 等）
- **Google Gemini**
- **xAI Grok**
- **DeepSeek**
- 以及其他兼容 OpenAI API 格式的模型

具体支持列表以官方文档为准：https://docs.openclaw.ai

---

**Q: API Key 去哪里获取？**

A: 参见 [API Key 获取指南](./api-keys-zh.md)。

---

**Q: 我的 API Key 安全吗？**

A: API Key 存储在本地 `~/.openclaw/` 目录，不会上传到任何服务器。OpenClaw 作为本地 Gateway 运行，请求直接从你的机器发往 AI 服务商。

---

## 💬 渠道相关

**Q: 支持哪些聊天平台？**

A: 目前支持 Telegram、Discord、WhatsApp。更多平台持续开发中，关注 https://openclaw.ai 获取最新动态。

---

**Q: 可以同时连接多个渠道吗？**

A: 可以！OpenClaw 支持同时连接多个渠道。

```bash
openclaw channels list   # 查看所有已连接渠道
```

---

**Q: Telegram Bot 怎么创建？**

A: 参见 [API Key 获取指南 - Telegram 部分](./api-keys-zh.md#telegram-bot-token)。

---

## ⚙️ 服务相关

**Q: Gateway 是什么？**

A: Gateway 是 OpenClaw 的核心服务，负责接收来自聊天平台的消息，调用 AI 模型，并回复用户。默认运行在 `localhost:18789`。

---

**Q: 守护进程（daemon）是什么？**

A: 守护进程让 OpenClaw 在后台持续运行，并在系统重启后自动恢复。通过 `openclaw onboard --install-daemon` 安装。

---

**Q: 如何彻底卸载 OpenClaw？**

```bash
openclaw daemon stop
npm uninstall -g openclaw
rm -rf ~/.openclaw
```

---

## ❓ 其他

**Q: 如何更新到最新版？**

```bash
npm update -g openclaw
openclaw --version
```

---

**Q: 遇到 Bug 怎么报告？**

A: 请访问 https://github.com/JFroson0610/openclaw-easy-deploy/issues 提交 Issue，并附上 `openclaw --version`、`node --version` 和 `~/.openclaw/install.log` 的内容。
