# API Key 获取指南

> [English API Keys Guide](./api-keys.md)

OpenClaw 需要 AI 服务商的 API Key 才能运作。以下是各主流服务商的获取方式。

---

## Anthropic Claude

1. 访问 https://console.anthropic.com/
2. 注册 / 登录账户
3. 左侧菜单点击 **API Keys**
4. 点击 **Create Key**，输入名称
5. 复制生成的 Key（**仅显示一次**，请立即保存）

**Key 格式**：`sk-ant-api03-...`

ℹ️ 新用户有免费额度，参考官网定价：https://www.anthropic.com/pricing

---

## OpenAI GPT

1. 访问 https://platform.openai.com/
2. 注册 / 登录账户
3. 点击右上角头像 → **API keys**
4. 点击 **Create new secret key**
5. 复制 Key（**仅显示一次**）

**Key 格式**：`sk-proj-...` 或 `sk-...`

ℹ️ 需要账户余额，新用户可在 https://platform.openai.com/account/billing 充値。

---

## Google Gemini

1. 访问 https://aistudio.google.com/
2. 登录 Google 账户
3. 点击左侧 **Get API key** 或直接访问 https://aistudio.google.com/app/apikey
4. 点击 **Create API key**
5. 复制 Key

**Key 格式**：`AIza...`

ℹ️ Gemini API 有免费颟，具体详见：https://ai.google.dev/pricing

---

## Telegram Bot Token

1. 打开 Telegram，搜索 `@BotFather`
2. 发送 `/newbot`
3. 按提示输入 Bot 名称（显示名）
4. 输入 Bot 用户名（必须以 `bot` 结尾）
5. BotFather 会回复一串 Token

**Token 格式**：`123456789:ABCdef...`

取得 Token 后，连接到 OpenClaw：

```bash
openclaw channels add --channel telegram --token 123456789:ABCdef...
```

---

## Discord Bot Token

1. 访问 https://discord.com/developers/applications
2. 点击 **New Application**，输入名称
3. 左侧点击 **Bot**
4. 点击 **Add Bot**，确认
5. 在 **Token** 区域点击 **Reset Token**，复制 Token
6. 开启 **MESSAGE CONTENT INTENT**（取消选中）

```bash
openclaw channels add --channel discord --token <DISCORD_TOKEN>
```

---

## xAI Grok / DeepSeek / 其他

具体获取方式请参考各平台官网：

| 平台 | 地址 |
|------|---------|
| xAI Grok | https://console.x.ai/ |
| DeepSeek | https://platform.deepseek.com/ |

---

## 安全提示

- ✅ API Key 存储在本地 `~/.openclaw/`，**不上传到任何服务器**
- ❗ **不要将 API Key 提交到 Git** 或分享给他人
- ❗ 如果 Key 泄露，立即到对应平台删除/重创建
- 💡 建议对 Key 设置使用限额，防止意外费用

---

## 在 onboard 向导中输入 API Key

安装过程中，onboard 向导会提示你选择 AI 平台并输入 API Key：

```bash
# 重新运行向导（更换 AI 模型或 API Key）
openclaw onboard
```
