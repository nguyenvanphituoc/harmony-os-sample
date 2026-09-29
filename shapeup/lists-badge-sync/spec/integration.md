---
type: integration
feature: lists-badge-sync
---

# Integration — lists-badge-sync

No new cross-system flow, no network, no persistence change. This is a single in-process render
chain fix on P1, plus one device-flow proof already fully supported by `scripts/ui-flow.sh`.

## In-process chain (the spike's isolation)

| Node | What | Notes |
|---|---|---|
| N2 | `ListsViewModel.cards` (`@Computed`) | reads `store.lists`/`store.items`, already correct on every read — not the fault |
| N3 | `AsyncBoundary`'s `@BuilderParam ready` slot → `readyBuilder` → `Repeat.each` → `cardBuilder(card: ListCard)` | the spike's leading candidate: `cardBuilder` is a `@Builder` method with no independent V2 render scope, called from inside `ListsPage`, which stays mounted (never torn down) while a list is open above it — unlike `ItemCard`, a real `@ComponentV2` on the working P2 chain |

No repository, no `Clock`/`NavPort` seam change — the fix, wherever A1 lands it, touches only how
P1 renders an already-correct `ListCard[]`.

## Device-flow language

`scripts/ui-flow.sh` already supports every step this pitch's device checks need: `launch`, `tap`,
`back`, `expect count`, `expect text`. No new op is required. The R4 repro (`launch` → open
Groceries → toggle Bread → back → expect the updated badge) is committed verbatim from
shaping.md's Problem Frame as this use case's TS-01-02 fixture; R2/R3/R5's flows (TS-01-03..05)
follow the same shape with add/delete/rename in place of toggle.

| Risk | Guard |
|---|---|
| A2 fixes the symptom by forcing a full P1 remount (e.g. re-keying the whole `Repeat`, or a manual refresh hook) instead of the one link A1 names | ruled out by the pitch's Rabbit Holes and No-goes; INV-04 names the fix's scope, and TS-01-01 would still pass (it does not exercise the render layer) while TS-01-02..05 would only mask, not prove, the fix is at the right link |
| A2 changes `ListsViewModel.cards`'s computation (e.g. to defensively re-sort or re-filter) instead of only the render unit | INV-01 names the computation frozen; a diff review against domain-model.md's scoped fix is the check, since no unit test distinguishes "fixed at the right link" from "fixed by coincidence" once the device flows pass |
| The device-flow fixture directory this pitch's checks write into is not granted to the scope that owns `ListsPage.ets`/`ListsViewModel.ets` | a MAP SCOPES / L1b concern (substrate-disjointness), not fixable in this phase; `probe owner` returning null for a flow path has repeated on this project before |

## Silent-failure risks specific to this pitch

- A1 is genuinely open going into Build (the spike narrowed the suspect but did not conclude it,
  per the hill signal) — a task that skips confirming the exact link and patches the first thing
  that makes the repro flow pass risks a fix that only happens to work for toggle (TS-01-02) while
  leaving add/delete/rename (TS-01-03..05) on a different, still-broken path; the Test Surface rows
  for R2/R3/R5 exist precisely to catch that.
- If the confirmed fix is "convert `cardBuilder`'s content into a `@ComponentV2` sub-component",
  a card's identity (the `Repeat` key, unchanged: `id|name|done|total`) must still map one render
  instance per list id — a keying mistake here would show as cards changing identity (and
  animating/flashing) on every store change rather than staying stable per list, which the device
  flows' repeated-visit shape (open the same list twice) would surface as a visibly different card
  order or a crash, not silently.
