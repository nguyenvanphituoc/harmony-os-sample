---
feature: "[[retro-todo]]"
schema: requirements-registry-v1
---

# Requirements Registry — retro-todo

Extracted from the pitch's `## Requirements` clauses. REQ-ids are assigned once and frozen;
a clause already carrying an `R<n>` in the source keeps that number. Only the PO sets a
`status` of `CUT (PO-approved)`.

| REQ-id | Clause | Source | Status | Note |
|---|---|---|---|---|
| REQ-0 | With no lists (for example after deleting every list), the lists screen invites the user to create the first one — never a blank screen. | shapeup/retro-todo/shaping/shaping.md R0 | covered | |
| REQ-1 | The user can create a list with a name. | shapeup/retro-todo/shaping/shaping.md R1 | covered | |
| REQ-17 | An empty or whitespace-only list name is refused with a message at the field. | shapeup/retro-todo/shaping/shaping.md R1 (split 2/3) | covered | |
| REQ-18 | Duplicate list names are allowed. | shapeup/retro-todo/shaping/shaping.md R1 (split 3/3) | covered | |
| REQ-2 | The user sees every list, each with its name and its progress (done / total, e.g. "3/5 done"). | shapeup/retro-todo/shaping/shaping.md R2 | covered | |
| REQ-3 | Opening a list shows that list's items and no other list's. | shapeup/retro-todo/shaping/shaping.md R3 | covered | |
| REQ-4 | The user can delete a list, together with its items, after confirming. | shapeup/retro-todo/shaping/shaping.md R4 | covered | |
| REQ-16 | The user can rename a list. | shapeup/retro-todo/shaping/shaping.md R16 | covered | |
| REQ-19 | An empty or whitespace-only rename value is refused with a message at the field. | shapeup/retro-todo/shaping/shaping.md R16 (split 2/2) | covered | |
| REQ-5 | Inside a list the user can add an item with a title. | shapeup/retro-todo/shaping/shaping.md R5 | covered | |
| REQ-20 | An empty or whitespace-only item title is refused with a message at the field. | shapeup/retro-todo/shaping/shaping.md R5 (split 2/2) | covered | |
| REQ-6 | One tap on the list marks an item done or not done. | shapeup/retro-todo/shaping/shaping.md R6 | covered | |
| REQ-7 | Done items always sit below every open item. | shapeup/retro-todo/shaping/shaping.md R7 | covered | |
| REQ-21 | In each group (open, done) the newest-created item comes first. | shapeup/retro-todo/shaping/shaping.md R7 (split 2/4) | covered | |
| REQ-22 | Marking an item done moves it into the done group at once. | shapeup/retro-todo/shaping/shaping.md R7 (split 3/4) | covered | |
| REQ-23 | Marking an item not done returns it to its creation-order place among the open items. | shapeup/retro-todo/shaping/shaping.md R7 (split 4/4) | covered | |
| REQ-8 | A done item's text is struck through, so it reads as finished. | shapeup/retro-todo/shaping/shaping.md R8 | covered | |
| REQ-24 | A done item's text changes color, so the finished difference never rests on color alone. | shapeup/retro-todo/shaping/shaping.md R8 (split 2/2) | covered | |
| REQ-9 | The user can delete an item after confirming. | shapeup/retro-todo/shaping/shaping.md R9 | covered | |
| REQ-10 | A list with no items invites the user to add the first one. | shapeup/retro-todo/shaping/shaping.md R10 | covered | |
| REQ-11 | Every list is its own card. | shapeup/retro-todo/shaping/shaping.md R11 | covered | |
| REQ-25 | Every item is its own card. | shapeup/retro-todo/shaping/shaping.md R11 (split 2/2) | covered | |
| REQ-12 | All text has a contrast ratio of at least 4.5:1 against its background — done-item text included (WCAG 2.x AA). | shapeup/retro-todo/shaping/shaping.md R12 | covered | |
| REQ-26 | Card borders and the check control have a contrast ratio of at least 3:1 against their background (WCAG 2.x AA). | shapeup/retro-todo/shaping/shaping.md R12 (split 2/2) | covered | |
| REQ-13 | Every screen follows one retro visual style — palette, type, card treatment — defined once. | shapeup/retro-todo/shaping/shaping.md R13 | covered | |
| REQ-14 | Data lives in memory only: every cold start begins with the same sample lists and items. | shapeup/retro-todo/shaping/shaping.md R14 | covered | |
| REQ-27 | Nothing survives a restart. | shapeup/retro-todo/shaping/shaping.md R14 (split 2/2) | covered | |
| REQ-15 | Every visible string is in English. | shapeup/retro-todo/shaping/shaping.md R15 | covered | |
