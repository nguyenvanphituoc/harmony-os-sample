---
feature: "[[settle-across-screens]]"
kind: requirements-registry
---

# Requirements Registry — settle-across-screens

One atomic customer-requirement clause per row. Ids are assigned once and frozen; a clause
carrying a source `R<n>` keeps that number. Only the PO may set `status: CUT (PO-approved)`.

| REQ-id | Clause | Source | Status | Note |
|---|---|---|---|---|
| REQ-1 | A ✕ tap inside the settle window after a toggle opens no delete dialog, even when the list screen was left and reopened between the toggle and the tap. | shaping/shaping.md R1 | covered | |
| REQ-2 | A toggle inside the settle window is ignored in the same case: after leaving and reopening the list, a second toggle within the window changes nothing. | shaping/shaping.md R2 | covered | |
| REQ-3 | Outside the settle window, a ✕ tap on a reopened list opens the dialog naming that row's item, exactly as today. | shaping/shaping.md R3 (split 1/2) | covered | |
| REQ-4 | Within one visit to the screen, toggle-once's and delete-settle's behavior is unchanged: their existing unit tests and device flows still pass without edits. | shaping/shaping.md R4 | covered | |
| REQ-5 | Outside the settle window, a toggle toggles on a reopened list, exactly as today. | shaping/shaping.md R3 (split 2/2) | covered | |
