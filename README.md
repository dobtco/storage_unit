trashable
=========

:recycle:

Soft deletion for Rails 4, done right.

### Goals

- Standard set of "soft deletion" methods (`trash`, `recover`, `trashed?`)
- Explicit trashable dependencies (automatically trash associated records)
- Low-overhead (minimize queries)
- No validations on `recover`. (If your records became invalid after they were trashed, check for this yourself)
- Small, readable codebase

### Non-goals

- Targeting anything less than Rails 4
- Reflection on Rails' associations
- Generally, anything weird or complex happening behind the scenes
