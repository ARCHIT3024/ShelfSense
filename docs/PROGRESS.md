# ShelfSense — Session State / Resume Point

**Read this file first when resuming.** It is a living document — update it at the end of every
work session (or whenever you hand off) so the next session can pick up cold. It supplements,
never replaces, `00_START_HERE.md` and the numbered doc set — read those for the *why*; this file
is only the *where are we right now*.

Last updated: 2026-09-12, ~18:30 IST (R2, after C's merge). Event: iQOO City Battle Chennai, build window Sat 12 Sep 11:00 → Sun 13 Sep 06:30 hard
feature freeze. **This means we are inside the live build window — check the clock against
`docs/Work Flow.md` §2/§6 immediately on resume and figure out which Red/Green block we're
actually in.**

---

## ⚠️ Compliance gaps still open

1. **Syncfusion Community Licence** — **watermark check done 12 Sep 18:25: an XLSX produced by
   `buildOrderXlsxBytes()` contains no Syncfusion/trial/licence text in any XML part**, so this is
   purely the legal registration (an account sign-up at
   https://www.syncfusion.com/products/communitylicense, not an in-code key — verified this
   session that `syncfusion_flutter_xlsio` 34.2.7 has no `registerLicense` API) has not been
   confirmed done by a human. Do this before the first real export, not at 06:00. See
   `ATTRIBUTION.md` and `lib/output/xlsx_builder.dart` for the full note.
2. ~~APK-on-device not yet verified.~~ **Resolved 12 Sep ~16:08:** release APK built, clean-installed
   on the iQOO 15 (`I2501`, Android 16), cold-started, and Load Demo Beat → seeded store list
   verified on-device. See "Release build notes" below for the Gradle fixes that were needed.

Resolved this session: git repo now exists and is pushed (was previously entirely missing —
see git log for the initial commit), `ATTRIBUTION.md` now exists, and a real compile error in
`capture_screen.dart` (missing drift `Value` import) was fixed.

---

## Release build notes (12 Sep, G2) — read before touching `android/`

`flutter build apk --release` did **not** work out of the box; four fixes, all committed:

- `android/app/build.gradle.kts`: `compileSdk`/`targetSdk` pinned to **36**. Flutter's default (37)
  only exists in the SDK as the minor-versioned `android-37.0` package, which AGP 9.0.1 can't
  resolve from the plain `android-37` hash. `android/build.gradle.kts` forces all plugin modules
  to 36 as well.
- `permission_handler` downgraded to `^11.4.0` (its Android module 14.x hard-requires
  compileSdk 37 via AAR metadata). It isn't used in `lib/` yet — re-check if someone bumps it.
- `android/gradle.properties`: `kotlin.incremental=false`, `kotlin.compiler.execution.strategy=in-process`
  (Kotlin 2.3 incremental caches fail with "Storage ... is already registered" on this machine)
  and `kotlin.jvm.target.validation.mode=warning` (tflite_flutter / mlkit declare Java 11 vs Kotlin 17).
- `android/app/proguard-rules.pro` (new, wired into `release`): `-dontwarn` for the optional
  ML Kit script recognisers R8 chokes on, and `-keep` for `com.google.mlkit.**` / TFLite
  (R8 was stripping ML Kit's no-arg registrar constructors, which would break OCR at runtime).

Build takes ~3.5 min warm. APK ≈ 105 MB. Install: `adb install -r build/app/outputs/flutter-apk/app-release.apk`.
adb lives at `E:\Android\Sdk\platform-toolsdb.exe` (not on PATH).

**Gotchas for anyone writing UI:** theme `FilledButton`/`OutlinedButton` have
`minimumSize: Size.fromHeight(...)` = infinite width — never place one in a `Row` next to an
`Expanded`, it eats the row. Drift's row class for the `Skus` table is `SkusData`, not `Sku`
(`Sku` is the dependency-free domain model in `lib/domain/models`).

Also fixed: `beat_screen.dart` "Load Demo Beat" didn't refresh the list after seeding (the
FutureBuilder's future was recreated in `build`, and `markNeedsBuild` on the builder context
never re-ran it). Now a `ConsumerStatefulWidget` holding the future and re-creating it after seed.

## L0 on-device status (12 Sep 18:23, after C's push — build `1f63108` + merge fixes)

Full path driven on the iQOO 15: `/beat` → store → **Start Visit** → shutter → `/review` (stub
boxes) → tag one → **Continue** → `/shelf` **(still the stub screen)** → **Continue** → `/order`
(C's real screen: 8 SKUs drafted by ReorderEngine from the planogram diff, steppers step by one
case, running total) → **Confirm** → "Visit confirmed · 8 lines" with Share XLSX / Share CSV.
**L0 is demoable except `/shelf`** — that screen is the one remaining gap between review and order.

## Repo / git state

- Remote: `https://github.com/ARCHIT3024/ShelfSense.git`, branch `main`.
- Repo was empty (no commits) before this session's first push — consistent with the "empty repo
  at kickoff" rule, since the actual `git init` just happened to run late (this session), not at
  11:00 sharp. If judges or organisers ask, the honest framing is "written across the build window
  in the same working copy; git history starts partway through because we didn't `git init`
  in the first 15 minutes as T-00 calls for."
- **Give both other teammates' laptops write access / have them clone now** — T-00's stated exit
  criterion ("all 3 can push") is not yet independently confirmed.

---

## What exists right now (verified by reading the files, not by memory)

Project: Flutter app `shelfsense` at repo root. `pubspec.yaml` has all planned packages added and
resolved (`flutter pub get` succeeds). `flutter analyze` reports **zero errors** — only lint-level
info/warnings (unused imports, deprecated `withOpacity`, a couple of unused fields/locals in
`capture_screen.dart`/`beat_screen.dart`/`database.dart`/`models.dart` — safe to ignore or clean up
opportunistically, none block a build). `android/app` applicationId is `com.shelfsense.app`. No
`build/` directory yet in this working copy — **actual on-device install still needs verifying by
whoever has the phone (see compliance gaps above).**

### Done — maps to task IDs in `03_IMPLEMENTATION_PLAN.md`

| Task | What | Evidence |
|---|---|---|
| **T-03** | `flutter create` done, all packages added, portrait lock + status bar styling in `main.dart`, theme tokens built | `lib/main.dart`, `lib/app/theme.dart` (`AppColors`/`AppText`/`Sp` tokens used everywhere downstream) |
| **T-04** | Full drift schema — all 11 tables from `05_DATA_SCHEMA.md`, code-gen'd, seed loader | `lib/data/db/tables/*.dart`, `lib/data/db/database.dart` + generated `database.g.dart` (build_runner already run), `lib/data/seed/seed_data.dart` reading `assets/seed/seed_*.json` |
| **T-05 (partial)** | `/beat` and `/store/:storeId` routes wired and screens built against seeded data | `lib/app/router.dart`, `lib/features/beat/beat_screen.dart`, `lib/features/store/store_screen.dart` — both read live from `dbProvider`. No `/boot` splash route exists; router's `initialLocation` is `/beat` directly. |
| **T-06** | `/capture/:visitId` — camera still-capture screen built; **release APK installed and cold-started on the physical iQOO 15 (12 Sep 16:08)** | `lib/features/capture/capture_screen.dart`; build fixes in `android/` (see "Release build notes"). Camera screen itself not yet exercised on-device — that's T-10. |
| **T-08 (C — complete)** | `xlsx_builder.dart` — production XLSX with styled headers, totals, freeze pane, override highlighting. `buildOrderXlsxBytes()` in-memory API for tests. 9 unit tests passing. | `lib/output/xlsx_builder.dart`, `test/output/xlsx_builder_test.dart`. Committed `3ad1342`. **⚠️ Still need on-device watermark check — run `writeHelloWorldXlsx()` on iQOO 15 before trusting real exports.** |
| **T-08 (C — complete)** | `csv_builder.dart` — RFC 4180 with CRLF, UTF-8 BOM, field quoting. `buildOrderCsvBytes()` in-memory API. 21 unit tests passing. | `lib/output/csv_builder.dart`, `test/output/csv_builder_test.dart`. Committed `021fc8f`. |
| **T-18 (C — complete)** | `facing_counter.dart` — counts facings per SKU from `MatchedBox` list, excludes gaps, tallies unknowns, returns unmodifiable `FacingCount`. 11 tests. | `lib/domain/services/facing_counter.dart`, `test/domain/facing_counter_test.dart`. |
| **T-18 (C — complete)** | `planogram_diff.dart` — diffs counted vs target facings → `List<ShelfFact>` with in_stock / below_plan / stockout / unlisted. UUID per fact, visitId + computedAt propagated. 12 tests. | `lib/domain/services/planogram_diff.dart`, `test/domain/planogram_diff_test.dart`. |
| **T-28 prep (C — partial)** | `reorder_engine.dart` — `suggest()` with TRD §5.4 formula: trailing history floor, whole-case rounding, absurd-qty cap, stockout-first sort. `medianOrZero()` helper exposed. 21 tests. Awaiting T-19 wiring and `value_paise` unit clarification with B. | `lib/domain/services/reorder_engine.dart`, `test/domain/reorder_engine_test.dart`. |
| **T-15** | `/review` — full implementation, verified on the iQOO 15 (12 Sep ~16:27): pinch-zoom/pan, boxes colour-coded by state with staggered reveal, pulsing unmatched, chips auto-hide when small, tap → SKU picker sheet (crop thumb, ranked candidates slot, search, **Enrol this pack** → `/enrol` with a cropped JPEG), long-press → resize/delete, resize mode with corner handles + move, long-press-drag on empty area draws a new box, summary banner with expandable untagged list that zooms to each box, `Continue (N untagged)`. Every correction writes `override_events` + `was_corrected`. | `lib/features/review/{review_screen,review_repository,sku_picker_sheet,crop_util}.dart`. Candidate ranking (`RankedSku`) is wired but empty until T-20's embedder exists. `/enrol` receives `extra: {cropPath, detectionId}`. |
| **T-22** | `/enrol` — 3-step flow verified on the iQOO 15 (12 Sep ~16:40) end-to-end from `/review`: Enrol this pack → step 1 (crop preloaded as shot 1; New SKU form with name/grammage/unit + collapsible brand/variant/MRP/case, or Existing SKU search) → step 2 (8-slot bright/dim/angled/occluded coverage grid with auto-advance, live preview with a pack guide, shutter crops to the guide, long-press a slot to delete) → step 3 (status summary, Add more shots, Done). Done tags the originating `/review` box with the new SKU and pops back; the box goes green immediately. | `lib/features/enrolment/{enrolment_screen,enrolment_repository,enrol_camera}.dart`. **Shots are stored as crops on disk (`<docs>/enrol/<skuId>/<ms>_<context>.jpg`); `sku_embeddings` rows are only written when `embedderProvider` (in `di.dart`, currently `null`) is non-null.** T-20 must (a) provide the `EmbedderService` there and (b) call `EnrolmentRepository.backfillPendingEmbeddings()` once after load so pre-model shots become recognisable. "Test it now" re-run against the last shelf photo is not implemented — it needs detector + embedder. Crop-to-guide should become crop-to-largest-detected-box once T-13 lands (`enrol_camera.dart` `_kGuideFrac`). |
| Support infra | Result/failure types, ids, structured logger, DI providers | `lib/core/result.dart`, `lib/core/failures.dart`, `lib/core/ids.dart`, `lib/core/logger.dart`, `lib/app/di.dart` |
| ML threshold constants | Single source of truth for detector conf/IoU, matcher accept/reject bands, enrolment shot targets, gap-detection area | `lib/ml/common/thresholds.dart` |
| Domain models | `lib/domain/models/models.dart` | |
| Interface scaffolds for the ML pipeline | Abstract service classes (no implementation — no models exist yet) so the intended shape is committed and each owner has a typed starting point | `lib/ml/detector/detector_service.dart` (T-12/13), `lib/ml/embedder/embedder_service.dart` (T-14/20), `lib/ml/ocr/ocr_service.dart` (T-30), `lib/ml/llm/llm_service.dart` (T-23/26), `lib/ml/asr/asr_service.dart` (T-29), `lib/output/pdf_builder.dart` (T-29) |

### ⚠️ Open decisions (C must resolve before T-19 wiring)

1. **`lib/output/` vs `lib/export/`** — TRD §3 says `lib/export/`; B created `lib/output/` and all existing imports point there. Team must agree and rename consistently. Do not split between directories.
2. **`value_paise` unit convention** — DATA_SCHEMA §10: `final_qty × mrp_paise × (case_size if unit=case)`. ReorderEngine currently stores qty in units (e.g., 12 = one case). If B's DB write treats `final_qty` as number of *cases*, the formula must change. Confirm with B before T-19 writes to `order_lines`.
3. **`skuName`/`skuCode` in ShelfFact** — PlanogramDiff leaves these null. The T-19 Riverpod provider must join with the SKU catalogue before passing `ShelfFact` to the XLSX builder so human-readable columns appear in the export.


### Scaffolded but not implemented (stub screens, each literally says what's next)

- `lib/features/shelf_report/shelf_report_screen.dart` → **T-18**
- `lib/features/order/order_screen.dart` → **T-19** (steppers + wiring to `xlsx_builder`/`csv_builder`)
- `lib/features/export/export_screen.dart` → has a working XLSX/CSV smoke-test button (T-08); still needs the real beat-level export flow + PDF + local HTTP handover (**T-19/T-30**)
- `lib/features/diagnostics/diagnostics_screen.dart` → threshold sliders, ties to **T-25**
- `lib/features/benchmark/benchmark_screen.dart` → **T-30/T-21** (on-device vs cloud comparison)

### Interfaces exist, implementations don't (no models trained/exported yet)

- `lib/ml/detector/` — `DetectorService` interface only. **T-12/T-13**: no `.tflite` model, no decode/NMS logic.
- `lib/ml/embedder/` — `EmbedderService`/`SkuIndex` interfaces only. **T-14/T-20**: no embedder model.
- `lib/ml/ocr/` — `OcrService` interface only. **T-30**: expected — L3 item, strictly time-boxed.
- `lib/ml/llm/` — `LlmService` interface only. **T-23/T-26**: no `flutter_gemma` wiring yet.
- `lib/ml/asr/` — `AsrService` interface only. **T-29**: expected — L2 item.
- `lib/output/pdf_builder.dart` — interface only, deliberately not implemented yet since it depends on `LlmService`'s `VisitRecord` output existing first.
- `assets/models/` — still empty, no detector/embedder `.tflite` files dropped in yet.
- `assets/benchmark/eval_set/` — still empty, no eval images or `cloud_baseline.json` yet (**T-21**).

### Physical/off-repo tasks — status unknown from files, ask directly on resume

- **T-01/T-02** (Model lead, A): SKU-110K download + YOLO11n training launch — can't be verified from this filesystem; ask whether it was started on A's laptop.
- **T-07**: demo shelf / FMCG packs purchased — physical task, ask.
- **T-09/T-11**: training monitored from phone, enrolment photo set shot — physical/phone task, ask.

---

## Immediate next steps (in priority order)

1. Confirm current wall-clock time against `Work Flow.md` §2/§6 to know which block (G1/R1/G2…)
   we're actually in, and re-plan accordingly — the schedule is time-boxed, not sequence-boxed.
2. Get the Syncfusion Community Licence account registration done (human task, 5 minutes) and
   run the `/export` smoke-test button on the physical device to confirm no watermark.
3. ~~Verify T-06/on-device~~ done. ~~T-15~~ done. ~~T-22~~ done. Next on-device check: open a store → `/capture`, confirm camera
   preview + shutter work, then the `/export` smoke-test button (Syncfusion watermark check).
4. Have the other two teammates actually clone `https://github.com/ARCHIT3024/ShelfSense.git` and
   confirm they can push — T-00's "all 3 can push" exit criterion is still unconfirmed.
5. Next real feature work: C owns **T-18**/**T-19** (in progress on C's laptop). B is out of
   model-free tasks: T-16 needs the detector, T-10 (on-phone UX pass of `/capture`) is a phone-block
   task. Then whichever of T-12/T-13
   (detector) or T-14/T-20 (embedder) has a trained model ready first.

---

## How to keep this file useful

Update the "Done" / "Scaffolded" / "Interfaces exist" tables together with the git commit
trail — whoever finishes a task ID should move its row and note the commit/tag. Keep the
"Compliance gaps" section empty once those items are actually resolved; don't let it silently go
stale.
