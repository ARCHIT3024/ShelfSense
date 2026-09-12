# 05 — Data Schema (on-device)

There is no server. "Backend" here means the on-device persistence layer: **drift over SQLite**.
A speculative future sync contract is in §9 — **do not build it this weekend.**

## Conventions

- Primary keys: `TEXT`, UUID v4, generated in Dart (`lib/core/ids.dart`).
- Timestamps: `INTEGER`, Unix **milliseconds UTC**. Never store local time.
- Money: `INTEGER` **paise**. Never a float. Divide by 100 only at render time.
- Enums: `TEXT`, lowercase snake_case, with a Dart enum + `CHECK` constraint.
- Booleans: `INTEGER` 0/1.
- Embeddings: `BLOB` = 128 × `float32` little-endian = **512 bytes exactly**.
- Soft delete via `is_active` where history matters; hard delete nowhere.

---

## 1. `beats`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `code` | TEXT NOT NULL UNIQUE | e.g. `BEAT-12` |
| `name` | TEXT NOT NULL | |
| `rep_name` | TEXT | |
| `created_at` | INTEGER NOT NULL | |

## 2. `stores`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `code` | TEXT NOT NULL UNIQUE | e.g. `KIR-0412` — appears in the export |
| `name` | TEXT NOT NULL | |
| `beat_id` | TEXT NOT NULL FK→beats.id | |
| `address` | TEXT | |
| `owner_name` | TEXT | |
| `phone` | TEXT | |
| `lat` / `lng` | REAL NULL | registered location, not visit location |
| `sequence` | INTEGER NOT NULL DEFAULT 0 | order within the beat |
| `created_at` | INTEGER NOT NULL | |

`INDEX idx_stores_beat ON stores(beat_id, sequence)`

## 3. `skus`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `code` | TEXT NOT NULL UNIQUE | e.g. `NDL-70` |
| `name` | TEXT NOT NULL | display name |
| `brand` | TEXT | |
| `category` | TEXT | |
| `grammage_value` | REAL NULL | **the field that separates near-identical packs** |
| `grammage_unit` | TEXT NULL | `g` \| `kg` \| `ml` \| `l` \| `n` |
| `variant` | TEXT NULL | e.g. `masala`, `plain` |
| `mrp_paise` | INTEGER NOT NULL DEFAULT 0 | |
| `case_size` | INTEGER NOT NULL DEFAULT 1 | units per case; used by `round_to_case` |
| `is_enrolled` | INTEGER NOT NULL DEFAULT 0 | has ≥ `kMinEnrolShots` active embeddings |
| `is_active` | INTEGER NOT NULL DEFAULT 1 | |
| `created_at` | INTEGER NOT NULL | |

`INDEX idx_skus_active ON skus(is_active, is_enrolled)`

## 4. `sku_embeddings`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `sku_id` | TEXT NOT NULL FK→skus.id | |
| `vector` | BLOB NOT NULL | 512 bytes, L2-normalised |
| `source_image_path` | TEXT | the enrolment crop, kept for re-training |
| `capture_context` | TEXT NULL | `bright` \| `dim` \| `angled` \| `occluded` — helps you see coverage gaps during enrolment |
| `is_active` | INTEGER NOT NULL DEFAULT 1 | |
| `created_at` | INTEGER NOT NULL | |

`INDEX idx_emb_sku ON sku_embeddings(sku_id, is_active)`

**Load the whole active set into memory once at startup** (`SkuIndex`). ~40 SKUs × 8 = 320 vectors
= 160 KB. Never query this table inside the detection loop.

## 5. `planogram_entries`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `store_id` | TEXT NOT NULL FK→stores.id | |
| `sku_id` | TEXT NOT NULL FK→skus.id | |
| `target_facings` | INTEGER NOT NULL | |
| `shelf_row` | INTEGER NULL | 1 = top |
| `source` | TEXT NOT NULL | `manual` \| `history` \| `default` |
| `updated_at` | INTEGER NOT NULL | |

