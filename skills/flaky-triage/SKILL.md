---
name: flaky-triage
description: Attribute an intermittent failure (flaky test, sporadic CI red, timing change) to a regression, a pre-existing problem or the environment by measuring the failure rate over repeated runs and a control run of the base ref. Hands root cause to the debugger agent.
---

# Flaky triage

A single failure proves nothing, and so does a single pass. This procedure turns "it failed once" into a rate and an attribution. Read the project's *Agent contract* first for the commands, the throwaway environment, rate limits that repeated runs could trip, and the never-touch list.

## Steps

1. **State the symptom.** The exact check, the exact error text, where it fails (CI or local, which environment), and the last time it was known good. Pull CI history if useful: `gh run list --workflow <name> --limit 20 --json conclusion,headSha,createdAt`.
2. **Reproduce and measure.** Use the helper to run the single failing check N times (default 8; fewer for slow checks, more for rare ones):
   `bash ~/.claude/skills/flaky-triage/scripts/repeat.sh 8 "$SCRATCH/head" -- <command>`
   Use the narrowest command that still shows the failure (one test, not the suite). Repeat any required environment setup inside the command. Mind rate limits and shared state: if runs write data, use the contract's throwaway environment, never a protected one.
3. **Read the failures, not just the count.** Compare the error text across failing runs. The same message every time suggests one cause; different messages suggest several problems or an environmental one. Note what varies between runs: time, order, data, load, network, another process.
4. **Control run.** Run the same check the same number of times on the base ref in a clean worktree: `git worktree add --detach "$SCRATCH/base" <base-ref>`. If the check depends on a live external service (a CDN, an API), **alternate** head and base runs so both see the same conditions; running one batch after the other confounds the result with time.
5. **Attribute.** Compare rates, with run counts stated:
   - fails on head, passes on base every time: **regression** (say how many runs backed it);
   - fails at similar rates on both: **pre-existing or environmental**;
   - fails on both but only under certain conditions (a slow network, a busy machine): **environmental**; name the condition;
   - small differences with few runs: **not determined**; add runs rather than guessing. As a rule of thumb, a failure rate that differs by less than what the run count can resolve is noise.
6. **Decide the next step.**
   - Regression: hand the evidence to the `debugger` agent (symptom, rates, what you ruled out) or fix it if the cause is already clear.
   - Pre-existing or environmental: describe the mechanism if known; recommend making the check tolerant of the real variation (for example waiting for a condition instead of a fixed time), never a blind retry or a looser assertion without showing the variation is by design.
   - Not determined: say what additional runs or logging would settle it.
7. **Clean up.** Remove the worktree (`git worktree remove --force`; files left by containers are removed through a container, not with sudo), stop anything you started by pid or exact name, delete scratch logs. Confirm with listings.

## Report
```
Check: <name>   Symptom: <error text>
Head <ref>: <pass>/<runs> pass     Base <ref>: <pass>/<runs> pass     (alternated: yes/no)
Verdict: regression | pre-existing | environmental | not determined — <one sentence>
Evidence: <what differs between failing and passing runs>
Next: <hand to debugger | fix | make tolerant | more runs needed>
Cleanup: <done>
```
State measured numbers only. Never write "should be fine" for something that was not run.
