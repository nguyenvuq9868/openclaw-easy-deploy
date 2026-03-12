#!/usr/bin/env bash
#
# OpenClaw Easy Deploy - 一键安装脚本
# 适用于 macOS 和 Linux
#
# 使用方法:
#   curl -fsSL https://raw.githubusercontent.com/JFroson0610/openclaw-easy-deploy/main/install.sh | bash
#
# 或者下载后执行:
#   chmod +x install.sh && ./install.sh
#

set -euo pipefail

# ============================================================================
# 全局变量
# ============================================================================

VERSION="1.0.0"
INSTALL_DIR="$HOME/.openclaw"
LOG_FILE="$INSTALL_DIR/install.log"
OPENCLAW_PORT="${OPENCLAW_PORT:-18789}"
OPENCLAW_BRIDGE_PORT="${OPENCLAW_BRIDGE_PORT:-18790}"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ============================================================================
# 日志和输出函数
# ============================================================================

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
    log "INFO: $*"
}

log_success() {
    echo -e "${GREEN}✅${NC} $*"
    log "SUCCESS: $*"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $*"
    log "WARNING: $*"
}

log_error() {
    echo -e "${RED}❌${NC} $*" >&2
    log "ERROR: $*"
}

log_step() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$*${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log "STEP: $*"
}

# ============================================================================
# 工具函数
# ============================================================================

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local answer
    
    if [[ "$default" == "y" ]]; then
        prompt="$prompt (Y/n)"
    else
        prompt="$prompt (y/N)"
    fi
    
    read -p "$prompt: " answer
    answer="${answer:-$default}"
    
    case "$answer" in
        [Yy]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
    esac
}

ask_input() {
    local prompt="$1"
    local default="$2"
    local value
    
    if [[ -n "$default" ]]; then
        read -p "$prompt [$default]: " value
        echo "${value:-$default}"
    else
        read -p "$prompt: " value
        echo "$value"
    fi
}

generate_token() {
    if command_exists openssl; then
        openssl rand -hex 32
    elif command_exists python3; then
        python3 -c "import secrets; print(secrets.token_hex(32))"
    else
        # 备用方案：使用 /dev/urandom
        cat /dev/urandom | LC_ALL=C tr -dc 'a-f0-9' | fold -w 64 | head -n 1
    fi
}

check_port() {
    # 检查指定端口是否有进程在监听（返回 0 = 有进程监听）
    local port="$1"
    if command_exists lsof; then
        lsof -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1
    elif command_exists netstat; then
        netstat -an | grep ":$port " | grep LISTEN >/dev/null 2>&1
    else
        return 1
    fi
}

# ============================================================================
# 清理和错误处理
# ============================================================================

cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "安装失败，退出码: $exit_code"
        log_error "详细日志: $LOG_FILE"
        echo ""
        log_info "如需帮助，请查看故障排查文档或提交 Issue"
    fi
}

trap cleanup EXIT

# ============================================================================
# 欢迎界面
# ============================================================================

show_welcome() {
    clear
    cat << "EOF"
    
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║       🦞  OpenClaw Easy Deploy  🦞                            ║
    ║                                                               ║
    ║       让 OpenClaw 部署变得简单 - 零技术门槛，一键安装           ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝

EOF
    echo -e "  版本: ${GREEN}v${VERSION}${NC}"
    echo -e "  项目: ${BLUE}https://github.com/JFroson0610/openclaw-easy-deploy${NC}"
    echo ""
}

# ============================================================================
# 系统检测函数
# ============================================================================

