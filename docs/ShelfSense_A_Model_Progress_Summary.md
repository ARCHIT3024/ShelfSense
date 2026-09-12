# ShelfSense — A (Model Lead) Implementation Progress Summary

## 1. Project Context

**Project:** ShelfSense — Offline shelf audit for kirana distribution

**Current responsibility:** Team A / Model Lead

The implementation workflow defines the first computer-vision stage as a **class-agnostic Pack Finder**. Its job is to locate individual product packs on a shelf image. SKU identity is handled later by the SKU Recogniser stage.

The planned model flow is:

```text
Shelf photo
    ↓
Stage A — Pack Finder (YOLO11n)
    ↓
Product bounding boxes
    ↓
Stage B — SKU Recogniser (embedding + cosine kNN)
    ↓
Stage C — OCR tie-break for low-confidence cases
```

The project workflow specifies YOLO11n for the Pack Finder and later requires export to an INT8 mobile model, followed by real on-phone latency/memory measurement.

---

# 2. Completed Work So Far

## Step 1 — Initial environment / GPU preparation

### Machine
The model-training laptop is the Team A machine with:

- NVIDIA GeForce RTX 4050 Laptop GPU
- 6 GB VRAM
- Windows
- Anaconda

### Conda
A dedicated Conda environment was created:

```text
shelfsense
```

The correct environment was verified and used for model work.

### Python
The final Windows model-training environment uses:

```text
Python 3.11.16
```

### PyTorch
PyTorch was installed successfully:

```text
PyTorch 2.11.0+cu128
CUDA build: 12.8
```

### GPU verification
PyTorch successfully detected the GPU:

```text
CUDA available: True
GPU count: 1
GPU: NVIDIA GeForce RTX 4050 Laptop GPU
```

A real CUDA matrix-multiplication test was also completed successfully, proving that the GPU could execute CUDA workloads rather than only being detected.

---

# 3. YOLO Environment

Ultralytics was installed in the `shelfsense` environment.

Verified version:

```text
Ultralytics 8.4.149
```

YOLO11n was downloaded and a baseline inference was run successfully on the RTX 4050.

Model used:

```text
yolo11n.pt
```

---

# 4. Project Structure Created

The project workspace was created at:

```text
C:\Users\Vinit Kumar\OneDrive\Documents\iqoo hac\ShelfSense
```

Current important structure:

```text
ShelfSense/
│
├── pack_finder/
│   ├── data/
│   │   ├── SKU-110K.yaml
│   │   └── SKU-110K-subset.yaml
│   │
│   ├── scripts/
│   │   ├── prepare_sku110k.py
│   │   ├── create_subset.py
│   │   └── check_images.py
│   │
│   ├── models/
│   │   └── pack_finder_yolo11n_best.pt
│   │
│   └── runs/
│
├── datasets/
│   └── SKU-110K/
│       ├── SKU110K_fixed/
│       │   ├── images/
│       │   ├── annotations/
│       │   └── ...
│       │
│       └── yolo/
│           ├── images/
│           │   ├── train/
│           │   ├── val/
│           │   └── test/
│           │
│           ├── labels/
│           │   ├── train/
│           │   ├── val/
│           │   └── test/
│           │
│           └── subset/
│               ├── train.txt
│               └── val.txt
│
└── README.md
```

---

# 5. SKU-110K Dataset

The SKU-110K archive was downloaded and extracted successfully.

Original extracted dataset:

```text
11,743 JPG images
3 annotation CSV files
2 TXT files
```

Annotation files:

```text
annotations_train.csv
annotations_val.csv
annotations_test.csv
```

The annotation format was inspected directly.

Example:

```text
train_0.jpg,208,537,422,814,object,3024,3024
```

This corresponds to:

```text
image_name
x_min
y_min
x_max
y_max
class
image_width
image_height
```

The dataset uses one generic class:

```text
object
```

---

# 6. Annotation Conversion

A Python conversion script was created:

```text
pack_finder/scripts/prepare_sku110k.py
```

It converts the original CSV bounding boxes into standard YOLO detection labels:

```text
class_id x_center y_center width height
```

Coordinates are normalized to the range expected by YOLO.

The conversion completed successfully.

Verified split counts:

```text
Train: 8219 images
Validation: 588 images
Test: 2936 images
```

Generated image/label counts were checked for train and validation and matched.

A sample generated label was verified to contain exactly five values:

```text
0 0.104167 0.223380 0.070767 0.091601
```

Therefore:

```text
class_id = 0
x_center
y_center
width
height
```

---

# 7. Image Integrity Check

A validation script was created:

```text
pack_finder/scripts/check_images.py
```

All 11,743 converted JPG images were checked.

Result:

```text
Bad images: 0
```

Therefore no images were removed.

YOLO later printed some JPEG decoder warnings such as:

```text
Corrupt JPEG data: ...
```

but the independent image validation reported zero unreadable images, and the training/evaluation runs completed successfully.

---

# 8. Training Subset

The project workflow calls for a SKU-110K subset rather than blindly using the entire dataset.

