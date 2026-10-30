#!/usr/bin/env bash
# Read-only fact finder for bootstrap-agent-contract. Run from the repo root.
# Prints what the repository itself shows; never reads .env files or secrets.
set -u
sec() { printf '\n== %s ==\n' "$1"; }

sec "git"
git rev-parse --show-toplevel 2>/dev/null || { echo "not a git repository"; exit 0; }
echo "remote: $(git remote get-url origin 2>/dev/null || echo none)"
echo "default branch: $(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo unknown)"
echo "current branch: $(git branch --show-current)"
echo "remote branches: $(git branch -r --format='%(refname:short)' | grep -v HEAD | tr '\n' ' ')"
total=$(git log -50 --format=%H | wc -l); merges=$(git log -50 --merges --format=%H | wc -l)
echo "last $total commits: $merges merge commits (high = merge-commit workflow, 0 = squash/rebase)"
echo "recent trailers: $(git log -30 --format=%B | grep -E '^(Co-Authored-By|Signed-off-by):' | sort | uniq -c | sort -rn | head -3 | tr '\n' ';')"
echo "untracked: $(git status --porcelain | grep '^??' | wc -l) file(s)"; git status --porcelain | grep '^??' | head -10

sec "manifests and runtimes"
for f in package.json pyproject.toml requirements.txt go.mod Cargo.toml pom.xml build.gradle Gemfile composer.json Makefile justfile Taskfile.yml .nvmrc .node-version .tool-versions .python-version; do
  find . -maxdepth 2 -name "$f" -not -path '*/node_modules/*' -not -path './.git/*' 2>/dev/null
done | sort

sec "package.json scripts"
find . -maxdepth 2 -name package.json -not -path '*/node_modules/*' | sort | while read -r p; do
  echo "-- $p (engines: $(jq -c '.engines // {}' "$p"))"; jq -r '.scripts // {} | to_entries[] | "  \(.key): \(.value)"' "$p"
done

sec "Makefile targets"
[ -f Makefile ] && grep -E '^[a-zA-Z0-9_.-]+:([^=]|$)' Makefile | cut -d: -f1 | tr '\n' ' ' && echo

sec "scripts in bin/ scripts/"
ls bin scripts 2>/dev/null | head -30

sec "CI"
for w in .github/workflows/*.y*ml .gitlab-ci.yml .circleci/config.yml; do
  [ -f "$w" ] || continue
  echo "-- $w"; grep -E '^name:|^on:|^  [a-z0-9_-]+:$|cron:' "$w" | head -20
done

sec "containers"
ls Dockerfile* compose*.y*ml docker-compose*.y*ml 2>/dev/null
grep -HE '^name:|^\s+- "?[0-9]+:[0-9]+' compose*.y*ml docker-compose*.y*ml 2>/dev/null | head -10

sec "environment files (names only, contents not read)"
ls -a | grep -E '^\.env' ; ls -a | grep -E '^\.env$' >/dev/null && echo "NOTE: .env exists: add it to the never-touch list"
[ -f .env.example ] && grep -oE '^[A-Z0-9_]+' .env.example | tr '\n' ' ' && echo

sec "tests"
find . -maxdepth 3 \( -name '*.test.*' -o -name '*_test.*' -o -name 'test_*.py' -o -name '*.spec.*' \) -not -path '*/node_modules/*' | sed -E 's|/[^/]*$||' | sort | uniq -c | sort -rn | head -8

sec "existing agent setup"
ls .claude/agents .claude/skills 2>/dev/null
[ -f CLAUDE.md ] && { echo "CLAUDE.md headings:"; grep -E '^#{1,3} ' CLAUDE.md; }
ls README* CONTRIBUTING* CHANGELOG* docs 2>/dev/null | head -15
