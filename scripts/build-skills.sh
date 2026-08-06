#!/usr/bin/env bash
# 在 beike-ai-platform 内原地构建和发布 Skill。
#
# 用法：
#   ./scripts/build-skills.sh              # 构建并校验全部 Skill
#   ./scripts/build-skills.sh --release    # 发布版本发生变化的 Skill
set -euo pipefail

usage() {
  cat <<'EOF'
用法：
  ./scripts/build-skills.sh [--release]

选项：
  --release  上传不可变的 GitHub Release，更新 manifest，提交并推送 main
  -h, --help 显示帮助

环境变量：
  BEIKE_GITHUB_REPO  GitHub 仓库，默认 hushunxu/beike-ai-platform
EOF
}

die() {
  echo "错误：$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "缺少命令：$1"
}

sha256_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

release=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --release) release=true; shift ;;
    -h | --help) usage; exit 0 ;;
    *) die "未知参数：$1" ;;
  esac
done

require_cmd python3
require_cmd zip

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
skills_dir="$repo_root/skills"
dist_dir="$repo_root/.build/skills"
published_manifest="$skills_dir/manifest.json"
github_repo="${BEIKE_GITHUB_REPO:-hushunxu/beike-ai-platform}"

[[ -f "$published_manifest" ]] || die "缺少发布清单：$published_manifest"

build_tmp="$(mktemp -d -t beike-skills-build.XXXXXX)"
cleanup() {
  [[ -d "$build_tmp" ]] && rm -rf "$build_tmp"
}
trap cleanup EXIT INT TERM

source_hash() {
  python3 - "$1" <<'PY'
import hashlib
import sys
from pathlib import Path

skill_dir = Path(sys.argv[1])
digest = hashlib.sha256()
for filename in ("SKILL.md", "manifest.json"):
    digest.update(filename.encode("utf-8"))
    digest.update(b"\0")
    digest.update((skill_dir / filename).read_bytes())
    digest.update(b"\0")
print(digest.hexdigest())
PY
}

preflight_release() {
  require_cmd git
  require_cmd gh

  local changes branch local_head remote_head
  changes="$(git -C "$repo_root" status --porcelain)"
  [[ -z "$changes" ]] || die "工作区不干净，请先提交 Skill 源码"

  branch="$(git -C "$repo_root" branch --show-current)"
  [[ "$branch" == "main" ]] || die "发布必须位于 main，当前为：${branch:-detached HEAD}"

  echo "==> 检查远端状态..."
  git -C "$repo_root" fetch origin main
  local_head="$(git -C "$repo_root" rev-parse HEAD)"
  remote_head="$(git -C "$repo_root" rev-parse origin/main)"
  [[ "$local_head" == "$remote_head" ]] || die "main 与 origin/main 不一致，请先同步"
}

changed_file="$build_tmp/changed-skills.txt"
if [[ "$release" == true ]]; then
  preflight_release

  python3 - "$skills_dir" "$published_manifest" "$changed_file" <<'PY'
import hashlib
import json
import re
import sys
from pathlib import Path

skills_dir = Path(sys.argv[1])
manifest_path = Path(sys.argv[2])
changed_path = Path(sys.argv[3])

with manifest_path.open(encoding="utf-8") as f:
    published = {item["name"]: item for item in json.load(f).get("skills", [])}

source_dirs = {
    path.name: path
    for path in skills_dir.iterdir()
    if path.is_dir() and (path / "manifest.json").is_file()
}

missing = sorted(set(published) - set(source_dirs))
if missing:
    raise SystemExit("错误：源码缺少已发布 Skill：" + ", ".join(missing))

def version_tuple(value):
    if not re.fullmatch(r"\d+(?:\.\d+)*", value):
        raise SystemExit(f"错误：不支持的版本格式：{value}")
    return tuple(int(part) for part in value.split("."))

