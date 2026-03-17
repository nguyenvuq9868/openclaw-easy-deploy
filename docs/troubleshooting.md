# Troubleshooting Guide

> [中文故障排查](./troubleshooting-zh.md)

## Quick Diagnosis

Run the built-in diagnostic tool:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/JFroson0610/openclaw-easy-deploy/main/bin/openclaw-manager)
# Choose option 7) Diagnostics
```

---

## Installation Issues

### ❌ `openclaw: command not found` after install

**Cause**: npm global bin directory is not in your PATH.

```bash
# Find global bin path
npm bin -g

# Add to PATH (example for ~/.zshrc)
echo 'export PATH="$(npm bin -g):$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify
openclaw --version
```

### ❌ Permission error during `npm install -g openclaw`

```bash
# Option 1: Use nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install 22 && nvm use 22
npm install -g openclaw@latest

# Option 2: Change npm global directory
mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
npm install -g openclaw@latest
```

### ❌ Node.js version too old

```bash
node --version    # Needs v22+

# macOS upgrade
brew install node@22
brew link node@22 --force --overwrite
export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

# Linux upgrade via nvm
nvm install 22 && nvm alias default 22
```

---

## Service Issues

### ❌ Gateway port not listening (18789)

```bash
# Check daemon status
openclaw gateway status

# Restart daemon
openclaw daemon stop
openclaw daemon start

# Check logs for errors
openclaw gateway logs
```

### ❌ Port already in use

```bash
# Find process using the port
lsof -i :18789

# Re-run onboard to choose a different port
openclaw onboard --install-daemon
```

### ❌ onboard wizard fails to start

```bash
# Confirm openclaw is available
which openclaw
openclaw --version

# Re-run
openclaw onboard --install-daemon
```

---

## Channel Issues

### ❌ Telegram bot not responding

1. Verify the Bot Token is correct (no extra spaces)
2. Make sure you created the bot via `@BotFather`
3. Check Gateway is running: `openclaw gateway status`
4. Re-add the channel:
   ```bash
   openclaw channels remove --channel telegram
   openclaw channels add --channel telegram --token <TOKEN>
   ```

### ❌ WhatsApp QR code timeout

```bash
# Re-login
openclaw channels login --channel whatsapp
# On phone: WhatsApp → Linked Devices → Link a Device → Scan QR
```

---

## Update Issues

### ❌ `npm update -g openclaw` has no effect

```bash
# Force reinstall latest version
npm uninstall -g openclaw
npm install -g openclaw@latest
openclaw --version
```

---

## Viewing Logs

```bash
# Live gateway logs
openclaw gateway logs --follow

# Install log
cat ~/.openclaw/install.log

# Manager operation log
cat ~/.openclaw/manager.log
```

---

## Full Reinstall

```bash
openclaw daemon stop 2>/dev/null || true
npm uninstall -g openclaw
rm -rf ~/.openclaw
npm install -g openclaw@latest
openclaw onboard --install-daemon
```

---

## Still Stuck?

Please include the following when filing an issue:

```bash
openclaw --version
node --version
npm --version
uname -a                        # Linux/macOS
cat ~/.openclaw/install.log
```

🐛 [Open an Issue](https://github.com/JFroson0610/openclaw-easy-deploy/issues)
