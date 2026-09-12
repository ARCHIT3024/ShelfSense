# Attribution

ShelfSense is original work written inside the iQOO City Battle Chennai build window
(12–13 Sep 2026). This repository was initialised empty at the start of that window; all
application code in `lib/`, `android/`, and `assets/` (excluding third-party packages and the
seed/model assets noted below) was written during the event.

Open-source packages and models used, per the event rules' attribution requirement:

| Component | Licence | Notes |
|---|---|---|
| [Ultralytics YOLO11](https://github.com/ultralytics/ultralytics) | AGPL-3.0 | Fine-tuned for Stage A (class-agnostic pack finder). For a commercial distributor deployment we would swap the backbone to NanoDet-Plus or RT-DETR (Apache-2.0) — the pipeline is backbone-agnostic. |
| [SKU-110K dataset](https://github.com/eg4000/SKU110K_CVPR19) | Research/academic use, see dataset licence | Subset used to fine-tune the pack finder. |
| MobileNetV3 (torchvision/timm pretrained weights) | Apache-2.0 / BSD (per source) | Backbone for the Stage B SKU embedder. |
| Google MediaPipe LLM Inference API, via [`flutter_gemma`](https://pub.dev/packages/flutter_gemma) | Apache-2.0 | On-device LLM runtime. |
| [Gemma 3 1B](https://ai.google.dev/gemma) | Gemma Terms of Use | On-device structured visit record + reorder rationale generation. |
| [whisper.cpp](https://github.com/ggml-org/whisper.cpp) / Whisper model | MIT | On-device ASR for voice notes. |
| [`google_mlkit_text_recognition`](https://pub.dev/packages/google_mlkit_text_recognition) | Apache-2.0 | On-device OCR for grammage/variant tie-break. |
| [`tflite_flutter`](https://pub.dev/packages/tflite_flutter) | Apache-2.0 | TFLite inference runtime for the detector and embedder. |
| [`drift`](https://pub.dev/packages/drift) / [`drift_flutter`](https://pub.dev/packages/drift_flutter) | MIT | Local database. |
| [`image`](https://pub.dev/packages/image) | MIT / Apache-2.0 | Image decode/resize in preprocessing isolates. |
| [`share_plus`](https://pub.dev/packages/share_plus) | BSD-3-Clause | Export handover via the OS share sheet. |
| [`shelf`](https://pub.dev/packages/shelf) | BSD-3-Clause | Local HTTP handover server (T-30) — laptop pulls files from the phone over the shared hotspot. |
| [`syncfusion_flutter_xlsio`](https://pub.dev/packages/syncfusion_flutter_xlsio) | **Syncfusion Community Licence** (or commercial) — see below | On-device XLSX generation. |
| [`pdf`](https://pub.dev/packages/pdf) / [`printing`](https://pub.dev/packages/printing) | Apache-2.0 / MIT | On-device PDF route summary generation. |
| [`camera`](https://pub.dev/packages/camera), [`go_router`](https://pub.dev/packages/go_router), [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod), [`geolocator`](https://pub.dev/packages/geolocator), [`connectivity_plus`](https://pub.dev/packages/connectivity_plus), [`permission_handler`](https://pub.dev/packages/permission_handler), [`path_provider`](https://pub.dev/packages/path_provider), [`uuid`](https://pub.dev/packages/uuid), [`intl`](https://pub.dev/packages/intl) | Various (BSD/MIT/Apache-2.0) | Standard Flutter ecosystem packages — see each package's own licence on pub.dev. |

## Syncfusion licence note

`syncfusion_flutter_xlsio` is a commercial package. It is used here under the **Syncfusion
Community Licence Program** (free for organisations with <5 developers and <$1M gross annual
revenue — https://www.syncfusion.com/products/communitylicense). Registration on Syncfusion's
site is a legal/account requirement independent of any in-code licence key: the installed package
version (34.2.7) exposes no `registerLicense` API to call. Verify no trial watermark appears on a
real generated `.xlsx` before the demo; if one does, fall back to the `excel` package or CSV + PDF
only (see `docs/Work Flow.md` §9, risk register).

## Team

3 students, iQOO City Battle Chennai, Productivity track, Students bucket.
