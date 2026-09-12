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
| MobileNetV3-Small ImageNet weights, via `keras.applications` (TensorFlow 2.19) | Apache-2.0 | Frozen backbone for the Stage B SKU embedder; trained head exported to `assets/models/embedder_fp16.tflite`. |
| [`google_mlkit_text_recognition`](https://pub.dev/packages/google_mlkit_text_recognition) 0.17.1 | Apache-2.0 (plugin); Google ML Kit terms for the bundled Latin recogniser | On-device OCR for the grammage/variant tie-break (L3, in progress). |
| [LiteRT](https://ai.google.dev/edge/litert) runtime 1.4.2 (`com.google.ai.edge.litert`) | Apache-2.0 | Native TFLite runtime bound by `tflite_flutter`; version forced in `android/app/build.gradle.kts`. |
| ~~`flutter_gemma` / Gemma 3 1B / whisper.cpp~~ | — | Planned for the voice-note path; **not integrated, not bundled**. The visit record and rationale are produced by a deterministic non-LLM path (`lib/ml/llm/deterministic_visit_record.dart`). |
| [`tflite_flutter`](https://pub.dev/packages/tflite_flutter) | Apache-2.0 | TFLite inference runtime for the detector and embedder. |
| [`drift`](https://pub.dev/packages/drift) / [`drift_flutter`](https://pub.dev/packages/drift_flutter) | MIT | Local database. |
| [`image`](https://pub.dev/packages/image) | MIT / Apache-2.0 | Image decode/resize in preprocessing isolates. |
| [`share_plus`](https://pub.dev/packages/share_plus) | BSD-3-Clause | Export handover via the OS share sheet. |
| [`shelf`](https://pub.dev/packages/shelf) | BSD-3-Clause | Local HTTP handover server (T-30) — laptop pulls files from the phone over the shared hotspot. |
| [`syncfusion_flutter_xlsio`](https://pub.dev/packages/syncfusion_flutter_xlsio) | **Syncfusion Community Licence** (or commercial) — see below | On-device XLSX generation. |
| [`pdf`](https://pub.dev/packages/pdf) / [`printing`](https://pub.dev/packages/printing) | Apache-2.0 / MIT | On-device beat-summary PDF generation. |
| [`qr`](https://pub.dev/packages/qr) 3.0.2 | BSD-3-Clause | QR code for the Wi-Fi handover URL (drawn with a `CustomPainter`). |
| [`archive`](https://pub.dev/packages/archive) 4.0.9 | MIT | Zips the enrolment shots for export from `/diagnostics`. |
| [`package_info_plus`](https://pub.dev/packages/package_info_plus) 10.2.1 | BSD-3-Clause | App version on `/diagnostics`. |
| [Inter](https://rsms.me/inter/) variable font | SIL OFL 1.1 | UI typeface, also embedded in the PDF. |
| [`camera`](https://pub.dev/packages/camera), [`go_router`](https://pub.dev/packages/go_router), [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod), [`geolocator`](https://pub.dev/packages/geolocator), [`connectivity_plus`](https://pub.dev/packages/connectivity_plus) (read-only state display on `/diagnostics`), [`permission_handler`](https://pub.dev/packages/permission_handler), [`path_provider`](https://pub.dev/packages/path_provider), [`uuid`](https://pub.dev/packages/uuid), [`intl`](https://pub.dev/packages/intl) | Various (BSD/MIT/Apache-2.0) | Standard Flutter ecosystem packages — see each package's own licence on pub.dev. |

## Models and data

| Asset | Licence | Use |
|---|---|---|
| [Ultralytics YOLO11n](https://github.com/ultralytics/ultralytics) (`yolo11n.pt` pretrained weights + training/export toolchain, v8.4.149) | AGPL-3.0 | Starting point and trainer for the Pack Finder. The app bundles only our exported `.tflite`, not Ultralytics code. |
| [SKU-110K](https://github.com/eg4000/SKU110K_CVPR19) (Goldman et al., CVPR 2019) | Academic / non-commercial research use, per the dataset's terms | 3,000-image training subset + 588 validation for the class-agnostic Pack Finder; 2,935-image test set for the reported mAP. Not redistributed. |

Pack Finder: YOLO11n, single class, trained 12 Sep 2026 during the build window on an RTX 4050
(30 epochs, 640 px, batch 8). Held-out SKU-110K test: P 0.887 · R 0.813 · mAP50 0.889 · mAP50-95 0.531.

SKU Recogniser: MobileNetV3-Small (ImageNet, frozen) + 128-d L2-normalised head, trained 13 Sep
2026 on 107 enrolment crops (13 SKUs) shot in the app — `ml/embedder/crops/`, script
`ml/embedder/train_embedder.py`. Held-out nearest-neighbour top-1 26/26. No third-party product
imagery or datasets were used for the recogniser.

## Syncfusion licence note

`syncfusion_flutter_xlsio` is a commercial package. It is used here under the **Syncfusion
Community Licence Program** (free for organisations with <5 developers and <$1M gross annual
revenue — https://www.syncfusion.com/products/communitylicense). **Registered by Archit
Khandelwal on 12 Sep 2026.** Registration is an account-level requirement independent of any
in-code licence key: the installed package version (34.2.7) exposes no `registerLicense` API.
A generated `.xlsx` was inspected (every XML part) on 12 Sep and contains no trial or watermark
text.

## Team

3 students, iQOO City Battle Chennai, Productivity track, Students bucket.
