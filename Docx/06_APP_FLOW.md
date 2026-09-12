# 06 — App Flow

## 1. Navigation graph

```
/boot  (model load, seed check)
  └─► /beat                         Today's beat — store list
        ├─► /store/:id              Store detail (pre-visit brief)
        │     └─► /capture/:visitId          ◄── THE CORE LOOP ──►
        │           └─► /review/:visitId     boxes, corrections
        │                 └─► /shelf/:visitId   facings & stockouts
        │                       └─► /order/:visitId
        │                             ├─► /voice/:visitId   (L2, optional)
        │                             └─► /confirm/:visitId
        │                                   └─► back to /beat
        ├─► /export                 Beat summary → XLSX / CSV / PDF
        │     └─► /handover         Share sheet · local server QR  (L3)
        ├─► /catalogue              SKU list, enrolment status
        │     └─► /enrol/:skuId?    Enrolment capture
        ├─► /benchmark              On-device vs cloud  (L3)
        └─► /diagnostics            Model status, latencies, thresholds
```

Router: `go_router`. Deep-link every route — you will want to jump straight to `/enrol` during the
demo without walking the whole tree.

## 2. Visit state machine

```
        ┌────────┐  create        ┌────────┐
        │  none  │───────────────►│ draft  │
        └────────┘                └───┬────┘
                                      │ confirm (≥1 photo, all boxes resolved
                                      │          or explicitly skipped)
                                      ▼
                                 ┌───────────┐
                                 │ confirmed │
                                 └─────┬─────┘
                                       │ included in an export batch
                                       ▼
                                 ┌──────────┐
                                 │ exported │
                                 └──────────┘
```

- A `draft` visit survives app kill. On relaunch, `/beat` shows a **Resume** chip on that store.
- Only one `draft` visit per store at a time.
- `exported` is terminal. Re-export regenerates files but does not change status.
- **Confirm is the only irreversible-feeling action.** It requires an explicit button press with a
  summary sheet above it. Nothing auto-submits, ever.

## 3. Happy path — one store, ~75 seconds

| Step | Screen | What happens | Budget |
|---|---|---|---|
| 1 | `/beat` | Rep taps the next store in sequence | 2 s |
| 2 | `/store/:id` | Pre-visit brief: last visit date, last order, known stockouts, planogram row count. Big **Start visit** button. Creates a `draft` visit, `started_at` set. | 5 s |
| 3 | `/capture` | Camera opens directly. Rep frames the rack, taps shutter. | 8 s |
| 4 | *(processing)* | Preprocess → detect → crop → embed → match. Progress overlay on the frozen frame. | **≤ 1 s** |
| 5 | `/review` | Boxes over the photo, colour-coded by match state. Rep taps any wrong box and corrects. Unmatched boxes are pulsing blue and counted in a banner. | 20 s |
| 6 | `/shelf` | Table: SKU · planogram · detected · status. Stockouts pinned to top in red. | 8 s |
| 7 | `/order` | Draft lines from the reorder engine, each with a stepper. Rep adjusts across the counter. | 20 s |
| 8 | `/voice` *(optional)* | Hold-to-record note. Transcribes on release. LLM writes the visit record in the background. | 10 s |
| 9 | `/confirm` | Summary sheet: N lines, ₹ value, N stockouts. **Confirm visit.** GPS captured. `duration_ms` written. | 3 s |
| 10 | → `/beat` | Store marked done, next store highlighted. | — |

**Step 4 is the product.** Everything else is a form. Optimise it first and hardest.

## 4. Screen-by-screen behaviour

### `/boot`
Loads models lazily in parallel, writes `model_registry`. **Never blocks on the LLM or ASR** — the
route advances as soon as detector + DB are ready. Max 3 s, then advance regardless and let
Diagnostics report what failed.

### `/beat`
Store list in `sequence` order. Per row: name, code, status pill (`pending` / `draft — resume` /
`done`). Sticky header: `7 / 12 done · ₹18,400 · 3 stockouts`. FAB → `/export`.

### `/capture`
- Camera preview, **no inference on the stream**.
- 64 dp shutter in the bottom thumb arc.
- Torch toggle — shops are dim; put it where a thumb reaches, not in a menu.
- A faint framing guide suggesting a full rack in view.
- After shutter: freeze the frame, overlay a determinate progress ring, run the pipeline.
- Multi-photo: after processing, offer **Add another photo** for wide racks. Detections accumulate
  across photos into one visit.

### `/review`
Core interaction. Photo fills the screen, pinch-zoom and pan.

| Box state | Colour | Action on tap |
|---|---|---|
| Matched, high confidence | green outline, SKU code chip | opens SKU picker (correction) |
| Matched, low confidence | amber outline, `?` chip | opens picker **pre-filled with top-3 ranked candidates** |
| Unmatched | blue pulsing outline | opens picker, search-first |
| Visual gap (advisory) | grey dashed | tap to dismiss |

- Long-press a box → delete. Drag corners → resize. Long-press empty area → draw a new box.
- Every correction writes `override_events` and sets `was_corrected = 1`.
- Banner: `14 packs · 11 matched · 3 need tagging`. **Continue** is enabled regardless — the rep is
  never trapped. If unmatched boxes remain, the button reads *Continue (3 untagged)*.
- **Enrol this pack** appears inside the picker sheet when nothing matches. This is the live-demo
  moment: it routes to `/enrol` with the current crop pre-loaded as the first shot.

