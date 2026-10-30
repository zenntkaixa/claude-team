#!/usr/bin/env bash
# Link this repo's agents and skills into ~/.claude so edits here are live.
# Idempotent. An existing file that differs is moved to <name>.bak.<timestamp>, never deleted.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd); dest=${CLAUDE_HOME:-$HOME/.claude}
mkdir -p "$dest/agents" "$dest/skills"
link() { # link <source> <target>
  local src=$1 tgt=$2
  if [ -L "$tgt" ] && [ "$(readlink -f "$tgt")" = "$(readlink -f "$src")" ]; then echo "ok      $tgt"; return; fi
  if [ -e "$tgt" ] || [ -L "$tgt" ]; then
    if diff -rq "$src" "$tgt" >/dev/null 2>&1; then rm -rf "$tgt"
    else mv "$tgt" "$tgt.bak.$(date +%Y%m%d%H%M%S)"; echo "backup  $tgt"; fi
  fi
  ln -s "$src" "$tgt"; echo "linked  $tgt"
}
for f in "$here"/agents/*.md; do link "$f" "$dest/agents/$(basename "$f")"; done
for d in "$here"/skills/*/; do link "${d%/}" "$dest/skills/$(basename "$d")"; done
echo "Done. Restart Claude Code or run /agents to load them."
