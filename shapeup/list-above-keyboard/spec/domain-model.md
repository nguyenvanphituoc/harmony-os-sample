---
type: domain-model
feature: list-above-keyboard
---

# Domain Model — list-above-keyboard

No new bounded context, aggregate, value object, domain event or repository method. `TodoItem`,
`TodoStore` (breadboard S1 — its items, unchanged), `ToggleItem`, `AddItem` and the ordering rule
(done items below every open item, KB-BA-007 / R7 elsewhere in this project) are untouched — this
pitch's No-goes are explicit that sorting, adding, toggling and deleting are unchanged. The fault
this pitch fixes is layout: what height the list screen's container resolves against while the
keyboard is up.

## The one setting this pitch adds — `⏳ TBD`, by design

Two API shapes exist on this stack for making a container resize above the keyboard instead of
being covered by it (code-surface.md, spike-keyboard-avoid.md):

| Candidate | Where it would live | What the spike found |
|---|---|---|
| Window-level keyboard avoid mode | `EntryAbility.onWindowStageCreate`'s `windowStage` / `getMainWindowSync()` — the only place in this codebase that touches the `Window`/`WindowStage` object today | Reaches every screen, including P3's dialog overlay — broader than the pitch needs, and the rabbit hole this pitch's A1 exists to check against R4 |
| Page-level keyboard-avoid attribute | `ListPage.ets`'s outer `Column`/`NavDestination` | The spike's own read of the rename dialog (rendered centered, bottom edge well clear of where a ~40%-height keyboard sits) suggests the dialog's `promptAction.openCustomDialog` overlay is already independent of a page-scoped fix — plausible as "the smallest setting" per the pitch's A1, but not confirmed: the spike did not verify the IME was actually raised in that same dump, and this orient run had no web access or local SDK `.d.ts` access to confirm the exact API name/enum values |

Per the two-pass contract rule (standard lens): the concrete symbol is `⏳ TBD — verify against
the SDK's own `.d.ts` or a device probe at Wire/Build`, not guessed here. What both candidates share,
and what this pitch actually relies on, is narrower than either API:

## The one fact this pitch is built on

`ListPage.ets`'s `List({ space: 12 }).width('100%').layoutWeight(1)` already means "take whatever
height the `Column` above it has left." Nothing today shrinks that `Column`'s own height for the
keyboard (code-surface.md: zero `setKeyboardAvoidMode`/`expandSafeArea` hits), so the `List`
currently resolves `layoutWeight(1)` against the full, unshrunk page height — confirmed empirically
by the spike (every node's bounds identical, ±noise, with and without the keyboard focused; root
content bounds stay `[0,0][1320,2856]` in both dumps). Whichever setting Wire/Build picks, **the
`List`'s own layout code does not change** — `layoutWeight(1)` already shrinks it for free once its
container's height does. This pitch is entirely "make the container above the `List` shrink," not
"make the `List` shrink."

## What the setting must NOT do (R3, R4)

- With no field focused (keyboard down), the setting must produce byte-for-byte today's layout on
  P2 and P1 — R3 is a no-op state, not a smaller resize. A setting that changes idle-state layout
  (e.g. a permanent `expandSafeArea` that also clips something today) is the wrong candidate.
- P3 (the list-name dialog, new or rename) must stay fully visible with the keyboard up (R4) —
  whichever candidate is picked, the task that applies it carries a device check against the
  dialog, not an assumption that "page-level can't reach it" or "window-wide obviously does."

## Use case index

[[UC-01]] every item stays reachable while the keyboard is up, on the list screen and its dialogs.
