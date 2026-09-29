---
shaping: true
feature: "[[lists-badge-sync]]"
status: shaped
appetite: ~1 day
---

# Lists Badge Sync — Shaping

The "done" badge on each list card in MY LISTS should say how many of that list's items are done.
Today it keeps the count it had when the app started: toggle an item inside a list, go back, and the
card still shows the old count.

## Problem Frame

Found by the QA hunt on settle-across-screens (finding QA-001), and reproduced by hand on the emulator
(2026-09-29, `127.0.0.1:5555`) with a device flow:

```
launch
tap text "Groceries"
expect count id "item.done" 1
tap id "list.itemCard.toggle" 1       # Bread → done
expect count id "item.done" 2         # passes: the toggle happened
back
tap text "Groceries"
expect count id "item.done" 2         # passes: the store kept it across screens
back
expect text "2/3 done"                # FAILS: the card still reads "1/3 done"
```

The item state is right, and a second visit to the list shows it. Only the MY LISTS card is stale. The
hunter also reported that the stale count survives a force-stop and relaunch. It does not: the store is
in memory and re-seeds on launch, so "1/3 done" after a relaunch is the correct seeded count (checked with
a second flow). Success: every card's badge matches its list's items whenever MY LISTS is on screen.

## Appetite

**~1 day.** Find the one link that drops the update and fix it there, plus the device check. Not a
rework of how the lists screen is built.

## Baseline

`soak/retro-todo-4` as settle-across-screens shipped it.
- `ListsViewModel.cards` is a `@Computed` over `store.lists` and `store.items`, and builds one `ListCard`
  (id, name, done, total) per list. `ListCard` is a plain class.
- `ToggleItem` → `InMemoryTodoRepository.setDone` replaces the item and reassigns `store.items`, which is
  `@Trace` on the `@ObservedV2` `TodoStore`.
- `ListsPage` renders `Repeat<ListCard>(this.vm.cards)`, keyed on `id|name|done|total`. Each card goes
  through a `@Builder cardBuilder(card)`, and the badge is `AppText({ text: $r('app.string.progress_done',
  card.done, card.total) })`.
- `TodoModule` keeps one `ListsViewModel` for the session. The lists screen stays mounted under the
  `Navigation` stack while a list is open.

## Constraints

- The build-enforced house rules (L1–L11) apply as for retro-todo: state management V2 only, no
  `@Provider`/`@Consumer`, no hex or quoted text literals.
- The seeded data and every other screen are unchanged.
- The permission grant is not widened; the device check uses the existing `ui-flow.sh` grant.

## Requirements

- **R1** — After toggling an item inside a list and going back, that list's card in MY LISTS shows the new
  done count.
- **R2** — The same holds after adding an item (the total changes) and after deleting one (the done count,
  the total, or both change).
- **R3** — Renaming a list still updates its card's name, and the order of the cards does not change.
- **R4** — The device flow above is committed as a Test Surface flow and passes.

## Rabbit Holes

- **Guessing the broken link.** Every link in the chain looks right on paper: the store is observed,
  `cards` is computed from it, the key includes the counts. Spike it before changing anything — log or
  flow-check each link (store → `cards` → `Repeat` key → the `@Builder` parameter → `AppText`) and fix
  only the one that drops the update. A `@Builder` that takes a plain object is passed by value, which is
  the first suspect, not a conclusion.
- **Re-creating the view model on every visit.** It would hide the bug and change the view model's lifetime.
  Out of scope.
- **A manual refresh hook** (`onShown`, `aboutToAppear`) that re-reads the store. It papers over the break
  instead of fixing it, and it would still leave the card wrong while it is on screen. Only if the spike
  shows V2 cannot carry the update at all, and then as a PO decision.

## No-goes

- No change to the list screen, the dialogs, the settle window, or persistence.
- No new state library or pattern; V2 decorators only.

## Selected Shape — A · Fix the link that drops the update

- **A1** — A spike names the link where the badge's update stops, with the evidence (which check passes and
  which one fails).
- **A2** — The fix is made at that link, in the lists screen or its view model, and nowhere else.
- **A3** — Device flows for R1, R2 and R3, the first one being the repro above.

## Fit Check

| Requirement | A |
|---|---|
| R1 | ✅ A1 + A2 |
| R2 | ✅ A2 (the same link carries every count change) |
| R3 | ✅ A2, A3 |
| R4 | ✅ A3 |

## Gate decisions (for downstream skills)

- PO asked to repro settle-across-screens' QA-001 by hand before shaping (2026-09-29). Repro confirmed; the
  relaunch half of the finding did not reproduce.
- Shape A: spike first, fix at the broken link, no refresh hook.
