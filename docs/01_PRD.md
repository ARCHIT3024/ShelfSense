# 01 — Product Requirements Document

## 1. Problem

A distributor sales rep works a beat of 30–40 kirana stores a day. Each stop lasts about four
minutes, most of it spent talking across the counter. The rep glances at the shelf on the way in,
asks the owner what has run short, writes the order on a pad or in an app, and moves on. The order
is recorded. **The shelf is not.**

Three things the brand pays for and cannot measure:

- **Stockouts** — which SKUs were empty at the moment of the visit, and how often the same slot
  goes empty across the beat.
- **Facings** — how much shelf the brand actually holds against the planogram it negotiated and
  pays a visibility fee for.
- **Competitor share** — what moved into the space when the brand's pack was missing.

Data entry then happens hours later at the office — a 60–90 minute evening shift of retyping.

Existing shelf-intelligence tools do not reach this channel because (a) every photo is an upload
and beat routes run through basements, market lanes and 2G pockets; (b) off-the-shelf retail
detectors are trained on Western SKUs and have no vocabulary for Indian sachets, strips and
hanging rails; (c) per-store licensing is priced against supermarket chains.

## 2. Product

**ShelfSense** is a phone-only field agent for distributor reps. One photo of the rack produces a
shelf audit, a stockout list, and a suggested reorder — in under a second, in a dim aisle, with
the device in aeroplane mode. At the end of the beat the phone itself generates the distributor's
spreadsheet and route summary. There is no server anywhere in the system.

### 2.1 Productivity-track positioning

ShelfSense is a **workflow-automation** product. The vision model is the mechanism, not the pitch.

| | Before | After |
|---|---|---|
| Per store | ~4 min, shelf unrecorded | ~4 min, shelf fully recorded |
| Per day | 60–90 min evening data entry | **0 min — eliminated** |
| Visit → distributor sheet | Next morning | Instant, generated on the handset |
| Shelf data captured | None | Facings, stockouts, planogram deviation, photo evidence |

Headline claim: **"We removed the evening data-entry shift."**

## 3. Users

**Primary — Ravi, distributor sales rep, 26.** Mid-range Android, 35 stores/day, on a two-wheeler.
Works standing, one-handed, phone in the right hand, order pad in the left. Not technical. Paid
partly on order value, so anything that slows the counter conversation will be abandoned by week
two. Distrusts systems that submit on his behalf.

**Secondary — Suresh, distributor owner, 48.** Runs a 400-outlet beat on thin margins. Lives in
Excel and Tally. Will not install software. Wants the order sheet in the format his back office
already uses, and wants to know which outlets go empty repeatedly.

**Not a user:** the brand's category manager. Out of scope for this build.

## 4. Scope

### 4.1 In scope (L0 — must ship)

| ID | Requirement |
|---|---|
| F-01 | Rep selects a beat, then a store from that beat's list. |
| F-02 | Rep captures one or more still photos of the rack with the device camera. |
| F-03 | On-device detector returns a bounding box per pack, class-agnostic, in < 1 s. |
| F-04 | Boxes render over the captured photo; rep can tap a box to assign an SKU manually. |
| F-05 | Rep can add, resize and delete boxes by hand. |
| F-06 | Facing counts are computed per SKU from the assigned boxes. |
| F-07 | Order draft is generated with an editable quantity per line; every line is overridable. |
| F-08 | Visit is confirmed and persisted locally with store id, timestamp, GPS fix and photos. |
| F-09 | Beat-level XLSX and CSV order sheets are generated **on the device**. |
| F-10 | Generated files are shareable via the OS share sheet. |
| F-11 | Every step above works with the device in aeroplane mode. |

### 4.2 In scope (L1)

| ID | Requirement |
|---|---|
| F-12 | Rep enrols a new SKU by photographing the pack ≥ 3 times; it is recognisable immediately, with no retraining and no app update. |
| F-13 | On-device embedding recogniser auto-assigns an SKU and confidence to each detected box. |
| F-14 | Low-confidence matches are visually flagged and presented as a ranked choice, never silently guessed. |
| F-15 | Store planogram (target facings per SKU) is diffed against detections to produce per-SKU status: `in_stock`, `below_plan`, `stockout`, `unlisted`. |
| F-16 | Suggested reorder quantity is derived from the planogram gap, adjusted by the store's trailing order history. |
| F-17 | Every user correction to a model output is logged as an override event. |

### 4.3 In scope (L2)

| ID | Requirement |
|---|---|
| F-18 | Rep records a spoken note; it is transcribed on device. |
| F-19 | On-device LLM converts detections + transcript into a structured visit record (JSON) and a one-paragraph rationale for the suggested order. |
| F-20 | Beat-level route summary PDF is generated on the device. |
| F-21 | If the LLM is unavailable or returns unparseable output, a deterministic non-LLM path produces the same fields. **No user-visible failure.** |

### 4.4 In scope (L3 — stretch)

| ID | Requirement |
|---|---|
| F-22 | On-device OCR reads grammage/variant text from low-confidence crops to break ties between near-identical SKUs. |
| F-23 | Benchmark screen shows on-device results vs a pre-computed cloud-VLM baseline on a fixed eval set, with latency and accuracy. |
| F-24 | Local HTTP server on the phone serves the generated files to a laptop on the same hotspot. |

### 4.5 Explicitly out of scope

- Any server, cloud database, user account, or login.
- Real-time inference on the camera preview stream.
- Multi-rep sync, conflict resolution, or a distributor-side web app.
- Competitor-share analytics (named in the pitch as roadmap; **not built this weekend**).
- Payments, invoicing, credit limits, returns.
- iOS.
- Tamil/Devanagari ASR. ⚠️ ASSUMPTION: demo is in English/Hinglish.

## 5. Acceptance criteria

**Demo-gate (must all pass in aeroplane mode on the iQOO 15 before the pitch):**

| ID | Criterion | Measure |
|---|---|---|
| A-01 | Cold app start to camera-ready | ≤ 3 s |
| A-02 | Shutter press to boxes rendered | ≤ 1000 ms end to end |
| A-03 | Detector recall on the physical demo shelf | ≥ 90% of visible packs boxed |
| A-04 | Recogniser top-1 accuracy on enrolled SKUs, demo shelf | ≥ 85% |
| A-05 | Live enrolment: new pack → recognised | ≤ 45 s, ≤ 3 photos |
| A-06 | Visit confirm to XLSX file on disk | ≤ 3 s for a 10-store beat |
| A-07 | Full demo path run 10× consecutively | 0 crashes |
| A-08 | Network calls during the demo path | **0** — verified in aeroplane mode |
| A-09 | LLM disabled | Every screen still functional |
| A-10 | Peak RSS during a detection cycle | ≤ 1.5 GB |

## 6. Metrics on the pitch slide

Report **time**, not accuracy, as the headline:

- Minutes of data entry eliminated per rep per day (measured against a stopwatch baseline you
  record yourselves at the venue — do not invent a number).
- Time from shutter press to a distributor-ready spreadsheet.
- Shelf records created per beat, where the prior value is zero.

Keep mAP, top-1 accuracy and latency on the technical-depth slide.

## 7. Known honest limitations to state on stage before a judge finds them

1. The recogniser is enrolled on ~40 SKUs shot today, not trained on a national catalogue.
2. Facing counts degrade under heavy occlusion; the rep confirms every line regardless.
3. Most real stores have no planogram on file — we fall back to trailing order history.
4. Whisper-tiny handles English/Hinglish; Tamil is roadmap.
5. The cloud baseline is pre-computed, not live, because the demo runs in aeroplane mode.
