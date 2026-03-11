#!/usr/bin/env bash
set -e
REPO_NAME="openclaw-easy-deploy"
REPO_DESC="🦞 OpenClaw 一键部署工具 - 让 OpenClaw 部署变得简单，零技术门槛"
GH_USER=$(gh api user --jq '.login')
echo "GitHub 用户: $GH_USER"
git init
git checkout -b main 2>/dev/null || git branch -M main
GH_NAME=$(gh api user --jq '.name // .login')
git config user.name "$GH_NAME"
gh repo create "$REPO_NAME" --public --description "$REPO_DESC" 2>/dev/null || true
git add -A
git commit -m "🚀 Initial release: OpenClaw Easy Deploy v1.0.0"
REMOTE_URL="https://github.com/$GH_USER/$REPO_NAME.git"
git remote add origin "$REMOTE_URL" 2>/dev/null || git remote set-url origin "$REMOTE_URL"
git push -u origin main
gh repo edit "$GH_USER/$REPO_NAME" --add-topic "openclaw" --add-topic "deploy" --add-topic "docker"
echo "✅ 完成！仓库: https://github.com/$GH_USER/$REPO_NAME"

