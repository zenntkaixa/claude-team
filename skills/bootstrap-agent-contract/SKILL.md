---
name: bootstrap-agent-contract
description: Create or refresh the Agent contract section of a project's CLAUDE.md that the generic sub-agents read first. Detects facts from the repo, asks only what it cannot infer, and edits after approval. Use in a repo without a contract, or after build, CI or branch changes.
---

# Bootstrap the Agent contract

The generic agents carry no project facts. They read an `## Agent contract` section in `CLAUDE.md`. This skill produces that section for any repository, or updates it when it has drifted. The section must stay short and point at other sections instead of repeating them.

## Steps

1. **Detect.** Run `bash ~/.claude/skills/bootstrap-agent-contract/scripts/detect.sh` from the repo root. It is read-only and prints branches, merge style, trailers, manifests and scripts, Makefile targets, CI workflows, container files, environment file names (never contents), test locations and what `CLAUDE.md` already has. If `CLAUDE.md` exists, read it fully first: reuse its wording and do not duplicate its sections.
2. **Read the sources of truth** the script points at: the CI workflows (CI's idea of green is the default scope for verification), the README sections on setup and testing, and the container and compose files for ports, project names and volumes.
3. **Verify every command before writing it.** A command in the contract that does not run is worse than none. Run the cheap ones (`--help`, a listing, a type check). For expensive or stateful ones (builds, e2e, anything that writes data) check they exist in the scripts and say they were not run.
4. **Ask only what the repository cannot answer**, in one batch (use the question tool). Typical questions:
   - Which resources must agents never touch (production services, shared databases, secrets files, third-party hosts)?
   - Which findings are accepted risks agents must not re-report?
   - Who merges and who pushes, and may agents ever commit?
   - Is there a throwaway environment recipe for tests that write data?
5. **Draft the section** with these bullets, each one line or two, pointing at existing sections where possible:
   - **Commands:** build, test, run-one-test, e2e, budgets. Required environment setup for every shell command, if any.
   - **Throwaway environment:** the exact command to create and to tear down. If a bare teardown would hit a real environment, write the full command with its variables and say never to run it bare.
   - **Never touch:** protected resources by exact name, secrets files, third-party hosts.
   - **Security tooling:** how to run the scanners and read alerts, and which are unavailable.
   - **Accepted risks (do not re-report):** with the reason each was accepted.
   - **Gotchas agents must check:** where they live, plus the three or four that cause real incidents.
   - **Git conventions:** default and integration branches, branch naming, merge style, commit trailer, who merges and who pushes.
6. **Show the draft and wait for approval** before editing `CLAUDE.md`. Then insert it before the gotchas section (or at the end), keep the rest of the file untouched, and re-read the result.
7. **Check it works:** list which generic agents will now find what they need, and name anything still missing. Do not commit unless asked; if the repo uses a PR flow, offer the `ship-pr` skill.

## Rules
- Never read `.env` files or print secrets. Record that a secrets file exists and that it is off limits.
- Do not invent facts. Mark anything unverified as "not verified" in the draft rather than guessing.
- Keep the section under about 20 lines. Detail belongs in the sections it links to.
- When refreshing, diff against the repository: remove stale entries, do not only add.
