# 03 — Implementation Plan

Task IDs are stable. Use them in commit messages (`T-14: embedder service + SkuIndex`).
Owners: **A** = model lead, **B** = app lead, **C** = output/AI lead.

## Timeline

| Block | Window | Light | Laptops |
|---|---|---|---|
| G1 | Sat 11:00–14:00 | 🟢 | direct |
| R1 | Sat 14:00–15:30 | 🔴 | Office Kit only |
| G2 | Sat 15:30–16:30 | 🟢 | direct |
| R2 | Sat 16:30–19:00 | 🔴 | Office Kit only |
| G3 | Sat 19:00–22:00 | 🟢 | direct |
| R3 | Sat 22:00–Sun 01:00 | 🔴 | Office Kit only |
| G4 | Sun 01:00–06:30 | 🟢 | direct |
| R4 | Sun 06:30–09:00 | 🔴 | Office Kit only |

⚠️ ASSUMPTION: colour reading from the photographed timeline; the bar stops at 09:00 while the event
runs later. **Treat everything after 09:00 as Red Light.**

**Governing principle:** Green Light is only for what physically needs a laptop — GPU training,
model export, Gradle builds, adb. Debugging app logic is phone work. And because a GPU does not
need a human, **start every long training run in the last 20 minutes of a Green block so it trains
through the Red block that follows.**

---

## G1 · Sat 11:00–14:00 · cold start

| ID | Owner | Task | Done when |
|---|---|---|---|
| T-00 | All | Empty repo, push, 3 clones. `ATTRIBUTION.md` created now. Verify Office Kit pairing on all 3 laptops. Ask organisers: evaluation times, post-09:00 schedule, QNN delegate availability. | all 3 can push |
| T-01 | A | Start SKU-110K subset download (~2k images) **first**. Verify CUDA — **15-minute rule**, else Colab. | dataset on disk |
| T-02 | A | YOLO11n config: `imgsz=640, batch=8, epochs=40, amp=True, single_cls=True`. **Launch by 13:40** so it trains through R1. | training running |
| T-03 | B | `flutter create`, add all packages via `flutter pub add`, portrait lock, theme tokens from doc 04. | builds |
| T-04 | B | drift schema — every table in doc 05, DAOs, seed loader. | `flutter test` green |
| T-05 | B | `/boot`, `/beat`, `/store` with seeded data. | navigable |
| T-06 | B | `/capture` still capture to app-private storage. **Release APK installed and cold-starting on the iQOO 15.** | APK on phone |
| T-07 | C | Leave venue, buy 30–40 FMCG packs (see §Demo shelf). Back by 12:30. Build a 3-shelf carton rack. | rack standing |
| T-08 | C | `xlsx_builder.dart` scaffold + Syncfusion licence registration check. | a hello-world .xlsx |

**G1 exit gate:** APK on the phone showing camera preview · detector training running · physical shelf standing.

---

## R1 · Sat 14:00–15:30 · first phone block

| ID | Owner | Task |
|---|---|---|
| T-09 | A | Monitor the training run **from the phone browser**. Real work, and HackTracker sees it. |
| T-10 | B | On-phone UX test of T-06. One-handed reachability, torch, dim-light framing. Fix via Office Kit remote control — this also earns the 10% Office Kit score. |
| T-11 | C | **Shoot the enrolment set on the iQOO phone.** 30–40 SKUs × 8 shots (`bright / dim / angled / occluded`). ~250–320 images. Transfer to laptop via Office Kit file transfer. |

T-11 is the highest-value 90 minutes of the entire event and can only be done on the phone.

---

## G2 · Sat 15:30–16:30 · short and surgical

| ID | Owner | Task | Done when |
|---|---|---|---|
| T-12 | A | Export best checkpoint → TFLite INT8. **Dump input/output tensor shapes and paste them into the PR.** | `detector_int8.tflite` in `assets/models/` |
| T-13 | B | `detector_service.dart`: load, **assert tensor shapes before writing decode logic**, letterbox preprocess in an isolate, YOLO decode, class-agnostic NMS. | boxes logged from a test image |
| T-14 | C | Train the embedder: MobileNetV3-Small, frozen backbone, 128-d ArcFace head on the T-11 crops. Export INT8, L2-normalise at export. | `embedder_int8.tflite` |

Three artefacts, one hour, hand off. Nothing else.

**Kick any remaining training off before 16:25** so it runs through R2.

---

## R2 · Sat 16:30–19:00 · make L0 real