A reproducible subset script was created:

```text
pack_finder/scripts/create_subset.py
```

The selected experiment subset is:

```text
Training:   3000 images
Validation: 588 images
Random seed: 42
```

The test set was kept untouched for final evaluation.

Subset files:

```text
datasets/SKU-110K/yolo/subset/train.txt
datasets/SKU-110K/yolo/subset/val.txt
```

Verified line counts:

```text
train.txt = 3000
val.txt   = 588
```

---

# 9. YOLO Dataset Configuration

The subset training configuration was created:

```text
pack_finder/data/SKU-110K-subset.yaml
```

Configuration:

```yaml
path: datasets/SKU-110K/yolo/subset

train: train.txt
val: val.txt

names:
  0: object
```

The dataset path was corrected during setup and the final configuration successfully loaded during training.

---

# 10. Training Smoke Test

A 1-epoch YOLO11n smoke test was run before the real training.

Configuration:

```text
Model:   yolo11n.pt
Epochs:  1
Image:   640
Batch:   2
Device:  0
Workers: 8
```

The run completed successfully and produced:

```text
best.pt
last.pt
```

plus training/validation visualizations and metrics.

This proved the full pipeline:

```text
Dataset
  ↓
YOLO YAML
  ↓
YOLO labels
  ↓
YOLO11n
  ↓
PyTorch
  ↓
CUDA
  ↓
RTX 4050
  ↓
Training
  ↓
Validation
```

---

# 11. Visual Sanity Check

Training and validation images were inspected.

The ground-truth boxes correctly represented individual retail product packs.

The predicted boxes from the smoke test were also generally placed over individual retail products, confirming that the model was learning the intended Pack Finder task.

The output was crowded because the model had only trained for one epoch, which was expected for a smoke test.

---

# 12. Real Pack Finder Training

The first actual Pack Finder training run was completed.

Configuration used:

```text
Model:     YOLO11n
Train set: 3000 images
Val set:   588 images
Image size: 640
Batch:     8
Workers:   2
AMP:       True
GPU:       device 0
Epochs:    30
```

This follows the project workflow's intended 640-pixel / batch-8 direction for a 6 GB GPU.

Training output was saved under:

```text
runs/detect/pack_finder/runs/pack_finder_v1
```

---

# 13. Trained Model Checkpoint

The trained checkpoints were successfully created:

```text
runs/detect/pack_finder/runs/pack_finder_v1/weights/best.pt
runs/detect/pack_finder/runs/pack_finder_v1/weights/last.pt
```

Both files were approximately 5.45 MB.

The best checkpoint was copied into the project model directory as:

```text
pack_finder/models/pack_finder_yolo11n_best.pt
```

This is the project copy that should be used for deployment/export work.

---

# 14. Validation Performance

The real training run produced the following validation result:

```text
Precision:  0.879
Recall:     0.810
mAP50:      0.880
mAP50-95:   0.500
```

These values are from the 30-epoch training experiment, not the 1-epoch smoke test.

---

# 15. Held-Out Test Evaluation

The trained:

```text
pack_finder_yolo11n_best.pt
```

was evaluated on the untouched SKU-110K test set.

Final observed test metrics:

```text
Test images evaluated: 2935
Instances:             431419

Precision:  0.887
Recall:     0.813
mAP50:      0.889
mAP50-95:   0.531
```

Therefore the current Pack Finder test performance is:

```text
mAP50     = 88.9%
mAP50-95  = 53.1%
```

### Important test-set note

The expected test split contains 2,936 images, but the evaluator processed:

```text
2935
```

One test image therefore needs to be identified/explained before we claim that all 2,936 test images were evaluated.

---

# 16. Laptop GPU Latency

The trained model's laptop validation timing was measured as approximately:

```text
Preprocess:   1.6 ms/image
Inference:    3.4 ms/image
Postprocess:  1.6 ms/image
```

Total:

```text
~6.6 ms/image
```

These are **RTX 4050 laptop measurements**.

They are NOT the final phone measurements.

The workflow requires real measurements later on the iQOO phone, including:

```text
preprocess
inference
NMS/postprocess
memory
```

---

# 17. TFLite / LiteRT Export Attempt

The next required deployment stage is:

```text
best.pt
   ↓
INT8 mobile model
   ↓
benchmark
   ↓
Flutter / iQOO
```

The first export attempt was made from Windows:

```text
format=tflite
int8=True
```

Ultralytics 8.4.149 redirected this to the newer LiteRT exporter.

It failed with:

```text
AssertionError:
LiteRT export only supported on Linux x86 and macOS
```

Therefore:

- `best.pt` is NOT damaged.
- No retraining is required.
- The problem is only the Windows export environment.

---

# 18. WSL / Ubuntu Setup

Windows Subsystem for Linux was installed successfully.

Ubuntu was installed successfully.

Architecture was checked:

```text
x86_64
```

The trained model was verified from Ubuntu using the Windows-mounted path:

