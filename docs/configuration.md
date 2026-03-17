# Configuration Guide

> [中文配置指南](./configuration-zh.md)

---

## Configuration Files

```
~/.openclaw/
├── config.json       # Main configuration file
├── install.log       # Install log
└── manager.log       # Manager operation log
```

All configuration is stored locally and **never uploaded anywhere**.

---

## Environment Variables

Configuration is primarily done through the `openclaw onboard` wizard. You can also use environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENCLAW_PORT` | `18789` | Gateway port |
| `OPENCLAW_BRIDGE_PORT` | `18790` | Bridge port |

Example — custom port:

```bash
export OPENCLAW_PORT=19000
openclaw onboard --install-daemon
```

---

## AI Model Configuration

The onboard wizard guides you through selecting an AI provider and model. To change your model or API key later:

```bash
openclaw onboard
```

Supported providers:

| Provider | Common Models |
|----------|--------------|
| Anthropic | claude-3-5-sonnet-latest |
| OpenAI | gpt-4o |
| Google | gemini-1.5-pro |
| xAI | grok-beta |
| DeepSeek | deepseek-chat |

---

## Channel Configuration

```bash
# List configured channels
openclaw channels list

# Add Telegram
openclaw channels add --channel telegram --token <BOT_TOKEN>

# Add Discord
openclaw channels add --channel discord --token <BOT_TOKEN>

# Login WhatsApp (QR code)
openclaw channels login --channel whatsapp

# Remove a channel
openclaw channels remove --channel telegram
```

---

## Gateway Configuration

```bash
# Check Gateway status
openclaw gateway status

# View live logs
openclaw gateway logs --follow
```

---

## Daemon Configuration

```bash
# Install daemon (auto-start on boot)
openclaw onboard --install-daemon

# Manual start / stop
openclaw daemon start
openclaw daemon stop
```

---

## Logs

| Log File | Description |
|----------|-------------|
| `~/.openclaw/install.log` | Install process log |
| `~/.openclaw/manager.log` | openclaw-manager operation log |

```bash
openclaw gateway logs          # Gateway logs
openclaw gateway logs --follow # Live tail
```

---

## Full Reset

```bash
# Re-run onboard (change model / API key / port etc.)
openclaw onboard

# Or force full reset
openclaw daemon stop
rm -rf ~/.openclaw
openclaw onboard --install-daemon
```

---

For advanced configuration options, see the official docs: https://docs.openclaw.ai
