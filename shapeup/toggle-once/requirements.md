---
feature: "[[toggle-once]]"
status: registry
---

# Requirements Registry — toggle-once

One atomic clause per row. REQ-ids are assigned once and frozen; a clause already carrying an
R-id in the source keeps that number.

| REQ-id | Clause | Source | Status | Note |
|---|---|---|---|---|
| REQ-1 | One double-tap on an open item's row marks that item done and changes no other item. | shaping.md R1 | covered | |
| REQ-2 | One double-tap on a done item's row marks that item open and changes no other item. | shaping.md R2 | covered | |
| REQ-3 | Two deliberate taps on two different rows, at a normal pace, toggle both items (the fix does not swallow real taps). | shaping.md R3 | covered | |
| REQ-4 | Done items still sink to the bottom and open items still stay on top, as retro-todo's UC-05 requires. | shaping.md R4 | covered | |
| REQ-5 | The device check language can express a double-tap on a row, so R1 and R2 are graded on the emulator and not only in a unit test. | shaping.md R5 | covered | |
