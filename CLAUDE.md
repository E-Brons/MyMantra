# Claude Instructions — myMantra

## Workflow — features, fixes, and refactors

When a feature, fix, or refactor is needed, follow this sequence:

1. Document it in PRD (`docs/product/product_requirements.md`), features (`docs/product/features.md`), and SRS (`docs/software/software_requirements.md`) as appropriate.
2. Prepare an implementation plan as a temporary file under `~/.claude/plans/` — **do not commit this file**.
3. Compact (summarise context, note the next step) before writing code.
4. Implement one step of the plan.
5. Test the step (run relevant tests or verify manually).
6. Update `docs/product/features.md` with the new status and commit.
7. Repeat from step 3 until complete.

---

## Mermaid diagrams

In Mermaid, use `<br>` for line breaks inside labels — not `\n`. Most renderers do not support `\n` inside node labels.

```
% correct
A[line one<br>line two]

% wrong
A[line one\nline two]
```
