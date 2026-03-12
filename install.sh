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
    log_step "安装 Docker"

    if [[ "$OS" == "macos" ]]; then
        log_info "macOS 用户请手动安装 Docker Desktop:"
        log_info "1. 访问: https://www.docker.com/products/docker-desktop"
        log_info "2. 下载并安装 Docker Desktop for Mac"
        log_info "3. 启动 Docker Desktop"
        echo ""

        if ask_yes_no "是否已完成 Docker Desktop 安装并启动?" "n"; then
            if check_docker; then
                return 0
            else
                log_error "Docker 检测失败,请确保 Docker Desktop 已启动"
                return 1
            fi
        else
            log_error "需要 Docker 才能继续安装"
            return 1
        fi

    elif [[ "$OS" == "linux" ]]; then
        log_info "正在安装 Docker..."

        # 使用官方安装脚本
        curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
        sudo sh /tmp/get-docker.sh

        # 将当前用户添加到 docker 组
        sudo usermod -aG docker "$USER"

        log_success "Docker 安装成功"
        log_warning "⚠ 需要重新登录（或新开终端）才能使 docker 组权限生效"
        log_info "当前会话临时激活权限，继续安装..."
        # 用 sg 在当前脚本剩余部分以 docker 组权限执行
        # 注意：这只对当前脚本进程有效，用户下次登录前仍需 newgrp
        if command_exists newgrp; then
            exec sg docker -c "bash $0 $*" 2>/dev/null || true
        fi

        return 0
    fi
}

# ============================================================================
# 配置函数
# ============================================================================

configure_openclaw() {
    log_step "配置 OpenClaw"

    # 创建配置目录
    mkdir -p "$INSTALL_DIR"

    # 生成 Gateway Token
    log_info "正在生成 Gateway Token..."
    GATEWAY_TOKEN=$(generate_token)
    log_success "Gateway Token 已生成"

    # 询问 API Keys
    echo ""
    log_info "配置 AI 模型 (至少需要一个)"
    echo ""

    CLAUDE_KEY=""
    OPENAI_KEY=""
    GEMINI_KEY=""

    if ask_yes_no "是否配置 Claude API Key?" "n"; then
        CLAUDE_KEY=$(ask_input "请输入 Claude API Key" "")
        if [[ -n "$CLAUDE_KEY" ]]; then
            log_success "Claude API Key 已保存"
        fi
    fi

    echo ""
    if ask_yes_no "是否配置 OpenAI API Key?" "n"; then
        OPENAI_KEY=$(ask_input "请输入 OpenAI API Key" "")
        if [[ -n "$OPENAI_KEY" ]]; then
            log_success "OpenAI API Key 已保存"
        fi
    fi

    echo ""
    if ask_yes_no "是否配置 Gemini API Key?" "n"; then
        GEMINI_KEY=$(ask_input "请输入 Gemini API Key" "")
        if [[ -n "$GEMINI_KEY" ]]; then
            log_success "Gemini API Key 已保存"
        fi
    fi

    # 检查是否至少配置了一个 API Key
    if [[ -z "$CLAUDE_KEY" ]] && [[ -z "$OPENAI_KEY" ]] && [[ -z "$GEMINI_KEY" ]]; then
        log_warning "未配置任何 AI 模型 API Key"
        log_info "您可以稍后通过编辑 ~/.openclaw/.env 文件添加"
    fi

    # 生成 .env 文件
    log_info "正在生成配置文件..."

    cat > "$INSTALL_DIR/.env" <<EOF
# OpenClaw 配置文件
# 由 OpenClaw Easy Deploy 自动生成

# Gateway 配置
OPENCLAW_GATEWAY_TOKEN="$GATEWAY_TOKEN"
OPENCLAW_CONFIG_DIR="$INSTALL_DIR"
OPENCLAW_WORKSPACE_DIR="$INSTALL_DIR/workspace"
OPENCLAW_GATEWAY_PORT="$OPENCLAW_PORT"
OPENCLAW_BRIDGE_PORT="$OPENCLAW_BRIDGE_PORT"
OPENCLAW_GATEWAY_BIND=lan

# AI 模型配置
CLAUDE_AI_SESSION_KEY="$CLAUDE_KEY"
OPENAI_API_KEY="$OPENAI_KEY"
GEMINI_API_KEY="$GEMINI_KEY"

# Docker 配置
OPENCLAW_SANDBOX=0
EOF

    log_success "配置文件已生成: $INSTALL_DIR/.env"
}

# ============================================================================
# 启动服务函数
# ============================================================================

