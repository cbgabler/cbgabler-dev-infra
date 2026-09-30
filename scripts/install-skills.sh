#!/usr/bin/env bash
# Link every skills/<project>/<skill>/ into ~/.claude/skills/<project>-<skill>.
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
dest="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
mkdir -p "$dest"

for skill_md in "$repo"/skills/*/*/SKILL.md; do
  [ -e "$skill_md" ] || continue
  dir="$(dirname "$skill_md")"
  name="$(basename "$(dirname "$dir")")-$(basename "$dir")"
  link="$dest/$name"
  if [ -e "$link" ] && [ ! -L "$link" ]; then
    echo "skip  $name (a real directory already exists at $link)" >&2
    continue
  fi
  case "$(uname -s)" in
    # Windows refuses symlinks without Developer Mode; a directory junction
    # needs no privilege and git pull still updates through it.
    MINGW*|MSYS*|CYGWIN*)
      [ -L "$link" ] && rm "$link"
      cmd //c mklink //J "$(cygpath -w "$link")" "$(cygpath -w "$dir")" > /dev/null ;;
    *) ln -sfn "$dir" "$link" ;;
  esac
  echo "link  $name -> ${dir#$repo/}"
done

# Drop links to skills that no longer exist in the repo.
for link in "$dest"/*; do
  [ -L "$link" ] || continue
  target="$(readlink "$link")"
  case "$target" in "$repo"/*) [ -e "$target" ] || { rm "$link"; echo "prune $(basename "$link")"; } ;; esac
done
