# Claude Instructions — myMantra

## Mermaid diagrams

In Mermaid, use `<br>` for line breaks inside labels — not `\n`. Most renderers do not support `\n` inside node labels.

```
% correct
A[line one<br>line two]

% wrong
A[line one\nline two]
```
