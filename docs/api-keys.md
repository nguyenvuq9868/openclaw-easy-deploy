# API Keys Guide

> [中文 API Key 指南](./api-keys-zh.md)

OpenClaw requires an API key from an AI provider to function. Below are instructions for each major provider.

---

## Anthropic Claude

1. Go to https://console.anthropic.com/
2. Sign up or log in
3. Click **API Keys** in the left sidebar
4. Click **Create Key**, enter a name
5. Copy the generated key (**shown only once** — save it immediately)

**Key format**: `sk-ant-api03-...`

ℹ️ New users get free credits. Pricing: https://www.anthropic.com/pricing

---

## OpenAI GPT

1. Go to https://platform.openai.com/
2. Sign up or log in
3. Click your avatar (top right) → **API keys**
4. Click **Create new secret key**
5. Copy the key (**shown only once**)

**Key format**: `sk-proj-...` or `sk-...`

ℹ️ Requires account balance. Add credits at https://platform.openai.com/account/billing

---

## Google Gemini

1. Go to https://aistudio.google.com/
2. Sign in with your Google account
3. Click **Get API key** on the left, or visit https://aistudio.google.com/app/apikey
4. Click **Create API key**
5. Copy the key

**Key format**: `AIza...`

ℹ️ Gemini API has a free tier. Pricing: https://ai.google.dev/pricing

---

## Telegram Bot Token

1. Open Telegram and search for `@BotFather`
2. Send `/newbot`
3. Follow prompts to enter a display name
4. Enter a username (must end in `bot`)
5. BotFather replies with the token

**Token format**: `123456789:ABCdef...`

Connect to OpenClaw:

```bash
openclaw channels add --channel telegram --token 123456789:ABCdef...
```

---

## Discord Bot Token

1. Go to https://discord.com/developers/applications
2. Click **New Application**, enter a name
3. Click **Bot** in the left sidebar
4. Click **Add Bot**, confirm
5. Under **Token**, click **Reset Token** and copy it
6. Enable **MESSAGE CONTENT INTENT** (toggle on)

```bash
openclaw channels add --channel discord --token <DISCORD_TOKEN>
```

---

## xAI Grok / DeepSeek / Others

| Provider | Console URL |
|----------|-------------|
| xAI Grok | https://console.x.ai/ |
| DeepSeek | https://platform.deepseek.com/ |

---

## Security Tips

- ✅ API keys are stored locally in `~/.openclaw/` and **never uploaded anywhere**
- ❗ **Never commit API keys to Git** or share them with others
- ❗ If a key is leaked, delete and regenerate it immediately
- 💡 Set usage limits on each key to prevent unexpected charges

---

## Entering Your API Key

During install, the onboard wizard prompts you to choose an AI provider and enter your key:

```bash
# Re-run to change AI model or update API key
openclaw onboard
```