detect_os() {
    log_step "检测系统环境"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        log_info "操作系统: macOS"

        # 检测 macOS 版本
        MACOS_VERSION=$(sw_vers -productVersion)
        log_info "macOS 版本: $MACOS_VERSION"

        # 检测架构
        ARCH=$(uname -m)
        if [[ "$ARCH" == "arm64" ]]; then
            log_info "CPU 架构: Apple Silicon (M1/M2/M3)"
        else
            log_info "CPU 架构: Intel x86_64"
        fi

    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        log_info "操作系统: Linux"

        # 检测 Linux 发行版
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            DISTRO="$ID"
            log_info "发行版: $NAME $VERSION"
        else
            DISTRO="unknown"
            log_warning "无法检测 Linux 发行版"
        fi

        ARCH=$(uname -m)
        log_info "CPU 架构: $ARCH"
    else
        log_error "不支持的操作系统: $OSTYPE"
        log_error "此脚本仅支持 macOS 和 Linux"
        exit 1
    fi

    # 检查磁盘空间
    local available_space
    if [[ "$OS" == "macos" ]]; then
        available_space=$(df -g "$HOME" | awk 'NR==2 {print $4}')
        log_info "可用磁盘空间: ${available_space}GB"
    else
        available_space=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
        log_info "可用磁盘空间: ${available_space}GB"
    fi

    if [[ $available_space -lt 2 ]]; then
        log_error "磁盘空间不足! 至少需要 2GB 可用空间"
        exit 1
    fi

    log_success "系统环境检测完成"
}

check_node() {
    log_step "检测 Node.js"

    if command_exists node; then
        NODE_VERSION=$(node -v | sed 's/v//')
        NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)

        log_info "已安装 Node.js: v$NODE_VERSION"

        if [[ $NODE_MAJOR -ge 22 ]]; then
            log_success "Node.js 版本满足要求 (≥22)"
            return 0
        else
            log_warning "Node.js 版本过低 (当前: $NODE_MAJOR, 需要: ≥22)"
            return 1
        fi
    else
        log_warning "Node.js 未安装"
        return 1
    fi
}

