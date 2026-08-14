#!/usr/bin/env bash
# 测试用：安装 beike_local（个人仓库分发，勿用于生产）
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/hushunxu/beike-ai-platform/main/cli-releases-test"
INSTALL_DIR="${HOME}/.local/bin"

case "$(uname -s)-$(uname -m)" in
  Darwin-arm64) ASSET="darwin-arm64/beike_local" ;;
  Darwin-x86_64) ASSET="darwin-x64/beike_local" ;;
  *)
    echo "不支持的平台: $(uname -s)-$(uname -m)"
    exit 1
    ;;
esac

mkdir -p "$INSTALL_DIR"
TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

echo "下载 ${ASSET} ..."
curl -fsSL "${REPO_RAW}/${ASSET}" -o "$TMP_FILE"
chmod +x "$TMP_FILE"

if [[ "$(uname -s)" == "Darwin" ]]; then
  # 去掉 macOS 下载隔离，避免 Gatekeeper 拦截
  xattr -dr com.apple.quarantine "$TMP_FILE" 2>/dev/null || true
fi

mv "$TMP_FILE" "$INSTALL_DIR/beike_local"
echo "已安装 beike_local -> ${INSTALL_DIR}/beike_local"
