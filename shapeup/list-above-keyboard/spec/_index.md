---
type: index
feature: list-above-keyboard
lens: standard
appetite: ~1 day
---

# list-above-keyboard — Spec index

Nothing sets a keyboard-avoid mode anywhere in this app (grepped: zero `setKeyboardAvoidMode`,
`expandSafeArea`, `SafeAreaType`/`SafeAreaEdge` hits under `app/entry/src/main/ets`), so the list
screen's `List({ ... }).layoutWeight(1)` resolves against the *full*, unshrunk page height. With
the new-item field focused the soft keyboard covers the lower ~40% of the screen and the list has
nothing to scroll — it already fits its own height — so the last items, done ones included since
done items sink to the bottom, are out of reach until the keyboard closes. The QA hunt on
lists-badge-sync read this as a rendering bug (QA-002, "an item vanishes"); a hand repro on the
emulator showed the store, the order and the render are all correct — the item is there, only
covered and unreachable. This pitch makes the list give way to the keyboard and gives the device
check a way to scroll, so nothing else about the list changes.

Source: the committed shaping in `shapeup/list-above-keyboard/shaping/` (shaping.md, breadboard.md)
and the requirement registry `shapeup/list-above-keyboard/requirements.md`. Orient's recon for this
run (code surface, the keyboard-avoid spike, discovered-task seed, hill signal) fed this analysis
but is run-tier and not cited here by path.

## Boundaries

In: a keyboard-avoid setting applied above the list screen's `List` (window-wide on
`EntryAbility`'s `WindowStage`, or page-level on `ListPage`'s outer `Column`/`NavDestination` — the
concrete API is `⏳ TBD`, decided at Wire/Build against the SDK's own `.d.ts`, not guessed here);
the `List`'s existing `.layoutWeight(1)` shrinking for free once the container above it shrinks; a
new `swipe id "<node>" up|down` step in `scripts/ui-flow.sh`; device flows proving R1–R4 on the
attached emulator, built on reachability (a target node becomes findable/tappable after a swipe),
never on a resize signal read off `uitest dumpLayout` bounds (the spike's own finding: `dumpLayout`
does not model the keyboard as an occlusion or a bounds change).

Out (No-goes, frozen by the pitch): any change to how items are sorted, added, toggled or deleted;
a custom keyboard or auto-hiding the keyboard after ADD; any change to the MY LISTS screen beyond
what R3 (unchanged-when-closed) already requires; scrolling the new item into view (it already
lands at the top of the open items); the Done-key-on-empty-field message (seen during the repro,
explicitly not this pitch per the pitch's Rabbit Holes); widening the device-check permission
grant beyond what `scripts/ui-flow.sh` already has.

## Document map

| Document | What |
|---|---|
| [[domain-model]] | no new aggregate or repository — the one setting this pitch adds, where it can live, and why the choice is left open to Wire/Build |
| [[ux-behavior]] | Screens P2 (List) and P3 (List-name dialog) — what changes (space above the keyboard) and what stays exactly as it is today |
| [[UC-01]] | Every item stays reachable while the keyboard is up, on both the list screen and its dialogs |
| [[integration]] | The one in-process seam (window/page → List), the `ui-flow.sh` `swipe` addition, and the device-flow proof shape |
| [[synthesis]] | traceability, risk register, dependency graph |
| [[feedback]] | PO / TL feedback template |