check_docker() {
    log_step "检测 Docker"

    if ! command_exists docker; then
        log_warning "Docker 未安装"
        return 1
    fi

    # 检查 Docker 是否运行
    if ! docker info &>/dev/null; then
        log_warning "Docker 已安装但未运行"
        if [[ "$OS" == "macos" ]]; then
            log_info "请启动 Docker Desktop"
        fi
        return 1
    fi

    DOCKER_VERSION=$(docker --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    log_info "Docker 版本: $DOCKER_VERSION"

    # 检查 Docker Compose
    if docker compose version &>/dev/null; then
        COMPOSE_VERSION=$(docker compose version --short)
        log_info "Docker Compose 版本: $COMPOSE_VERSION"
        log_success "Docker 环境正常"
        return 0
    else
        log_warning "Docker Compose 未安装或版本过旧"
        log_info "需要 Docker Compose V2 (docker compose 命令)"
        return 1
    fi
}

# ============================================================================
# 依赖安装函数
# ============================================================================

install_node() {
    log_step "安装 Node.js 22"

    if [[ "$OS" == "macos" ]]; then
        # macOS: 优先使用 Homebrew
        if command_exists brew; then
            log_info "使用 Homebrew 安装 Node.js 22..."
            if brew install node@22; then
                # node@22 是 keg-only，需要手动设置 PATH
                if [[ -d "/opt/homebrew/opt/node@22/bin" ]]; then
                    export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
                elif [[ -d "/usr/local/opt/node@22/bin" ]]; then
                    export PATH="/usr/local/opt/node@22/bin:$PATH"
                fi
                log_success "Node.js 22 安装成功 (Homebrew)"
                return 0
            else
                log_warning "Homebrew 安装失败，尝试使用 nvm..."
            fi
        fi
    fi

    # 使用 nvm 安装 (macOS 和 Linux 通用)
    log_info "使用 nvm 安装 Node.js 22..."

    # 加载 nvm（如果已安装但当前 shell 未激活）
    export NVM_DIR="$HOME/.nvm"
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        \. "$NVM_DIR/nvm.sh"
    fi

    # nvm 是 shell 函数，不能用 command_exists 检测，用 type 代替
    if ! type nvm &>/dev/null; then
        log_info "正在安装 nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        # 安装后立即加载
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi

    log_info "正在安装 Node.js 22..."
    nvm install 22
    nvm use 22
    nvm alias default 22

    if check_node; then
        log_success "Node.js 22 安装成功"
        return 0
    else
        log_error "Node.js 安装失败"
        return 1
    fi
}

install_docker() {
    # Docker 在 NPM 主路线下是可选的（仅 Docker 路线需要）
    # 此函数在 NPM 路线下不会被调用
    log_step "安装 Docker（可选）"

    if [[ "$OS" == "macos" ]]; then
        echo ""
        log_info "macOS 需要手动安装 Docker Desktop："
        echo ""
        echo -e "  ${BLUE}1.${NC} 访问: https://www.docker.com/products/docker-desktop"
        echo -e "  ${BLUE}2.${NC} 点击 \"Download for Mac (Apple Silicon)\" 或 \"(Intel Chip)\""
        echo -e "  ${BLUE}3.${NC} 安装完成后启动 Docker Desktop，等待菜单栏图标变为 ▶"
        echo ""
        log_warning "安装完成后请重新运行本脚本"
        return 1

    elif [[ "$OS" == "linux" ]]; then
        log_info "正在通过官方脚本安装 Docker Engine..."
        if ! curl -fsSL https://get.docker.com | sudo sh; then
            log_error "Docker 安装失败"
            return 1
        fi

        # 添加当前用户到 docker 组
        sudo usermod -aG docker "$USER"

        # 启动 Docker 服务
        sudo systemctl enable docker 2>/dev/null || true
        sudo systemctl start docker 2>/dev/null || true

        log_success "Docker 安装成功"
        log_warning "⚠ 需要重新登录才能免 sudo 使用 Docker，当前会话用 sudo 临时运行"
        return 0
    fi
}

# ============================================================================
# 配置函数
# ============================================================================

# ============================================================================
# 安装 OpenClaw（NPM 路线）
# ============================================================================

install_openclaw_npm() {
    log_step "安装 OpenClaw（NPM 方式）"

    log_info "正在通过 npm 全局安装最新版 OpenClaw..."
    echo ""

    # npm install -g openclaw@latest
    # 如果在 macOS 上 npm 全局安装需要权限，先尝试直接安装，失败则提示
    if ! npm install -g openclaw@latest 2>&1; then
        log_warning "npm 全局安装失败，尝试使用 sudo..."
        if ! sudo npm install -g openclaw@latest; then
            log_error "OpenClaw 安装失败"
            log_info "请手动运行: npm install -g openclaw@latest"
            return 1
        fi
    fi

    # 验证安装成功
    if ! command_exists openclaw; then
        # 可能 npm global bin 不在 PATH 里，尝试加载
        local npm_bin
        npm_bin=$(npm bin -g 2>/dev/null || npm root -g 2>/dev/null | sed 's|/node_modules||')
        if [[ -f "$npm_bin/openclaw" ]]; then
            export PATH="$npm_bin:$PATH"
        fi
    fi

    if command_exists openclaw; then
        local oc_version
        oc_version=$(openclaw --version 2>/dev/null || echo "已安装")
        log_success "OpenClaw $oc_version 安装成功"
        return 0
    else
        log_error "openclaw 命令未找到，请检查 npm 全局路径是否在 PATH 中"
        log_info "可运行: npm bin -g  查看全局 bin 目录"
        return 1
    fi
}

# ============================================================================
# 运行 openclaw onboard（交互式向导）
# ============================================================================

run_onboard() {
    log_step "运行 OpenClaw 配置向导（onboard）"

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  接下来将运行 OpenClaw 官方交互式配置向导${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  向导会引导你完成："
    echo -e "  ${BLUE}•${NC} 配置 AI 模型（Claude / OpenAI / Gemini 等）"
    echo -e "  ${BLUE}•${NC} 生成 Gateway Token"
    echo -e "  ${BLUE}•${NC} 安装守护进程（开机自启）"
    echo -e "  ${BLUE}•${NC} 启动 Gateway 服务"
    echo ""
    echo -e "  ${YELLOW}提示：${NC}按照提示操作即可，完成后回到这里。"
    echo ""

    if ! ask_yes_no "准备好了，开始向导?" "y"; then
        log_warning "已跳过配置向导"
        log_info "你可以随时手动运行: openclaw onboard --install-daemon"
        return 0
    fi

    echo ""
    log_info "正在启动 openclaw onboard --install-daemon ..."
    echo ""

    # 运行官方 onboard 向导，带 --install-daemon 参数自动安装守护进程
    if openclaw onboard --install-daemon; then
        echo ""
        log_success "onboard 配置向导完成！"
        return 0
    else
        local exit_code=$?
        echo ""
        log_warning "onboard 向导退出（退出码: $exit_code）"
        log_info "如果已手动跳过部分步骤，这是正常的"
        log_info "可随时重新运行: openclaw onboard --install-daemon"
        # 不返回 1，因为用户可能故意退出
        return 0
    fi
}

# ============================================================================
# 启动服务函数
# ============================================================================

# ============================================================================
# Docker 路线：下载并运行 docker-setup.sh（可选，高级用户）
# ============================================================================

start_openclaw_docker() {
    log_step "启动 OpenClaw（Docker 路线）"

    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"

    # 下载官方 docker-compose.yml
    log_info "下载 docker-compose.yml..."
    if ! curl -fsSL https://raw.githubusercontent.com/openclaw/openclaw/main/docker-compose.yml \
            -o "$INSTALL_DIR/docker-compose.yml"; then
        log_error "下载 docker-compose.yml 失败，请检查网络"
        return 1
    fi

    # 下载官方 docker-setup.sh
    log_info "下载 docker-setup.sh..."
    if ! curl -fsSL https://raw.githubusercontent.com/openclaw/openclaw/main/docker-setup.sh \
            -o "$INSTALL_DIR/docker-setup.sh"; then
        log_error "下载 docker-setup.sh 失败，请检查网络"
        return 1
    fi
    chmod +x "$INSTALL_DIR/docker-setup.sh"
    log_success "配置文件下载完成"

    # 使用 GHCR 公开镜像（不需要本地 docker build）
    export OPENCLAW_IMAGE="${OPENCLAW_IMAGE:-ghcr.io/openclaw/openclaw:latest}"
    log_info "使用镜像: $OPENCLAW_IMAGE"
    log_info "正在运行 docker-setup.sh（会拉取镜像并启动向导）..."
    echo ""

    if "$INSTALL_DIR/docker-setup.sh"; then
        log_success "OpenClaw 服务启动成功"
        return 0
    else
        log_error "docker-setup.sh 运行失败"
        log_info "请查看日志: $LOG_FILE"
        return 1
    fi
}

# ============================================================================
# 验证安装
# ============================================================================

verify_installation() {
    log_step "验证安装"

    # 检查 openclaw 命令是否存在
    if ! command_exists openclaw; then
        log_warning "openclaw 命令未找到，可能需要重新打开终端后生效"
        log_info "尝试运行: openclaw --version"
        return 0
    fi

    local oc_ver
    oc_ver=$(openclaw --version 2>/dev/null || echo "未知版本")
    log_success "openclaw 命令已就绪（$oc_ver）"

    # 检查 Gateway 端口（守护进程可能需要几秒才能监听）
    log_info "等待 Gateway 启动（最多 30 秒）..."
    local max_wait=30
    local waited=0
    while [[ $waited -lt $max_wait ]]; do
        if check_port "$OPENCLAW_PORT"; then
            log_success "Gateway 端口 $OPENCLAW_PORT 已监听"
            break
        fi
        sleep 2
        waited=$((waited + 2))
    done

    if ! check_port "$OPENCLAW_PORT"; then
        log_warning "Gateway 端口 $OPENCLAW_PORT 暂未监听"
        log_info "这是正常的，onboard 向导可能尚未完成服务启动"
        log_info "向导完成后可运行: openclaw gateway status"
        return 0
    fi

    # HTTP 健康检查
    log_info "进行 HTTP 健康检查..."
    local max_retries=5
    local retry=0
    while [[ $retry -lt $max_retries ]]; do
        if curl -fs "http://localhost:$OPENCLAW_PORT/healthz" >/dev/null 2>&1; then
            log_success "✅ Gateway 健康检查通过！"
            return 0
        fi
        retry=$((retry + 1))
        sleep 3
    done

    log_warning "健康检查未通过，服务可能仍在初始化"
    log_info "稍后手动检查: curl http://localhost:$OPENCLAW_PORT/healthz"
    return 0
}

# ============================================================================
# 成功提示
# ============================================================================

show_success() {
    echo ""
    echo ""
    cat <<EOF
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║                   🎉  安装成功！ 🎉                           ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝

EOF

    echo -e "${GREEN}✅ OpenClaw 已成功安装！${NC}"
    echo ""
    echo -e "${CYAN}📍 访问 Gateway 控制台:${NC}"
    echo -e "   http://localhost:$OPENCLAW_PORT"
    echo -e "   ${YELLOW}（如果向导已完成并启动了守护进程）${NC}"
    echo ""
    echo -e "${CYAN}📚 常用命令:${NC}"
    echo ""
    echo -e "   ${BLUE}• 查看版本${NC}"
    echo -e "     openclaw --version"
    echo ""
    echo -e "   ${BLUE}• 查看 Gateway 状态${NC}"
    echo -e "     openclaw gateway status"
    echo ""
    echo -e "   ${BLUE}• 重新运行配置向导${NC}"
    echo -e "     openclaw onboard"
    echo ""
    echo -e "   ${BLUE}• 连接聊天平台（以 Telegram 为例）${NC}"
    echo -e "     openclaw channels add --channel telegram --token <BOT_TOKEN>"
    echo ""
    echo -e "   ${BLUE}• 查看所有已连接渠道${NC}"
    echo -e "     openclaw channels list"
    echo ""
    echo -e "   ${BLUE}• 查看 Gateway 日志${NC}"
    echo -e "     openclaw gateway logs"
    echo ""
    echo -e "   ${BLUE}• 停止/启动守护进程${NC}"
    echo -e "     openclaw daemon stop"
    echo -e "     openclaw daemon start"
    echo ""
    echo -e "${CYAN}📖 完整文档:${NC}"
    echo -e "   https://github.com/JFroson0610/openclaw-easy-deploy"
    echo -e "   https://docs.openclaw.ai/start/getting-started"
    echo -e "   https://docs.openclaw.ai"
    echo ""
    echo -e "${CYAN}❓ 遇到问题?${NC}"
    echo -e "   - 查看日志: $LOG_FILE"
    echo -e "   - 故障排查: https://github.com/JFroson0610/openclaw-easy-deploy/blob/main/docs/installation-zh.md"
    echo -e "   - 提交 Issue: https://github.com/JFroson0610/openclaw-easy-deploy/issues"
    echo ""
}

# ============================================================================
# 主函数
# ============================================================================

main() {
    # 创建日志目录
    mkdir -p "$(dirname "$LOG_FILE")"

    # 显示欢迎界面
    show_welcome

    # 检测系统环境
    detect_os

    # ── 步骤 1：检查 / 安装 Node.js（必须） ───────────────────────────────
    if ! check_node; then
        log_warning "未检测到 Node.js 22+"
        if ask_yes_no "是否自动安装 Node.js 22?" "y"; then
            if ! install_node; then
                log_error "Node.js 安装失败，请手动安装后重试"
                log_info "参考: https://nodejs.org/en/download/package-manager"
                exit 1
            fi
        else
            log_error "Node.js 22+ 是必须的，安装中止"
            exit 1
        fi
    fi

    # ── 步骤 2：安装 OpenClaw（npm install -g） ───────────────────────────
    if ! install_openclaw_npm; then
        log_error "OpenClaw 安装失败，请查看日志: $LOG_FILE"
        exit 1
    fi

    # ── 步骤 3：运行官方 onboard 交互式向导 ──────────────────────────────
    run_onboard

    # ── 步骤 4：验证安装结果 ─────────────────────────────────────────────
    verify_installation

    # ── 步骤 5：显示成功信息和常用命令 ───────────────────────────────────
    show_success

    log_success "全部完成！"
}

# ============================================================================
# 脚本入口
# ============================================================================

main "$@"
