# Harness mechanism defects — Betting Table raw ideas

Defects in the harness itself, not guidance for any worker skill. Nothing here steers a skill;
each entry is a raw idea for the Betting Table to shape or discard. Filed per AGENTS.md
("Mechanism defects file to `knowledge-base/harness-defects.md` as Betting Table raw ideas, never
worker steering").

---

## HD-1 — Two harness rules collide, and the collision hard-aborts a run at L1b

**Observed:** run `find-my-todos-20260921T142815Z-b80de580`, 2026-09-21, unattended lane.
ORIENT, ANALYZE, WIRE and MAP SCOPES all completed — 25 agent dispatches, ~28 minutes, ~1.17M
subagent tokens — and the run then aborted at GATE L1b on a single `TIER-DIRECTION` red:

```
shapeup/find-my-todos/requirements.md:8 points into .shapeup/ — a committed file cannot
reference the gitignored tier; the path dangles on every other clone.
```

The offending line was one sentence of provenance prose: *"Atomic requirement clauses extracted
from `.shapeup/find-my-todos/intake.md`."*

**The collision.** Two rules are individually correct and jointly unsatisfiable by a worker that
follows both naively:

1. `harness init run` normalizes the pitch into the **gitignored** run tier at
   `.shapeup/<slug>/intake.md`, and that is the path `ba-pitch-analyzer` is handed and actually
   reads.
2. `requirements.md` is a **committed** artifact, and spec-lint's `TIER-DIRECTION` rule forbids a
   committed file from carrying a `.shapeup/` path.

So the worker is asked to cite its source, is given only a gitignored path to cite, and is then
hard-stopped for citing it. Citing the source accurately is the defect.

**Why this is worth a bet rather than a knowledge-base rule for `ba-pitch-analyzer`.** A rule
telling the analyzer "never write a `.shapeup/` path into a committed file" would suppress this
instance, but the analyzer would still have no *correct* path to name — it does not necessarily
know which committed artifact the intake was copied from (it could be `shaping.md`, a `pitch.md`,
or a `--breadboard`-named file elsewhere). The fix belongs upstream of the worker, not in
guidance to it.

**Candidate shapes, unranked:**

- Have `init run` record the committed provenance path in the run receipt, and hand workers
  *both* — the readable gitignored copy and the citable committed original.
- Have spec-lint's `TIER-DIRECTION` rule auto-rewrite a `.shapeup/<slug>/intake.md` reference to
  the receipt's `intake_file`, since the mapping is known and unambiguous.
- Downgrade `TIER-DIRECTION` to `warn` when the dangling path is the intake specifically, and
  keep it `red` for run artifacts (orders, results, T0 evidence) where no committed equivalent
  exists.

**The cost of the current behaviour, which is the part that argues for a bet:** the abort lands
*after* the whole planning stretch has been paid for, and on the unattended lane there is no human
present to spend ten seconds fixing a sentence. A CI run would report `aborted` having built
nothing, with ~1.17M tokens spent and a one-line prose defect as the cause.

**Disposition in this run:** the tech lead repaired line 8 to name the committed pitch and describe
the run tier without a path, re-linted to `red: 0`, and relaunched. No requirement, scope,
acceptance criterion or gate answer was changed — the repair was confined to provenance prose in a
file the harness had written minutes earlier.

---

## HD-2 — The inner circuit breaker trips on an attempt that was never dispatched

**Observed:** run `find-my-todos-20260922T020229Z-9036e2b6`, 2026-09-22, unattended lane,
`attempt_budget: 5`. The pipeline returned
`{"status":"gate_h","breaker":"inner","hammer_proposals":["find-my-todos-screen"],"green_scopes":[]}`
— the documented meaning of which is that the scope exhausted its per-scope T0 attempts. It had
not. The records say one attempt was spent, not five.

**The evidence, all of it append-only and run-scoped:**

| record | `r1-a1` | `r1-a2` |
|---|---|---|
| `orders/<id>.json` compiled | 02:10:49Z | 02:21:00Z |
| `receipts/dispatch.jsonl` | present, `dispatch_ok: true` | **absent** |
| `legs.jsonl`, `attested: true` | present, 894 341 ms | **absent** |
| `results/<id>.json` | present | **absent** |
| `t0/verdicts/` trial | `r1-a1-t1`, `r1-a1-t2` | `r1-a2-t1` at 02:22:50Z |

`r1-a2` was compiled and T0-verified at 02:21:00Z and 02:22:50Z — **both before `r1-a1` ingested
at 02:25:46Z**, i.e. while attempt 1 was still in flight. No worker was ever dispatched for it.
The attempt loop opened a second attempt against a scope whose first attempt had not returned,
graded the tree that attempt 1 was still writing, and counted the result against the budget.

**Why this is a mechanism defect and not a worker defect.** No worker skill did anything wrong:
`task-executor` ran once, was attested, and ingested normally. The second order has no worker
associated with it at all. The three channels the harness uses to attest work — the dispatch
receipt, the leg, the WorkResult — unanimously say attempt 2 never happened, while the two that
feed the breaker — the order set and the T0 verdict set — say it did. The breaker reads the
channels that can be written without a worker.

**What it cost here.** The run stopped at GATE H with `green_scopes: []` after one attempt, with
4 attempts and roughly 2.4 h of a 10 800 s wall-clock budget still unspent. `scope-hammer`'s
census independently caught the discrepancy and declined to treat it as exhaustion, which is the
only reason it surfaced at all — a census that trusted the breaker's own framing would have
reported a scope that had fought five times and lost.

**Candidate shapes, unranked:**

- Gate attempt *n+1*'s compile on attempt *n*'s ingest, so an attempt cannot open while its
  predecessor is in flight.
- Count an attempt against the budget only when it has an attested leg, not when it has an order
  — make the budget read the same channel the receipt invariant already trusts.
- Have T0 refuse to grade a scope that has a live unanswered order, the way EVAL refuses a round
  whose build gate is red: a trial over a tree another attempt is still writing is evidence about
  nothing.
- Make the `gate_h` return distinguish "budget exhausted" from "the loop stopped for another
  reason", so the census is not handed a claim the records contradict.

**Left open deliberately:** the orphaned `r1-a2` order is still unanswered on disk. Per AGENTS.md
the substrate fence holds on an unanswered order for as long as the run pointer exists, and
`init run --force` is what writes the synthetic result that lifts it. That cleanup is a PO
decision here, not a tech-lead one, because it is entangled with whether this run is resumed or
re-cut.

### Recurrence — run `find-my-todos-20260922T150616Z-a61b921c`, 2026-09-22, plugin 3.7.1-rc.2

Reproduced a third time, and this one adds the fact the original filing could not: **`init run
--force` does not reset the channel the breaker counts.**

This run was opened `--force` precisely to discard the prior runs' history. It then spent exactly
**one** attested attempt — `r1-a1`, two T0 trials (`r1-a1-t3` 15:09:46Z, `r1-a1-t4` 15:11:52Z),
both `round 1 / attempt 1` — and never compiled an `r1-a2` order at all. It still returned
`{"status":"gate_h","breaker":"inner",…}`.

The kernel's own derived probe contradicts its own breaker:

```
harness probe attempts --slug find-my-todos --scope find-my-todos-screen --round 1 --attempt-budget 5
→ {"spent":1,"in_flight":0,"unattested":4,"green":false,"tripped":false}
```

`tripped: false`, from the same kernel, in the same tree, seconds after the run closed
`breaker=inner`. What `--force` *did* do is write the synthetic result that lifted the orphaned
`r1-a2` order (`results/find-my-todos-screen-r1-a2.json` → `{"synthetic": true, "status":
"abandoned", …}`), which is the documented behaviour and worked. What it did not do is clear the
cross-run accumulation in `t0/trials.jsonl` — whose `trial` field is a global sequence per scope
(this run's rows are trials 4 and 5 of 5) while the per-verdict `trial` field is a per-attempt
index (`r1-a1-t4.json` internally says `"trial": 4`). Two counters, same name, different bases.

This sharpens the second candidate shape above from "preferable" to "the fix": the budget must
read the attested channel — the one `probe attempts` already reads and already gets right. It
also adds a shape the original filing did not have: **`--force` should truncate or run-scope the
per-scope T0 trial ledger**, or the breaker should filter it by `run_id`, since a fresh cut that
inherits three prior runs' trials is not a fresh cut.

### Recurrence — run `about-screen-20260924T032732Z-7fe0bef6`, 2026-09-24, plugin 3.7.1, `--no-qa`, unattended/`ci`

Fourth occurrence, and the first where the missing channel is the ingest step itself rather than
a raced second order. `task-executor` ran attempt `r1-a1` once, wrote
`results/about-screen-r1-a1.json` with all 6 tasks `status: done` and cited
`./scripts/t0-assemble.sh → BUILD SUCCESSFUL` as evidence — but the result was never ingested:
`legs.jsonl` carries no row for `r1-a1`, and no T0 artifact exists anywhere under
`.shapeup/about-screen/`. The workflow's T0 confirm step, finding nothing to confirm, returned
`green:false, path:null`, and the run closed `escalated` with `breaker=inner` after that single
attempt — against a budget of 5.

```
harness probe attempts --slug about-screen --scope about-screen --round 1 --attempt-budget 5
→ {"spent":1,"in_flight":0,"unattested":4,"green":false,"tripped":false,
   "attempts":[{"attempt":1,"hasReceipt":true,"hasResult":true,"hasLeg":false,"state":"spent"}, …]}
```

`tripped: false`, same as both prior recurrences — the kernel's own derivation disagrees with the
label the run closed under. What's new here: attempt 1 is not orphaned or raced (`hasReceipt` and
`hasResult` are both `true`, and the worker's own account is a clean pass) — the single missing
attestation is the leg row the ingest step writes. Whatever classified this close as `inner` is
reading a channel that never got written because ingest itself never ran, not because the worker
failed five times or even once. `scope-hammer`'s census (this filing) again caught it via `probe
attempts` before treating it as exhaustion — the fourth time this exact catch was needed, not the
first.

**Sharpens which candidate shape actually covers this:** the second candidate above ("count an
attempt against the budget only when it has an attested leg") would have prevented the false trip
here specifically, since `hasLeg: false` is exactly what marks this attempt as unattested for
budget purposes. It does not by itself explain why ingest never ran at all for a result that
exists and reports success — that half is still open.

---

## HD-3 — The ship report the harness writes is illegal under the harness's own lint, and committing it bricks the slug

**Observed:** run `find-my-todos-20260922T020229Z-9036e2b6`, 2026-09-22, unattended lane, launch 3
(resume). The pipeline fast-forwarded ORIENT/ANALYZE/WIRE/MAP-SCOPES correctly — no planning was
re-dispatched, 12 agents, 80 s, ~403 k subagent tokens — crossed L1a and L1a.5, and then aborted:

```
{"status":"aborted","aborted_at":"L1b",
 "reason":"spec-lint reported red findings before BUILD … (23 red TIER-DIRECTION findings
           about board ids cited in a committed file)"}
```

All 23 reds are in **one file, `shapeup/find-my-todos/REPORT.md`** — `type: ship-report`, the
artifact `harness reduce ship` writes and GATE L4 freezes. One red on line 27, twenty-two on lines
48–69. The rule text is the same for every one of them:

```
shapeup/find-my-todos/REPORT.md:57 names TASK-001 — a committed file cannot carry a board id.
Boards live in .shapeup/ (gitignored) and renumber on every regeneration, so this resolves on
the machine that wrote it and nowhere else. Cite the use case or the scope_id, which are stable.
```

**Why this is not HD-1 with a different filename.** HD-1's offender was one sentence of prose a
human could rewrite in ten seconds; the worker had a correct alternative available and simply did
not pick it. Here the generator has **no legal output**:

- Line 27 is the report's "4 task(s) did not finish" callout. Naming which tasks did not finish is
  the callout's entire content.
- Lines 48–69 are the Requirements projection, whose `covering AC` column is specified by AGENTS.md
  as `REQ → AC → criterion → verdict`. In this spec the AC ids *are* board ids (`TASK-004: Screen
  renders 'loading' on first mount … (covers: REQ-1)`). The rule says to cite the use case or
  `scope_id` instead — but neither identifies *which acceptance criterion* graded the requirement,
  which is the column's only job. There is one scope here, so `scope_id` would make all 22 rows
  identical.

So `reduce ship` cannot emit a conforming report, and `verify spec` cannot accept a conforming one.
Two harness components disagree by construction, not by accident.

**The part that makes it worse than a failed run: it is persistent and it is contagious.**
`REPORT.md` is a committed artifact. It was written by launch 2's `gate_h` close and committed in
`6e4de89`. `verify spec` was re-run standalone here, outside any run context, and still returns
`red: 23` — the verdict is a pure function of the committed tree, not of run state. Therefore:

- Every future run of this slug aborts at L1b, including a deliberate `init run --force` fresh cut.
- The block survives deleting `.shapeup/`, because the offender is in the committed tier.
- A slug is bricked by the act of shipping it and committing the receipt — i.e. by doing the
  documented thing.

This is the failure mode with the worst shape of the three: HD-1 cost a planning stretch, HD-2 cost
four attempts and 2.4 h of budget, HD-3 costs *every subsequent run of the slug* until a human
edits a frozen run record.

**Second-order observation, minor but worth a line.** The abort reason reached the operator as
`Command ran and exited with code 1; output was JSON without a top-level "decision" key`. That is
the gate adapter describing its own disappointment, not the defect. The 23 findings were only
legible after running `verify spec` by hand. A red lint is a normal, expected gate outcome and
should surface as `spec-lint red: 23 findings in REPORT.md`, not as a shape complaint about the
envelope.

**Candidate shapes, unranked:**

- Exclude `type: ship-report` from `TIER-DIRECTION` entirely. A ship report is a *record of a run*,
  not a spec input; it is supposed to name run-tier things, and nothing downstream resolves ids by
  reading it.
- Scope the lint to the artifacts it actually governs (`requirements.md`, `spec/`, `scopes/`,
  `wiring-map.md`) rather than globbing the committed slug folder, so harness-generated records are
  structurally out of range.
- Have `reduce ship` emit a stable dual id for each AC — `find-my-todos-screen / UC-SearchTodos /
  AC-3` alongside the board id — and have the lint accept a board id that appears beside one.
- Make the lint's red conditional on the id being *resolvable-and-wrong* rather than merely present:
  a board id inside a frozen record of the run that produced it dangles for no one.

**Disposition in this run: none — deliberately.** No repair was applied. Unlike HD-1, the offending
lines are not prose a worker chose badly; rewriting them would falsify a frozen ship report, and
`reduce ship` would reproduce them on the next ship anyway. Whether to delete `REPORT.md`, rewrite
it, or change the rule is a Betting Table decision, and it blocks the 3.7.0 comparison this launch
was opened to run.

**Status on 3.7.1-rc.2 — does not reproduce.** Run
`find-my-todos-20260922T150616Z-a61b921c`, 2026-09-22, opened fresh (not resumed) on 3.7.1-rc.2,
crossed L1b without a spec-lint red and reached BUILD and T0 — the first run of this slug to do
so. After that run's `gate_h` close, `harness reduce ship` regenerated `REPORT.md` and
`harness verify spec --slug find-my-todos` returned `{"red": 0, "warn": 0, "findings": []}`.
The regenerated report anchors its unfinished-work callout on use cases
(`use cases: UC-SearchTodos, UC-ViewTodoList, UC-ToggleTodo`) rather than board ids, which is
exactly the third candidate shape above. The slug is no longer bricked by shipping it.
Whether the fix landed in the generator, the lint, or both is not determined here — only that
the generator/lint pair no longer disagree by construction on this spec.

**Experiment note — this launch measured nothing about 3.7.0.** The receipt pins
`plugin.version: 3.6.0` / `pluginRoot: …/3.6.0`; the session loaded 3.6.0; and
`.shapeup/workflows/shapeup-run.js` is the copy staged when the run opened, because `init run`
re-stages only on open and correctly refused as already-open. Per AGENTS.md a run in flight keeps
the copy it started with. A resume therefore holds the plugin version fixed by design — the one
variable this run existed to change is the one a resume cannot change. Testing 3.7.0 needs a fresh
run, which HD-3 currently blocks.

---

## HD-4 — A fixture the sandbox refuses to run is recorded as a fixture that failed

**Observed:** run `find-my-todos-20260922T150616Z-a61b921c`, 2026-09-22, unattended lane,
plugin 3.7.1-rc.2. Both of `find-my-todos-screen`'s `e2e_verification_fixtures` shell out to
DevEco's `hvigorw` by absolute path. Every trial recorded `exit: 1, pass: false` on both
fixtures — `fixtures_passed: 0/2`, `overall: "red"`. The build was never attempted.

**The evidence that this is a denial, not a red build:**

| | |
|---|---|
| This run's trials (`r1-a1-t3`, `r1-a1-t4`) | `exit: 1`, **`digest: []`** |
| Trial `r1-a1-t1` (2026-09-21, run `b80de580`) | `exit: 1`, digest with 8 stack frames rooted at `app/build-src/enforce/index.ts:35` ← `app/hvigorfile.ts:11` |

Same extractor, same fixture, same tree layout: a *genuine* failure produces diagnostic content.
Three consecutive trials produced none, because nothing ran. The `task-executor` established the
cause directly and recorded it in its own WorkResult (`results/find-my-todos-screen-r1-a1.json`,
`deviations`): `env DEVECO_SDK_HOME=… hvigorw --version`, alone and unchained, was refused with
**"This command requires approval"**. The session's grant (`.claude/settings.json`) is three
rules — `Bash(node "*/kernel/harness.mjs" *)`, its bare variant, and `Workflow`. `hvigorw` is
outside all three. The tech lead hit the same denial independently on `hdc list targets` and on a
`python3` heredoc during the same run.

**Why this is a mechanism defect and not a worker defect.** The worker behaved exactly as it
should: it re-audited the tree statically against every enforce rule, found no violation, declined
to invent a fix for a signal it could not read, reported every unobservable acceptance criterion
`fail` rather than assuming `pass`, and escalated naming the one thing that would unblock it
("human/CI access to a raw `hvigorw` log"). The harness then scored that dispatch `0/2` with
`delta: "no change"`, so the seesaw reverted it, and the attempt loop had nothing to converge on.

**What it cost, and the part that argues for a bet.** A denial and a failure are the same signal
downstream, so everything reading that signal draws a false conclusion:

- `scope-hammer`'s baseline comparison concluded "the working tree **does not assemble** — worse
  than baseline", which no artifact on disk establishes. The tree may well assemble; nobody asked it.
- The hill phase, the `REPORT.md` T0 column (`0/2`), and the run's whole verdict channel inherit
  the same unfounded reading.
- AGENTS.md already anticipates the *layer* ("the grant covers the run's own deterministic entry
  points, not any command a worker reaches for beyond the grant's own exact shape") but the
  harness has no runtime expression of it — the run discovers it by spending a build round.

**Candidate shapes, unranked:**

- Give `verify t0` a third fixture state. `pass` / `fail` / **`blocked`**, where `blocked` means
  the command did not execute. A `blocked` fixture is an environment gap, not a code defect: it
  should not score, should not move the hill, and should not feed the seesaw's revert decision.
- Treat "non-zero exit with empty captured output" as `inconclusive` rather than `fail`. Cheap,
  needs no new plumbing, and would have caught all three trials here.
- **Preflight the fixtures at L0.** Every `e2e_verification_fixture` is on disk in the scope
  contract before the run opens, and so is the permission grant. Probe each fixture's binary once
  (`--version`, or a dry `command -v`) at GATE L0 and refuse the run there — "fixture command not
  executable in this session" — instead of after N attempts and a `gate_h` census.
- Have `init run` diff the commands named in `scopes/*.md` against `permissions.allow` and warn in
  the L0 block when a fixture names a binary no rule covers.

---

## HD-5 — `reduce ship` does not retire the run pointer on a no-verdict close

**Observed:** same run. AGENTS.md states the pointer is "the one lever every close needs pulled,
and `reduce ship` pulls it for you". After `harness reduce ship --slug find-my-todos` wrote
`shapeup/find-my-todos/REPORT.md`, `.shapeup/active-scope` was still on disk, still naming this
run (`started_at: 2026-09-22T15:06:16.731Z`).

**Why it may be deliberate, and why it still needs a decision.** This close had `verdict: ~` —
GATE H returned CANNOT SHIP, so nothing shipped. It is defensible that a no-verdict close leaves
the pointer standing. But AGENTS.md draws the line at *ship close* vs *any other close* and says a
ship close retires it; here a `reduce ship` ran to completion and did not. So either the
documentation over-promises or the code under-delivers, and an operator cannot tell which from
the outside.

**What it costs:** the next `init run` on this slug exits 3 and needs `--force` — which, per HD-2's
recurrence note, is itself not a clean reset. The two defects compound: the pointer forces
`--force`, and `--force` does not clear the breaker's channel.

**Candidate shapes, unranked:**

- Have `reduce ship` retire the pointer unconditionally and say so in its output (it currently
  prints only the report path).
- Or document the no-verdict close as pointer-preserving, and give it a named lever
  (`harness reduce close --escalated`) so an operator is never left hand-deleting a pointer.
- Either way, have `reduce ship` print what it did to the pointer, so the close is auditable
  without an `ls`.

**Disposition in this run: none.** The pointer was left exactly as the harness left it. Removing
it by hand is the failure mode AGENTS.md warns against, and the operator asked for documented
levers only.

**Recurrence — run `find-my-todos-20260922T184150Z-25eb5e83`, 2026-09-22, unattended lane.**
Reproduced unchanged, and on a close with *no unanswered orders* (every compiled order had a
result; `pending_orders` was empty), which removes the one explanation that would have made the
behaviour defensible. `harness reduce ship --slug find-my-todos` printed only
`shapeup/find-my-todos/REPORT.md` and left `.shapeup/active-scope` on disk naming this run
(`started_at: 2026-09-22T18:41:50.250Z`). So the pointer survives a `reduce ship` even when there
is nothing outstanding for it to be protecting — the next `init run` on this slug will exit 3 and
demand `--force`, which per HD-2 is not a clean reset. This second sighting narrows the ambiguity
the first one recorded: it is not "a no-verdict close preserves the pointer deliberately", because
a close with a full order set does it too. Disposition again: none — pointer untouched.

---

## HD-6 — L1b's abort message welds "I could not parse a gate decision" onto "there is a red finding"

**Observed:** run `find-my-todos-20260922T180547Z-8889fb08`, both launches, aborted at L1b. The
returned `reason` read:

```
spec-lint reported red findings before BUILD: Command ran and exited 1; output was JSON with
no top-level "decision" or "export_warning" key (had slug/scopes/tasks/red/warn/findings),
reporting one red TIER-DIRECTION finding.
```

The *outcome* was correct both times — the lint was genuinely red and a red spec-lint at L1b is a
documented hard stop. The message is the defect. The gate resolver looked for a `decision` /
`export_warning` key, and `harness verify spec` does not emit one: its contract is
`{slug, scopes, tasks, red, warn, findings}`. So the resolver fell through a parse-failure branch
and then appended a findings summary, producing one sentence that asserts two unrelated things.

**What it costs:** the parse-failure clause is load-bearing noise. If `verify spec` ever exits
non-zero for a reason that is *not* a red finding — a crash, an unreadable artifact, a bad slug —
this same path will still say "spec-lint reported red findings", and an operator will go hunting
for findings that do not exist. The one case where the message matters most is the case where it
is wrong.

**Candidate shapes, unranked:**

- Teach the resolver `verify spec`'s actual output shape, so the red-findings branch is reached on
  purpose rather than as a fallthrough.
- Or have `verify spec` emit a top-level `decision` like every other gate-resolving command, and
  keep one contract across the gate surface.
- Either way, keep "could not parse this command's output" and "this command reported N reds" as
  two distinct, separately-reported outcomes.

**Disposition in this run: none.** Reported only; nothing in the resolver was touched.

---

## HD-7 — a pitch's No-gos become registered requirements, and L1b then demands they be covered

**Observed:** same run, second launch, aborted at L1b on 7 red `REQ-UNCOVERED` findings. The 7 are
exactly `REQ-23` … `REQ-29`, and every one of them is a clause from the pitch's **No-gos** section:
"No persistence", "No sort, no filter-by-done, no sections", "No match highlighting", "No debounce
or async search", and so on.

AGENTS.md's L1b rule is that a registered requirement which no AC grades **and** no scope claims is
red. The scope contract's `covers: [REQ-1 … REQ-22]` rescues the first 22. Nothing can rescue the
last 7 on the scope-claim path, because a no-go is *defined* by not being built — no scope will ever
legitimately claim one. That leaves the AC path (grade an absence) or `CUT (PO-approved)`.

**Why this is a mechanism question and not a plan defect.** The BA was not wrong to register the
No-gos: they are clauses of the pitch, they are atomic, and AGENTS.md says one row per pitch clause.
The scope architect was not wrong to leave them unclaimed. Both workers followed their contracts and
the result is a hard stop that only a PO can clear — in a lane (`--unattended`) whose entire purpose
is to run without one. The `ci` answer set cannot help: a red spec-lint is a hard stop, not a gate
the answer set crosses.

**Candidate shapes, unranked:**

- Give the registry a polarity — `kind: deliverable | constraint | no-go` — and scope L1b's
  coverage demand to deliverables. A no-go would then be gradeable *optionally* (as a negative AC)
  rather than red by default.
- Or have the BA emit No-go clauses pre-marked `CUT (PO-approved)` at registration time, with the
  pitch section as the approving authority, since the PO already approved the No-gos by betting on
  the pitch that contains them.
- Or leave the rule as-is and have GATE L0 refuse an unattended run whose registry contains rows no
  scope claims — failing at the gate that can still be answered cheaply, rather than 9 minutes into
  a pipeline.

**Adjacent finding, filed here because it was found by the same probe — a committed artifact
attests to a coverage state that does not exist.** `shapeup/find-my-todos/spec/synthesis.md`
claims, at line 32 and again at line 82, that "every registered REQ-id (REQ-1..22) reaches an AC
carrying `(covers: REQ-…)`" and that `harness verify spec` reports 0 REQ-UNCOVERED. Neither holds:
the registry has 29 rows, not 22 (the No-gos were appended after synthesis.md was written — file
mtimes 21:58 vs 21:46, ids correctly frozen and not renumbered), and a grep for `covers:` across
the whole spec folder returns **only those two self-referential claim lines** — not one acceptance
criterion anywhere carries the clause. `harness verify trace` independently reports `0/29 covered`.
The synthesis step's own "Coverage 🟢" sign-off is therefore self-attested rather than derived,
which is the exact failure mode the "requirements matrix is a projection, never a verdict"
invariant exists to prevent. Worth asking whether synthesis may assert coverage at all, or whether
that cell must be filled by the oracle.

**Disposition in this run: none.** No clause was marked `CUT (PO-approved)` and no AC was edited —
both are PO decisions, and this session had no PO to give one.

**Recurrence of the adjacent finding — run `find-my-todos-20260922T184150Z-25eb5e83`.** The PO has
since marked `REQ-23`…`REQ-29` `CUT (PO-approved)`, which clears the L1b hard stop (that run
crossed L1b clean: red 0, warn 0). The `covers:` gap it flagged is **not** cleared: the frozen
report's requirements table shows an empty `covering AC` cell for all 22 live clauses, and
`probe requirements` reports `0/29 PASS · 7 CUT (PO) · 22 no evidence`. The cut fixed the lint; it
did not populate the join. Consequence worth stating: on this spec the requirements matrix could
not have credited a single clause even if the build had compiled, so the two failures are
independent and only one of them has been addressed.

---

## HD-8 — a stale hill dot outlives the evidence that set it, because the derivation can only move forward

**Observed:** run `find-my-todos-20260922T184150Z-25eb5e83`, 2026-09-22, unattended lane, opened
deliberately on a fresh state (the gitignored run tier deleted, the committed planning tier kept).

The committed shard `shapeup/find-my-todos/hill/find-my-todos-screen.yml` reads:

```yaml
scope_id: find-my-todos-screen
phase: UPHILL_SOLVED
```

It was written 2026-09-21 by an earlier run. This run produced **zero** green T0 trials — 2 trials,
both `0/2` fixtures, both `overall: red` — and issued no verdict at all. Re-deriving on purpose
does not correct it:

```
harness reduce hill --slug find-my-todos
→ [ { "scope_id": "find-my-todos-screen", "phase": "UPHILL_SOLVED", "changed": false } ]
```

Two committed artifacts disagree with the shard, in the same tier: the scope contract's own
frontmatter says `hill_phase: UPHILL_UNKNOWN`, and Orient's hill signal for this run calls the
`@Trace` re-render risk "unverified — not solved."

**Why this is the mechanism and not a worker.** Nothing self-reported the dot; `reduce hill` is the
only writer and it behaved as designed. The design is the problem: the derivation moves a dot
forward on green evidence and has **no path to move it back**, not even to `UNKNOWN`, when a run
has no evidence at all. A fresh-state run inherits the shard and cannot revise it — so "derived
only from T0/T1/seesaw artifacts" holds for each individual write while the committed value ends up
derived from a *previous* run's artifacts that no longer exist on disk. `changed: false` is
reported identically for "re-derived and confirmed" and "had nothing to derive from", which is the
part an operator cannot see through.

**What it costs.** The hill shards are the committed tier — they are what `/hill-chart` renders and
the only thing that survives after the gitignored run tier is cleaned up, including for a pitch
marked Archived. Here they tell a teammate the hardest part of this scope is solved, on a branch
where the feature has never once compiled. That is the precise claim the mechanical-hill invariant
exists to make impossible, arrived at without any worker ever overstating anything.

**Candidate shapes, unranked:**

- Stamp each shard with the `run_id` and trial hash that set it, and have `/hill-chart` mark a dot
  stale when the run that set it is not the run being rendered.
- Or let `reduce hill` demote to `UPHILL_UNKNOWN` when a run closes with no green trial for that
  scope, so absence of evidence reads as absence rather than as the last good news.
- Or make the scope contract's `hill_phase` and the shard one value with one writer, since two
  committed files currently disagree with no rule about which wins.
- Either way, have `reduce hill` distinguish "confirmed against this run's artifacts" from "no
  artifacts to derive from" instead of reporting `changed: false` for both.

**Disposition in this run: none.** The shard was not hand-edited — it is a derived artifact, and
authoring it by hand is the failure mode the invariant names. Reported only.

---

## HD-9 — the `ci` answer set signs off `L4 | ship` over a run that GATE H just declared CANNOT SHIP

**Observed:** same run, at close. GATE H's census returned **CANNOT SHIP** (the blocking defect is
unowned by every scope and outside the pitch). Resolving the ship gate immediately afterwards:

```
harness gate --resolve L4 --slug find-my-todos --preset ci --auto-level unattended
→ { "gate": "L4", "decision": "ship", "source": "preset:ci",
    "note": "Ship sign-off pre-approved. THIS is the one a reviewer should look at first…" }
```

So `.shapeup/<slug>/gates.jsonl` ends with `{"gate":"L4","decision":"ship"}` while
`harness-run.md` for the same run ends with `status: escalated`, `final_verdict: ~`, `deploy: ~`,
`close_cause: breaker=inner green_scopes=0 hammer_proposals=1`. Both are harness-written. Nothing
reconciles them, and the gate record is the one that reads like a conclusion.

**Why it is a mechanism question.** The preset is behaving as documented — AGENTS.md says a gate
resolves from the answer set and the ledger names the source, and it does. The gap is that the
answer set has no vocabulary for "cannot ship": `ci` carries one pre-recorded answer for L4 and
returns it without reference to the census verdict the gate is supposed to be signing off *on*. The
resolver never reads the hammer's output. An unattended run therefore cannot record a refusal to
ship, only a ship — which inverts the one gate the preset's own note calls the most audit-worthy.

**What it costs.** The failure mode AGENTS.md opens with — a run that "reads like a clean success"
— reached the gate ledger here, on a branch where nothing compiled. It took the run ledger, the
frozen report and the census to contradict a single line that a reviewer auditing gate decisions
would hit first, exactly as the note instructs them to.

**Candidate shapes, unranked:**

- Have L4's resolver take the GATE H verdict as an input and refuse to return `ship` over a
  `CANNOT SHIP` census, whatever the answer set says — a preset may answer a gate, not overrule a
  breaker.
- Or give the answer sets a `cannot-ship`/`escalate` answer for L4 and have the ci preset select it
  when the run's `final_verdict` is `~`.
- Or have `gate --resolve` refuse any gate whose run ledger is already `closed_status: escalated`,
  so a closed-escalated run cannot accrue a ship record at all.

**Disposition in this run: none.** The gate was resolved as the operator's `--gate-answers ci`
instructed, and the row stands as the harness wrote it. It was **not** treated as authority to
report a ship: the run is reported as escalated, and the frozen report records CANNOT SHIP.

---

## HD-10 — `compile` refuses attempt *n+1* as "unanswered" over an attempt every attested channel says came back

**Observed:** run `about-screen-20260924T175105Z-5c21bab4`, 2026-09-24, plugin 3.7.3, unattended/`ci`,
`--no-qa --max-rounds 1`, `attempt_budget: 5`. The pipeline returned
`{"status":"gate_h","breaker":"none","stalled":"no_green","green_scopes":[],"hammer_proposals":["about-screen"]}`
after **one** attempt, with four attempts of budget unspent and no stagnation observed.

This is the mirror image of HD-2. There, the loop opened attempt 2 over an attempt 1 that had not
returned and spent budget on nobody's work; 3.7.1 onward guards against that by refusing to compile
attempt *n+1* while attempt *n* is unanswered. Here that guard fired on an attempt that **had**
returned, and the refusal is what ended the round — not a breaker, not a verdict.

**The evidence, all append-only and run-scoped, all for `about-screen/about-screen-r1-a1`:**

| channel | state |
|---|---|
| `receipts/dispatch.jsonl` | row present, `dispatch_ok: true`, `skill_invoked: task-executor`, 17:58:50Z |
| `legs.jsonl` | row present, `attested: true`, ingested 18:03:10Z (260 537 ms) |
| `results/about-screen-r1-a1.json` | present, `status: done` |
| `t0/verdicts/r1-a1-t1.json` | present, `overall: red` (1/2 fixtures), trial `kept`, `delta: baseline` |
| `probe attempts` | `{"spent":1,"in_flight":0,"tripped":false,"attempts":[{"attempt":1,"hasReceipt":true,"hasResult":true,"hasLeg":true,"state":"spent"}, …]}` |
| `probe leg --round 1` | `{"closed":true,"orders_total":1,"results_total":1,"applied_total":1,"unapplied":[]}` |
| `harness compile --scope … --round 1 --attempt 2` | **exit 3**, three identical retries: *"…is unanswered: no dispatch receipt was ever written for it. Grading a tree the previous attempt may still be writing counts an attempt that never ran … Wait for it to return, or record its outcome, before opening the next one."* |

So the kernel's own `probe attempts` reads the receipt (`hasReceipt: true`) and `compile` says no
receipt was ever written — two readers of one channel, in one tree, seconds apart, disagreeing.
Note the first attempt's receipt was written under the same `order_id` the order file carries
(`about-screen/about-screen-r1-a1`), so this is not an id-format mismatch visible from outside.

**Why this is a mechanism defect and not a worker defect.** The build step did exactly what the
run's own instruction tells it — *"let it come back rather than opening the next one"* — and, with
no override flag named in its dispatched task, stopped rather than forcing progress. It reported
the contradiction verbatim instead of improvising, which is the behaviour to keep. The worker before
it (`task-executor`) ran once, was attested, and ingested normally.

**What it cost.** The T0 red that attempt 1 surfaced is a **baseline** defect — `./scripts/t0-test.sh`
fails on `app/entry/src/test/LocalUnit.test.ets:45,50` (`assertNotEqual` is not on hypium 1.0.25's
`Assert`), a file last touched in `86b41bf` (2026-09-21), before this pitch existed, outside the
scope's substrate. That is exactly the "unowned red fixture" a second attempt would have escalated
cleanly as `design-decision`, or that GATE H would have censused as "no scope owns X". Instead the
loop stopped with `breaker: none`, the round build gate and EVAL never ran (`rounds_used: 0`), and
the run closed `escalated` having graded nothing — the fifth consecutive run of this slug family
to end at GATE H with `green_scopes: []` for a reason the records do not support.

**What did work this time, and is worth recording as fixed:** the ingest leg was written (HD-2's
fourth recurrence was a missing leg — not reproduced on 3.7.3), the close exported its fact tables
to `.shapeup/exports/<run_id>/`, and `.shapeup/active-scope` was retired on the `gate_h` close
(HD-5 — not reproduced on 3.7.3).

**Candidate shapes, unranked:**

- Make `compile`'s unanswered-check read the same derivation `probe attempts` reads. Two readers of
  the receipt channel with two answers is the defect; one function with one answer is the fix.
- Have the refusal print *which* path it looked in and what it found, so an operator can tell a
  genuinely missing receipt from a reader looking in the wrong place.
- Distinguish the stall in the `RunReturn`: `stalled: "no_green"` is what the loop concluded, but
  the cause was `compile_refused`, and GATE H's census should be handed that fact rather than a
  green-count.
- Preserve HD-2's guard — it is correct — but let the leg row (`attested: true`) satisfy it on its
  own: a leg is only ever written by ingest, and ingest only runs over a result, so a leg is the
  strongest evidence the attempt came back.

**Disposition in this run:** reported only. The refusal was not overridden and no second attempt
was forced; the baseline test-tier red is handed to GATE H's census as an unowned item.

---

## HD-11 — L4 now demands a census artifact, and nothing in the plugin writes one

**Observed:** same run, at close, plugin 3.7.3. HD-9's fix landed: the `ci` preset can no longer
sign `L4 | ship` blind. Resolving L4 after the hammer's census returned:

```
harness gate --resolve L4 --slug about-screen --preset ci --auto-level unattended
→ exit 4 { "gate":"L4", "decision":"ask", "refused":"ship", "census": null,
   "reason": "GATE L4 cannot be answered \"ship\": scope-hammer has not run, so no census
   exists. An answer set chooses among the answers a gate allows; it cannot supply the evidence
   that makes one allowed. Put the block to the PO, or run the census first." }
```

`scope-hammer` **had** run — a full H0/H1/H2 census with a CANNOT SHIP verdict, returned as the
worker's report. The resolver is right that nothing on disk says so. The worker then established,
by probing rather than assuming, that nothing *can*: the scope-hammer skill names no artifact path
or schema for its census (it describes H0/H1/H2 as printed blocks and defers to "the report
artifact" of a WorkResult), `harness.mjs` has no `reduce hammer` or equivalent, and `gate --file`
is an alternate answer set, not a census input. GATE H itself resolved `accept-cut-list` from the
preset without reading any census either.

**Why it is a mechanism defect.** The gate asks for derived evidence and the plugin provides no
channel to derive it through. A worker that hand-authors a file at a guessed path would be
narrating the very evidence the refusal exists to demand — the worker declined, correctly. The net
effect is that HD-9's inversion has been replaced by its complement: a headless lane can never
record `L4 | ship`, only `ask`, whatever the census actually concluded. On this run the outcome
happens to match (the verdict was CANNOT SHIP), so nothing false was recorded — but the same
refusal would fire over a green census.

**Candidate shapes, unranked:**

- Give the hammer's dispatch a WorkResult-declared `artifacts` entry with a fixed schema
  (`census.json`: must-haves, cut list, verdict) and have `reduce ingest` place it where L4 reads.
- Or have L4 read the hammer's ingested WorkResult directly, since the receipt/leg channels already
  attest that scope-hammer ran — the same attested channels HD-10 asks `compile` to trust.
- Have GATE H's resolver require the same artifact, so H and L4 read one census rather than H
  accepting a cut list nobody wrote down.

**Disposition in this run:** no file was invented. L4 stands as `ask`, the run stays `escalated`
per its `gate_h` close, and the census is recorded in prose in the tech lead's close-out.

### Recurrence — run `about-screen-20260924T193808Z-6b9ab0f2`, 2026-09-24, plugin 3.7.4, `--no-qa`, unattended/`ci`, `--max-rounds 1`

Same refusal, stronger evidence about what the resolver does *not* read. This time the hammer was
dispatched twice, and the second dispatch used every attested channel the plugin has:

1. First as a standalone `--slug about-screen --breaker outer` call, the shape the tech-lead skill's
   Step 3 table spells out for a `gate_h` return. The worker compiled its own order
   (`compile --operation hammer` — a 3.7.4 addition; its substrate names `REPORT.md` and a
   `reports/**` folder under the run trace) and wrote its H0/H1/H2 census there. No dispatch
   receipt was recorded (the Skill call carried no `--order`), no WorkResult existed.
   `gate --resolve L4` → exit 4, `census: null`, "scope-hammer has not run".
2. Then as `Skill(scope-hammer) --order <the compiled hammer order>`: the hook appended an attested
   receipt row (`skill_invoked: scope-hammer`, `dispatch_ok: true`); a WorkResult validated only
   after two schema rejections (`$.verdict` is evaluator-shaped — `expected object`, then
   `"ship-now" not in enum [PASS, FAIL]` — so the hammer's verdict had to travel as a non-schema
   key beside `cut_list`); `reduce ingest --order …` exited 0 with
   `✓ attested: about-screen/hammer ran scope-hammer` and `✅ ingested about-screen/hammer`.
   `gate --resolve L4` again → exit 4, `census: null`, the identical reason text.

So the L4 census reader consults neither the receipt ledger, nor the ingested WorkResult, nor the
`reports/**` substrate that the hammer's own compiled order grants — the three channels the rest
of the runtime treats as the attested record. 3.7.4 added the `hammer` compile operation and its
substrate, which is half of candidate shape one above; the missing half is a WorkResult slot for a
hammer verdict (the schema has none) and a reader at L4 that looks where ingest writes. Until then
the headless outcome is fixed regardless of the census: `L4 | ask`, run `escalated`. On this run
the hammer's verdict was SHIP now (feature built, T0 green, ungraded on device), so for the first
time the refusal fired over a green census — the case the previous entry predicted.

**Disposition in this run:** as before — nothing invented, L4 recorded as `ask`, run stays
`escalated`, the census travels in prose (the frozen report and the tech lead's close-out).

## HD-12 — a committed spec fast-forwards ANALYZE, but the board it needs lives in the tier that does not survive

**Observed:** run `about-screen-20260924T193808Z-6b9ab0f2`, 2026-09-24, plugin 3.7.4 — the fourth
run of this pitch on this machine. `harness init run` opened a fresh run root under the gitignored
tier; `probe resume` reported `has_spec_tree: true` because the spec tree is committed, so the
workflow fast-forwarded ANALYZE ("spec tree already on disk") and dispatched no
`ba-pitch-analyzer`. The dispatch ledger for the run shows exactly three workers: orient,
task-executor, spec-evaluator. Nothing regenerated the board. Consequences, all recorded by the
runtime itself rather than narrated:

- GATE L2 ("Board 100% ✅ + T0-green") crossed `proceed` over a board with zero tasks — the frozen
  report prints `Board 0/0 tasks done`. A hundred percent of nothing crossed a gate whose whole
  question is whether the board is done.
- The evaluator's second escalation: "The per-machine board is not on disk, so no AC `covers:`
  clauses could be read. `traces_to` is left empty on every criterion rather than guessed."
- `probe requirements` therefore prints `0/11 PASS · 4 CUT (PO) · 7 no evidence` — and has
  printed it on every run of this pitch, including the ones whose static criteria all passed. The
  `REQ → AC → criterion → verdict` projection can never populate, because the join it needs
  (`covers:` on the board's acceptance criteria) is never on disk after the first run.

**Why it is a mechanism defect.** ANALYZE has two outputs in two tiers (ADR-0001): the spec tree,
committed, and the board, per-machine and gitignored. The fast-forward keys on the committed half
only, while GATE L2, the evaluator and the requirements projection read the per-machine half. Any
run after the first on a machine — and every run on a fresh checkout, which is the CI case the
unattended lane exists for — has a spec without a board. AGENTS.md says "a registry already on
disk is not re-dispatched", but that sentence is about `requirements.md`; nothing says the board
is optional, and the L2 gate's own wording assumes it exists. The worker was right not to invent
one: the board is ANALYZE's artifact, and a task-executor or evaluator that wrote one would be
authoring its own grader.

**Candidate shapes, unranked:**

- Fast-forward ANALYZE on both halves: `has_spec_tree && has_board`. A committed spec with no
  board dispatches `ba-pitch-analyzer` in a board-only mode (`--tasks-only` already exists for the
  discovered-invariant flow) that regenerates the board from the committed spec tree without
  re-deriving the tree — ids renumber per machine anyway, which is exactly why the board is not
  committed.
- Or have GATE L2 refuse a board with zero tasks rather than counting `0/0` as complete, so the
  gap surfaces at the gate that claims to check it instead of three phases later in the
  evaluator's deviations.
- Either way, the requirements projection should say *why* it is empty — "no board on disk" is a
  different fact from "no AC covers this clause", and the report currently prints them identically.

**Disposition in this run:** nothing regenerated by hand. L2's `proceed` and the `0/11` projection
stand as recorded; the evaluator's escalation and this entry are the trace.

**Status on 3.7.5 — does not reproduce.** Run `about-screen-20260925T011514Z-a4094924`, 2026-09-25,
same flags. The dispatch ledger carries a `ba-pitch-analyzer` row for an order named `board`
(receipt, WorkResult and leg all present, 172 s) — the committed spec fast-forwarded the tree and the
run regenerated the per-machine board from it: 6 tasks, every AC carrying `(covers: REQ-…)`. GATE L2
crossed over `6/6` rather than `0/0`, the evaluator anchored criteria to board ACs, and the
requirements projection credited its first clause on this pitch (`1/11 PASS`, REQ-7 via the
TS-BASELINE-01 criterion). The join now populates; the remaining `no evidence` rows are the device
gap (below), not a missing board.

---

## HD-11 — status on 3.7.5: does not reproduce

Run `about-screen-20260925T011514Z-a4094924`, 2026-09-25, `--no-qa --max-rounds 1`, unattended/`ci`.
The launch dispatched `scope-hammer` itself on the outer breaker (order `hammer`, receipt + WorkResult
+ leg, census written under the run trace's `reports/` folder), resolved GATE H `accept-cut-list`
and then GATE L4 `ship` from the preset **inside the workflow**, and closed the run `shipped` with
`close_cause: … census=ship-now cut_list=6`. No standalone hammer dispatch and no manual L4 resolve
was needed; the `RunReturn` came back `status: "shipped"` with the census verdict and cut list
inline. The refusal (`census: null`) did not fire. Whether L4 now reads the ingested WorkResult or
the `reports/` artifact is not determined here — only that the headless lane can record `L4 | ship`
over a green census for the first time.

---

## HD-3 — recurrence on 3.7.5, by a different section of the same report

**Observed:** same run, at close. `harness verify spec --slug about-screen` over the freshly frozen
`shapeup/about-screen/REPORT.md` returns `red: 3`, all `TIER-DIRECTION`, all on the report's
**"Discovered, not built"** section (lines 129–131): `reduce ship` copied the discovery ledger's
entry verbatim — `+ [ESCALATE] ESCALATE substrate-expansion [TASK-005]` and its two body lines, each
naming the board id — into the committed report. HD-3's original path (the requirements table and
the unfinished-work callout) stayed clean, exactly as the 3.7.1-rc.2 note recorded: the callout
anchors on use cases, the `covering AC` column cites AC text. The generator fixed the two sections
it knew about and gained a third that echoes worker prose unfiltered.

**Why it is the same defect.** The ledger entry is *correct* where it lives — the discovery ledger is
run-tier and board ids are the right key there. The report is a committed record that copies it
without translating the key, and the lint then refuses the report the harness wrote. Same
generator/lint disagreement by construction, and the same cost: **committing this `REPORT.md`
bricks the slug** — every later `init run` on `about-screen` aborts at L1b on these three reds,
on every clone, until a human edits a frozen run record. On an unattended lane the ship close and
the poisoned commit are one step apart.

**Candidate shapes** (in addition to HD-3's): have `reduce ship` render a discovered item by its
use case or scope_id and the ledger's own class/title, never by its board id — the same rewrite it
already applies to the unfinished-work callout; or exclude the discovered section from the report
and point at the ledger by tier name.

**Disposition in this run:** the report was not hand-edited (a frozen record; HD-3's reasoning
holds). It is left **uncommitted** with this note beside it so the next operator decides between
rewriting three lines and changing the rule.

---

## HD-13 — the orient order is never answered, and a `shipped` close does not notice

**Observed:** same run. The first dispatch of the run — `orient` (receipt at 01:16:40Z,
`dispatch_ok: true`, `skill_invoked: orient`) — produced its four artifacts under the run trace's
`orient/` folder, but **no WorkResult and no leg row**: `results/` holds `board`, `about-screen-r1-a1`,
`evaluate-r1` and `hammer`, and `legs.jsonl` the same four. `reduce graph --subgraph run` lists
`pending_orders: ["about-screen/orient"]`; the close's own export writes the dispatch row as
`result_status: null, answered: false`. The previous run of this pitch on 3.7.4
(`about-screen-20260924T193808Z-6b9ab0f2`) exported the same row as `result_status: "done",
answered: true` — so this is a regression between 3.7.4 and 3.7.5, not a long-standing gap.

**Why it is a mechanism defect.** The workflow went on to ANALYZE, WIRE and BUILD over an order it had
not ingested, and closed `shipped` with an order still open by construction. AGENTS.md reserves that
state for runs "closed any other way than shipping"; a ship close is supposed to be the one ending
that leaves nothing unanswered. The pointer was retired on this close (correct, 3.7.1 onward), so
nothing is fenced now — but the order stays "un-fenced, not done", and the attempt census's ability
to tell work nobody did from work that failed rests on exactly this channel.

**What it costs:** small this time (Orient's artifacts were on disk and every later phase read them),
but the next `init run` on the slug inherits an unanswered order and either needs `--force` or starts
with a synthetic `abandoned` result for work that in fact completed. It also means a run's `orders`
minus `results` is no longer a usable "is the fast-forward clean" check — the check the tech-lead
skill tells the operator to run before a relaunch.

**Candidate shapes, unranked:** have the ORIENT phase ingest its result like every other phase (the
receipt shows the dispatch shape is already the attested one); or have a `shipped` close refuse
while `pending_orders` is non-empty, the way ingest refuses a result with no receipt.

**Disposition in this run:** nothing synthesised. The order is left unanswered as the harness left it.

---

## HD-14 — the run ledger's front matter contradicts its own close line, and its tables are empty

**Observed:** same run. `.shapeup/about-screen/harness-run.md` closes with
`status: shipped`, `closed_status: shipped`,
`close_cause: verdict=fail rounds=1 qa_findings=0 after=gate_h breaker=outer census=ship-now cut_list=6`
— and, in the same front matter, `final_verdict: ~`, `rounds_used: 0`, `discovered_rounds: 0`. The
Rounds table below holds one row (`Init — run opened`) and the Decisions table holds none, while
`gates.jsonl` holds seven decisions (L1a, L1a.5, L1b, L2, L3, H, L4) and the export's `run.jsonl`
records `rounds_used: 1, rounds_judged: 1`. The file is 31 lines.

**Why it matters:** `harness-run.md` is the artifact the L4 block names as `Ledger`, and the one a
teammate opens first. Its close line is derived and right; its counters and tables are hand-shaped
placeholders that nothing fills. A reader who trusts the counters concludes no round ran.

**Adjacent, same run — three projections of one task's status disagree.** The task-executor's
attested WorkResult says the local-unit-test task is `skipped` (its substrate has no
`app/entry/src/test/**`, so the sandbox denies the files it needs — the escalation is in the
ledger) and the result's own `status` is `escalated`. The frozen report projects that correctly as
`Board 5/6`, "1 task did not finish — UC-ViewBuildInfo". The per-machine board index under
`tasks/` shows all six tasks ✅ done. `scope-hammer` read the index, called the ledger entry
"stale/superseded", and censused nothing for it — its cut list still lands on the same work by
another route (a host-runnable fixture comparing the rendered version to `app.json5`), so the
outcome was not wrong, but the census was fed the one projection that was. Whoever writes the
index's status column should read the WorkResult, not the worker's optimism.

**Candidate shapes:** derive the ledger's counters and tables from the same records the export
reads (they already agree with each other); derive the board index's status column at ingest from
`task_results[].status`.

**Disposition in this run:** nothing edited. Reported only.

---

## HD-3 — third occurrence on 3.7.6: the committed 3.7.5 report bricked the slug, as predicted

**Observed:** run `about-screen-20260925T020033Z-bb601edb`, 2026-09-25, plugin 3.7.6, `--no-qa`,
unattended/`ci`, `--max-rounds 1`, `HEAD` `d4ad8a2`. The 3.7.5 recurrence note above left the
frozen report uncommitted "so the next operator decides". It was committed as-is in `d4ad8a2`
("the 3.7.5 run's output"), and this run then did exactly what that note predicted: ORIENT and
ANALYZE dispatched (the run tier had been cleaned, so the board was regenerated rather than
fast-forwarded — HD-12 did not recur), WIRE and MAP SCOPES fast-forwarded off the committed spine,
L1a and L1a.5 crossed on the preset, and L1b aborted:

```
{"status":"aborted","aborted_at":"L1b",
 "reason":"spec-lint reported red findings before BUILD: verify spec --slug about-screen exited 1
           with 3 red TIER-DIRECTION findings (REPORT.md lines 129-131 cite TASK-005, a board id,
           in a committed file)."}
```

Cost of confirming it: 20 agents, 650 s, ~792 k subagent tokens, nothing built. The three reds
are the same three lines (the "Discovered, not built" section echoing the discovery ledger's
`[TASK-005]` entry); `git diff` shows the run touched nothing in the committed tier but the
profile's L0 re-confirmation, so the offender is entirely the previous run's frozen record.

**What this run adds to the finding.** The abort reason is now legible on its own — it names the
rule, the count, the file, the lines and the token — so HD-6 (the welded parse complaint) does not
reproduce on 3.7.6. The pointer was retired and the run exported on the abort close (HD-5 holds
fixed). But the shape of HD-3 is unchanged: a report that `reduce ship` writes and L4 freezes is
refused by the lint the same plugin ships, and the unbrick path is still a human editing three
lines of a frozen run record, or the generator changing.

**Disposition in this run:** the report was not hand-edited and the run was not re-opened with
`--force`. The tech-lead skill reserves a relaunch after `aborted` for a human decision, and the
3.7.5 note reserved this exact decision — rewrite three lines, or change the rule — for the
operator. Nothing here changes that. The concrete rewrite, if the operator takes it: replace each
`TASK-005` on lines 129–131 with the task's stable key, `about-screen` / `UC-OpenAboutScreen`
("the TodoList info-affordance task"), then `init run --force` and relaunch.

---

## HD-13 — status on 3.7.6: still unanswered, but the close now says so

**Observed:** same run. `receipts/dispatch.jsonl` records the orient dispatch attested
(`dispatch_ok: true`, `skill_invoked: orient`, 02:02:16Z); its four artifacts are under `orient/`;
`orders/` holds `orient` and `board`, `results/` holds only `board`, `legs.jsonl` only `board`.
`reduce graph --subgraph run` → `pending_orders: ["about-screen/orient"]`. So the ORIENT phase
still does not ingest its own result. The one change from 3.7.5: the run ledger's `close_cause`
ends with `unanswered_orders=1` — the close now notices the open order, where a 3.7.5 `shipped`
close did not. That is the second candidate shape (a close that knows) half-landed; the first
(ORIENT ingesting like every other phase) has not.

**Disposition in this run:** nothing synthesised; the order is left as the harness left it.

---

## HD-14 — status on 3.7.6: front matter consistent on an abort close; the round tables untested

**Observed:** same run. `harness-run.md` closes with `status: aborted`, `closed_status: aborted`,
`closed_at` set, `close_cause` carrying the L1b reason, and `rounds_used: 0` / `final_verdict:
not-evaluated` — which is true, since no round ran. The Decisions log holds two rows (L1a, L1a.5)
matching `gates.jsonl` exactly. So the contradiction and the empty decisions table do not
reproduce here. Whether the Rounds table fills once a round actually runs is not determined by
this run, which never reached BUILD; leave HD-14 open on that half.

**Disposition in this run:** nothing edited. Reported only.

---

## Status on 3.7.7 — run `about-screen-20260925T022045Z-9a235758`, 2026-09-25, `--no-qa --max-rounds 1`, unattended/`ci`

The first run of this pitch to open, build, judge and close `shipped` in one launch with a clean
order set: 44 agents, 1028 s, ~1.74 M subagent tokens, `pending_orders: []`, pointer retired,
export written, `verify spec` over the frozen report `red: 0`.

- **HD-3 — does not reproduce.** The frozen `REPORT.md`'s "Discovered, not built" section now
  renders the ledger entry by use case (`UC-OpenAboutScreen/UC-ViewBuildInfo's committed
  AboutScreenIntegration.test.ets …`) with no board id, and `harness verify spec` returns `red: 0,
  warn: 0` over the committed tier with the report in place. Committing this report will not brick
  the slug. (The 3.7.6 abort was over the *previous* run's report, repaired by hand in `49fc870`
  before this run opened; the generator fix is what this run confirms.)
- **HD-13 — does not reproduce.** `results/orient.json` and a leg row exist for the orient order;
  `reduce graph --subgraph run` → `pending_orders: []`. ORIENT now ingests like every other phase.
- **HD-14 — round tables fill.** `harness-run.md`'s Rounds table carries `Build 1 — T0 1 green /
  0 red — round build gate: green` and `Eval 1 — FAIL — 7 PASS / 12 FAIL criteria`; the Decisions
  log carries all seven rows matching `gates.jsonl`; the front matter reads `status: shipped,
  final_verdict: FAIL, rounds_used: 1`, consistent with the close line. The half left open on
  3.7.6 is closed. The adjacent index-vs-WorkResult finding was not re-checked: the board index's
  status column is `—` for every task on this run.
- **HD-12 — holds fixed.** A `board` order regenerated the per-machine board (6 tasks); L2 crossed
  over `5/6`.

## HD-15 — the requirements projection reads none of the `covers:` clauses the board carries

**Observed:** same run. The regenerated board's acceptance criteria carry **30** `(covers: REQ-n)`
clauses across the six task files (grep count), and the evaluator anchored all 19 criteria to
requirements. `probe requirements` still prints `0/11 PASS · 4 CUT (PO) · 7 no evidence ·
15 inconsistency rows`, with `covering_acs: []` on **every** row — including REQ-6 and REQ-7,
whose anchored criterion `UC-OpenAboutScreen TS-BASELINE-01` is a PASS. Every one of the 15
anchors is listed under "anchored to a requirement no acceptance criterion covers — reconcile,
do not count", so the join credits nothing. On 3.7.5 the same pitch, same spec, credited REQ-7
through the same criterion (`1/11 PASS`).

**What the files say.** The clauses are present but sit at the end of multi-line AC bullets, on
the continuation line (e.g. `TASK-004:32 … without the other (TS-INV-03) (covers: REQ-1)`), where
3.7.5's board carried them on the bullet's first line. Whether the reader keys on the first line
only is not determined here — only that a board whose every AC carries a clause projects as a
board carrying none, and the report then prints "no evidence" for clauses that have a PASS
criterion anchored to them.

**What it costs:** the `REQ → AC → criterion → verdict` table is the one line L4 reads and the
one GATE H's census takes its "clauses with no evidence" from; both were fed a projection that
disagrees with the board it claims to project. It blocked nothing (by design), but the report
states a coverage state that does not exist, in the direction opposite to HD-7's adjacent finding.

**Candidate shapes, unranked:** have the reader collect `covers:` across the whole AC bullet
(until the next bullet), not its first line; have the BA emit the clause on the bullet's first
line; either way have `probe requirements` print, per row, whether the board had *any* clause
naming it, so "no clause on disk" and "clause present but unread" are distinguishable.

**Disposition in this run:** nothing edited on the board or the report. Reported only.

## HD-16 — the evaluator has no grant-covered way to hash the T0 artifact it must cite, so a headless run aborts at L3 on its first verdict

**Observed:** run `retro-todo-20260925T131043Z-b3bd4e6e`, 2026-09-25, plugin 3.9.2, unattended
lane, `ci` answer set, `--no-qa --max-rounds 1`. ORIENT → MAP SCOPES → one BUILD round all
completed (45 dispatches, ~53 minutes, ~2.25M subagent tokens). The single scope went T0-green
on its first attempt (2/2 fixtures, `assembleHap` + unit tier, 45/45 tests), the round build
gate was green, and the evaluator returned a FAIL verdict over 35 criteria (6 PASS / 29 FAIL).
Ingest then refused the verdict and the run closed as `aborted` at L3:

```
verdict:r1: no verdict this round can act on — the FAIL verdict cites
t0/verdicts/r1-a1-t1.json with sha256 undefined, but the file on disk hashes to
aae5fbdf… — a T0 citation is re-hashed from disk, never taken on the handed word
```

**What the evaluator says happened.** Its report carries a "T0 citation" table with the hash
column reading `NOT RECOMPUTED`, and explains: every hashing entry point it tried — `shasum`,
`openssl dgst`, `node -e crypto` — needs an approval the headless grant does not give. It read
the artifact in full, ran `harness probe t0` (which answers `green: true` and the path, but
prints no hash), and left the field empty rather than copy the hash from the trial row, which the
contract forbids. The WorkResult it returned carries no `sha256` key at all; the ingest refusal is
exactly the rule working as written.

**The collision.** Two rules are individually correct and jointly unsatisfiable in the headless
lane:

1. The verdict contract requires the evaluator to cite a T0 artifact **it re-hashes itself**,
   never a handed value (AGENTS.md, "Hill phase is mechanical").
2. The permission grant `npx shapeup-sdlc init` writes covers `harness.mjs`, the project's T0
   scripts and hvigor — and no hashing command. `harness.mjs` has no subcommand that prints an
   artifact's digest either (`probe t0` returns green/path only).

So an unattended run whose build succeeds spends its whole round budget, reaches its one
verdict, and cannot act on it — the outcome the lane exists to avoid. Attended runs never hit
this because a human approves `shasum` once.

**A second discrepancy, adjacent.** AGENTS.md says a scoped verdict citing no artifact is
"refused: its round stays open and is evaluated again, never advanced." This run did not re-
evaluate; it closed. Whether `max_rounds 1` is what turned "stays open" into "abort" is not
determined here — only that the documented outcome and the observed one differ.

**What it costs:** one full run of planning and build, then a close with `final_verdict: FAIL`
and an `unapplied_results: [evaluate-r1]` entry in the run graph. The 29 FAIL rows — 15 of them
`[ui]` criteria with no evidence because no device is reachable — were never ingested, so no
refuted box moved, no bug was compiled into a next round, and GATE H never ran a census over the
green scope. The export under `exports/<run_id>/` did land.

**Candidate shapes, unranked:** add a grant-covered `harness probe t0 --hash` (or print `sha256`
in `probe t0`'s existing return) so the evaluator re-hashes through the one entry point the
grant already names; have `init` add a `Bash(shasum:*)`-shaped rule to the grant; have ingest
treat a citation with `sha256` absent (as opposed to wrong) as "re-hash it here, record that the
evaluator could not" — the artifact is on disk and the verdict names it, so the only thing
missing is which process ran the hash; and make the "citing none → round stays open" rule and
the `max_rounds` breaker agree on which one wins.

**Disposition in this run:** nothing edited. The verdict file, the build and the spec tree are
on disk as the run left them; reported only.

## HD-16 — update after the re-run (same run id, plugin 3.9.2, model matrix sonnet throughout)

The re-run got past the L3 hash abort: the citation carries `aae5fbdf…`, which is what the file on
disk hashes to. Two things about *how* are unresolved and worth separating from "fixed":

- The evaluator's report still says the hash "could not be recomputed" (`shasum`, `openssl dgst`,
  `node -e crypto` all "need approval"). By then `Bash(shasum:*)` was in the project's
  `permissions.allow`, and a top-level headless session with only that rule hashed a file
  correctly, without `--allowedTools`. Whether a workflow sub-agent inherits `permissions.allow`
  is **not determined** here — the sub-agent transcripts keep the prompt but not the tool calls.
- The correct digest exists on disk from T0 time, written by the kernel: `t0/trials.jsonl` carries
  `sha256` for `t0/verdicts/r1-a1-t1.json`. It also sits, verbatim, in the `close_cause` of the
  aborted attempt, which the resumed ledger kept. A retry therefore has the answer in front of it
  without hashing anything, and the abort message that names the digest is what makes that so.

`probe t0` answers `{green, path, scope_id, round}` and no digest. Adding the digest to that
output, or pointing the evaluator at the trial row, would satisfy "never a handed value" with a
kernel-computed one and needs no shell hasher in any grant.

## HD-17 — the evaluate order carries no launch evidence, so `[ui]` rows stay ungraded even when the round gate's launch probe is green

**Observed:** same run, 2026-09-25. `build/r1-t2.json` (16:14:37Z) records the round build gate
green with **both** steps executed: `build_probe ./scripts/t0-assemble.sh exit 0` and
`launch_probe ./scripts/launch-probe.sh exit 0` (install accepted, `start ability successfully`,
pid alive, no new faultlog, 6 text-bearing nodes in `.shapeup/launch-probe/layout.json`). Seventeen
seconds later the evaluate order was compiled with payload keys `trial_history, dimensions, round,
spec_folder, feature, t0_artifacts` — no `run_cmd`, no launch evidence, no pointer to the gate
artifact. The verdict graded all 15 `[ui]` rows `NO EVIDENCE` and filed a major bug for the missing
launch path.

**Why.** The spec-evaluator contract reads `payload.run_cmd` ("absent orchestrated → ESCALATE, do
not guess"), and the workflow passes only `rs.run_cmd`, which comes from the run ledger's front
matter. That key is written by the tech lead at L0 and this run's ledger has none. The profile's
`launch_probe` feeds the build gate and stops there.

**Two statements in the run's own output are contradicted by disk** and are now frozen in the
untracked `REPORT.md` (line 146) and the eval report: `launch_probe: ~` (the profile read
`"./scripts/launch-probe.sh"` throughout), and "the round build gate was fast-forwarded, so
`launch-probe.sh` never ran" (`build/r1-t2.json` shows it ran).

**Also a semantic overload.** `run_cmd` is the build gate's first step (a build) and the
evaluator's "how to start the running app". On this stack those are different commands, and the
launch script run first would install a stale HAP.

## HD-18 — a run resumed after an abort and then shipped cannot record its close, and its ledger contradicts itself

**Observed:** same run. After the L3 abort (`closed_status: aborted`, 14:06:27Z), a relaunch
resumed the same `run_id`, re-crossed L1a → L1a.5 → L1b (rows 6–8 duplicate rows 2–4; no leg was
re-dispatched), crossed L2, L3, H and L4, and shipped. The close was refused as once-only. Result:

```
status: shipped        closed_status: aborted        closed_at: 14:06:27Z (the abort's)
close_cause: L3: verdict:r1: … sha256 undefined …    (the abort's)
.shapeup/last-run → {"closed_status":"aborted","closed_at":"2026-09-25T14:06:27.546Z"}
```

Anything that reads the close — the export, the trace, the next run's resume — sees `aborted`. The
only repair the run found was `init run --force`, which discards the round history. AGENTS.md
promises that every ending records a close derived from the ending itself; this ending records
the previous one. A pause is the only ending documented as recording none, and an abort is not a
pause.

## HD-17 — measured: one field in the evaluate order moves the verdict from 6/29 to 28/7

Same run id, same code, same T0 artifact, same model (sonnet), same grants. The only change was the
order: compiled by hand with `--payload '{"dimensions":["spec-conformance"],"round":1,"run_cmd":"./scripts/launch-probe.sh"}'`,
dispatched in a top-level headless session (`claude -p --model sonnet`, plugin loaded, the `hdc`
prefix granted for that one invocation), then applied with `reduce ingest --order`.

| | order without `run_cmd` | order with `run_cmd` |
|---|---|---|
| verdict | FAIL, 6 PASS / 29 FAIL | FAIL, 28 PASS / 7 FAIL |
| `[ui]` rows | 15 of 15 `NO EVIDENCE` | 15 of 15 graded (14 PASS, 1 FAIL) |
| requirements with PASS evidence | 4 of 28 | 17 of 28 |
| evidence on disk | none | 4 screenshots + a driven-app report |

The evaluator drove the app with `uitest` (scroll, toggle, rename) and read affordance ids and text
back. Ingest accepted the result into the already-closed run (a second attested leg row for
`evaluate-r1`; the earlier result and report were replaced, the earlier ones are archived). The close
still reads `closed_status: aborted` under `status: shipped` — HD-18 is unchanged by this.

So the field is the blocker, not the run, the model or the grant. The orchestrated pipeline still
cannot produce this verdict on its own: the ledger carries no `run_cmd`, and the round build gate's
green `launch_probe` output is never forwarded to the evaluator.

## HD-16 — a second datapoint

In that top-level session the evaluator recomputed the T0 digest itself (`aae5fbdf…3fff`, matching
the artifact) with no complaint about approval, under the same `permissions.allow` the workflow
sub-agent had. That fits "a workflow sub-agent does not inherit `permissions.allow`", but the
sub-agent transcripts do not keep tool calls, so it stays a hypothesis rather than a finding.

## HD-17 / HD-16 — status: fixed in the plugin working tree, not yet released

The evaluate order now carries `build_gate` (this run's newest round build gate artifact) and
`launch_cmd` (the profile's launch probe), both derived by `harness compile`; `probe t0` prints the
sha256 of the green verdict. Exercised against this run: an order compiled from the workflow's own
payload — no `run_cmd` — was graded with all `[ui]` rows evidenced (16 of 16). HD-18 (the close of a
run resumed after an abort) is unchanged. Until a release, this checkout still runs the installed
3.9.2, which carries neither field.

## HD-17 / HD-16 — status: released in plugin 3.10.0 (2026-09-26)

This checkout is repointed to 3.10.0 at project scope. The next run's evaluate order carries
`build_gate` and `launch_cmd` without anyone pinning a `run_cmd`, and `probe t0` prints the digest.
HD-18 remains open.

## HD-16 — resolved: workflow sub-agents take grants from the settings file, not from launch flags

Measured on run `retro-todo-20260926T090044Z-3d1928c9` (plugin 3.10.0, Sonnet throughout). With
`Bash(shasum:*)` in `.claude/settings.json`, every evaluator sub-agent recomputed all four T0
digests itself. With `hdc` granted only through the launch's `--allowedTools`, the same sub-agents
reported "no UI driver was available" and graded every device row past the first screen NO EVIDENCE
— 4 rows in round 2, 17 in round 3 — with `bugs: []`, so the fix rounds had nothing to fix. A
top-level session given the same flag drove the app with `hdc … uitest` without complaint.

So a grant that an unattended run's workers need must live in the project's settings file; a launch
flag reaches the orchestrating session only. `hdc` was added to this checkout's `permissions.allow`
on 2026-09-26 (PO decision). The plugin still has no way to tell a run, before it spends a round,
that its judge cannot drive the app: the Preflight canary runs the probes from a sub-agent, but a
probe that only launches cannot show that the evaluator could not go further.

## HD-19 — QA reaches the device but hunts no charter (open, raw idea for the Betting Table)
Measured on two runs of retro-todo, 2026-09-27, Sonnet throughout. On plugin 3.15.0 the hunter looked
for `hdc` on PATH, found nothing, never ran `launch_cmd`, and returned `done` with `charters: 0/0`;
the ship report said `QA: run`. Plugin 3.15.1 fixed both halves: the report now reads `not-hunted`
from the hunt's own charter count, and the preflight reads the knowledge base first and runs
`launch_cmd`. On 3.15.1 the hunter reached the emulator (launch exit 0, `hdc` by full path, clean
fault sweep), then still drafted **zero** interactive charters and returned `done`. So the app is
reachable and nothing is hunted. Two things remain open: the run's own QA ledger row and its return
still say `run`, and nothing requires a hunt over a reachable app to draft at least one charter.

## HD-20 — the judge graded the Test Surface as two aggregate criteria (open)
Same run on 3.15.1 (`receipt.json` → 3.15.1). The verdict PASSed on two rows, "Device Test Surface
rows" and "Local Test Surface rows", each at medium confidence and with no `traces_to`. Earlier runs
graded one criterion per row. The effects: the requirements projection reads 0/28 even though every AC
carries `covers:`; REQ-15 (`vi_VN` strings with the same keys as base) is unmet and passed anyway,
because only `resources/base` exists; and the board stood at 6/10 when EVAL ran. A per-row verdict is
what makes the matrix, the bug routing and the rewritten-check list work, so an aggregate criterion
switches off all three without any error.

## HD-20 — resolved in plugin 3.16.0 (2026-09-27)
A PASS now names every Test Surface row. A grouped PASS is refused on ingest and by `probe eval`, and
the judge is sent back once. Run `retro-todo-20260927T063004Z-4db8f5ed` (receipt 3.16.0, Sonnet): the
judge graded 42 criteria, one per row, on its first dispatch, so the refusal did not have to fire.
The requirements matrix went from 0/28 to 22/28. The six without evidence are REQ-11/12/25/26
(card contrast tokens), REQ-27 (in-memory persistence) and REQ-15 (`vi_VN` strings; no such resource
exists). They are weighed at GATE H rather than vetoed.

## HD-19 — did not reproduce on 3.16.0; the gap stays open
On the same run the hunt ran 3/3 charters on the emulator and recorded two findings: QA-101, an
unbounded list name fills the screen, and QA-102, a double-tap on one item row toggles three items
done. So the zero-charter hunt on 3.15.1 was model variance. Nothing yet requires a hunt over a
reachable app to draft a charter, and the run's QA ledger row still says `run` whatever the count.

## Full status re-check — 2026-09-27, plugin 3.16.1
Each row was checked against run `retro-todo-20260927T063004Z-4db8f5ed` (receipt 3.16.0) and the
plugin source, not against the entries above.

| HD | Status | Evidence |
|---|---|---|
| 1 | fixed | L1b crossed; spec lint red 0 on the current tree |
| 2 | fixed | an attempt counts as spent only when a dispatch receipt plus a leg row or WorkResult say so; run 8 closed with no breaker |
| 3 | **recurred 4th time, fixed in 3.16.1** | see HD-21 |
| 4 | fixed | a fixture that never started keeps an `error` field distinct from a failing exit |
| 5 | fixed | no run pointer after the close; `last-run` crumb names the run |
| 6 | fixed | a red spec-lint aborts L1b with its own message, apart from an unreadable gate decision |
| 7 | fixed | spec lint flags a No-go registered as a covered requirement |
| 8 | fixed | the hill derivation may move a dot backwards |
| 9 | fixed | a `cannot-ship` census narrows L4 to its evidence |
| 10 | fixed | the attempt gate reads the run key |
| 11 | fixed | census written by the run (`reports/hammer-census.json`) |
| 12 | fixed | run 8 regenerated the board from the committed spec |
| 13 | fixed | `results/orient.json` and a leg row exist |
| 14 | fixed | front matter agrees with the close line (`shipped`, PASS, 1 round) |
| 15 | fixed | requirements 22/28 with evidence |
| 16 | fixed | grants belong in the project's settings file |
| 17 | fixed | the evaluate order carries `build_gate` and `launch_cmd` |
| 18 | fixed by fixture, not seen live | a resumed closed run reopens with `prior_closes` (3.11.0); no live run has resumed one since |
| 19 | **open** | a hunt over a reachable app may still draft zero charters; the report says `not-hunted` (3.15.1) but nothing requires a charter |
| 20 | fixed | a PASS names every row (3.16.0); 42 per-row criteria in run 8 |
| 21 | fixed in 3.16.1 | below |
| 22 | fixed in 3.16.1 | below |
| 23 | fixed in 3.16.1 | below |

## HD-21 — the report's QA section copied a run-trace path, and the committed report bricked the slug
In run 8, the first run whose hunt had findings, `REPORT.md:154` quoted the hunt report's pointer to
the discovery ledger by its `.shapeup/` path. The next run's spec lint reds that file, so L1b aborts.
The report's write boundary rewrote board ids only. From 3.16.1 it rewrites run-trace paths too, and
this report was regenerated from run 8's own trace (one line changed; spec lint red 0).

## HD-22 — GATE L4 was signed twice
Run 8's gate ledger holds two `L4 ship` rows, the second a minute after the close. The run crosses L4
itself, and the orchestrator's closing step (still reading "the workflow never sees L4") resolved it
again. From 3.16.1, resolving L4 over a closed run returns the sign-off on record and writes nothing.

## HD-23 — the run's return carried a sentence where the report path belongs
The RunReturn's `report` field held the ship command's one-line summary. From 3.16.1 it is the path.
`--orch-model` was documented as an override and changed nothing; the option list now says so.

## Plugin 3.17.0 → 3.17.2 — toggle-once soaks (2026-09-28)
The first pitch built from a QA finding (retro-todo's QA-102, the double-tap). Three runs, all Sonnet.

| | Result |
|---|---|
| HD-19 (hunt with no charter) | fixed in 3.17.0 — a `done` hunt over a reachable app with 0 charters is refused and sent back once; both toggle-once hunts ran 3/3 charters |
| HD-18 (resume of a closed run) | **verified live** — a run killed mid-BUILD, closed `aborted`, relaunched: it reopened, kept the abort under `prior_closes`, and closed `shipped` with its own cause |
| HD-22 (L4 twice) | verified live — one L4 row per run |
| HD-24 (new) | fixed in 3.17.1 — one scope with no green T0 made the judge refuse the whole round, and the run aborted at L3. The order now names such scopes and their rows are graded FAIL |
| HD-25 (new) | fixed in 3.17.2 — the same spec read 5/5 under one judge and 0/5 under the next, which filled no `traces_to`. A verdict that anchors no criterion beside a covering board is sent back once |
| KB-SA-009 (PO, COACH-1) | held — the re-cut granted `List.test.ets` to the scope that added a unit test |

Shipped: `toggle-once` PASS in one round, built from baseline. Checked by hand on the emulator: a system
double-click on Bread leaves two items done (was three), and a deliberate tap a second later still
toggles. QA-001 of the last run ("two quick taps on two rows both drop") did not reproduce: the first
tap toggles and only the second, inside the 400 ms window, is ignored, as designed. Open, for the PO:
C-02, a tap on a row's ✕ just after a toggle re-sorts the list can open the delete dialog for the item
that slid into place (one CANCEL from a wrong-item delete).

## Re-check of the last trace — 2026-09-29, run `toggle-once-20260928T114548Z-e2675ab4`
This was read from the run's own records (receipt 3.17.1, gate ledger, hook ledger, verdict, and all
seven exports). The run's narration was not used. Hook ledger: 225 rows for this run, every one
`allow`, and no denial the run worked around.

| HD | Status | Evidence |
|---|---|---|
| 25 | **fixed in 3.17.2, not yet seen live** | this run's receipt says 3.17.1, and its close still narrates "requirements 0/5". No run has used 3.17.2 yet |
| 26 (new) | open, plugin HD-069 | below |
| 27 (new) | open, plugin HD-070 | below |

## HD-26 — the judge grades one dimension on every run, whatever the spec carries
`harness-run.md` opens with `eval_dimensions: [spec-conformance]`, and `orders/evaluate-r1.json` passes
exactly that list. By the judge's own rule an explicit list switches off its auto-enable, so
`test-surface-conformance` never ran here, although `spec/usecases/UC-01.md` carries a Test Surface.
Across all seven exported runs, 101 of 101 criterion verdicts are `spec-conformance`. The L4 block
says as much ("not evaluated: tdd-surface, integration, completeness, test-surface-conformance"),
and until now nobody had read that line as a defect.

## HD-27 — the relaunch re-signed L1a, L1a.5 and L1b while the run still read closed
Close `aborted` at 11:54:41. The gate rows re-crossed at 11:58:22, 11:58:35 and 11:59:04, and the
reopen came at 11:59:08, on the first `building` write. The Decisions table lists each planning gate
twice. The only other traffic in that window was the canary Orient (no order) and read-only
commands, so nothing was built over the closed run.

## Open for the PO (not harness defects)
- **C-02**: after a toggle re-sorts the list, a tap on a row's ✕ can open the delete dialog for the
  item that slid into that row. One CANCEL stands between the user and deleting the wrong item.

## delete-settle soak — 2026-09-29, plugin working tree past 3.17.2, run `delete-settle-20260929T031445Z-607891db`
C-02 was shaped as its own pitch (`delete-settle`). The run used a `git archive` copy of the plugin
as `--plugin-dir`, outside this project (the shape of a marketplace clone), with the installed copy
disabled for the session, and Sonnet at every tier. It was killed mid-BUILD, closed `aborted`, and
relaunched. It shipped PASS in one round: 13/13 criteria, requirements 5/5, QA 1 finding.

| HD | Status | Evidence |
|---|---|---|
| 25 | **verified live** | 6 of 13 criteria carry `traces_to`; requirements 5/5 PASS |
| 26 | **fixed, verified live** | the ledger reads `eval_dimensions: auto`; `orders/evaluate-r1.json` names spec-conformance, tdd-surface, completeness and test-surface-conformance; the verdict graded three of them |
| 27 | **fixed, verified live** | reopen at 03:21:54, before any relaunch gate; the Decisions table marks every row after it `launch 2 (after a reopen)` |
| 28 (new) | fixed | the relaunch copied the orchestrator's `\`-continued `init run` and came back "requires approval" over a grant that covers it. The shipped command is now one line |
| 29 (new) | fixed | the next relaunch ran `init run --force` and opened a fresh run, following the pause table's "`--force` if truly restarting" for an aborted run. The table now says a relaunch resumes |
| 30 (new) | fixed | after the reopen, 225 of 234 hook rows carried no run key: the close retired the run pointer and nothing wrote it back. The reopen now restores it |
| 31 (new) | fixed | the PASS graded no criterion under `tdd-surface`, which the order named, and L4 listed it as evaluated. A PASS with an ungraded named dimension is now sent back once |

The two build legs ran one after the other (v2 depends on v1), so the concurrent case of the plugin's
sibling-result guard is proven by fixture only. Live, the guard allowed 14 in-substrate writes,
including every leg's own result, and refused 2 writes to `/tmp`; it made no false refusal.

## Open for the PO (not harness defects)
- **QA-001 (delete-settle)**: the settle window lives on the `ListViewModel` instance, and every navigation
  builds a new one (`Index.ets` → `TodoModule.listViewModel()`). So toggle, back, reopen and delete inside
  400 ms opens the dialog. The finding contradicts INV-02 as written, but the gesture is contrived. It is
  worth a pitch only if the PO wants the window to be screen-independent.

## settle-across-screens — 2026-09-29, plugin 3.18.0 (marketplace install), run `settle-across-screens-20260929T045649Z-4f29bf…`
delete-settle's QA-001 was shaped as its own pitch and shipped PASS in one round: 17/17 criteria,
requirements 5/5, QA 1 finding. It is the first run on the released 3.18.0 (`receipt.json` → 3.18.0).

| HD | Status | Evidence |
|---|---|---|
| 26 | holds on the release | the ledger reads `auto`; the order names four dimensions |
| 31 | **verified live** | all four named dimensions are graded (6 test-surface, 5 spec, 5 completeness, 1 tdd-surface); delete-settle's PASS had left tdd-surface empty |
| 13 | **recurred (3rd time)** | the orient order has a dispatch receipt and no WorkResult or leg row. Its four artifacts are on disk, so the phase went on; the close names `unanswered_orders=1`, as designed. Every recurrence so far is the orient leg: a raw idea for the Betting Table is a send-back-once for a phase whose envelope never came back |

## Open for the PO (not harness defects)
- **QA-001 (settle-across-screens)**: the MY LISTS "done" badge stays stale after toggles on the list
  screen. The hunter reports that it survives a force-stop and relaunch. Not verified by hand, and the
  relaunch part is surprising for an in-memory store, so repro it before shaping.

## HD-13 — fixed in plugin 3.18.1 (2026-09-29)
A planning leg with a dispatch receipt and no WorkResult is now dispatched again once, told its artifacts
stand, and is named at the close only on a second miss (ORIENT and WIRE). The behavior is proven by a check
that executes the shipped post-condition. A soak (run `settle-across-screens-20260929T062138Z-31050811`)
re-ran the shipped pitch over a fresh tier, and orient answered on its first dispatch, so the send-back was
not needed live. PASS 18/18 criteria, requirements 5/5, no unanswered order.
