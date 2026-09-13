# ShelfSense — Submission

**Event:** iQOO City Battle Chennai · 12–13 Sep 2026 · Productivity track · Students bucket
**Team:** 3 (A — models, B — app, C — output & AI)
**Repo:** https://github.com/ARCHIT3024/ShelfSense · tag **`demo`**
**APK:** `dist/ShelfSense-demo-arm64.apk` (48.5 MB, arm64) — also attached to the `demo` GitHub release
SHA-256 `ec37d852256e71853bc0b968b890bf6ad5cf36363515cfac4fdb0f460ff092d3`

## What it is

Offline shelf audit and ordering for kirana distributor reps. The rep photographs a shelf; the
phone finds every pack, recognises the enrolled SKUs, diffs against the store's planogram,
drafts the reorder, and writes the XLSX / CSV / PDF on the handset. No server, no account, no
network call on the core path — verified in aeroplane mode. New products are enrolled by
photographing them; they are recognisable immediately, with no retraining and no app update.

## What runs on the device (iQOO 15, Android 16)

| Stage | Model / component | Measured on the demo phone |
|---|---|---|
| Pack Finder | YOLO11n INT8, 3.0 MB, trained on SKU-110K during the build window | 25–35 ms inference (GPU); mAP50 0.889 on 2,935 held-out test images |
| SKU Recogniser | MobileNetV3-Small + 128-d head, fp16, 2.0 MB, trained on 148 in-app enrolment crops | ~2 ms per crop; 97.1 % held-out top-1 over 17 SKUs; live 7/7 Red Bull cans at 0.65–0.77 cosine |
| OCR tie-break | ML Kit Latin, on low-confidence same-brand size variants only | 50–150 ms per crop |
| Shutter → recognised boxes | | **~0.8–0.9 s** end to end |
| Cold start | | 1.0–1.15 s |
| Peak memory during detection | | 400 MB |

Everything else — planogram diff, reorder engine, override log, XLSX/CSV/PDF, Wi-Fi handover
server, diagnostics — is pure Dart and runs in the same process.

## Acceptance criteria (PRD §5)

A-01 cold start ✅ · A-02 shutter ≤ 1 s ✅ · A-05 enrol ≤ 45 s ✅ · A-06 XLSX ≤ 3 s ✅ ·
A-07 10× demo path, 0 crashes ✅ · A-08 zero network (aeroplane mode) ✅ · A-09 works with no
LLM ✅ · A-10 RSS ≤ 1.5 GB ✅ · A-03/A-04 measured on real packs ✅ with one caveat below.

## Honest limitations

- **The Pack Finder needs shelf-distance framing.** Trained on SKU-110K (dozens of small packs per
  image), it finds nothing when one or two products fill the frame. From ~1 m with several packs
  in view it boxed 7/7 cans and 100/100 on a dense shelf. Close-ups use the manual path:
  long-press-draw a box, the recogniser labels it in ~150 ms, and the correction is logged.
- **Same-shape, same-brand-family bottles can swap** (Sprite vs Thums Up at 0.58–0.68). More
  enrolment shots with the label square-on separate them; the OCR tie-break handles size variants.
- **Not built:** voice note → ASR → on-device LLM (the deterministic visit record fills every field
  the LLM would); on-device-vs-cloud benchmark screen. Both are documented as roadmap.

## Judge demo (3 minutes)

`docs/DEMO_SCRIPT.md` — exact taps, what to say, and an "if X goes wrong, do Y" table.
Before starting: Diagnostics → **Reset demo data** (keeps catalogue and enrolment).

## Where things are

| | |
|---|---|
| App | `lib/` — Flutter 3.44, Riverpod 3, drift, go_router, tflite_flutter (LiteRT 1.4.2) |
| Models + training | `ml/pack_finder/` (scripts, yamls, best.pt, reports) · `ml/embedder/` (train/verify scripts, crops, results.json) |
| Bundled models | `assets/models/detector_int8.tflite`, `assets/models/embedder_fp16.tflite` |
| Docs | `docs/00_START_HERE.md` → `06_APP_FLOW.md` (the plan), `docs/PROGRESS.md` (what actually happened, with timestamps), `docs/DEMO_SCRIPT.md` |
| Tests | `test/` — 140 unit tests (`flutter test`) |
| Licences | `ATTRIBUTION.md` — every package, model weight and dataset; Syncfusion Community Licence registered |
| Tags | `L0` → `L0.5-detector` → `L1` → `demo-rc1..4` → **`demo`** |

## Build

```
flutter pub get
flutter build apk --release --split-per-abi --target-platform android-arm64
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
adb shell pm grant com.shelfsense.app android.permission.CAMERA
```
Gradle notes (compileSdk 36, LiteRT 1.4.2, permission_handler 11.x) are in `README.md`.

## Originality

Repository initialised empty inside the build window; every line of application code, both
models' training runs and both exported `.tflite` files were produced during the event. Open-source
packages and the SKU-110K dataset / ImageNet backbone weights are credited in `ATTRIBUTION.md`.
