# claude-team

Generic sub-agents and skills for Claude Code that work on any repository. They carry no project facts: each project describes itself in an **Agent contract** section of its `CLAUDE.md`, which the agents read first. The `bootstrap-agent-contract` skill writes that section for a new repo.

## Contents

| Agents (`agents/`) | Job | Model |
|---|---|---|
| `reviewer` | pre-merge code review | sonnet (pass `model: opus` for risky diffs) |
| `security-engineer` | scanner triage, diff threat model | sonnet |
| `verifier` | run CI-equivalent checks, repeat flaky ones, attribute failures | sonnet |
| `debugger` | root cause of non-obvious or intermittent failures | opus |
| `release-engineer` | release inventory, risks, rollback, draft PR and notes | sonnet |
| `docs-auditor` | test documentation claims against the code | sonnet |

| Skills (`skills/`) | Job |
|---|---|
| `bootstrap-agent-contract` | create or refresh a project's Agent contract (`scripts/detect.sh` gathers facts) |
| `ship-pr` | the commit, push and PR workflow; manual-only, pushes only on the user's go-ahead |
| `flaky-triage` | attribute an intermittent failure by repeated runs and a control (`scripts/repeat.sh`) |

All agents are read-only. They never commit, push or merge.

## Install on a machine

```
git clone <this repo> ~/claude-team
~/claude-team/install.sh
```

This symlinks the agents and skills into `~/.claude/`, so editing a file here changes the live one. A different existing file is moved to `.bak.<timestamp>`, not deleted. Restart Claude Code or run `/agents`. Set `CLAUDE_HOME` to install somewhere else. The skills' helper scripts are found through `~/.claude/skills/...`, which the links provide.

## Use in a project

1. In the project, run the `bootstrap-agent-contract` skill to create the Agent contract in its `CLAUDE.md`.
2. Keep project-specific agents, hooks and settings in that project's own `.claude/` and commit them there. Do not copy the generic ones in; they would drift.

## Changing things

Edit here, commit, push, and pull on the other machines. Agent descriptions are part of the context of every request, so keep them short (about 50 words) and put detail in the body. Frontmatter must stay valid YAML: no `: ` inside an unquoted description.

## Later: plugin

The layout (`agents/`, `skills/` at the root) matches the Claude Code plugin layout, so it can become a plugin with a marketplace file for per-project opt-in. The skills would then need plugin-relative script paths instead of `~/.claude/skills/...`.
