---
name: fix-bug
description: >
  End-to-end workflow for diagnosing and fixing a bug in MyMantra using the Red → Green idiom.
  Use when the user says "fix a bug", "there's a crash", "BUG-XXX", "something is broken",
  or when a task is categorised as a fix/ branch in git_workflow.md.
---

# Fix Bug

## 0. Pre-flight

Confirm you are on `main` and it is up to date:
```
git checkout main && git pull origin main
```
Identify today's date (YYYY_MM_DD) — it will be used for the branch name.

---

## 1. Understand the Bug

Before touching any code:

- Reproduce the bug locally — confirm you can observe the failure.
- Identify the precise failure condition: which input, state, or sequence triggers it.
- Locate the relevant requirement in `docs/software/software_requirements.md` (SR-x.x) that this bug violates.
- Check `docs/test/test_cases.md` — if a test case exists for this area, understand why it did not catch the bug.

---

## 2. Create the Branch

```
git checkout -b fix/YYYY_MM_DD-<short-bug-description>
```

Use the bug ID in the description if one exists (e.g. `fix/2026_03_14-bug-004-render-emoji-ios`).

---

## 3. Red Commit — Write the Failing Test First

Write a test that reproduces the bug exactly. The test **must fail** before the fix is applied.

- Place the test in the appropriate suite: `test/unit/`, `test/widget/`, or `integration_test/`.
- Run `make test` (or `make test-integration TARGET=macos`) to confirm the test fails (CI goes **red**).
- Commit the failing test alone — do not include any fix code:

```
test: RED – <short description of what fails and why>
```

This commit is the proof that the test genuinely catches the regression.

---

## 4. Green Commit — Apply the Fix

Implement the minimal change that makes the failing test pass without breaking any existing tests.

- Run `make test` — all tests must pass.
- Run `make test-integration TARGET=macos` if the fix touches app flow.
- Commit the fix separately from the test:

```
fix[(<scope>)]: <short description of root cause and remedy>
```

The two-commit sequence (`test: RED` → `fix:`) is mandatory and non-negotiable — see `git_workflow.md` §8.

---

## 5. Document the Bug (if significant)

If the bug was user-visible or caused a regression, add or update a bug report under `docs/test/specific_test_details/`:
- File name: `bug-<id>-<short-name>.md`
- Include: symptom, root cause, fix summary, and the test that now guards it.

---

## 6. Open the Pull Request

Push the branch and open a PR targeting `main`:
```
git push origin fix/YYYY_MM_DD-<short-bug-description>
```

The PR description must include:
- The bug symptom and reproduction steps
- The root cause
- Which requirement (SR-x.x) was violated
- The Red → Green commit pair that proves the fix

The PR must pass all five CI jobs (see `git_workflow.md` §5) and receive approval before merging.