| ID | Owner | Task |
|---|---|---|
| T-15 | B | `/review`: boxes over the photo, zoom/pan, tap→SKU picker, manual add/resize/delete. |
| T-16 | B | **30-minute decision point: is Dart preprocessing > 300 ms?** If yes, Kotlin `MethodChannel` for the vision path. Decide once. Never revisit. |
| T-17 | A | Real latency + peak memory on the iQOO 15, split into preprocess / inference / NMS. **These numbers replace the `000 ms` placeholders on deck slide 9.** |
| T-18 | C | `facing_counter.dart`, `planogram_diff.dart`, `/shelf` table. |
| T-19 | C | `/order` steppers, `/confirm`, XLSX + CSV generation **on the phone**, share sheet. |

**19:00 checkpoint — possible evaluation round. Be demoable:** shoot the rack → boxes → manual tag
→ real XLSX on the device, in aeroplane mode.

---

## G3 · Sat 19:00–22:00 · heavy integration

| ID | Owner | Task |
|---|---|---|
| T-20 | A | `embedder_service.dart` + `SkuIndex` (load all active vectors once at startup) + cosine kNN + threshold routing. |
| T-21 | A | **Run the cloud VLM baseline now** via OpenRouter on your 20-image eval set, while the network is a tool and not a risk. Save `assets/benchmark/cloud_baseline.json`. |
| T-22 | B | `/enrol` — 3-step flow, coverage grid, **Test it now**. Sub-45-second completion. This is the judge-facing magic trick; it must be flawless. |
| T-23 | C | `flutter_gemma` + Gemma 3 1B int4 bundled. **90-minute timebox** — if it will not load, switch to llama.cpp + Qwen2.5-1.5B. Timer, not judgement. |

**G3 exit gate: L0 complete and git-tagged.** If L0 is not done at 22:00, **cancel L2 and L3** and
harden L0 for the rest of the night.

**Kick the final embedder retrain (with any re-shot SKUs) off before 21:40.**

---

## R3 · Sat 22:00–Sun 01:00 · phone block + sleep rotation

| ID | Owner | Task |
|---|---|---|
| T-24 | B | **Sleep 22:00–00:30.** B owns the 5.5-hour G4 block and must be sharp. |
| T-25 | A | On-phone accuracy testing against the physical shelf. Build a confusion list — which SKUs swap? Re-shoot enrolment images for the weak ones. Retune thresholds via the Diagnostics sliders, **not** by rebuilding. |
| T-26 | C | LLM prompt engineering **on the device** — a 1B int4 model behaves differently from the fp16 you'd test on a laptop. Force JSON, write the tolerant parser, write the deterministic fallback for every field. |
| T-27 | C | Start the deck rewrite (8 slides, real numbers, Productivity framing). |

Sleep rotation: B in R3 · A 02:00–04:00 · C 04:00–06:00. Three exhausted people produce fewer
working features in 5.5 hours than two rested ones.

---

## G4 · Sun 01:00–06:30 · the biggest block

| Time | ID | Task |
|---|---|---|
| 01:00–02:30 | T-28 | **L1 close-out**: auto-match wired into the capture pipeline, planogram diff live, `reorder_engine.dart`, `override_events` logging. **Tag `L1`.** |
| 02:30–04:00 | T-29 | **L2**: ASR + `/voice`, LLM service + tolerant parser + deterministic fallback, PDF route summary via the `pdf` package. **Tag `L2`.** |
| 04:00–05:00 | T-30 | **L3, strictly time-boxed**: OCR grammage tie-break, `/benchmark`, local `shelf` HTTP handover. **Anything not working at 05:00 is reverted, not fixed.** |
| 05:00–06:00 | T-31 | **Bug bash only. No new code.** Run the full demo path 10× in aeroplane mode. Every crash gets fixed or the feature gets hidden behind a flag. Verify all 10 acceptance criteria in PRD §5. |
| 06:00–06:30 | T-32 | `flutter build apk --release --split-per-abi`. Clean install on the demo phone. Push everything. **Submit the repo + demo assets to Reskilll now** — beat the cutoff by hours. |

**06:30 = HARD FEATURE FREEZE.** Git tag `demo`. Nobody touches a laptop again except to reinstall
the identical APK. C has written authority to veto any further change — recorded here so it is not
a debate at 07:15.

---

## R4 · Sun 06:30–09:00 · pitch prep, phone only

