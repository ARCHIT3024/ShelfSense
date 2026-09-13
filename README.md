# ShelfSense

> **Judges:** start with [`SUBMISSION.md`](SUBMISSION.md) — one-page summary, numbers, limitations, where everything is. Demo script: [`docs/DEMO_SCRIPT.md`](docs/DEMO_SCRIPT.md).

Offline shelf audit and ordering for kirana distributor reps. The rep photographs a shop's rack;
the phone finds every pack, recognises which SKU each one is, diffs the shelf against the store's
planogram, drafts a reorder, and writes the order as XLSX, CSV and a beat-summary PDF — all on the
handset, with the radios off. There is no server. The phone is the backend.

Built in the iQOO City Battle Chennai build window, 12–13 Sep 2026 (Productivity track, Students
bucket), for the iQOO 15 (Snapdragon 8 Elite Gen 5, Android 16). Three students. Repo initialised
empty at the start of the window; every line under `lib/`, `ml/` and `assets/` was written during it.

## What works on the device

The build ladder is L0 → L3. Each level is tagged in git once it runs on the physical phone.

| Level | Tag | Ships | Status |
|---|---|---|---|
| **L0** | `L0` | Capture → boxes → manual SKU tag → planogram diff → order draft → XLSX + CSV on device, shared via the OS share sheet | ✅ done |
| **L0.5** | `L0.5-detector` | Class-agnostic Pack Finder (YOLO11n INT8) live on the GPU | ✅ done |
| **L1** | `L1` | SKU enrolment on the phone (8 shots, no retraining) → embedding recogniser → boxes auto-labelled green / amber / blue → facings, stockouts, below-plan | ✅ done — 13 SKUs enrolled from the test set; accuracy on the physical rack depends on re-enrolling real packs (45 s each) |
| **L2** | — | Beat-summary PDF + structured visit record and reorder rationale | ✅ PDF and the deterministic (non-LLM) record are live · ✗ voice note → on-device ASR → LLM: roadmap |
| **L3** | — | Wi-Fi handover server + QR · OCR grammage tie-break · on-device vs cloud benchmark | ✅ handover · ⏳ OCR tie-break in progress · ✗ benchmark not built |

Zero network calls on the demo path. The only network feature is the handover *server*, which the
phone hosts for a laptop on the same hotspot; it is off by default and never fetches anything.

## How it works

```
still JPEG (shutter press — never the preview stream)
   │
   ▼  decode · letterbox 640 · isolate
Stage A  Pack Finder ─ YOLO11n INT8, single class ─ GPU delegate ─ 32 ms
   │  class-agnostic boxes, NMS
   ▼  crop every box · resize 224 · ImageNet-normalise · isolate
Stage B  SKU Recogniser ─ MobileNetV3-Small + 128-d head, fp16 ─ ~2 ms per crop
   │  cosine kNN against enrolled vectors in memory (SkuIndex)
   │  ≥ 0.72 accept (green) · 0.55–0.72 ranked choice (amber) · else unmatched (blue)
   ▼
/review   rep confirms or corrects — every correction is logged as an override event
   ▼
FacingCounter → PlanogramDiff → shelf_facts (in_stock · below_plan · stockout · unlisted)
   ▼
ReorderEngine → order draft (planogram gap, trailing-history floor, whole-case rounding)
   ▼
/order  steppers · add line · confirm
   ▼
XLSX (Syncfusion) · CSV · beat PDF (pdf) · deterministic visit record
   ▼
OS share sheet   or   /handover: local HTTP server on the hotspot + QR
```

Everything lives in one SQLite database (drift). Enrolment shots stay on disk as crops, so a new
recogniser model re-embeds them at the next app start without re-shooting.

## Numbers (measured, not estimated)

| | |
|---|---|
| Pack Finder, held-out SKU-110K test (2,935 images, 431k packs) | P 0.887 · R 0.813 · **mAP50 0.889** · mAP50-95 0.531 |
| Recogniser, held-out enrolment crops (26, 13 SKUs) | top-1 nearest neighbour **26 / 26** |
| iQOO 15 — detect (640 px, GPU) | **32 ms** inference · ~350 ms with JPEG decode + letterbox |
| iQOO 15 — embed | **~2 ms per crop** |
| iQOO 15 — shutter press → boxes recognised on screen | **~760 ms** |
| Model load at app start | detector 0.7 s · recogniser 0.9 s (OpenCL shader compile, once) |
| Bundled models | `detector_int8.tflite` 3.0 MB · `embedder_fp16.tflite` 2.0 MB |
| Unit tests | 113 (`flutter test`) |
| Network calls on the demo path | 0 |

