# Installation Guide

> [中文安装指南](./installation-zh.md)

This guide walks you through installing OpenClaw AI Assistant on macOS, Linux, and Windows.

## Prerequisites

| Requirement | Details |
|-------------|----------|
| OS | macOS 12+, Ubuntu 20.04+ / Debian 11+, Windows 10/11 |
| Node.js | 22+ (auto-installed if missing) |
| Disk Space | 500 MB free |
| Network | Internet access required |

---

## macOS / Linux — One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/JFroson0610/openclaw-easy-deploy/main/install.sh | bash
```

The script will:
1. Detect your OS and environment
2. Install Node.js 22 (via Homebrew on macOS, nvm on Linux) if needed
3. Install OpenClaw globally via npm
4. Launch the interactive **onboard wizard** to configure AI models and install the daemon
5. Verify the installation

### Manual Download

```bash
curl -fsSL https://raw.githubusercontent.com/JFroson0610/openclaw-easy-deploy/main/install.sh -o install.sh
bash install.sh
```

---

## Windows — PowerShell

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/JFroson0610/openclaw-easy-deploy/main/install.ps1 | iex
```

Or download first:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install.ps1
```

Node.js is installed automatically via winget → Chocolatey → manual fallback.

---

## What Happens During Install

```
Step 1  Detect environment (OS, arch, disk, Node.js)
   ↓
Step 2  Install Node.js 22 (if not present)
   ↓
Step 3  npm install -g openclaw@latest
   ↓
Step 4  openclaw onboard --install-daemon
        • Choose AI model (Claude / OpenAI / Gemini ...)
        • Paste your API key
        • Install background daemon (auto-start on boot)
   ↓
Step 5  Verify + show success summary
```

---

## Post-Install: Connect Chat Platforms

```bash
# Telegram
openclaw channels add --channel telegram --token <BOT_TOKEN>

# Discord
openclaw channels add --channel discord --token <BOT_TOKEN>

# WhatsApp (QR code scan)
openclaw channels login --channel whatsapp
```

---

## Managing OpenClaw

```bash
openclaw --version            # Check version
openclaw gateway status       # Gateway status
openclaw gateway logs         # View logs
openclaw daemon start         # Start daemon
openclaw daemon stop          # Stop daemon
npm update -g openclaw        # Update to latest
```

### Interactive Manager

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/JFroson0610/openclaw-easy-deploy/main/bin/openclaw-manager)
```

Provides a menu-driven interface for status, logs, channels, diagnostics, and uninstall.

---

## Uninstall

```bash
openclaw daemon stop
npm uninstall -g openclaw
rm -rf ~/.openclaw            # optional: remove config & logs
```

---

## Troubleshooting

See [Troubleshooting Guide](./troubleshooting.md) for common issues.

## Need Help?

- 📖 Official docs: https://docs.openclaw.ai
- 🐛 Issues: https://github.com/JFroson0610/openclaw-easy-deploy/issues
