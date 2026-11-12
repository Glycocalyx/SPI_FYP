---
name: fyp-record-sync
description: Use when the SPI FYP user supplies a CODEX SYNC PACKAGE for documentation and Git synchronization.
---

# LOG_SYNC

1. Read root `AGENTS.md` and the supplied package. Inspect only the relevant documents, branch status, and latest applicable IDs.
2. Append the next permanent ACT, VER, DEC, and UP IDs independently. Keep each experiment and rerun distinct. Preserve supplied evidence grades (`CONFIRMED`, `USER_REPORTED`, `INFERRED`, `PLANNED_NOT_EXECUTED`, `UNKNOWN`) and preserve missing facts as `UNKNOWN`.
3. Update related decisions, artifact locations, and upload states. Keep approved unexecuted transfers `APPROVED_PENDING`. Change them to `UPLOADED` only with user-supplied execution evidence.
4. Update the current state when the package changes it. Create a detailed verification report only when requested, using `docs/templates/VERIFICATION_TEMPLATE.md`.
5. Review the Markdown diff, stage only the intended files, and commit/push approved changes to the designated branch when safe. Stop on unexpected changes, conflicts, or divergence. Preserve the commit and report any push failure.
6. Report new ID ranges, modified files, commit/push status, SHA, and missing information or conflicts.