### `/shelf`
Sorted `stockout` → `below_plan` → `unlisted` → `in_stock`. Columns: SKU · plan · found · status.
Tap a row to jump back to its boxes in `/review`.

### `/order`
One card per line: SKU name, grammage, suggested qty (small, greyed, labelled *suggested*), a large
stepper for `final_qty`, and the line value. Overridden lines carry a subtle marker.
Running total pinned to the bottom. **Add line** for anything the owner asks for that isn't on the
shelf — this is how real counter conversations go, and omitting it makes the app feel fake.

### `/voice` (L2)
Hold-to-record, waveform feedback, 30 s cap. On release: transcribe, show editable text, fire the
LLM in the background. The rep can leave this screen immediately — **generation never blocks
navigation.** If the LLM finishes after the rep has moved on, the record updates silently.

### `/enrol`
1. Pick or create the SKU (name, brand, grammage + unit, variant, MRP, case size).
2. Capture ≥ 3 shots; the app nudges for 8 across `bright / dim / angled / occluded`.
3. Each shot: detect the largest box, crop it, embed, store.
4. Live coverage meter and a **Test it now** button that re-runs the last shelf photo against the
   updated index.

Sub-45-second completion is a demo-gate criterion (A-05). Every tap in this flow must be justified.

### `/export`
Beat totals, then **Generate**: XLSX (multi-sheet), CSV (flat), PDF (route summary). Progress per
artefact, file sizes on completion, then `/handover`.

### `/handover`
Share sheet per file, plus (L3) a **Serve on Wi-Fi** toggle that starts the local HTTP server and
shows a QR of `http://<phone-ip>:8080`. The laptop joins the phone's hotspot and downloads.
On stage: *"The distributor's spreadsheet is being served by the phone. There is no server."*

### `/benchmark` (L3)
Fixed eval set. Left column on-device (live, computed now), right column cloud baseline (loaded
from the seeded JSON, clearly labelled *pre-computed*). Rows: accuracy, mean latency, per-image
thumbnails. **Label the cloud column as pre-computed in the UI** — do not let a judge discover it.

### `/diagnostics`
Per-model load status and mean latency. Live threshold sliders. Connectivity state with a large
**OFFLINE** badge. Buttons: re-run seed, wipe visits (`demo_mode`), dump logs.

Open this screen during the pitch to show the real latency numbers. It is a scoring asset, not a dev tool.

## 5. Failure paths

| Failure | Rep sees | System does |
|---|---|---|
| Detector returns 0 boxes | *"No packs found — tap to draw boxes manually"* + a manual-draw affordance | logs, continues |
| Detector model won't load | Manual box mode, no error dialog | `model_registry.last_error` |
| All boxes unmatched | Blue boxes, picker is search-first | normal |
| Embedder won't load | Every box unmatched, manual tagging | Diagnostics only |
| ASR fails | Text field replaces the mic | Diagnostics only |
| LLM fails / unparseable | Templated summary appears; **no error** | Diagnostics only |
| LLM numeric disagrees with Dart | Dart value shown | LLM numeric discarded |
| Camera permission denied | Full-screen rationale + settings deep link | — |
| Storage full during export | *"Not enough space — free up and retry"*, export is atomic | no partial batch |
| App killed mid-visit | **Resume** chip on `/beat` | draft survives |
| Every table empty on launch | Seed runs | — |

## 6. The demo path — rehearse exactly this, six times

```
0:00  Diagnostics screen. Point at OFFLINE badge and the real latency numbers.
0:10  /beat → tap "Kumar Stores"
0:15  Start visit → /capture → shutter on the physical shelf
0:16  Boxes appear. Say the measured millisecond number out loud.
0:30  /shelf — two stockouts in red, one below-plan in amber
0:45  HAND A JUDGE A PACK NOT IN THE CATALOGUE.
      /enrol → 3 shots → Test it now → re-shoot the rack → it is recognised.
1:30  /voice — "owner wants extra noodles before Diwali"
      Transcript + LLM rationale appear
1:50  /order — adjust one line with the stepper, show the override marker
2:05  Confirm → /export → Generate → XLSX opens ON THE PHONE
2:25  "No server touched this. None exists."
2:35  /benchmark — on-device vs cloud, one glance
2:50  12-week pilot line. Stop talking.
```

Aeroplane mode **on** before step 0:00 and visible throughout.

## 7. Build order for Claude Code

Implement strictly in this sequence. Each numbered item must run on a physical device before the
next begins.

**L0** — 1 drift schema + seed · 2 `/beat`, `/store` · 3 `/capture` still capture · 4 detector
service + shape assertion · 5 `/review` boxes + manual tagging · 6 facing counter · 7 `/order`
steppers · 8 `/confirm` · 9 XLSX + CSV builders · 10 `/export` + share sheet.

**L1** — 11 embedder service + `SkuIndex` · 12 `/enrol` · 13 auto-match in the pipeline ·
14 planogram diff + `/shelf` · 15 reorder engine · 16 `override_events`.

**L2** — 17 ASR + `/voice` · 18 LLM service + tolerant parser + deterministic fallback ·
19 PDF route summary.

**L3** — 20 OCR tie-break · 21 `/benchmark` · 22 local HTTP handover · 23 `/diagnostics` polish.

Git-tag `L0`, `L1`, `L2`, `L3`, `demo` as each passes on device.
