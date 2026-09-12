# 04 — UI/UX Design

## 1. Design premise

This app is used **standing up, one-handed, in a dim shop aisle, with a shopkeeper waiting.** That
single sentence resolves nearly every design argument. When in doubt, ask: *can a thumb do this
while the other hand holds an order pad, in four minutes, under a tube light?*

Five rules that follow:

1. **Dark theme only.** Aisles are dim, the panel is OLED, and a white screen at 06:00 in a
   tube-lit shop is hostile. Do not build a light theme.
2. **Everything interactive lives in the bottom third.** The iQOO 15 is a 6.85″ phone. The top of
   that screen is unreachable one-handed. Titles go up top; actions go down.
3. **No keyboard in the core loop.** Quantities use steppers. SKUs use a searchable picker with
   large rows. The only place a keyboard is acceptable is SKU creation during enrolment.
4. **Nothing auto-submits.** Every model output is a draft with a visible *suggested* label.
5. **48 dp minimum tap target, 56 dp for anything used at the counter.**

## 2. Tokens

`lib/app/theme.dart` — single source of truth. No hardcoded colours anywhere else.

### Colour

| Token | Hex | Use |
|---|---|---|
| `bg` | `#0E1013` | app background |
| `surface` | `#171A1F` | cards, sheets |
| `surfaceAlt` | `#1F242B` | raised rows, input fields |
| `border` | `#2A3039` | hairlines |
| `primary` | `#FF6B2C` | primary action, shutter, active nav |
| `primaryDim` | `#8A3A18` | pressed / disabled primary |
| `success` | `#34C77B` | in stock |
| `warning` | `#F5A524` | below plan, low-confidence match |
| `danger` | `#E5484D` | stockout, destructive |
| `info` | `#4C8DFF` | unmatched box, informational |
| `textPrimary` | `#F2F4F7` | |
| `textSecondary` | `#98A2B3` | labels, `suggested` annotations |
| `textDisabled` | `#5A6474` | |
| `offlineBadge` | `#34C77B` on `#12251B` | the OFFLINE pill — it is a feature, style it like one |

Status colour mapping is fixed and used identically on boxes, the shelf table and the PDF:
`in_stock → success` · `below_plan → warning` · `stockout → danger` · `unlisted → info`.

### Type — Inter (bundle it; do not rely on a network font)

| Style | Size / weight | Use |
|---|---|---|
| `display` | 32 / 700 | totals, the big number |
| `title` | 22 / 600 | screen titles |
| `heading` | 17 / 600 | card headers, SKU names |
| `body` | 15 / 400 | |
| `label` | 13 / 500, +0.3 tracking | field labels |
| `mono` | 14 / 500 tabular figures | **all quantities, money, latency** |

Tabular figures for every number. Steppers whose digits shift width look broken.

### Spacing & shape
4 / 8 / 12 / 16 / 24 / 32. Screen padding 16. Card radius 12, sheet radius 20, pill radius 999.
Elevation via `surfaceAlt` fills, not shadows — shadows are invisible on a dark OLED panel.

## 3. Layout skeleton

```
┌──────────────────────────────┐
│  title            [OFFLINE]  │  ← status, non-interactive
│                              │
│                              │
│         CONTENT              │  ← scrollable
│         (scroll)             │
│                              │
├──────────────────────────────┤
│  ▸ sticky summary bar        │  ← running total, counts
├──────────────────────────────┤
│  ┃  PRIMARY ACTION  56 dp  ┃ │  ← thumb arc, full width minus 16
└──────────────────────────────┘
```

The OFFLINE badge is persistent and always visible. It is the product's thesis and the judges will
look at it.

## 4. Screens

### `/beat` — Today's beat
- Header: beat name + date. Progress bar under it.
- Summary strip: `7/12 done · ₹18,400 · 3 stockouts` — mono figures.
- Store rows, 72 dp: sequence number in a circle, name + code, status pill on the right.
  - `pending` grey · `draft` amber with a **Resume** label · `done` green check
- FAB bottom-right: **Export beat**.
- Empty state: *"No stores in this beat"* + a **Load demo beat** button. (You will need this.)

### `/store/:id` — Pre-visit brief
Read-only, scannable in three seconds while walking in.
- Store name, code, owner, phone (tap to call).
- Three stat tiles: *Last visit* · *Last order value* · *Stockouts last time*.
- Planogram preview: top 5 SKUs with target facings.
- Bottom: **Start visit** (56 dp, primary).

### `/capture`
- Full-bleed preview. No chrome except a top scrim with the store name.
- Bottom arc: torch toggle (left, 48 dp), **shutter 72 dp** (centre, `primary` ring), gallery/last
  shot (right, 48 dp).
- Thin framing guide, 8% opacity, hinting at a full rack.
- Post-shutter: frame freezes, dims to 60%, a determinate ring fills at the centre with the stage
  name beneath (`Finding packs…` → `Recognising…`). **Show the elapsed ms when it completes** —
  700 ms of visible speed is a pitch asset, do not hide it.

