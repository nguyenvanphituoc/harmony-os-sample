---
schema_version: 1
feature: retro-todo
entry_point: app/entry/src/main/ets/entryability/EntryAbility.ets
---

# Wiring map — retro-todo

Chain: EntryAbility.onWindowStageCreate loads pages/Index, Index assembles TodoModule once, TodoModule hands the use cases to the ViewModels, and the screens are built inside Index's Navigation. No routerMap, route_map.json or module.json5 change (pitch RH1); the List route is a builder route table inside Index.

## Wiring

| use_case | engine | wiring_seam | entry_call_site | affordance |
|---|---|---|---|---|
| UC-01 | app/entry/src/main/ets/features/todo/domain/CreateList.ts | TodoModule constructs it with the repository; ListNameForm.submit (N20) calls it | EntryAbility.ets loads pages/Index, which assembles TodoModule | U1 + NEW LIST (P1) opens P3; U19 SAVE |
| UC-02 | app/entry/src/main/ets/features/todo/domain/RenameList.ts | TodoModule constructs it; ListNameForm.submit (N20) calls it in rename mode | EntryAbility.ets loads pages/Index, which assembles TodoModule | U4 rename (P1) opens P3; U19 SAVE |
| UC-03 | app/entry/src/main/ets/features/todo/domain/DeleteList.ts | TodoModule constructs it; ListsViewModel.onDelete calls it on P4 DELETE | EntryAbility.ets loads pages/Index, which assembles TodoModule | U5 delete (P1) then U22 DELETE (P4) |
| UC-04 | app/entry/src/main/ets/features/todo/domain/AddItem.ts | TodoModule constructs it; ListViewModel.onAdd calls it | EntryAbility.ets loads pages/Index, which assembles TodoModule | U9 field and U10 ADD (P2) |
| UC-05 | app/entry/src/main/ets/features/todo/domain/ToggleItem.ts | TodoModule constructs it; ListViewModel.onToggle calls it | EntryAbility.ets loads pages/Index, which assembles TodoModule | U13 item card tap (P2) |
| UC-06 | app/entry/src/main/ets/features/todo/domain/DeleteItem.ts | TodoModule constructs it; ListViewModel.onDeleteItem calls it on P4 DELETE | EntryAbility.ets loads pages/Index, which assembles TodoModule | U14 delete (P2) then U22 DELETE (P4) |
| UC-07 | app/entry/src/main/ets/features/todo/domain/InMemoryTodoRepository.ts | TodoModule builds the repository and runs seed() on cold start; ListsViewModel cards and status computeds read the store | EntryAbility.ets loads pages/Index, which is the root content P1 | U2 list card, U6 empty invite (P1) |
| UC-08 | app/entry/src/main/ets/features/todo/domain/ItemOrder.ts | ListViewModel.items computed sorts through ItemOrder.sort; Index builder route table pushes List with the list id | EntryAbility.ets loads pages/Index, whose Navigation route table registers List | U3 card tap (P1) to P2; U12 item card, U15 empty invite (P2) |

## Deviations

- The spec names no engine files beyond "plain .ts under features/todo/domain"; the file names above are inferred one per use case and are design intent for the scope cut.
- UC-07 and UC-08 have no use-case class of their own in the breadboard (N14, N15, N21-N23 are ViewModel computeds), so their engines are the repository and ItemOrder they read through.
- Keep the List route as a builder route table inside pages/Index.ets. Creating route_map.json would arm rule L6 and need a module.json5 change the pitch forbids.
- pages/Index.ets is currently the template Hello World; the seam to TodoModule does not exist yet and the build must create it, or every engine above is orphaned.