## Repository layout

```
lib/
  app/            router, theme tokens, DI providers
  core/           Result/Failure, ids, logger
  data/db/        drift schema (14 tables) + seed loader
  domain/         dependency-free models; FacingCounter, PlanogramDiff, ReorderEngine
  features/       beat · store · capture · review · shelf_report · order · enrolment
                  export · handover · diagnostics
  ml/detector     TfliteDetector + pure YOLO decode/NMS
  ml/embedder     TfliteEmbedder + in-memory SkuIndex (cosine kNN)
  ml/ocr, ml/llm, ml/asr   service interfaces (OCR in progress; LLM/ASR roadmap)
  output/         xlsx_builder · csv_builder · pdf_builder
ml/pack_finder/   SKU-110K conversion + subset scripts, dataset yamls, best.pt, eval reports
ml/embedder/      train_embedder.py · verify_embedder.py · crops/ (enrolment set) · results
assets/models/    the two .tflite files the app loads
assets/seed/      demo beat: 12 stores, 29 SKUs, planograms
docs/             PRD · TRD · plan · UI spec · schema · app flow · PROGRESS.md · DEMO_SCRIPT.md
test/             domain, output, ml, features
```

## Build and run

Flutter 3.44 (Dart 3.12), Android SDK with platform 36, JDK 17.

```
flutter pub get
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
adb shell pm grant com.shelfsense.app android.permission.CAMERA   # skips the runtime prompt
```

Three Gradle settings are deliberate and documented in `docs/PROGRESS.md` ("Release build notes");
do not "fix" them:

- `compileSdk`/`targetSdk` pinned to **36** for the app and every plugin module — the Flutter
  default (37) only exists as `android-37.0`, which AGP 9 cannot resolve.
- `permission_handler` pinned to `^11.4.0`; 13.x hard-requires compileSdk 37.
- **LiteRT 1.4.2** forced in `android/app/build.gradle.kts` — the plugin's 1.4.0 rejects the
  exported detector, and 2.x drops the classic C API the Dart FFI binds. Kotlin compiles
  in-process, non-incrementally (Kotlin 2.3 incremental caches fail on this toolchain).

`flutter analyze` has zero errors; `flutter test` runs the 113 unit tests without a device.

To swap a model, drop the file into `assets/models/` and rebuild — the loaders read the tensor
shapes at start and log them (`adb logcat -s flutter | grep -E "TfliteDetector|TfliteEmbedder"`).
Contracts: detector `[1,3,640,640]` or `[1,640,640,3]` in, `[1,5,8400]` out; embedder
`[1,224,224,3]` in, `[1,128]` L2-normalised out. A model that fails its contract check leaves the
app in manual-box mode; it never crashes.

## The demo, in eight steps

1. **Beat** — today's stores with Done / Resume / Pending and the running total. `OFFLINE` badge top right.
2. **Store** — last visit, last order value, stockouts last time, planogram top 5. *Start visit.*
3. **Capture** — one shutter press on the rack. `Finding packs… Recognising…` — under a second.
4. **Review** — green boxes carry the SKU code; amber ones open a ranked choice; blue ones are
   untagged. Tap to correct, long-press to resize or delete, long-press empty space to draw.
5. **Enrol** — an unknown pack: *Enrol this pack* → name and grammage → 2 more shots → *Done*.
   The box turns green; the next photo recognises it. Under 45 seconds, no retraining.
6. **Shelf** — plan vs found per SKU: stockouts first, then below plan, unlisted, in stock.
7. **Order** — suggested quantities, steppers by the case, *Add line* for what the owner asks for.
   *Confirm* writes the visit and the files.
8. **Export** — *Generate all* → XLSX + CSV + PDF in one share sheet, then **Handover**: *Serve on
   Wi-Fi* shows a URL and QR; a laptop on the same hotspot downloads the files from the phone.

`docs/DEMO_SCRIPT.md` has the timed script and the what-if table. `docs/PROGRESS.md` is the
engineering log. Licences and model provenance: [ATTRIBUTION.md](ATTRIBUTION.md).
