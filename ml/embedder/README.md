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

## Results (13 Sep 01:40 — `assets/models/embedder_fp16.tflite`, 2.04 MB)

MobileNetV3-Small (ImageNet, frozen) + 128-d head, L2-normalised; scaled-cosine softmax with a
0.15 margin; hard augmentation. 81 train / 26 held-out (last bright + last other shot per SKU),
60 epochs, **34 s on the laptop CPU**.

| Metric (held-out, nearest neighbour by cosine — what the app does) | fp16 TFLite |
|---|---|
| top-1 | **26 / 26 = 100%** |
| mean cosine to own SKU / to best other SKU | 0.856 / 0.423 |
| worst margin (own − best other) | +0.086 |
| app routing @ 0.72 / 0.55 | 23 accept · 2 low-confidence (amber) · 1 unmatched |
| confusions | none |

Closest SKU pairs by mean cross-cosine (the ones to watch on the rack): DOVE-100G ~ NIVEA-500G
0.33, CADBUR-200G ~ TONE-200G 0.25, PEPSI-1000ML ~ PEPSI-550ML 0.24, DOVE-100G ~ DOVE-250ML 0.23.
The feared Pepsi size-variant collapse did not happen on this set — but 26 held-out crops from the
same screen photos is a small, optimistic test; expect lower scores on the physical rack.

**INT8 is not shipped.** The full-integer export fails to prepare under XNNPACK (MobileNetV3
hard-swish), so `train_embedder.py` only promotes it if it loads and scores within 2 points of
fp16. Do not hand-copy an int8 file into `assets/models/` — the app prefers it over fp16.

Reproduce (Python 3.11, ~2 min incl. the ImageNet weight download):
```
cd ml/embedder && python -m venv .venv
.venv/Scripts/pip install tensorflow==2.19.0 pillow numpy ai-edge-litert
.venv/Scripts/python train_embedder.py      # -> assets/models/embedder_fp16.tflite, results.json
.venv/Scripts/python verify_embedder.py     # tensor dump, held-out NN, confusions, cosine matrix
```

## Contract for the export (already wired in the app)

`assets/models/embedder_int8.tflite` (or `_fp16` / `_fp32`): input `[1,224,224,3]` NHWC or
`[1,3,224,224]` NCHW, RGB, ImageNet mean/std normalised; output `[1,128]` L2-normalised.
Verify with `adb logcat -s flutter | grep TfliteEmbedder` after the first app start.
