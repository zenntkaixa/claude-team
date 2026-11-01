# Prompt playbook: from empty folder to a deployed web app with Claude Code

Distilled from the radiozk project (2026-10-24 to 2026-11-01, about 200 prompts). Replace `[brackets]`.
Most prompts are one line. The detail lives in `CLAUDE.md`, not in your prompts, so write it early (phase 3).

## The loop that does most of the work

Every feature, fix or upgrade followed the same five steps. Five short prompts, repeated:

| Step | Prompt |
|---|---|
| 1. Ask for options | `Analyze [area] and think about how to [goal]. Suggest options, ranked.` |
| 2. Pick | `Yes, go ahead with [option / PR 2a].` (or `Ok. Start with PR #1`) |
| 3. Ship | `Commit in stages and open a PR.` (or `Push it and open a PR`) |
| 4. After you merge | `PR merged, check the CI.` then `Check the develop run again` if still running |
| 5. Next | `What's next?` |

Release: `Yes, open the release PR` then `Release PR merged, check the CI` then `Yes, delete the merged branches`.

You merge PRs yourself. Claude pushes only when you say so.

---

## Phase 0: Machine and toolchain
- `Install and configure a webserver and database we can use for locally prototyping a website we are going to build.`
- `Install Node.js and set up a basic app.` Add `Show me the plan first` if you want to approve it.
- If you have no root: say so (`no sudo, everything under the project folder`). That produced the `.local/` toolchain.
- Later: `Make a setup script that recreates the toolchain on a fresh clone.`

## Phase 1: Scaffold and git
- `Let's make the frontend with [React].`
- `Initialize a git repo with a .gitignore.`
- Give Claude your git identity and remote: `I've added my Git, check git config.` and `I've created a repo at [git@github.com:you/repo.git]. Push our progress into it.`
- Install `gh` and ask `I've installed gh. Verify it.`

## Phase 2: First feature, research external services first
- `Generate a webpage that does [X] using [URL / API].`
- `Examine the output of [metadata / API] on the same host.`, `What other APIs are available on the site?` (read-only exploration before building)
- Then build: `Let's do the "[feature]".` Ask design questions in plain words, e.g. "If a listener votes, then the song comes back later, is the vote kept?" and "Is it feasible to add the IP address to the fingerprint?"
- Tell Claude what is not yours to touch: `Don't call [third-party endpoint]; it writes to their system.`

## Phase 3: Write CLAUDE.md early (Claude Code's `/init` prompt works)
- `Analyze this codebase and create a CLAUDE.md for future Claude Code instances: commands (build, lint, test, run one test), architecture, gotchas.`
- Refresh it at each milestone: `Have you updated CLAUDE.md with what we did so far?`
- Put standing rules in it once: "Commit and push only when asked", "fetch and pull all branches before pushing", "merge commits, not squash", "never `git add -A` (untracked files)", "never touch [production resource]", and the commit trailer.

## Phase 4: Git and GitHub workflow
- `Let's practise using a develop branch and PRs. Is that already set up? Correct me if I'm wrong before you proceed.`
- `Set up branch protection and auto-delete of merged branches. Require the ci check.`
- Branches from `develop`, PRs into `develop`, then `develop` to `main` release PRs.
- `There are merge conflicts in PR #N. Check and fix it.`
- `PR has failed checks. Please check.` then `Commit the fix and push it to the PR.`

## Phase 5: Tests and refactor
- `Is there a feasible opportunity to refactor our current code?` then `Start with the refactor, tests first.`
- `Think about how to build a unit-testing framework for the front end and the back end.` (name your preferred tool, e.g. "use the newer Vitest")
- `Have a README-TESTING.md as well.`
- Browser tests by Claude itself: `Use MCP so you can test with [Firefox]. Register the Playwright MCP server.`
- When a test is flaky: `Investigate the e2e flake first.`

## Phase 6: Docs
- `Generate a README.md suitable for this GitHub project.`
- `Generate a system architecture diagram in Mermaid format.` Note: GitHub READMEs may not render the format you want; keep the diagram in its own file and link it.
- Ask for a docs audit once per release (the `docs-auditor` agent).

## Phase 7: CI
- `Integrate our unit tests and security scans into the GitHub Actions workflow.`
- `Yes, require the ci check.` (branch protection on the gate job)
- Dependabot: `Check the Dependabot PRs.` Expect bot-run workflows to fail until bots are allowed.

## Phase 8: Containers
- `Package this project in Docker with dev and prod releases so it deploys self-contained.`
- `What are the instructions for me to test the docker?`
- `Kick off the production environment if it is not already running.` and `Release PR merged, rebuild production.`
- Say once which stack holds real data and must never be torn down.

## Phase 9: Security
- `Do we already have npm audit scanning and a make target for security tests?`
- Decide policy in the answer, e.g. `Fail on high, and just document the rate limiting.`, then later `Yes, go ahead with the security headers`, `Yes, go ahead with Trivy/CodeQL`.
- Alerts: `Check the CodeQL alerts.`, then `Go with option 1, dismiss it.` (for accepted risks)

## Phase 10: Upgrades and speed
- `Since Node [N] is now LTS, check feasibility to upgrade.` Ask for a round of dependency PR checks first.
- `Analyze the website and think about how to optimize page speed.` Claude returns a numbered PR list; run them one at a time: `Start PR 1`, `PR #15 merged. What's next?`
- Cut features you don't want: `I'm happy with the current UI. Cross it off the list.`

## Phase 11: Agents and skills (optional, pays off across projects)
- `Suggest sub-agents that would help on this project.`, then `Create the first one.`, `Build the reviewer / verifier / debugger / release-engineer / docs-auditor agent.`
- `Suggest skills tailored to a senior, mature software team.` (agents do the work; skills are how)
- Cost: `Subagent and skill invocations would burn a lot of my tokens, how can we optimize?`
- Portability: `Store them in a git repo` (the private `claude-team` repo, with `install.sh`).

## Phase 12: Deploy online
1. `With the current state of the app, how do I deploy it online with a public link? What platforms do I have?`
2. Pick one: `I want to go with [platform]. Continue.` (Vercel then Render took two tries; decide early.)
3. `Prepare [render.yaml / platform config] on a new branch.`, then `Commit it, push it and open a PR.`
4. Tooling: `Install the [platform] CLI and validate the config.`, `Authenticate [platform].` (run the login yourself)
5. Apply it yourself in the dashboard. **Tell Claude the branch you used** and that you deployed the whole Blueprint, not a single service.
6. `I have deployed it. Check the logs; there are errors in it.`
7. Verify on the live URL: health endpoint, one real read, then anything per-visitor (rate limits) from a second network.
8. Clean up: `Delete the old [service] with the CLI.`, `Fix the docs on a branch.`, `Close PR #N.`, release PR, delete branches.

---

## Habits worth repeating
- **Ask before building:** `Correct me if I'm wrong before you proceed.` caught that a workflow already existed.
- **One concern per PR**, with `Commit in stages`.
- **Say "check the CI" after every merge.** It caught the port clash in the tests only after merge to the PR.
- **Name what is production** and what must never be deleted.
- **Approve each push, merge and delete** in words. Claude does not carry approval over.

## What I'd do differently next time
1. Decide the deploy platform before building a second one.
2. Say upfront that the app deploys as several pieces (static site, API, database) so a single Dockerfile service is not used.
3. Reserve test ports in `CLAUDE.md` at the start (the shared-port clash cost a CI round).
4. Ask for the rate-limit and forwarded-header check as part of the first deploy, run from two networks within the same minute.
5. Put `Don't propose [topic]` decisions in memory when you make them (e.g. no restyling).
