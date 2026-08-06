#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
skills_dir="$repo_root/skills"
dist_dir="$repo_root/.build/skills"

"$script_dir/build-skills.sh" >/dev/null

for skill_dir in "$skills_dir"/*/; do
  [[ -f "$skill_dir/manifest.json" ]] || continue
  skill_name="$(basename "$skill_dir")"
  archive_name="$(python3 -c "import json; print(json.load(open('$skill_dir/manifest.json'))['archiveName'])")"
  version="$(python3 -c "import json; print(json.load(open('$skill_dir/manifest.json'))['version'])")"
  zip_path="$dist_dir/${archive_name}-${version}.zip"

  test -s "$zip_path"
  zip -T "$zip_path" >/dev/null
  cmp "$skill_dir/SKILL.md" <(unzip -p "$zip_path" "$skill_name/SKILL.md")
  cmp "$skill_dir/manifest.json" <(unzip -p "$zip_path" "$skill_name/manifest.json")
  if command -v shasum >/dev/null 2>&1; then
    (cd "$dist_dir" && shasum -a 256 -c "$(basename "$zip_path").sha256") >/dev/null
  else
    (cd "$dist_dir" && sha256sum -c "$(basename "$zip_path").sha256") >/dev/null
  fi
done

echo "Skill package checks passed."
