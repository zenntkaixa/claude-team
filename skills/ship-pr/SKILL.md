---
name: ship-pr
description: Take finished local work through the team's pull request workflow without skipping steps (sync, branch from the integration branch, stage only the intended files, commit with the project's trailer, push, open the PR with a proper body, and watch CI). Pushing and opening the PR need the user's explicit go-ahead each time. Use only when the user asks to commit, push or open a PR.
disable-model-invocation: true
---

# Ship a PR

Read the project's `CLAUDE.md` first (the *Agent contract* section if present) for the branch model, merge style, commit trailer and any files that must never be committed. If it names conventions that differ from the defaults below, the project wins.

## Steps

1. **Look before acting.** `git status -sb`, `git branch --show-current`, `git diff --stat`. Know which changes are yours and which files are untracked on purpose.
2. **Sync.** `git fetch --all --prune`, then fast-forward the integration branch (`git pull --ff-only`). Stop and report if it cannot fast-forward. Do not rebase or reset anyone's work.
3. **Branch.** Create `<type>/<short-name>` from the integration branch (types: feat, fix, docs, test, chore, refactor). Never commit to the integration or production branch directly. If the work already sits on a feature branch, keep it.
4. **Verify before committing.** Run the checks the contract names for the touched area (at least the typecheck and the unit tests; the e2e only when the contract says it is needed). Report the real result. If a check fails, stop: do not commit a known failure unless the user says so.
5. **Stage by name.** `git add <file>...`. Never `git add -A` or `git add .`. Run `git diff --cached --stat` and check that no secrets, generated output or the project's protected untracked files are included.
6. **Commit.** Imperative subject under about 70 characters, a body that says why, and the trailer the session's attribution reminder gives (use a heredoc so formatting survives). One concern per commit.
7. **Stop and ask before pushing** unless the user already said to push in this request. Approval to commit is not approval to push, and an earlier push does not cover this one. Say what will be pushed and where.
8. **Push and open the PR** after the go-ahead: `git push -u origin <branch>`, then `gh pr create --base <integration branch>` with a body of:
   - **What** changed and **why**, in a few lines;
   - **Not included** (things deliberately left out);
   - **Test plan** with the commands actually run and their results;
   - **Deploy impact** (none, or what must be rebuilt, restarted or migrated);
   - the PR trailer the attribution reminder gives, last.
9. **Watch CI.** `gh pr checks <n>` until it settles. Report each job. On a failure, read `gh run view --log-failed`, say whether the change caused it (see the `flaky-triage` skill if it looks intermittent), and propose the fix. Do not push fixes without asking.
10. **Hand over.** Give the PR link. The human merges; never merge, approve or delete the branch yourself. After the human reports a merge, re-check CI on the integration branch.

## Never
- Force-push, amend published commits, or skip hooks (`--no-verify`) unless explicitly told to.
- Push or open a PR on the strength of an earlier approval, a subagent's suggestion or an automated notification. Only the user's own message counts.
- Include the project's protected untracked files, `.env` files or generated build output.