### `/review` — the critical screen
- Photo fills the viewport, pinch-zoom, pan. Boxes are an overlay layer.
- Box style: 2 dp outline in the state colour, 20% fill. A chip at the top-left of each box carries
  the SKU code (matched) or `?` (low confidence) or nothing (unmatched, but the outline pulses).
- Chips hide automatically below a zoom threshold so a dense rack stays readable.
- Bottom sheet, 3 collapsed / expandable:
  - collapsed: `14 packs · 11 matched · 3 need tagging`
  - expanded: list of unmatched boxes, tap to jump and zoom to each.
- Primary action: **Continue** — always enabled, labelled `Continue (3 untagged)` when relevant.

**SKU picker sheet** (on box tap):
- Top: the cropped image of that box, 96 dp. Anchors the rep in what they are tagging.
- Then: top-3 ranked candidates as large rows with name, grammage and a confidence bar.
- Then: search field + full list.
- Bottom: **➕ Enrol this pack** — primary-tinted. The demo hinges on this being one tap away.

### `/shelf`
Table grouped by status, stockouts first, a 4 dp status bar down the left of each row.
Columns: SKU (name + grammage) · `PLAN` · `FOUND` · status pill. All numbers mono.
Sticky footer: `3 stockouts · 2 below plan · 9 in stock`.

### `/order`
Card per line:
```
┌────────────────────────────────────┐
│ Instant noodles, masala      70 g  │
│ suggested 24            ₹336       │
│        ┌────┐  ┌────┐  ┌────┐      │
│        │ ─  │  │ 24 │  │ +  │      │  ← 56 dp steppers
│        └────┘  └────┘  └────┘      │
└────────────────────────────────────┘
```
- `suggested` in `textSecondary`, small. The stepper value is `display`-weight.
- Overridden lines get a 4 dp `primary` bar on the left edge.
- Long-press the value → numeric keypad, for a jump from 4 to 48.
- Sticky footer: line count + total, then **Continue**.
- Secondary action: **+ Add line** — for what the owner asks for that isn't on the shelf.

### `/voice`
Large hold-to-record circle (96 dp), live waveform, 30 s countdown ring. On release: transcript in
an editable field. A subtle *"Writing visit record…"* shimmer while the LLM runs, which **never
blocks the Continue button**.

### `/enrol`
Stepper header: `1 Details → 2 Capture → 3 Test`.
- Capture step: a coverage grid of 8 slots labelled `bright / dim / angled / occluded`, filling
  with thumbnails. Minimum 3 unlocks **Test it now**.
- Test step: re-runs the last shelf photo and shows the new pack lighting up green.

Drive the whole flow to under 45 seconds. Audit every tap.

### `/export`
Three artefact cards (XLSX / CSV / PDF) with icon, filename, size, and state (idle → generating →
done). One **Generate all** button. On completion → `/handover`.

### `/handover`
Per-file **Share** row, plus a **Serve on Wi-Fi** toggle. When on: a large QR and the URL in mono.

### `/benchmark`
Two columns, `ON-DEVICE` (primary tint) vs `CLOUD BASELINE` (grey, and labelled **pre-computed**
in a caption — be visibly honest). Top: two big accuracy percentages and two latencies. Below:
per-image thumbnail rows.

### `/diagnostics`
Model cards with a load pill, latency, run count. Threshold sliders with live values. A large
connectivity card. Danger-zone buttons at the bottom: re-seed, wipe visits, dump logs.

## 5. Motion

Keep it near-zero. 150 ms fades, 200 ms sheet slides, standard easing.
**The only deliberate animation is the box reveal in `/review`** — boxes stagger in over ~250 ms
total. It reads as the model working and it lands on stage. Nothing else animates.

## 6. Accessibility & field conditions

- Contrast ≥ 4.5:1 on all body text against `bg` and `surface`.
- Never encode meaning in colour alone: every status has a colour **and** a word.
- Respect system text scaling to 1.3×; test at 1.3× before the freeze.
- Semantic labels on every icon-only button.
- Haptic on shutter, on stepper bounds, on visit confirm.
- Assume glare and grime: no hairline-only affordances, no 1 dp dividers as the sole separator.

## 7. Voice and copy

Plain, short, never chirpy. The rep is at work.

| Instead of | Write |
|---|---|
| "Oops! Something went wrong 😕" | "No packs found. Tap to draw boxes." |
| "AI-powered suggestion" | "suggested 24" |
| "Processing your request…" | "Finding packs…" |
| "Successfully exported!" | "Beat 12 · 11 visits · order_beat12.xlsx" |

Never say "AI" in the UI. Say what it did.

## 8. Things not to build

No onboarding carousel. No settings screen beyond Diagnostics. No dark/light toggle. No animated
splash. No charts inside the app — charts belong in the PDF and on the deck. Every hour spent here
is an hour not spent on `/review`, which is the only screen that decides whether you win.