def source_hash(skill_dir):
    digest = hashlib.sha256()
    for filename in ("SKILL.md", "manifest.json"):
        digest.update(filename.encode("utf-8"))
        digest.update(b"\0")
        digest.update((skill_dir / filename).read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()

changed = []
for name, skill_dir in sorted(source_dirs.items()):
    with (skill_dir / "manifest.json").open(encoding="utf-8") as f:
        source_manifest = json.load(f)
    source_version = source_manifest["version"]
    source_digest = source_hash(skill_dir)
    current = published.get(name)

    if current is None:
        changed.append(name)
        continue

    current_version = current["version"]
    if version_tuple(source_version) < version_tuple(current_version):
        raise SystemExit(
            f"错误：{name} 源版本 {source_version} 低于已发布版本 {current_version}"
        )
    if source_version == current_version:
        current_digest = current.get("sourceSha256")
        if not current_digest:
            raise SystemExit(f"错误：{name} 的发布清单缺少 sourceSha256")
        if source_digest != current_digest:
            raise SystemExit(f"错误：{name}@{source_version} 内容已变化，请先提升版本号")
        continue
    changed.append(name)

changed_path.write_text("\n".join(changed) + ("\n" if changed else ""), encoding="utf-8")
PY
fi

selected_skills=()
if [[ "$release" == true ]]; then
  while IFS= read -r skill_name; do
    [[ -n "$skill_name" ]] && selected_skills+=("$skill_name")
  done < "$changed_file"
  if [[ ${#selected_skills[@]} -eq 0 ]]; then
    echo "没有待发布的 Skill。"
    exit 0
  fi
else
  for skill_dir in "$skills_dir"/*/; do
    [[ -f "$skill_dir/manifest.json" ]] && selected_skills+=("$(basename "$skill_dir")")
  done
fi

mkdir -p "$dist_dir"
updates_file="$build_tmp/updates.jsonl"
: > "$updates_file"

for skill_name in "${selected_skills[@]}"; do
  skill_dir="$skills_dir/$skill_name"
  [[ -f "$skill_dir/SKILL.md" && -f "$skill_dir/manifest.json" ]] \
    || die "$skill_name 缺少 SKILL.md 或 manifest.json"

  python3 - "$skill_name" "$skill_dir/manifest.json" <<'PY'
import json
import re
import sys

directory_name, manifest_path = sys.argv[1:]
with open(manifest_path, encoding="utf-8") as f:
    manifest = json.load(f)
for key in ("name", "displayName", "version", "archiveName"):
    if not isinstance(manifest.get(key), str) or not manifest[key]:
        raise SystemExit(f"错误：{manifest_path} 缺少有效的 {key}")
if manifest["name"] != directory_name:
    raise SystemExit(
        f"错误：{manifest_path} 的 name 必须为 {directory_name}"
    )
if not re.fullmatch(r"\d+\.\d+\.\d+", manifest["version"]):
    raise SystemExit(f"错误：{manifest_path} 的 version 必须为 x.y.z")
if not re.fullmatch(r"[a-z0-9][a-z0-9-]*", manifest["archiveName"]):
    raise SystemExit(f"错误：{manifest_path} 的 archiveName 不合法")
PY

  archive_name="$(python3 -c "import json; print(json.load(open('$skill_dir/manifest.json'))['archiveName'])")"
  version="$(python3 -c "import json; print(json.load(open('$skill_dir/manifest.json'))['version'])")"
  display_name="$(python3 -c "import json; print(json.load(open('$skill_dir/manifest.json'))['displayName'])")"
  zip_name="${archive_name}-${version}.zip"
  zip_path="$dist_dir/$zip_name"
  tmp_zip_path="$build_tmp/$zip_name"
  stage_dir="$build_tmp/stage-$skill_name"

  mkdir -p "$stage_dir/$skill_name"
  cp "$skill_dir/SKILL.md" "$skill_dir/manifest.json" "$stage_dir/$skill_name/"
  touch -t 198001010000 \
    "$stage_dir/$skill_name" \
    "$stage_dir/$skill_name/SKILL.md" \
    "$stage_dir/$skill_name/manifest.json"
  (cd "$stage_dir" && zip -X -q "$tmp_zip_path" \
    "$skill_name/" \
    "$skill_name/SKILL.md" \
    "$skill_name/manifest.json")
  zip -T "$tmp_zip_path" >/dev/null
  cp "$tmp_zip_path" "$zip_path"

  checksum="$(sha256_file "$zip_path")"
  printf '%s  %s\n' "$checksum" "$zip_name" > "$zip_path.sha256"
  source_digest="$(source_hash "$skill_dir")"
  release_tag="${skill_name}-v${version}"
  release_url="https://github.com/$github_repo/releases/download/$release_tag/$zip_name"

  python3 - "$updates_file" "$skill_name" "$display_name" "$version" "$archive_name" "$release_url" "$checksum" "$source_digest" <<'PY'
import json
import sys

path, name, display_name, version, archive_name, url, checksum, source_digest = sys.argv[1:]
with open(path, "a", encoding="utf-8") as f:
    f.write(json.dumps({
        "name": name,
        "displayName": display_name,
        "version": version,
        "archiveName": archive_name,
        "url": url,
        "sha256": checksum,
        "sourceSha256": source_digest,
    }, ensure_ascii=False) + "\n")
PY

  echo "✓ $zip_name  ($checksum)"

done

if [[ "$release" == false ]]; then
  echo ""
  echo "构建完成：$dist_dir"
  exit 0
fi

# 在上传任何产物前检查全部 tag，避免批量发布到一半才发现冲突。
for skill_name in "${selected_skills[@]}"; do
  version="$(python3 -c "import json; print(json.load(open('$skills_dir/$skill_name/manifest.json'))['version'])")"
  release_tag="${skill_name}-v${version}"
  if gh release view "$release_tag" --repo "$github_repo" >/dev/null 2>&1; then
    die "GitHub Release 已存在，拒绝覆盖：$release_tag"
  fi
done

for skill_name in "${selected_skills[@]}"; do
  archive_name="$(python3 -c "import json; print(json.load(open('$skills_dir/$skill_name/manifest.json'))['archiveName'])")"
  version="$(python3 -c "import json; print(json.load(open('$skills_dir/$skill_name/manifest.json'))['version'])")"
  display_name="$(python3 -c "import json; print(json.load(open('$skills_dir/$skill_name/manifest.json'))['displayName'])")"
  zip_path="$dist_dir/${archive_name}-${version}.zip"
  release_tag="${skill_name}-v${version}"
  gh release create "$release_tag" \
    "$zip_path" "$zip_path.sha256" \
    --repo "$github_repo" \
    --title "$display_name $version" \
    --notes "$display_name $version"
done

python3 - "$published_manifest" "$updates_file" <<'PY'
import json
import sys

manifest_path, updates_path = sys.argv[1:]
with open(manifest_path, encoding="utf-8") as f:
    manifest = json.load(f)
with open(updates_path, encoding="utf-8") as f:
    updates = {item["name"]: item for item in map(json.loads, filter(str.strip, f))}

skills = []
seen = set()
for item in manifest.get("skills", []):
    replacement = updates.get(item["name"], item)
    skills.append(replacement)
    seen.add(item["name"])
for name in sorted(set(updates) - seen):
    skills.append(updates[name])

manifest["skills"] = skills
manifest["latest"] = max(
    (item["version"] for item in skills),
    key=lambda value: tuple(int(part) for part in value.split(".")),
    default="0.0.0",
)
with open(manifest_path, "w", encoding="utf-8") as f:
    json.dump(manifest, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY

git -C "$repo_root" add skills/manifest.json
git -C "$repo_root" diff --cached --check
git -C "$repo_root" commit -m "release: ${selected_skills[*]}"
git -C "$repo_root" push origin main

echo "已发布并更新 skills/manifest.json"
