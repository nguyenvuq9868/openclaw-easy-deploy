# Frequently Asked Questions (FAQ)

> [中文 FAQ](./faq-zh.md)

---

## 📦 Installation

**Q: Which operating systems are supported?**

A: macOS 12+, Ubuntu 20.04+/Debian 11+ (Linux), and Windows 10/11.

---

**Q: How much disk space is required?**

A: About 200–500 MB (Node.js + OpenClaw npm package).

---

**Q: Do I need root or admin privileges?**

A: Not required. The script prefers user-level installs (nvm, ~/.npm-global). Using nvm for Node.js avoids sudo entirely.

---

**Q: Can I install offline?**

A: No. An internet connection is required to access npm Registry and GitHub.

---

**Q: Does it work on Apple Silicon (M1/M2/M3)?**

A: Yes. The script detects arm64 architecture automatically. Homebrew and nvm both support Apple Silicon natively.

---

**Q: How do I reinstall after a failed install?**

```bash
openclaw daemon stop 2>/dev/null || true
npm uninstall -g openclaw
rm -rf ~/.openclaw
curl -fsSL https://raw.githubusercontent.com/JFroson0610/openclaw-easy-deploy/main/install.sh | bash
```

---

## 🤖 AI Models

**Q: Which AI models are supported?**

A: OpenClaw supports major LLM providers:
- **Anthropic Claude** (claude-3-5-sonnet, etc.)
- **OpenAI GPT** (gpt-4o, etc.)
- **Google Gemini**
- **xAI Grok**
- **DeepSeek**
- Any OpenAI-compatible API endpoint

See the official docs for the full list: https://docs.openclaw.ai

---

**Q: Where do I get an API key?**

A: See the [API Keys Guide](./api-keys.md).

---

**Q: Is my API key secure?**

A: Your API key is stored locally in `~/.openclaw/` and never uploaded anywhere. OpenClaw runs as a local gateway — requests go directly from your machine to the AI provider.

---

## 💬 Channels

**Q: Which chat platforms are supported?**

A: Telegram, Discord, and WhatsApp. More platforms are in development — follow https://openclaw.ai for updates.

---

**Q: Can I connect multiple channels at once?**

A: Yes! OpenClaw supports multiple simultaneous channels.

```bash
openclaw channels list   # View all connected channels
```

---

## ⚙️ Service

**Q: What is the Gateway?**

A: The Gateway is OpenClaw's core service. It receives messages from chat platforms, calls the AI model, and sends replies. It runs on `localhost:18789` by default.

---

**Q: What is the daemon?**

A: The daemon keeps OpenClaw running in the background and restarts it automatically after system reboots. It is installed via `openclaw onboard --install-daemon`.

---

**Q: How do I completely uninstall OpenClaw?**

```bash
openclaw daemon stop
npm uninstall -g openclaw
rm -rf ~/.openclaw
```

---

## ❓ Other

**Q: How do I update to the latest version?**

```bash
npm update -g openclaw
openclaw --version
```

---

**Q: How do I report a bug?**

A: Open an issue at https://github.com/JFroson0610/openclaw-easy-deploy/issues. Please include `openclaw --version`, `node --version`, and the contents of `~/.openclaw/install.log`.
