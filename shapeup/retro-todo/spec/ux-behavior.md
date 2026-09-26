---
type: ux-behavior
feature: retro-todo
---

# UX Behavior — retro-todo

One screen per breadboard Place with UI affordances (P1–P4). P5 (App runtime) is non-UI and is specified
in [[integration]]. Every screen follows the four-state contract: `@Computed status` (Loading, Empty,
Ready, Error) rendered through `AsyncBoundary`; Loading lasts one frame; the Error branch exists and has
no trigger (in-memory data cannot fail). Returning to a screen refreshes it in place. All strings are
English and come from `resources/base`. Style: neo-brutalist retro, defined once in the kit
(`background` `surface` `surfaceDone` `ink` `inkMuted` `brand` `danger` `onDanger`).

## Screen: Lists (P1)

Root screen. Title "MY LISTS". Use cases: [[UC-07]], [[UC-01]], [[UC-02]], [[UC-03]].

| State | What the user sees | Source |
|---|---|---|
| Loading | first frame only, no content | N15 |
| Empty | U6: "No lists yet" + "CREATE YOUR FIRST LIST" | N15 |
| Ready | U2 list cards, newest-created first | N14, S1, S2 |
| Error | branch exists, no trigger | N15 |

| ID | Affordance | Behavior |
|---|---|---|
| U1 | "+ NEW LIST" primary button | tap -> `onNew` (N16) opens P3 in Create mode |
| U2 | list card: name + progress ("1/3 done"; "No items" when empty) | rendered from `cards` (N14) |
| U3 | card body | tap -> `onOpen(listId)` (N17) pushes route `List` (P2) |
| U4 | ✎ rename icon button | tap -> `onRename` (N18) opens P3 in Rename mode |
| U5 | ✕ delete icon button | tap -> `onDelete` (N19) opens P4 |
| U6 | empty invitation | tap "CREATE YOUR FIRST LIST" -> `onNew` (N16) |

Error cases: none reachable. Icon buttons are separate from the card body so a tap on ✎ or ✕ never opens
the list.

## Screen: List (P2)

Route `List`, parameter `listId`. Use cases: [[UC-08]], [[UC-04]], [[UC-05]], [[UC-06]].

| State | What the user sees | Source |
|---|---|---|
| Loading | first frame only | N23 |
| Empty | U15: "No items yet" + "Add your first item above" | N23 |
| Ready | U12 item cards in `ItemOrder` (N5, N22) | S2 |
| Error | branch exists, no trigger | N23 |

| ID | Affordance | Behavior |
|---|---|---|
| U7 | ← back icon button (system Back does the same) | tap -> `onBack` (N27) pops to P1 |
| U8 | the list's name as the title | from `title` (N21) |
| U9 | new-item field; keyboard submit adds too | submit -> `onAdd` (N24) |
| U10 | "ADD" primary button | tap -> `onAdd` (N24) |
| U11 | field error "Title can't be empty" | shown when `AddItem` returns `ITEM_TITLE_EMPTY`; the typed text stays |
| U12 | item card + check box. Open: `ink` text on `surface`, empty box. Done: struck through in `inkMuted` on `surfaceDone`, checked box (`brand` fill, `ink` check) | rendered from `items` (N22) |
| U13 | item card body (box + title) | tap anywhere on the card -> `onToggle` (N25); the move is instant |
| U14 | ✕ delete icon button | tap -> `onDeleteItem` (N26) opens P4; never toggles |
| U15 | empty invitation | shown when the list has no items |

Repeat keys cover every field a card draws: an item card is keyed on id + title + done.

## Screen: List Name Dialog (P3)

Modal card-framed dialog opened by a ViewModel through the captured `UIContext`; a form, always Ready.
Use cases: [[UC-01]], [[UC-02]].

| ID | Affordance | Behavior |
|---|---|---|
| U16 | title "NEW LIST" or "RENAME LIST" | set by the opener (N16, N18) |
| U17 | name field, pre-filled when renaming | typing feeds `submit` (N20) |
| U18 | field error "Name can't be empty" | shown when `submit` returns `LIST_NAME_EMPTY`; the dialog stays open |
| U19 | "SAVE" primary button | tap -> `ListNameForm.submit()` (N20); `Ok` closes the dialog |
| U20 | "CANCEL" button | closes the dialog, back to P1, nothing changes |

Dark-mode note: with the system in dark mode the dialog and its text field stay light (light mode is pinned).

## Screen: Confirm Delete Dialog (P4)

Modal card-framed dialog for both deletions. Use cases: [[UC-03]], [[UC-06]].

| ID | Affordance | Behavior |
|---|---|---|
| U21 | message `Delete "<list>" and its <n> items?` (plural resource) or `Delete "<item>"?` | opened by N19 or N26 |
| U22 | "DELETE" danger button (`danger` fill, `onDanger` label) | confirms the pending delete: N19 -> `DeleteList` (N8) or N26 -> `DeleteItem` (N11) |
| U23 | "CANCEL" button | closes the dialog, back to P1 or P2, nothing deleted |

## Visual rules (all screens)

- Cream ground; white cards with a 2vp ink border and a hard ink shadow offset 4vp down-right, drawn as a `Stack` over a solid ink block (a `.shadow` radius 0 draws nothing).
- Every list and every item is its own card. A pressed button or card face shifts onto its shadow.
- System font, bold, uppercase headings and button labels; no bundled font.
- Contrast: text at least 4.5:1 (done text `inkMuted` on `surfaceDone` is 6.26:1), card borders and the check control at least 3:1.
- Light palette only, no dark resources, English only, no locale qualifier.
