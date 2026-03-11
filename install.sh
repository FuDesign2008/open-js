#!/usr/bin/env bash
# youdaonote-cli 一键安装脚本
# 用法（推荐，避免父 shell set -x 时打印脚本内容）:
#   curl -fsSL https://cdn.jsdelivr.net/gh/FuDesign2008/open-js@main/install.sh | bash
# 或: bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/FuDesign2008/open-js@main/install.sh)"
# 仅支持 macOS 和 Linux

set -e
# 禁用 xtrace/verbose，避免脚本内部命令被逐行打印
{ set +x +v; } 2>/dev/null || true

# 版本与下载地址（发版时更新）
VERSION="1.1.1-52916f89"
BASE_URL="https://github.com/FuDesign2008/open-js/releases/download/youdaonote-cli-v1.1.1"

# 颜色输出
BOLD="$(tput bold 2>/dev/null || printf '')"
RED="$(tput setaf 1 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
BLUE="$(tput setaf 4 2>/dev/null || printf '')"
NO_COLOR="$(tput sgr0 2>/dev/null || printf '')"

info() { printf '%s\n' "${BOLD}${BLUE}==>${NO_COLOR} $*"; }
warn() { printf '%s\n' "${YELLOW}!${NO_COLOR} $*" >&2; }
error() { printf '%s\n' "${RED}x${NO_COLOR} $*" >&2; }
ok() { printf '%s\n' "${GREEN}✓${NO_COLOR} $*"; }

abort() {
  error "$@"
  exit 1
}

has() { command -v "$1" 1>/dev/null 2>&1; }

# 检测目录是否可写
test_writeable() {
  local path="${1:-}/.write-test"
  if touch "${path}" 2>/dev/null; then
    rm -f "${path}"
    return 0
  fi
  return 1
}

# 检测平台: darwin-arm64, darwin-x64, linux-arm64, linux-x64
detect_platform() {
  local os arch
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m | tr '[:upper:]' '[:lower:]')"

  case "${arch}" in
    x86_64|amd64) arch="x64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) abort "不支持的架构: ${arch}" ;;
  esac

  case "${os}" in
    darwin) printf '%s' "darwin-${arch}" ;;
    linux) printf '%s' "linux-${arch}" ;;
    *) abort "不支持的系统: ${os}，仅支持 macOS 和 Linux" ;;
  esac
}

# 获取下载 URL
get_download_url() {
  local platform="$1"
  printf '%s/%s-%s.tar' "${BASE_URL}" "${platform}" "${VERSION}"
}

# 下载文件（显示详细进度：百分比、速度、剩余时间）
download() {
  local file="$1" url="$2"
  if has curl; then
    curl -fL -o "${file}" "${url}" || abort "下载失败: ${url}"
  elif has wget; then
    wget -O "${file}" "${url}" || abort "下载失败: ${url}"
  else
    abort "需要 curl 或 wget，请先安装"
  fi
}

usage() {
  cat <<EOF
youdaonote-cli 安装脚本

用法: curl -fsSL https://cdn.jsdelivr.net/gh/FuDesign2008/open-js@main/install.sh | bash
  或: bash -c "\$(curl -fsSL https://cdn.jsdelivr.net/gh/FuDesign2008/open-js@main/install.sh)"

选项:
  -b, --bin-dir DIR   安装目录 [默认: /usr/local/bin]
  -f, -y, --force     跳过确认
  -h, --help          显示此帮助

EOF
  exit "${1:-0}"
}

# 解析参数
BIN_DIR="/usr/local/bin"
FORCE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -b|--bin-dir) BIN_DIR="$2"; shift 2 ;;
    -b=*|--bin-dir=*) BIN_DIR="${1#*=}"; shift 1 ;;
    -f|-y|--force|--yes) FORCE=1; shift 1 ;;
    -h|--help) usage 0 ;;
    *) error "未知选项: $1"; usage 1 ;;
  esac
done

# 检测平台
PLATFORM="$(detect_platform)"
URL="$(get_download_url "${PLATFORM}")"

info "检测到平台: ${PLATFORM}"
info "将安装到: ${BIN_DIR}"

# 确认（非 force 时）
if [[ -z "${FORCE}" ]] && [[ -t 0 ]]; then
  printf "%s " "${YELLOW}?${NO_COLOR} 安装 youdaonote-cli v${VERSION} 到 ${BIN_DIR}? ${BOLD}[y/N]${NO_COLOR}"
  read -r yn
  case "${yn}" in
    [yY]|[yY][eE][sS]) ;;
    *) abort "已取消";;
  esac
fi

# 检查 BIN_DIR 存在
if [[ ! -d "${BIN_DIR}" ]]; then
  if test_writeable "$(dirname "${BIN_DIR}")"; then
    mkdir -p "${BIN_DIR}"
  else
    warn "需要 sudo 创建 ${BIN_DIR}"
    sudo mkdir -p "${BIN_DIR}"
  fi
fi

# 下载并安装
TMPDIR="$(mktemp -d)"
trap 'rm -rf "${TMPDIR}"' EXIT
TARFILE="${TMPDIR}/youdaonote.tar"

info "正在下载..."
download "${TARFILE}" "${URL}"

info "正在解压..."
if test_writeable "${BIN_DIR}"; then
  tar xf "${TARFILE}" -C "${TMPDIR}"
  cp -f "${TMPDIR}/${PLATFORM}/youdaonote" "${BIN_DIR}/youdaonote"
  chmod +x "${BIN_DIR}/youdaonote"
else
  warn "需要 sudo 写入 ${BIN_DIR}"
  tar xf "${TARFILE}" -C "${TMPDIR}"
  sudo cp -f "${TMPDIR}/${PLATFORM}/youdaonote" "${BIN_DIR}/youdaonote"
  sudo chmod +x "${BIN_DIR}/youdaonote"
fi

ok "安装完成"
echo
info "运行 \`youdaonote --help\` 查看用法"
if [[ ":${PATH}:" != *":${BIN_DIR}:"* ]]; then
  warn "${BIN_DIR} 可能不在 PATH 中，请确保已配置"
fi