| ID | Owner | Task |
|---|---|---|
| T-33 | All | Finish the deck **on the phone**. Every placeholder zero replaced with a measured number. |
| T-34 | All | **Rehearse the demo six times, out loud, on the phone, in aeroplane mode.** Time it. Find the one step that breaks under nerves and script around it. |
| T-35 | C | Verify the Reskilll submission landed. Screenshot the confirmation. |
| T-36 | All | Charge to 100%. Clean the lens. Set the shelf exactly as rehearsed. `demo_mode` reset — **which must not wipe `sku_embeddings`.** |

---

## Demo shelf shopping list (T-07)

Budget ₹2,000–3,000, all of it demo-usable:

- **Near-identical pairs** — same brand at two grammages (500 g / 1 kg), same brand at two variants
  (masala / plain). These prove the OCR tie-break.
- **Regional-language pack faces** — the exact case you claim cloud models fail on.
- **Hanging strips / sachet rails** — deck slide 8's occlusion case.
- **Two competitor packs** — for the competitor-share story.
- Mix of rigid cartons, pouches and bottles. Foil pouches are your hard case; include some.
- Three cartons make the rack. **Deliberately leave two gaps** so stockout detection fires live.

Every other team will demo on a screenshot. You will hand a judge a packet and enrol it in front of
them. That is the Demo 10% and a large slice of End Product 30%, bought for ₹3,000.

---

## Risk register

| Risk | Trigger | Action |
|---|---|---|
| SKU-110K download too slow | not down by 12:00 | drop to 800 images, or label 300 of your own shelf shots — enough for a single-class finder on *your* rack |
| CUDA won't initialise | 15 min in | move that run to Colab T4. Do not debug drivers. |
| 6 GB VRAM OOM | first epoch | `batch=4` or `imgsz=512`. 512 is fine — these are large rigid packs, not small objects. |
| Output tensor shape differs from TRD §4.2 | T-13 | that is why the shape assertion is written first. Fix the decoder, not the assumption. |
| Dart preprocessing too slow | T-16 | Kotlin platform channel, 60-min budget; else `imgsz=512` and accept ~700 ms |
| `flutter_gemma` won't load | 90 min into T-23 | llama.cpp + Qwen2.5-1.5B-Instruct Q4_K_M |
| Syncfusion licence banner in the XLSX | first export at T-08 | register the community licence; else `excel` package or CSV + PDF |
| Two SKUs consistently confused | T-25 | OCR tie-break; else show both with confidences and let the rep pick — slide 11 already says the human confirms every line, so this is a *feature* |
| Thermal throttle during demo | repeated inference | inference on shutter press only, never on preview |
| HackTracker lockout | any time | **go to an organiser immediately.** Never work around it. |
| Someone "just adds one thing" after 06:30 | Sunday morning | C vetoes. Written here so it isn't a debate. |

---

## Phone / laptop split — reference card

**Laptop only (Green Light):** GPU training · TFLite export & quantisation · Gradle builds and APK
installs · adb · bulk dataset handling · the single cloud baseline run.

**Phone (Red Light, and better for it):** enrolment and eval photography · all accuracy testing
against the real shelf · LLM prompt iteration on the quantised model · latency and thermal
measurement · one-handed UX testing · deck building · demo rehearsal · submission · monitoring a
training run from the browser.

**Through Office Kit (Red Light, earns the 10%):** remote-starting a training run · pulling
enrolment images off the phone · pushing a rebuilt APK back · clipboard while debugging from the
phone screen.

Roughly **two-thirds native phone work, one-third Office Kit** per red block. Spending all of red
light puppeting a laptop maximises the 10% and starves the 15%.

---

## Attribution checklist (`ATTRIBUTION.md`, required by the rules)

- Ultralytics YOLO11 — **AGPL-3.0**. State the commercial swap plan: NanoDet-Plus / RT-DETR under Apache-2.0.
- SKU-110K dataset — cite the paper and licence
- MobileNetV3 (torchvision / timm) weights
- MediaPipe LLM Inference via `flutter_gemma`; Gemma 3 1B under the Gemma Terms of Use
- whisper.cpp — MIT; Whisper model — MIT
- `google_mlkit_text_recognition`, `tflite_flutter`, `drift`, `image`, `share_plus`, `shelf`, `pdf`, `printing`
- **`syncfusion_flutter_xlsio` — community licence, registered**
- **State plainly: repo initialised empty at 11:00 Saturday; all application code written in-window.**
