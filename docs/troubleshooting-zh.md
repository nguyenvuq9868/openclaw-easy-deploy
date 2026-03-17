# 故障排查指南

> [English Troubleshooting](./troubleshooting.md)

## 快速诊断

运行诊断工具，一键排查常见问题：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/JFroson0610/openclaw-easy-deploy/main/bin/openclaw-manager)
# 选择 7) 诊断工具
```

---

## 安装问题

### ❌ `openclaw: command not found`（安装后命令找不到）

**原因**：npm 全局 bin 路径不在 PATH 中。

```bash
# 找到全局 bin 路径
npm bin -g

# 添加到 PATH（以 ~/.zshrc 为例）
echo 'export PATH="$(npm bin -g):$PATH"' >> ~/.zshrc
source ~/.zshrc

# 验证
openclaw --version
```

### ❌ `npm install -g openclaw` 权限报错

```bash
# 方案1：使用 nvm（推荐）
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install 22 && nvm use 22
npm install -g openclaw@latest

# 方案2：修改 npm 全局目录（避免 sudo）
mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
npm install -g openclaw@latest
```

### ❌ Node.js 版本过低

```bash
node --version    # 需要 v22+

# macOS：升级
brew install node@22
brew link node@22 --force --overwrite
export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

# Linux：通过 nvm 升级
nvm install 22 && nvm alias default 22
```

### ❌ `curl: command not found`（罕见）

```bash
# Ubuntu/Debian
sudo apt-get install -y curl

# CentOS/RHEL
sudo yum install -y curl
```

---

## 服务启动问题

### ❌ Gateway 端口未监听（18789）

```bash
# 检查守护进程状态
openclaw gateway status

# 重启守护进程
openclaw daemon stop
openclaw daemon start

# 查看日志定位原因
openclaw gateway logs
```

### ❌ 端口被占用

```bash
# 查看占用进程
lsof -i :18789

# 更换端口（重新运行 onboard）
openclaw onboard --install-daemon
```

### ❌ onboard 向导启动失败

```bash
# 确保 openclaw 命令可用
which openclaw
openclaw --version

# 重新运行
openclaw onboard --install-daemon
```

---

## 渠道连接问题

### ❌ Telegram Bot 无响应

1. 确认 Bot Token 正确（去掉多余空格）
2. 确认已通过 `@BotFather` 创建 Bot 并获取 Token
3. 确认 Gateway 正在运行：`openclaw gateway status`
4. 重新添加渠道：
   ```bash
   openclaw channels remove --channel telegram
   openclaw channels add --channel telegram --token <TOKEN>
   ```

### ❌ WhatsApp 扫码超时

```bash
# 重新登录
openclaw channels login --channel whatsapp
# 打开手机 WhatsApp → 已关联设备 → 关联设备 → 扫码
```

---

## 更新问题

### ❌ `npm update -g openclaw` 无效

```bash
# 强制重新安装最新版
npm uninstall -g openclaw
npm install -g openclaw@latest
openclaw --version
```

---

## 查看日志

```bash
# Gateway 实时日志
openclaw gateway logs --follow

# 安装日志
cat ~/.openclaw/install.log

# Manager 操作日志
cat ~/.openclaw/manager.log
```

---

## 完全重装

```bash
openclaw daemon stop 2>/dev/null || true
npm uninstall -g openclaw
rm -rf ~/.openclaw
npm install -g openclaw@latest
openclaw onboard --install-daemon
```

---

## 仍然无法解决？

请携带以下信息提交 Issue：

```bash
openclaw --version
node --version
npm --version
uname -a                        # Linux/macOS
cat ~/.openclaw/install.log
```

🐛 [提交 Issue](https://github.com/JFroson0610/openclaw-easy-deploy/issues)
