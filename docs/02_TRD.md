# 02 — Technical Requirements Document

## 1. Target

| | |
|---|---|
| Device | iQOO 15 — Snapdragon 8 Elite Gen 5, Adreno 840, Android 16, 12/16 GB RAM ⚠️ ASSUMPTION: variant unknown |
| Min SDK | 26 |
| Target SDK | Latest available in the installed Flutter/AGP toolchain |
| Orientation | Portrait locked |
| Network | **None required.** App must pass a full run in aeroplane mode. |

## 2. Stack

```
Flutter (Dart) ── UI, state, persistence, file generation, LLM/ASR orchestration
       │
       ├── tflite_flutter ──────── YOLO11n detector + MobileNetV3 embedder (GPU delegate)
       ├── google_mlkit_text_recognition ── offline OCR tie-break
       ├── flutter_gemma ───────── Gemma 3 1B int4 (MediaPipe LLM Inference)
       ├── whisper_ggml ────────── Whisper-tiny ASR   [fallback: speech_to_text offline]
       ├── drift ───────────────── SQLite persistence
       ├── syncfusion_flutter_xlsio ─ XLSX generation, pure Dart
       ├── pdf + printing ──────── PDF route summary, pure Dart
       └── shelf ───────────────── local HTTP handover server (L3)
```

Add every package with `flutter pub add <name>`. **Do not write version constraints from memory.**

**Escape hatch:** if Dart image preprocessing exceeds the budget in §6, move
resize → normalise → inference behind a Kotlin **platform channel** (`MethodChannel`
`com.shelfsense/vision`). Decide this once, at the R2 decision point, and do not revisit.

## 3. Directory layout

```
lib/
  main.dart
  app/            router.dart, theme.dart, di.dart
  core/           result.dart, failures.dart, logger.dart, clock.dart, ids.dart
  data/
    db/           database.dart, tables/*.dart, daos/*.dart
    repositories/ store_repo.dart, sku_repo.dart, visit_repo.dart,
                  planogram_repo.dart, order_repo.dart, export_repo.dart
    seed/         seed_data.dart
  ml/
    detector/     detector_service.dart, yolo_postprocess.dart, nms.dart
    embedder/     embedder_service.dart, sku_index.dart, cosine.dart
    ocr/          ocr_service.dart, grammage_parser.dart
    asr/          asr_service.dart
    llm/          llm_service.dart, prompts.dart, visit_record_parser.dart
    common/       image_preprocess.dart, model_registry.dart, isolate_runner.dart
  domain/
    models/       *.dart (pure Dart, no drift imports)
    services/     planogram_diff.dart, facing_counter.dart, reorder_engine.dart
  export/         xlsx_builder.dart, csv_builder.dart, pdf_builder.dart, handover_server.dart
  features/
    beat/ store/ capture/ review/ shelf_report/ order/ voice/ enrolment/
    export/ benchmark/ diagnostics/
      └── each: *_screen.dart, *_controller.dart, widgets/
assets/
  models/         detector_int8.tflite, embedder_int8.tflite, labels.json,
                  gemma3-1b-it-int4.task, whisper-tiny.bin
  benchmark/      eval_set/*.jpg, cloud_baseline.json
  seed/           seed_beats.json, seed_stores.json, seed_skus.json, seed_planogram.json
```

## 4. ML pipeline

```
still JPEG (camera)
   │
   ▼  decode + letterbox to 640×640, /255.0, NHWC   [isolate]
STAGE A — detector_int8.tflite
   │  class-agnostic "pack" boxes
   ▼  confidence filter → NMS
List<RawBox>  (x1,y1,x2,y2 normalised to original image, score)
   │
   ▼  crop each box from the full-res JPEG, resize 224×224   [isolate]
STAGE B — embedder_int8.tflite
   │  → Float32List(128), L2-normalised
   ▼  cosine similarity vs SkuIndex (all active sku_embeddings)
(skuId, score) ranked
   │
   ├── score ≥ MATCH_HIGH (0.72) ──────────► accept, method = embedding
   ├── MATCH_LOW ≤ score < MATCH_HIGH ─────► STAGE C, OCR tie-break  (L3)
   └── score < MATCH_LOW (0.55) ───────────► unmatched, prompt the rep
   │
   ▼
STAGE C — ML Kit OCR on the crop  (L3 only)
   │  extract numeric grammage + unit (g/kg/ml/L/N) and variant tokens
   ▼  re-rank the top-3 candidates by grammage agreement
   │
   ▼
Detection rows → FacingCounter → PlanogramDiff → ShelfFact rows
   │
   ▼
ReorderEngine → OrderLine rows (suggested_qty, editable)
   │
   ▼ (L2, non-blocking)
Voice note → Whisper-tiny → transcript ──┐
                                          ├──► Gemma 3 1B → visit record JSON + rationale
ShelfFacts + OrderLines serialised ──────┘
```

