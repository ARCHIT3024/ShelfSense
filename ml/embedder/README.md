# Embedder training set (T-14)

`crops/<SKU-CODE>/<millis>_<context>.jpg` — pulled from the demo phone's `/enrol` shots
(`adb ... run-as com.shelfsense.app tar app_flutter/enrol`), folders named by SKU code from the
app catalogue. Context suffix = bright / dim / angled / occluded as recorded by the app.

Pull 2 (13 Sep 00:30): **13 SKUs, 107 crops.** `OLAY-200G` (1 abandoned shot) merged into
`OLAY-200G-2`; the two `TEST*` fixtures dropped.

## Caveats before training

- Only `RED-250ML` (and partly `CADBUR-200G`) are single physical packs. The other 11 SKUs were
  photographed **off a laptop screen showing a shelf**, and the guide square captured 3–6 packs per
  crop. The embedder should learn the dominant product, but expect `PEPSI-450ML / 550ML / 1000ML`
  and `DOVE-100G / 250ML` to confuse each other — grammage variants of the same brand are exactly
  the OCR tie-break case (T-30).
- The Pack Finder does not fire on these close-ups (max score ≈ 0.2): SKU-110K packs are small
  and dense; a pack filling a third of the frame is out of distribution. Do not try to re-crop
  with the detector; train on the crops as they are, or re-shoot with **one pack filling the square**.
- Re-shooting with real packs on the physical rack replaces this set; the app names and organises
  everything, one adb pull refreshes this folder.

## Contract for the export (already wired in the app)

`assets/models/embedder_int8.tflite` (or `_fp16` / `_fp32`): input `[1,224,224,3]` NHWC or
`[1,3,224,224]` NCHW, RGB, ImageNet mean/std normalised; output `[1,128]` L2-normalised.
Verify with `adb logcat -s flutter | grep TfliteEmbedder` after the first app start.