start_openclaw() {
    log_step "启动 OpenClaw"

    # 创建必要的目录
    mkdir -p "$INSTALL_DIR/workspace"
    mkdir -p "$INSTALL_DIR/identity"
    mkdir -p "$INSTALL_DIR/agents/main/agent"
    mkdir -p "$INSTALL_DIR/agents/main/sessions"

    # 下载 docker-compose.yml 和 docker-setup.sh
    log_info "正在下载 OpenClaw 配置文件..."

    cd "$INSTALL_DIR"

    # 下载官方 docker-compose.yml
    if ! curl -fsSL https://raw.githubusercontent.com/openclaw/openclaw/main/docker-compose.yml -o docker-compose.yml; then
        log_error "下载 docker-compose.yml 失败"
        return 1
    fi

    # 下载官方 docker-setup.sh
    if ! curl -fsSL https://raw.githubusercontent.com/openclaw/openclaw/main/docker-setup.sh -o docker-setup.sh; then
        log_error "下载 docker-setup.sh 失败"
        return 1
    fi

    chmod +x docker-setup.sh

    log_success "配置文件下载完成"

    # 运行 docker-setup.sh
    log_info "正在启动 OpenClaw 服务..."

    # 导出环境变量
    export OPENCLAW_CONFIG_DIR="$INSTALL_DIR"
    export OPENCLAW_WORKSPACE_DIR="$INSTALL_DIR/workspace"
    export OPENCLAW_GATEWAY_PORT="$OPENCLAW_PORT"
    export OPENCLAW_BRIDGE_PORT="$OPENCLAW_BRIDGE_PORT"
    export OPENCLAW_GATEWAY_TOKEN="$GATEWAY_TOKEN"

    # 运行官方安装脚本
    if ./docker-setup.sh; then
        log_success "OpenClaw 服务启动成功"
        return 0
    else
        log_error "OpenClaw 服务启动失败"
        return 1
    fi
}

# ============================================================================
# 验证安装
# ============================================================================

verify_installation() {
    log_step "验证安装"

    log_info "等待服务启动..."
    sleep 10

    # 检查端口
    if check_port "$OPENCLAW_PORT"; then
        log_success "端口 $OPENCLAW_PORT 已监听"
    else
        log_error "端口 $OPENCLAW_PORT 未监听"
        return 1
    fi

    # 健康检查
    log_info "正在进行健康检查..."

    local max_retries=5
    local retry=0

    while [[ $retry -lt $max_retries ]]; do
        if curl -f -s "http://localhost:$OPENCLAW_PORT/healthz" > /dev/null 2>&1; then
            log_success "健康检查通过"
            return 0
        fi

        retry=$((retry + 1))
        if [[ $retry -lt $max_retries ]]; then
            log_info "重试 $retry/$max_retries..."
            sleep 5
        fi
    done

    log_warning "健康检查失败,但服务可能仍在启动中"
    log_info "请稍后运行: curl http://localhost:$OPENCLAW_PORT/healthz"
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

    echo -e "${GREEN}✅ OpenClaw 已成功安装并运行！${NC}"
    echo ""
    echo -e "${CYAN}📍 访问地址:${NC}"
    echo -e "   http://localhost:$OPENCLAW_PORT"
    echo ""
    echo -e "${CYAN}🔑 Gateway Token:${NC}"
    echo -e "   $GATEWAY_TOKEN"
    echo -e "   ${YELLOW}(已保存到 $INSTALL_DIR/.env)${NC}"
    echo ""
    echo -e "${CYAN}📁 配置目录:${NC}"
    echo -e "   $INSTALL_DIR"
    echo ""
    echo -e "${CYAN}📚 下一步操作:${NC}"
    echo ""
    echo -e "   ${BLUE}1. 配置聊天平台 (WhatsApp/Telegram/Discord)${NC}"
    echo -e "      cd $INSTALL_DIR"
    echo -e "      docker compose run --rm openclaw-cli channels login"
    echo ""
    echo -e "   ${BLUE}2. 查看服务状态${NC}"
    echo -e "      docker compose -f $INSTALL_DIR/docker-compose.yml ps"
    echo ""
    echo -e "   ${BLUE}3. 查看日志${NC}"
    echo -e "      docker compose -f $INSTALL_DIR/docker-compose.yml logs -f"
    echo ""
    echo -e "   ${BLUE}4. 停止服务${NC}"
    echo -e "      docker compose -f $INSTALL_DIR/docker-compose.yml down"
    echo ""
    echo -e "   ${BLUE}5. 重启服务${NC}"
    echo -e "      docker compose -f $INSTALL_DIR/docker-compose.yml restart"
    echo ""
    echo -e "${CYAN}📖 完整文档:${NC}"
    echo -e "   https://github.com/JFroson0610/openclaw-easy-deploy"
    echo -e "   https://docs.openclaw.ai"
    echo ""
    echo -e "${CYAN}❓ 遇到问题?${NC}"
    echo -e "   - 查看日志: $LOG_FILE"
    echo -e "   - 故障排查: docs/troubleshooting-zh.md"
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

    # 检查依赖
    local need_node=false
    local need_docker=false

    if ! check_node; then
        need_node=true
    fi

    if ! check_docker; then
        need_docker=true
    fi

    # 安装缺失的依赖
    if [[ "$need_node" == true ]]; then
        if ask_yes_no "是否自动安装 Node.js 22?" "y"; then
            if ! install_node; then
                log_error "Node.js 安装失败,无法继续"
                exit 1
            fi
        else
            log_error "需要 Node.js 22+ 才能继续"
            exit 1
        fi
    fi

    if [[ "$need_docker" == true ]]; then
        if ask_yes_no "是否安装 Docker?" "y"; then
            if ! install_docker; then
                log_error "Docker 安装失败,无法继续"
                exit 1
            fi
        else
            log_error "需要 Docker 才能继续"
            exit 1
        fi
    fi

    # 配置 OpenClaw
    configure_openclaw

    # 启动服务
    if ! start_openclaw; then
        log_error "OpenClaw 启动失败"
        exit 1
    fi

    # 验证安装
    verify_installation

    # 显示成功信息
    show_success

    log_success "安装完成!"
}

# ============================================================================
# 脚本入口
# ============================================================================

main "$@"