### 4.1 Thresholds (single source of truth — `lib/ml/common/thresholds.dart`)

```dart
const double kDetConfThreshold  = 0.35;
const double kDetNmsIou         = 0.50;
const int    kDetMaxBoxes       = 100;
const double kMatchHigh         = 0.72;  // accept
const double kMatchLow          = 0.55;  // below this = unmatched
const int    kMinEnrolShots     = 3;
const int    kTargetEnrolShots  = 8;
const double kGapMinArea        = 0.004; // fraction of image, for empty-slot heuristic
```

Every threshold must be overridable at runtime from the Diagnostics screen. You will retune these
against the physical shelf at 22:00 Saturday, and you will not want to rebuild to do it.

### 4.2 Tensor contracts

**Detector (Ultralytics YOLO11n, TFLite export)**
- Input: `[1, 640, 640, 3]`, `float32`, range `0.0–1.0`, **NHWC**, RGB, letterboxed with grey padding.
- Output: `[1, 5, 8400]` for a single class — rows are `[cx, cy, w, h, score]`, coordinates in
  **pixels relative to the 640×640 letterboxed input**. Requires a transpose before decoding.
- **⚠️ VERIFY, DO NOT ASSUME.** The first thing `detector_service.dart` must do on load is dump
  `interpreter.getInputTensors()` / `getOutputTensors()` to the log and assert the shape. INT8
  exports carry quantisation params that shift the decode path. Write the assertion before the
  decode logic.
- Post-process: undo letterbox → normalise to `[0,1]` of the **original** image → class-agnostic NMS.

**Embedder (MobileNetV3-Small + projection head, our own export)**
- Input: `[1, 224, 224, 3]`, `float32`, ImageNet mean/std normalised, NHWC, RGB.
- Output: `[1, 128]`, `float32`, **L2-normalised at export time** so runtime similarity is a plain
  dot product.
- Training: ArcFace or triplet loss over the enrolment crops. Frozen backbone, train the head only —
  minutes, not hours, on a 6 GB card.

**LLM**
- `gemma3-1b-it-int4.task`, loaded via `flutter_gemma`. GPU backend. `maxTokens` 512, `topK` 40,
  `temperature` 0.2 (low — this is structured extraction, not creative writing).

**ASR**
- `whisper-tiny` GGML. 16 kHz mono PCM input. Hard cap 30 s per note.

### 4.3 Model loading

All models load **lazily and independently**. A failure to load any single model must not prevent
app start. `ModelRegistry` records per-model `loaded_ok`, `load_ms` and `mean_latency_ms`, surfaced
on the Diagnostics screen. If the LLM fails to load, the app runs in deterministic mode silently —
the rep sees no error, only the absence of the rationale paragraph.

## 5. Core algorithms

### 5.1 Facing counter
Group accepted detections by `sku_id`. `detected_facings = count`. Detections within the same
`shelf_row` band (cluster box centres by y, tolerance = 0.6 × median box height) count as one row's
facings; store `shelf_row` for the report but do not use it to deduplicate.

### 5.2 Planogram diff

```
for each sku in (planogram_skus ∪ detected_skus):
    target   = planogram.target_facings   (0 if absent)
    detected = facings.get(sku)           (0 if absent)
    if target == 0 and detected  > 0 -> unlisted
    if target  > 0 and detected == 0 -> stockout
    if detected < target             -> below_plan
    else                             -> in_stock
```

