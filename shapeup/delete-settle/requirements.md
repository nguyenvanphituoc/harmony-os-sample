---
feature: "[[delete-settle]]"
kind: requirements-registry
---

# Requirements Registry — delete-settle

One atomic customer-requirement clause per row. Ids are assigned once and frozen; a clause
carrying a source `R<n>` keeps that number. Only the PO may set `status: CUT (PO-approved)`.

| REQ-id | Clause | Source | Status | Note |
|---|---|---|---|---|
| REQ-1 | A tap on any row's ✕ inside the settle window after a toggle opens no delete dialog and deletes nothing. | shaping/shaping.md R1 | covered | |
| REQ-2 | A tap on a row's ✕ outside the settle window opens the delete dialog naming that row's item, as before. | shaping/shaping.md R2 | covered | |
| REQ-3 | Toggling is unchanged: the settle window still swallows a second toggle. | shaping/shaping.md R3 (split 1/3) | covered | |
| REQ-4 | Toggling is unchanged: the settle window still lets a deliberate toggle through. | shaping/shaping.md R3 (split 2/3) | covered | |
| REQ-5 | Toggling is unchanged: done items still sink at once. | shaping/shaping.md R3 (split 3/3) | covered | |