```text
/mnt/c/Users/Vinit Kumar/OneDrive/Documents/iqoo hac/ShelfSense/pack_finder/models/pack_finder_yolo11n_best.pt
```

The model was confirmed accessible from Ubuntu.

---

# 19. Current Linux Export Environment

Ubuntu currently provides:

```text
Python 3.14.4
```

A Linux virtual environment was successfully created:

```text
~/shelfsense-export
```

and activated as:

```text
(shelfsense-export)
```

The Python 3.13 packages were not available from the default Ubuntu repositories, so the current plan is to use the already-created Python 3.14 export environment rather than continue modifying the OS Python installation.

### Current export status

```text
Linux/WSL installed:          ✅
Ubuntu installed:             ✅
x86_64 confirmed:              ✅
best.pt accessible in WSL:    ✅
Linux export venv created:     ✅
Ultralytics in Linux venv:     ⏳
INT8 LiteRT export:            ❌ Not done yet
TFLite/LiteRT benchmark:       ❌ Not done yet
Phone integration:             ❌ Not done yet
```

---

# 20. Current Project Status

## Pack Finder

```text
YOLO11n baseline                 ✅
SKU-110K downloaded              ✅
Dataset converted                ✅
Images validated                 ✅
Subset created                   ✅
Dataset YAML created             ✅
Smoke training                   ✅
Real training                    ✅
best.pt generated                ✅
Held-out test evaluation         ✅
Laptop benchmark                 ✅
INT8 mobile export               ⏳
Phone benchmark                  ⏳
Flutter handoff                  ⏳
```

## Current best model

```text
pack_finder/models/pack_finder_yolo11n_best.pt
```

## Current reported test performance

```text
Precision:  88.7%
Recall:     81.3%
mAP50:      88.9%
mAP50-95:   53.1%
```

---

# 21. Current Project Tree — Important Files

```text
ShelfSense/
│
├── README.md
│
├── pack_finder/
│   ├── data/
│   │   ├── SKU-110K.yaml
│   │   └── SKU-110K-subset.yaml
│   │
│   ├── scripts/
│   │   ├── prepare_sku110k.py
│   │   ├── create_subset.py
│   │   └── check_images.py
│   │
│   ├── models/
│   │   └── pack_finder_yolo11n_best.pt
│   │
│   └── runs/
│
├── datasets/
│   └── SKU-110K/
│       ├── SKU110K_fixed/
│       │   ├── images/
│       │   └── annotations/
│       │
│       └── yolo/
│           ├── images/
│           ├── labels/
│           └── subset/
│               ├── train.txt
│               └── val.txt
│
└── runs/
    └── detect/
        └── pack_finder/
            └── runs/
                ├── pack_finder_v1/
                └── pack_finder_test_final/
```

---

# 22. Immediate Next Step

### Step 18 — Complete INT8 mobile export

Work in the **Ubuntu/WSL terminal**, not Windows PowerShell.

Current target:

```text
best.pt
   ↓
Linux / Ubuntu
   ↓
Ultralytics LiteRT exporter
   ↓
INT8 .tflite
```

The newer exporter syntax should use the current quantization interface rather than the deprecated `int8=True` flag:

```text
quantize=8
```

The exported `.tflite`/LiteRT artifact then needs to be:

1. Verified
2. Accuracy-checked
3. Benchmarked
4. Handed to the App/Flutter teammate
5. Tested on the iQOO phone

---

# 23. Next A Tasks After Export

After the mobile model is produced:

```text
INT8 export
   ↓
TFLite/LiteRT validation
   ↓
Laptop/mobile benchmark
   ↓
iQOO phone latency + memory measurement
   ↓
Hand .tflite to B
   ↓
B wires image → resize/normalize → GPU delegate → NMS → boxes
```

The workflow then moves A toward the **SKU Recogniser**:

```text
Pack crop
   ↓
MobileNetV3-Small embedder
   ↓
128-d embedding
   ↓
cosine nearest neighbour
   ↓
SKU label + confidence
```

and later the OCR tie-break stage for low-confidence crops.

---

# 24. Important Notes for Future Work

### Do not delete

Keep these:

```text
pack_finder/models/pack_finder_yolo11n_best.pt
runs/detect/pack_finder/runs/pack_finder_v1
datasets/SKU-110K/
```

until the mobile export and benchmark are fully verified.

### Do not confuse the models

```text
yolo11n.pt
```

= original pretrained YOLO11n

```text
pack_finder_yolo11n_best.pt
```

= our trained Pack Finder model

```text
*.tflite
```

= mobile deployment artifact produced from the trained model

### Core architectural distinction

Pack Finder detects/counts product packs.

Planogram diff logic later calculates:

```text
expected facings - detected facings = gap
```

SKU recognition is a separate stage from Pack Finder.

---

# 25. One-Line Current Status

**A's Pack Finder model is trained, tested, benchmarked on the RTX 4050, and saved as `pack_finder_yolo11n_best.pt`; the only unfinished part of the Pack Finder deployment milestone is INT8 mobile export and the required real iQOO on-device benchmark.**

