---
name: implement-feature
description: >
  End-to-end workflow for implementing a new user-facing feature in MyMantra.
  Use when the user says "add a feature", "implement X", "build Y", "I need a new screen/behaviour",
  or when a task is categorised as a feat/ branch in git_workflow.md.
---

# Implement Feature

## 0. Pre-flight

Confirm you are on `main` and it is up to date:
```
git checkout main && git pull origin main
```
Identify today's date (YYYY_MM_DD) — it will be used for the branch name.

---

## 1. Document the Feature

Before writing any code, update the three canonical documents in this order:

1. **PRD** (`docs/product/product_requirements.md`) — add the feature to the relevant phase section with a clear user-facing description.
2. **Features list** (`docs/product/features.md`) — add a row with status `Planned`.
3. **SRS** (`docs/software/software_requirements.md`) — add functional and non-functional requirements (SR-x.x format) that this feature must satisfy.

Commit these doc changes on `main` (or as the first commit on the feature branch if the change is branch-specific).

---

## 2. Prepare an Implementation Plan

Create a temporary plan file at `/tmp/plans/<YYYY_MM_DD>-<feature-name>.md`.

The plan must cover:
- **Branch name**: `feat/YYYY_MM_DD-<short-description>`
- **Scope**: what screens, models, providers, services are affected
- **Commit sequence**: list each planned commit with its `feat:` / `test:` / `docs:` prefix
- **Test plan**: which unit tests, widget tests, and integration tests will be added (in separate commits)
- **Documentation updates**: which docs need updating after implementation

Present the plan to the user. Negotiate scope and details. Do not proceed until the user approves.

If the user asks to pause for a future session — copy the plan to `docs/software/plans/` and stop.

---

## 3. Create the Branch

```
git checkout -b feat/YYYY_MM_DD-<short-description>
```

---

## 4. Implement — One Step at a Time

For each step in the approved plan:

1. **Compact**: summarise context and note the next step before writing code.
2. **Implement** the step — keep commits focused and atomic.
3. **Test**: run `make test` (lint + unit + widget) after each commit; fix any failures before moving on.
4. Commit with the appropriate prefix:
   - `feat[(<scope>)]: <description>` — for implementation changes
   - `test[(<scope>)]: <description>` — for tests (must be a **separate commit** from the implementation)
   - `docs: <description>` — for documentation updates

**Tests must be in their own commit(s)**, separate from the implementation, so the test intent is independently reviewable.

Repeat this sub-loop until all steps in the plan are complete.

---

## 5. Final Checks Before PR

- Run the full local test suite: `make test`
- Run integration tests if the feature touches app flow: `make test-integration TARGET=macos`
- Update `docs/product/features.md` — change the feature status to `In Review`.
- Commit the features.md update: `docs: update features.md — <feature> in review`

---

## 6. Open the Pull Request

Push the branch and open a PR targeting `main`:
```
git push origin feat/YYYY_MM_DD-<short-description>
```

The PR description must include:
- What the feature does (user-facing description)
- Which requirements (SR-x.x) it satisfies
- How to test / verify manually

The PR must pass all five CI jobs (see `git_workflow.md` §5) and receive approval before merging.

---

## 7. After Merge

Update `docs/product/features.md` — change the feature status to `Released` and commit on `main`.
