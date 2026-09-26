---
type: index
feature: retro-todo
lens: standard
appetite: ~2 weeks
---

# retro-todo — Spec index

A small in-memory todo app with several named lists. Finished items sink below open ones and read as
finished (strikethrough plus a color change); the whole app wears one neo-brutalist retro style.
HarmonyOS phone only, ArkTS, state management V2, template entry kept (`EntryAbility` -> `pages/Index`).
Nothing persists; every cold start seeds Groceries, Work and Weekend.

Source: the committed shaping in `shapeup/retro-todo/shaping/` (shaping.md, breadboard.md, three spikes)
and the requirement registry `shapeup/retro-todo/requirements.md`.

## Boundaries

In: lists (create, rename, delete, progress), items (add, toggle, delete), ordering, retro kit, app shell.
Out (No-goes): persistence, Settings or Gallery screens, a second language, dark theme, due dates,
reminders, tags, search, sharing, sync, drag-to-reorder, sub-tasks, moving items, item detail or title
edit, clear-completed, Loading/Error demo switches, reorder animation.

## Document map

| Document | What |
|---|---|
| [[domain-model]] | aggregates, rules, repository, seed |
| [[ux-behavior]] | screens P1–P4 with states and affordances |
| [[UC-01]] [[UC-02]] [[UC-03]] | create, rename, delete a list |
| [[UC-04]] [[UC-05]] [[UC-06]] | add, toggle, delete an item |
| [[UC-07]] [[UC-08]] | view the lists, open a list |
| [[integration]] | startup, navigation, in-process chain, silent-failure risks |
| [[todo-repository]] | repository contract |
| [[synthesis]] | traceability, risks, dependencies |
| [[feedback]] | PO / TL feedback template |