`UNIQUE(store_id, sku_id)` · `INDEX idx_plano_store ON planogram_entries(store_id)`

Most real stores have no planogram. When absent, `PlanogramRepo.resolve(storeId)` synthesises one
from the trailing three confirmed orders and writes it with `source = 'history'`. If there is no
history either, it uses the beat-level default with `source = 'default'`. **The resolution order is
`manual > history > default` and must never silently vary.**

## 6. `visits`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `store_id` | TEXT NOT NULL FK→stores.id | |
| `beat_id` | TEXT NOT NULL FK→beats.id | denormalised on purpose — the export groups by beat |
| `status` | TEXT NOT NULL | `draft` \| `confirmed` \| `exported` |
| `started_at` | INTEGER NOT NULL | |
| `confirmed_at` | INTEGER NULL | |
| `lat` / `lng` | REAL NULL | captured at confirm |
| `gps_accuracy_m` | REAL NULL | |
| `was_offline` | INTEGER NOT NULL DEFAULT 1 | **set from the real connectivity state — this is evidence for the pitch, do not hardcode it** |
| `note_audio_path` | TEXT NULL | |
| `note_transcript` | TEXT NULL | from ASR or typed |
| `llm_summary` | TEXT NULL | free text only |
| `llm_rationale` | TEXT NULL | free text only |
| `llm_model_id` | TEXT NULL | null ⇒ deterministic fallback was used |
| `duration_ms` | INTEGER NULL | started_at → confirmed_at; **this is your Productivity KPI** |

`INDEX idx_visits_beat_status ON visits(beat_id, status)`

## 7. `visit_photos`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `visit_id` | TEXT NOT NULL FK→visits.id | |
| `file_path` | TEXT NOT NULL | app-private storage |
| `width` / `height` | INTEGER NOT NULL | original pixels — needed to denormalise boxes |
| `detect_latency_ms` | INTEGER NULL | per-photo; feeds the benchmark slide |
| `captured_at` | INTEGER NOT NULL | |

## 8. `detections`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `visit_id` | TEXT NOT NULL FK→visits.id | |
| `photo_id` | TEXT NOT NULL FK→visit_photos.id | |
| `x1`,`y1`,`x2`,`y2` | REAL NOT NULL | **normalised 0–1 against the original photo.** Never store pixels. |
| `det_confidence` | REAL NOT NULL | stage A |
| `sku_id` | TEXT NULL FK→skus.id | null = unmatched |
| `match_confidence` | REAL NULL | cosine similarity, stage B |
| `match_method` | TEXT NOT NULL | `embedding` \| `ocr_tiebreak` \| `manual` \| `unmatched` |
| `shelf_row` | INTEGER NULL | assigned by y-clustering |
| `is_gap` | INTEGER NOT NULL DEFAULT 0 | advisory visual gap, not a stockout |
| `was_corrected` | INTEGER NOT NULL DEFAULT 0 | |
| `embedding` | BLOB NULL | kept only for corrected boxes — free future training data |
| `created_at` | INTEGER NOT NULL | |

`INDEX idx_det_visit ON detections(visit_id)`

## 9. `shelf_facts` — derived, recomputed, never hand-edited

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `visit_id` | TEXT NOT NULL FK→visits.id | |
| `sku_id` | TEXT NOT NULL FK→skus.id | |
| `detected_facings` | INTEGER NOT NULL | |
| `target_facings` | INTEGER NOT NULL | |
| `status` | TEXT NOT NULL | `in_stock` \| `below_plan` \| `stockout` \| `unlisted` |
| `computed_at` | INTEGER NOT NULL | |

`UNIQUE(visit_id, sku_id)`

Delete-and-reinsert the whole visit's set on every recompute. Cheap, and it removes an entire class
of stale-row bug you do not have time to debug at 04:00.

