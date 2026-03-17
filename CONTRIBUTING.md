# Contributing to OpenClaw Easy Deploy

感谢你对本项目的兴趣！欢迎任何形式的贡献。

Thank you for your interest in contributing! Contributions of all kinds are welcome.

---

## 快速开始 / Quick Start

```bash
# 1. Fork 并 clone 仓库
git clone https://github.com/<YOUR_USERNAME>/openclaw-easy-deploy.git
cd openclaw-easy-deploy

# 2. 创建功能分支
git checkout -b feat/your-feature-name

# 3. 进行修改并测试
bash -n install.sh          # 语法检查
bash -n scripts/*.sh        # 全部子模块

# 4. 提交变更
git add -A && git commit -m "feat: describe your change"
git push origin feat/your-feature-name

# 5. 在 GitHub 上开启 Pull Request
```

---

## 项目结构 / Project Structure

```
openclaw-easy-deploy/
├── install.sh              # macOS/Linux 主控入口（160行）
├── install.ps1             # Windows PowerShell 安装脚本
├── bin/
│   └── openclaw-manager    # 交互式管理工具
├── scripts/
│   ├── common.sh           # 共用函数库
│   ├── detect-env.sh       # 环境检测
│   ├── install-node.sh     # Node.js 安装
│   ├── install-docker.sh   # Docker 安装（备用路线）
│   ├── configure.sh        # OpenClaw npm 安装 + onboard
│   ├── start-service.sh    # 服务启动
│   └── verify.sh           # 验证和成功提示
├── docs/                   # 文档目录
└── README.md
```

---

## 代码规范 / Code Style

### Bash 脚本

- 所有脚本必须以 `set -euo pipefail` 开头
- 自定义函数用注释说明用途
- 私有函数以下划线前缀：`_my_private_func()`
- 变量在双引号中使用：`"$variable"`
- 每次修改后运行语法检查：`bash -n <file>`
- 尽量避免外部命令需求，保持小巧单一
- 日志使用 `scripts/common.sh` 中的函数（`log_info`、`log_success` 等）

### PowerShell

- 使用 `$ErrorActionPreference = 'Stop'` 和 `Set-StrictMode -Version Latest`
- 函数命名用 `Verb-Noun` 风格
- 日志使用 `Write-Info`、`Write-Success` 等自定义函数

### 文档

- 中英文对照（每个文档都有对应的 `-zh.md` 版本）
- 保持简洁，不超过 150 行
- 包含可用的 `bash` 代码示例

---

## 提交 Issue / Submitting Issues

提交 Issue 时，请包含：

- 操作系统和版本
- `openclaw --version` 和 `node --version` 输出
- 完整错误信息
- `~/.openclaw/install.log` 的相关内容

---

## Pull Request 指南

- PR 标题格式：`feat: ...` / `fix: ...` / `docs: ...` / `chore: ...`
- PR 描述中说明修改原因和影响范围
- Bash 修改必须通过 `bash -n` 语法检查
- 欢迎导向 `main` 分支

---

## 联系 / Contact

- 🐛 提交 Issue: https://github.com/JFroson0610/openclaw-easy-deploy/issues
- 📖 官方文档: https://docs.openclaw.ai
- 🌐 官网: https://openclaw.ai
