#!/usr/bin/env bash
# 贝壳 Skills 安装脚本（macOS / Linux）
# 用法：
#   curl -fsSL https://raw.githubusercontent.com/hushunxu/beike-ai-platform/main/skills/install.sh | bash
#   curl -fsSL ... | bash -s -- beike-buy beike-rent（安装指定 skills）

if [ -z "${BASH_VERSION:-}" ]; then
    exec bash "$0" "$@"
fi
set -uo pipefail

BEIKE_SKILLS_DIR="${BEIKE_SKILLS_DIR:-$HOME/.claude/skills}"
MANIFEST_URL="${BEIKE_MANIFEST_URL:-https://raw.githubusercontent.com/hushunxu/beike-ai-platform/main/skills/manifest.json}"

usage() {
    cat <<EOF >&2
贝壳 Skills 安装脚本

用法:
  curl -fsSL https://raw.githubusercontent.com/hushunxu/beike-ai-platform/main/skills/install.sh | bash
  curl -fsSL ... | bash -s -- beike-buy beike-rent

选项:
  <skill-name>  指定要安装的 skill（支持多个），默认安装全部
  -h, --help    显示帮助
EOF
}

requested_skills=()
while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help) usage; exit 0 ;;
    -*) echo "Error: 未知参数 $1" >&2; usage; exit 1 ;;
    *) requested_skills+=("$1"); shift ;;
    esac
done

require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: 需要 $1 但未安装" >&2
        exit 1
    fi
}