## 10. `order_lines`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `visit_id` | TEXT NOT NULL FK→visits.id | |
| `sku_id` | TEXT NOT NULL FK→skus.id | |
| `suggested_qty` | INTEGER NOT NULL | model's draft — **never mutated after creation** |
| `final_qty` | INTEGER NOT NULL | what the rep confirmed |
| `unit` | TEXT NOT NULL | `case` \| `piece` |
| `value_paise` | INTEGER NOT NULL | `final_qty × mrp_paise × (case_size if unit=case)` |
| `was_overridden` | INTEGER NOT NULL DEFAULT 0 | `final_qty != suggested_qty` |
| `created_at` | INTEGER NOT NULL | |

`UNIQUE(visit_id, sku_id)`

Keeping `suggested_qty` immutable is what lets you compute and show the **override rate** — the
metric slide 11 promises to watch.

## 11. `override_events` — the training-signal log

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `visit_id` | TEXT NOT NULL | |
| `entity` | TEXT NOT NULL | `detection` \| `order_line` |
| `entity_id` | TEXT NOT NULL | |
| `field` | TEXT NOT NULL | `sku_id` \| `final_qty` \| `box` \| `deleted` |
| `old_value` | TEXT NULL | |
| `new_value` | TEXT NULL | |
| `created_at` | INTEGER NOT NULL | |

## 12. `export_batches`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `beat_id` | TEXT NOT NULL | |
| `visit_count` | INTEGER NOT NULL | |
| `line_count` | INTEGER NOT NULL | |
| `total_value_paise` | INTEGER NOT NULL | |
| `xlsx_path`, `csv_path`, `pdf_path` | TEXT NULL | |
| `created_at` | INTEGER NOT NULL | |

On success, every included visit moves `confirmed → exported` in the same transaction.

## 13. `model_registry`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `kind` | TEXT NOT NULL | `detector` \| `embedder` \| `llm` \| `asr` \| `ocr` |
| `label` | TEXT NOT NULL | e.g. `yolo11n-sku110k-int8` |
| `asset_path` | TEXT NOT NULL | |
| `loaded_ok` | INTEGER NOT NULL DEFAULT 0 | |
| `load_ms` | INTEGER NULL | |
| `mean_latency_ms` | REAL NULL | rolling mean |
| `run_count` | INTEGER NOT NULL DEFAULT 0 | |
| `last_error` | TEXT NULL | |

Drives the Diagnostics screen and supplies the real numbers that replace the `000 ms` placeholders
on deck slide 9.

## 14. `benchmark_runs` (L3)

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `eval_image` | TEXT NOT NULL | filename in `assets/benchmark/eval_set/` |
| `mode` | TEXT NOT NULL | `on_device` \| `cloud_baseline` |
| `model_label` | TEXT NOT NULL | |
| `latency_ms` | INTEGER NOT NULL | cloud latency comes from the pre-computed JSON |
| `correct_count` / `total_count` | INTEGER NOT NULL | vs your hand-labelled ground truth |
| `created_at` | INTEGER NOT NULL | |

Cloud rows are **seeded from `assets/benchmark/cloud_baseline.json`**, produced during a Green Light
block. The app never calls a cloud API at runtime.

## 15. `app_settings`

`key TEXT PK, value TEXT NOT NULL, updated_at INTEGER NOT NULL`

Seeded keys: all thresholds from TRD §4.1, plus `llm_enabled`, `ocr_enabled`, `demo_mode`,
`active_beat_id`.

---

## 16. Seeding

`assets/seed/` ships one beat, 8–12 stores with realistic Chennai-style codes, ~40 SKUs matching
the physical packs you buy, and a planogram for every store. Seed runs once on first launch.

**Add a `demo_mode` reset** that wipes visits and re-seeds without touching `skus` or
`sku_embeddings`. You will use it between demo runs, and losing your enrolment set at 08:45 Sunday
would be unrecoverable.

## 17. Future sync contract — DO NOT BUILD THIS WEEKEND

Documented only so the roadmap slide is credible. If asked on stage: a delta `POST /visits` with
idempotent keys `{device_id}:{visit_id}`, resumable multipart photo upload, and a weights-bundle
download endpoint. **None of it exists, and saying so is a strength, not a gap.**
