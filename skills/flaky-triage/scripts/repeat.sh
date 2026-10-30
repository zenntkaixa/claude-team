#!/usr/bin/env bash
# Run a command N times and report the pass rate. Logs go to a directory, not the terminal.
# Usage: repeat.sh <runs> <log-dir> -- <command...>
# Exit status is 0 always; read the summary. Each run has its own log: <log-dir>/run-<i>.log
set -u
runs=$1; dir=$2; shift 2; [ "${1:-}" = "--" ] && shift
mkdir -p "$dir"; pass=0; fail=0; failed=()
for i in $(seq 1 "$runs"); do
  if "$@" >"$dir/run-$i.log" 2>&1; then pass=$((pass+1)); else fail=$((fail+1)); failed+=("$i"); fi
done
echo "runs=$runs pass=$pass fail=$fail failed_runs=${failed[*]:-none}"
for i in "${failed[@]:-}"; do
  [ -n "$i" ] && { echo "--- first error lines of run $i"; grep -m5 -iE 'fail|error|assert|✗|not ok' "$dir/run-$i.log"; }
done