fatal_error() {
    echo "" >&2
    echo "错误: $1" >&2
    if [[ $# -gt 1 ]]; then
        shift
        for msg in "$@"; do echo "  - $msg" >&2; done
    fi
    echo "" >&2
    exit 1
}

download() {
    local url="$1" output="$2"
    local retries=3 n=0
    while [[ $n -lt $retries ]]; do
        [[ $n -gt 0 ]] && sleep 2
        if command -v curl >/dev/null 2>&1; then
            curl -fsSL --retry 2 --connect-timeout 30 --max-time 300 \
                -H "User-Agent: beike-skills-installer/curl-bash" \
                "$url" -o "$output" && return 0
        elif command -v wget >/dev/null 2>&1; then
            wget -q --tries=2 --connect-timeout=30 --read-timeout=300 \
                --user-agent="beike-skills-installer/curl-bash" \
                "$url" -O "$output" && return 0
        else
            echo "Error: 需要 curl 或 wget" >&2; exit 1
        fi
        rm -f "$output" 2>/dev/null || true
        n=$((n + 1))
    done
    return 1
}

TMP_DIR=""
cleanup() {
    [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR" 2>/dev/null || true
}

main() {
    TMP_DIR="$(mktemp -d -t beike-skills-install.XXXXXX)"
    trap cleanup EXIT INT TERM

    require_cmd tar

    echo "==> 获取 Skill 清单..."
    local manifest_file="$TMP_DIR/manifest.json"
    if ! download "$MANIFEST_URL" "$manifest_file"; then
        fatal_error "无法下载 manifest" "URL: $MANIFEST_URL"
    fi

    local manifest_json
    manifest_json="$(cat "$manifest_file")"

    # 如果未指定 skill，则安装全部
    if [[ ${#requested_skills[@]} -eq 0 ]]; then
        echo "==> 未指定 skill，将安装全部"
        requested_skills=($(python3 <<PYSCRIPT
import json
with open('$manifest_file') as f:
    m = json.load(f)
    print(' '.join([s['name'] for s in m.get('skills', [])]))
PYSCRIPT
))
        if [[ ${#requested_skills[@]} -eq 0 ]]; then
            fatal_error "无法从 manifest 解析 skill 列表"
        fi
    fi

    echo "==> 计划安装: ${requested_skills[*]}"
    echo ""

    mkdir -p "$BEIKE_SKILLS_DIR"

    # 对每个 skill 进行安装
    for skill_name in "${requested_skills[@]}"; do
        echo "==> 安装 $skill_name..."

        # 从 manifest 文件中查找该 skill
        local url checksum version
        read -r url checksum version <<EOF
$(python3 <<PYSCRIPT
import json
with open('$manifest_file') as f:
    manifest = json.load(f)
    skills = manifest.get('skills', [])
    for s in skills:
        if s.get('name') == '$skill_name':
            print(s.get('url', ''))
            print(s.get('sha256', ''))
            print(s.get('version', 'unknown'))
            break
PYSCRIPT
)
EOF

        if [[ -z "$url" ]]; then
            fatal_error "未找到 Skill: $skill_name" "请检查 skill 名称是否正确"
        fi

        if [[ -z "$url" ]]; then
            fatal_error "manifest 中 $skill_name 缺少下载地址"
        fi

        echo "  版本: $version"

        # 检查本地是否已安装
        local skill_install_dir="$BEIKE_SKILLS_DIR/$skill_name"
        if [[ -f "$skill_install_dir/manifest.json" ]]; then
            local local_version
            local_version=$(python3 <<PYSCRIPT
import json
try:
    with open('$skill_install_dir/manifest.json') as f:
        print(json.load(f).get('version', 'unknown'))
except:
    print('unknown')
PYSCRIPT
)
            if [[ "$local_version" == "$version" ]]; then
                echo "  ℹ 已是最新版本（$local_version），跳过"
                continue
            else
                echo "  ℹ 本地版本 $local_version，准备更新到 $version"
            fi
        fi

        local archive_file="$TMP_DIR/$skill_name.tar.gz"
        echo "  下载中..."
        if ! download "$url" "$archive_file"; then
            fatal_error "下载 $skill_name 失败" "URL: $url"
        fi

        local file_size
        file_size=$(wc -c <"$archive_file" 2>/dev/null || echo "0")
        [[ "$file_size" -lt 1024 ]] && fatal_error "下载文件过小 ($file_size bytes)，可能已损坏"

        # 校验 sha256
        if [[ -n "$checksum" ]]; then
            echo "  校验完整性..."
            local actual=""
            if command -v shasum >/dev/null 2>&1; then
                actual=$(shasum -a 256 "$archive_file" | cut -d' ' -f1)
            elif command -v sha256sum >/dev/null 2>&1; then
                actual=$(sha256sum "$archive_file" | cut -d' ' -f1)
            fi
            if [[ -n "$actual" && "$actual" != "$checksum" ]]; then
                fatal_error "校验失败" "期望: $checksum" "实际: $actual"
            fi
        fi

        echo "  解压中..."
        local skill_dir="$BEIKE_SKILLS_DIR/$skill_name"
        mkdir -p "$skill_dir"
        tar -xzf "$archive_file" -C "$skill_dir" || fatal_error "解压 $skill_name 失败"

        # 检查必需文件
        if [[ ! -f "$skill_dir/$skill_name/SKILL.md" ]]; then
            fatal_error "压缩包中未找到 $skill_name/SKILL.md"
        fi

        # 将文件挪到 skill_dir 根目录
        mv "$skill_dir/$skill_name"/* "$skill_dir/" 2>/dev/null || true
        rmdir "$skill_dir/$skill_name" 2>/dev/null || true

        echo "  ✓ 安装成功"
        echo ""
    done

    echo "=== 安装完成 ==="
    echo "✓ 已安装以下 Skills:"
    for skill_name in "${requested_skills[@]}"; do
        skill_dir="$BEIKE_SKILLS_DIR/$skill_name"
        if [[ -f "$skill_dir/manifest.json" ]]; then
            version=$(python3 -c "import json; print(json.load(open('$skill_dir/manifest.json')).get('version', 'unknown'))")
            echo "  • $skill_name@$version"
        fi
    done
    echo ""
    echo "位置: $BEIKE_SKILLS_DIR"
    echo ""
    echo "💡 在 Claude 等 AI 工具中提问时，首次使用会自动提示配置 API Key。"
}

main "$@"
