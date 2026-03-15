# Agent Instructions — myMantra

## Workflow — features

When a feature is needed, follow this sequence:

1. Document it in appropriate documents:
 - PRD (`docs/product/product_requirements.md`)
 - Features (`docs/product/features.md`)
 - SRS (`docs/software/software_requirements.md`)
2. Prepare an implementation plan as a temporary file under `/tmp/plans/`
   - The plan must include:
     - a new *feat/* branch (following `git_workflow.md`)
     - documentation
     - unit/integration tests
   - Let the user review the plan, including negotiating it's details
   - In some cases, the user may ask to keep the plans for future resuming
     - in that case, copy the temporary file to docs/software/plans and exit
3. Compact (summarise context, note the next step) before writing code
4. Implement one step of the plan
5. Test the step (run relevant tests or verify manually)
6. Update `docs/product/features.md` with the new status and commit
7. Repeat from step 3 until complete

---

## Mermaid diagrams

In Mermaid, use `<br>` for line breaks inside labels — not `\n`. Most renderers do not support `\n` inside node labels.

```
% correct
A[line one<br>line two]

% wrong
A[line one\nline two]
```
