# ShelfSense — Document Set for Claude Code

**Project:** ShelfSense — offline, on-device shelf audit and ordering for kirana distribution
**Event:** iQOO City Battle Chennai, 12–13 Sep 2026 · Productivity track · Students bucket
**Team:** 3 · **Devices:** iQOO 15 (Snapdragon 8 Elite Gen 5, Android 16) ×3, Windows laptops ×3 (~6 GB VRAM)
**Build window:** Sat 11:00 → Sun 06:30 hard feature freeze

---

## Read in this order

| # | Document | What it answers |
|---|---|---|
| 01 | `01_PRD.md` | Who, what, why. Scope, personas, user stories, acceptance criteria, out-of-scope. |
| 02 | `02_TRD.md` | How. Stack, model pipeline, tensor contracts, services, performance budgets. |
| 03 | `03_IMPLEMENTATION_PLAN.md` | In what order, by when, by whom. Task IDs mapped to the Red/Green timeline. |
| 04 | `04_UIUX_DESIGN.md` | Screens, design tokens, one-handed layout rules, empty/error states. |
| 05 | `05_DATA_SCHEMA.md` | Every table, column, index, enum, and the derived-value rules. |
| 06 | `06_APP_FLOW.md` | Navigation graph, state machines, happy path, failure paths, demo path. |

---

## Non-negotiable constraints — violating any of these loses the event

1. **ZERO NETWORK in the core path.** Capture → detect → recognise → diff → order → export must
   complete with the device in aeroplane mode. There is no server. Any `http` call outside the
   explicitly-flagged `BenchmarkService` is a bug.
2. **The phone is the backend.** XLSX, CSV and PDF are generated on the handset, not uploaded.
3. **The LLM is never blocking.** Detection, diff, order draft and export must all work with the
   LLM disabled. The LLM adds narrative and rationale only.
4. **Detect on shutter press, never on the camera preview stream.** Preview-stream inference causes
   thermal throttle and battery drain during the demo.
5. **Every level in the L0→L3 ladder must be independently demoable.** Do not start a level until
   the one below it runs on a physical device. Tag each level in git.
6. **06:30 Sunday is a hard feature freeze.** After that: build, install, rehearse, submit.
7. **Original work only.** Repo initialised empty inside the build window. Open-source packages are
   fine with attribution in `ATTRIBUTION.md`. No pre-built application code.
8. **Do not pin package versions from memory.** Run `flutter pub add <name>` and let pub resolve.
   Any version number written in these docs is illustrative, not authoritative.

---

## The L0 → L3 ladder (this governs everything)

| Level | Deadline | Ships |
|---|---|---|
| **L0** | Sat 22:00 | Capture → class-agnostic boxes → manual SKU tag → order draft → XLSX + CSV on device |
| **L1** | Sun 02:30 | SKU enrolment + embedding recogniser + planogram diff (facings, stockouts, below-plan) |
| **L2** | Sun 05:00 | Voice note → ASR → on-device LLM → structured visit record + reorder rationale + PDF beat summary |
| **L3** | Sun 06:15 | OCR grammage tie-break · on-device vs cloud benchmark screen · local HTTP handover server |

**If L0 is not complete at Sat 22:00, cancel L2 and L3 outright** and spend the remaining time
hardening L0. A polished L0 scores higher than a broken L2.

---

## Open questions still outstanding

These are marked `⚠️ ASSUMPTION` where they appear. If any is wrong, it changes the docs:

1. Exact evaluation-round times, and the schedule after Sun 09:00.
2. Whether a Qualcomm QNN / Hexagon TFLite delegate ships in the vendor kit (ask at the 10:00 teach-in).
3. Whether the loaner iQOO 15 is the 12 GB or 16 GB variant (affects LLM headroom).
4. Whether OpenRouter credits cover a vision-capable model for the cloud baseline.
5. Demo language for the voice note — English/Hinglish assumed; Tamil is roadmap.
