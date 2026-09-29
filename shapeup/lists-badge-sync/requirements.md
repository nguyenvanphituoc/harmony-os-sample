# Lists Badge Sync — Requirements Registry

One atomic clause per row, extracted from the shaped pitch. `REQ-<n>` ids are assigned once and
frozen; the `source` cell is the only field that survives a re-run.

| REQ-id | clause | source | status | note |
|---|---|---|---|---|
| REQ-1 | After toggling an item inside a list and going back, that list's card in MY LISTS shows the new done count. | shaping.md R1 | covered | |
| REQ-2 | After adding an item to a list, that list's card in MY LISTS shows the new total. | shaping.md R2 (split 1/2) | covered | |
| REQ-3 | Renaming a list still updates its card's name in MY LISTS. | shaping.md R3 (split 1/2) | covered | |
| REQ-4 | The device flow (the repro: toggle an item, go back, expect the card's done count to match) is committed as a Test Surface flow and passes. | shaping.md R4 | covered | |
| REQ-5 | After deleting an item from a list, that list's card in MY LISTS shows the new done count, the new total, or both, as applicable. | shaping.md R2 (split 2/2) | covered | |
| REQ-6 | Renaming a list does not change the order of the cards in MY LISTS. | shaping.md R3 (split 2/2) | covered | |
