# Agent Instructions — myMantra

## Skills

| Skill               | File                                        | When to use                        |
| ------------------- | ------------------------------------------- | ---------------------------------- |
| `implement-feature` | `.agents/skills/implement-feature/SKILL.md` | Adding any new user-facing feature |
| `fix-bug`           | `.agents/skills/fix-bug/SKILL.md`           | Diagnosing and fixing a bug        |
| `on-git-ci-failure` | `.agents/skills/on-git-ci-failure/SKILL.md` | CI pipeline is red                 |

---

## Mermaid diagrams

In Mermaid, use `<br>` for line breaks inside labels — not `\n`. Most renderers do not support `\n` inside node labels.

```
% correct
A[line one<br>line two]

% wrong
A[line one\nline two]
```

## Settings and Configurations

Always prefer externalising settings, lists, and configuration into data files rather than hardcoding values in Dart (or any other code) files.

- **YAML** (`assets/data/*.yml`) — human-readable lists and structured configuration (e.g. themes, icon catalogues).
- **JSON** (`assets/data/*.json`, `target.json`) — machine-consumed configuration and structured data.

Rules:
- If a value could ever change without a code change (colours, labels, IDs, feature flags, asset paths, numeric thresholds), it belongs in a data file.
- Code files may only contain constants that are truly invariant (e.g. mathematical ratios, platform API identifiers).
- When adding a new configurable value, check whether an appropriate data file already exists before creating a new one.
- Data files under `assets/` must be declared in `pubspec.yaml` to be bundled with the app.
