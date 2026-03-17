---
name: on-git-ci-failure
description: A workflow to fetch, diagnose, and repair GitHub Actions failures using the gh CLI. Use when the user says "fix the build", "CI is broken", "why is the pipeline red", "the PR checks failed", "check github failure", or "repair integration failure".
---

# On GitHub CI Failure

Use this skill when the user asks to fix, check, or diagnose a failure in CI, unit test, integration test or a GitHub Actions workflow.

## 0. Pre-flight
- Verify `gh` is authenticated: `gh auth status`
- If not authenticated, instruct the user to run `gh auth login` and stop.
- Confirm the current repo, branch and recent commits:
``` bash
  git remote get-url origin
  git branch --show-current
  git log -n 10
```

## 1. Discovery Phase
List recent failures to identify the relevant run:
`gh run list --status failure --limit 10`

If no failures are found, ask the user for guidance.

Identify the most relevant failure using these heuristics:
- Same commit SHA as the current branch HEAD
- Related to the current conversation context
- The latest one

If multiple failures are relevant — present them as options for the user to choose.

## 2. Diagnosis Phase
Fetch the log for the identified run:
`gh run view <run_id> --log`

If logs are too long, use:
`gh run view <run_id> --log-failed`

Focus on the **first failing step** — subsequent steps often fail as cascading side effects.

Within that step, extract **all distinct errors** (up to 10), for example:
- Multiple lint violations
- Multiple build errors
- Multiple test failures
- Multiple missing imports

For each error extract:
- The error message / stack trace
- The file(s) and line number(s) if available

## 3. Analyze Phase
Classify the error type, for example:
- Dependency conflict
- Failing test
- Linter / type-check error
- Missing secret or env var
- Infrastructure / runner issue

Explain the root cause clearly to the user before proposing anything.

## 4. Repair Phase
- Propose a fix with a clear explanation of what will change and why.
- **Wait for explicit user approval before applying anything.**
- After approval: apply the fix, run relevant tests locally.
- Derive a meaningful commit message from the actual problem found, e.g.:
  `git add . && git commit -m "fix(ci): <short description of root cause>"`
- Do **not** push.
- If there are obvious multiple root-causes
  - create a fix and a separate commit for each one.

## 5. Local verification
- If you can run verification locally - do it.
  - If only the user can run verification, guide them on how to do it.
- If verification indicated revisit is needed
  - soft reset the Phase #4 commit to ammend them.
  `git reset --soft HEAD~1`
  - Go back to Phase #4 - and repair

## 6. Push to repo
- Tell the user "fix is ready to push" and suggest:
  - you will push to branch <origin/branch-whose-ci-failed>
  - let the user push and confirm push was done

## 7. Monitor CI
**Only after the user confirms they have pushed:**
`gh run watch`

Confirm the new run passes. If it fails again, return to Phase 2 with the new run ID.