### 5.3 Gap detection
A `stockout` is asserted from the planogram diff, not from pixels — that is the reliable signal.
Additionally, flag visual gaps: contiguous background regions on a shelf row wider than
`kGapMinArea` and bounded by two detected packs. **Visual gaps are advisory only and never override
the planogram diff.** Render them as dashed outlines.

### 5.4 Reorder engine

```
base       = max(0, target_facings - detected_facings)
trailing   = median(last 3 confirmed order qty for this store+sku)   // 0 if none
suggested  = round_to_case(max(base, trailing * 0.8))
capped     = min(suggested, target_facings * 2)     // never propose absurd quantities
```
`suggested_qty` is always presented as an **editable draft**. The app never submits an order on its
own. Every edit writes an `override_events` row — that is the training signal named on slide 11.

### 5.5 LLM contract
The prompt is in `lib/ml/llm/prompts.dart`. It receives a compact JSON of shelf facts + order lines
+ transcript, and must return **JSON only**. Because a 1B int4 model will not reliably honour a
schema:

1. Strip markdown fences and any prose before the first `{` / after the last `}`.
2. Parse tolerantly; accept missing keys.
3. Validate every field against the deterministic value computed in Dart.
4. **If any numeric field disagrees with the Dart computation, the Dart value wins.** The LLM may
   only contribute free-text fields: `summary`, `rationale`, `owner_requests[]`, `follow_up`.
5. On any parse failure, fall back to a templated summary. Log the failure; show nothing to the rep.

## 6. Performance budget (A-02: shutter → boxes ≤ 1000 ms)

| Stage | Budget | If exceeded |
|---|---|---|
| JPEG decode + letterbox (isolate) | 120 ms | Capture at lower resolution; cap the long edge at 1920 px |
| Detector inference (GPU delegate) | 250 ms | Drop `imgsz` to 512 |
| NMS + decode (Dart) | 30 ms | Cap `kDetMaxBoxes` |
| Crop + resize ×N (isolate, batched) | 200 ms | Batch the embedder; cap N at 40 crops |
| Embedder ×N | 250 ms | Batch input `[N,224,224,3]` in one call |
| Cosine kNN over ~320 vectors | < 5 ms | Non-issue |
| UI render | 100 ms | — |

**Preprocessing is the known Flutter trap.** All image work runs in a Dart isolate via
`compute()` or a long-lived `Isolate` with a port. If the measured total exceeds 300 ms for
preprocessing alone at the R2 decision point, take the platform-channel escape hatch.

Thermal: inference runs **only** on shutter press and during enrolment. Never in a loop.

## 7. Threading

| Work | Where |
|---|---|
| UI, drift queries | Main isolate |
| Image decode, resize, normalise, crop | Worker isolate |
| TFLite inference | Main isolate is acceptable (delegate work is off-CPU), but prefer `IsolateInterpreter` if it does not fight the GPU delegate. ⚠️ VERIFY on device — GPU delegate + isolate can be brittle. Fall back to main-isolate inference with preprocessing offloaded. |
| LLM generation | Plugin-managed, async, streamed to UI |
| File generation (XLSX/PDF) | Worker isolate |

## 8. Error handling

- Every service returns `Result<T, Failure>`. No exceptions cross a service boundary.
- Every ML stage has a defined degraded mode:
  - detector fails → manual box-drawing mode, app still usable
  - embedder fails → all boxes `unmatched`, manual tagging, app still usable
  - OCR fails → skip tie-break
  - ASR fails → text input field
  - LLM fails → deterministic templated summary
- **No degraded mode shows a red error to the rep.** Log it, surface it on Diagnostics only.

## 9. Security / privacy

- All data local. No telemetry, no analytics SDK, no crash reporter that phones home.
- Photos in app-private storage, not the public gallery.
- GPS captured at visit confirm only, never continuously.
- `BenchmarkService` is the **only** code permitted to touch the network, it is feature-flagged
  off by default, and it is never invoked on the demo path.

## 10. Build & release

- `flutter build apk --release --split-per-abi` (arm64-v8a is the only one you need).
- Model assets are large — confirm the APK installs and cold-starts on the device by **14:00
  Saturday**, not at 04:00 Sunday.
- Git tags: `L0`, `L1`, `L2`, `L3`, `demo`. Tag as each level passes on a physical device.
