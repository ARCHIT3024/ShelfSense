"""T-14 — SKU embedder: MobileNetV3-Small (frozen, ImageNet) + 128-d L2-normalised head.

Trained with a scaled-cosine softmax over the normalised embedding (ArcFace-style
margin on the target logit) on ml/embedder/crops/<SKU-CODE>/*.jpg. Two shots per
SKU are held out (one bright, one other context) and scored the way the app
scores: nearest neighbour by cosine against the training embeddings.

Input contract (must match lib/ml/embedder/tflite_embedder.dart):
  [1,224,224,3] float32 NHWC RGB, ALREADY normalised as (x/255 - mean)/std with
  ImageNet mean/std — the app does that, so the graph must NOT re-normalise.
Output: [1,128] float32, L2-normalised at export.

Usage (from ml/embedder, inside .venv):
  python train_embedder.py            # trains, exports fp16 (+ int8 candidate)
"""
from __future__ import annotations

import json
import os
import random
import sys
import time
from pathlib import Path

import numpy as np

os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")
import tensorflow as tf  # noqa: E402
from PIL import Image  # noqa: E402

HERE = Path(__file__).resolve().parent
CROPS = HERE / "crops"
OUT_DIR = HERE.parent.parent / "assets" / "models"
SIZE = 224
EMB_DIM = 128
MEAN = np.array([0.485, 0.456, 0.406], np.float32)
STD = np.array([0.229, 0.224, 0.225], np.float32)
SEED = 42
EPOCHS = int(os.environ.get("EPOCHS", "60"))

random.seed(SEED)
np.random.seed(SEED)
tf.random.set_seed(SEED)


# ---------------------------------------------------------------------------
# Data
# ---------------------------------------------------------------------------

def load_image(path: Path) -> np.ndarray:
    """RGB uint8 HxWx3, resized to SIZE (plain resize — crops are already tight)."""
    im = Image.open(path).convert("RGB").resize((SIZE, SIZE), Image.BILINEAR)
    return np.asarray(im, np.uint8)


def normalise(x_uint8: np.ndarray) -> np.ndarray:
    """Exactly what the app does before calling the model."""
    return ((x_uint8.astype(np.float32) / 255.0) - MEAN) / STD


def split_dataset():
    """Hold out 2 shots per SKU: the last 'bright' one and the last non-bright one."""
    classes = sorted(p.name for p in CROPS.iterdir() if p.is_dir())
    train, val = [], []
    for ci, code in enumerate(classes):
        files = sorted((CROPS / code).glob("*.jpg"))
        ctx = lambda f: f.stem.rsplit("_", 1)[-1]
        bright = [f for f in files if ctx(f) == "bright"]
        other = [f for f in files if ctx(f) != "bright"]
        held = []
        if bright:
            held.append(bright[-1])
        if other:
            held.append(other[-1])
        for f in files:
            (val if f in held else train).append((f, ci))
    return classes, train, val


def to_arrays(items):
    xs = np.stack([load_image(f) for f, _ in items])
    ys = np.array([c for _, c in items], np.int32)
    return xs, ys


# ---------------------------------------------------------------------------
# Model
# ---------------------------------------------------------------------------

def build_embedder() -> tf.keras.Model:
    inp = tf.keras.Input((SIZE, SIZE, 3), name="image_normalised")
    backbone = tf.keras.applications.MobileNetV3Small(
        include_top=False, weights="imagenet", pooling="avg",
        input_shape=(SIZE, SIZE, 3), include_preprocessing=False,
    )
    backbone.trainable = False
    # Keras' MobileNetV3 with include_preprocessing=False expects inputs in
    # [-1, 1]-ish range; ImageNet-normalised inputs are close enough for a frozen
    # backbone with a trained head, and it is what the app provides.
    feat = backbone(inp, training=False)
    feat = tf.keras.layers.Dropout(0.2)(feat)
    emb = tf.keras.layers.Dense(EMB_DIM, use_bias=False, name="embed")(feat)
    emb = tf.keras.layers.Lambda(
        lambda t: tf.math.l2_normalize(t, axis=1), name="embedding")(emb)
    return tf.keras.Model(inp, emb, name="sku_embedder")


class CosineSoftmax(tf.keras.layers.Layer):
    """Scaled cosine logits with an additive angular-style margin on the target."""

    def __init__(self, n_classes, scale=20.0, margin=0.15, **kw):
        super().__init__(**kw)
        self.n, self.s, self.m = n_classes, scale, margin

    def build(self, _):
        self.w = self.add_weight(shape=(EMB_DIM, self.n), name="w",
                                 initializer="glorot_uniform")

    def call(self, inputs):
        emb, labels = inputs
        w = tf.math.l2_normalize(self.w, axis=0)
        cos = tf.matmul(emb, w)  # emb already unit length
        onehot = tf.one_hot(tf.cast(labels, tf.int32), self.n)
        return self.s * (cos - self.m * onehot)


def build_trainer(embedder, n_classes):
    img = tf.keras.Input((SIZE, SIZE, 3))
    lbl = tf.keras.Input((), dtype=tf.int32)
    logits = CosineSoftmax(n_classes)([embedder(img), lbl])
    return tf.keras.Model([img, lbl], logits)


# ---------------------------------------------------------------------------
# Augmentation (hard — the set is small and mostly screen photos)
# ---------------------------------------------------------------------------

AUG = tf.keras.Sequential([
    tf.keras.layers.RandomFlip("horizontal"),
    tf.keras.layers.RandomRotation(0.06),
    tf.keras.layers.RandomZoom((-0.25, 0.15), (-0.25, 0.15)),
    tf.keras.layers.RandomTranslation(0.12, 0.12),
    tf.keras.layers.RandomBrightness(0.35, value_range=(0, 255)),
    tf.keras.layers.RandomContrast(0.4),
], name="aug")


def make_ds(xs, ys, training, batch=32):
    ds = tf.data.Dataset.from_tensor_slices((xs, ys))
    if training:
        ds = ds.shuffle(len(xs), seed=SEED).repeat()
        ds = ds.batch(batch)
        ds = ds.map(lambda x, y: (AUG(tf.cast(x, tf.float32), training=True), y),
                    num_parallel_calls=tf.data.AUTOTUNE)
    else:
        ds = ds.batch(batch).map(lambda x, y: (tf.cast(x, tf.float32), y))
    # Normalise like the app, then hand (image, label) as the two inputs.
    ds = ds.map(lambda x, y: ((((x / 255.0) - MEAN) / STD, y), y),
                num_parallel_calls=tf.data.AUTOTUNE)
    return ds.prefetch(tf.data.AUTOTUNE)


# ---------------------------------------------------------------------------
# Evaluation: nearest neighbour by cosine, like the app's SkuIndex
# ---------------------------------------------------------------------------

def nn_accuracy(embed_fn, train_items, val_items, classes):
    xt, yt = to_arrays(train_items)
    xv, yv = to_arrays(val_items)
    et = embed_fn(normalise(xt))
    ev = embed_fn(normalise(xv))
    sims = ev @ et.T  # cosine, both unit length
    # best score per class (the app's rankCandidates does max-per-SKU)
    per_class = np.full((len(ev), len(classes)), -1.0, np.float32)
    for j, c in enumerate(yt):
        per_class[:, c] = np.maximum(per_class[:, c], sims[:, j])
    pred = per_class.argmax(1)
    top1 = float((pred == yv).mean())
    confusions = [(classes[a], classes[b], float(per_class[i, b]))
                  for i, (a, b) in enumerate(zip(yv, pred)) if a != b]
    same = [per_class[i, yv[i]] for i in range(len(yv))]
    other = [np.delete(per_class[i], yv[i]).max() for i in range(len(yv))]
    return top1, confusions, float(np.mean(same)), float(np.mean(other))


# ---------------------------------------------------------------------------
# Export
# ---------------------------------------------------------------------------

def export_fp16(embedder, path: Path):
    conv = tf.lite.TFLiteConverter.from_keras_model(embedder)
    conv.optimizations = [tf.lite.Optimize.DEFAULT]
    conv.target_spec.supported_types = [tf.float16]
    path.write_bytes(conv.convert())


def export_int8(embedder, xs_uint8, path: Path):
    def rep():
        for i in range(0, len(xs_uint8), 1):
            yield [normalise(xs_uint8[i:i + 1])]
    conv = tf.lite.TFLiteConverter.from_keras_model(embedder)
    conv.optimizations = [tf.lite.Optimize.DEFAULT]
    conv.representative_dataset = rep
    conv.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
    conv.inference_input_type = tf.float32   # app feeds float; weights/acts int8
    conv.inference_output_type = tf.float32
    path.write_bytes(conv.convert())


def tflite_embed_fn(path: Path):
    from ai_edge_litert.interpreter import Interpreter
    it = Interpreter(model_path=str(path), num_threads=4)
    it.allocate_tensors()
    ii = it.get_input_details()[0]["index"]
    oi = it.get_output_details()[0]["index"]

    def fn(x_norm):
        out = np.zeros((len(x_norm), EMB_DIM), np.float32)
        for i in range(len(x_norm)):
            it.set_tensor(ii, x_norm[i:i + 1].astype(np.float32))
            it.invoke()
            v = it.get_tensor(oi)[0]
            out[i] = v / (np.linalg.norm(v) + 1e-9)
        return out
    return fn


# ---------------------------------------------------------------------------

def main():
    classes, train_items, val_items = split_dataset()
    print(f"{len(classes)} SKUs · train {len(train_items)} · held-out {len(val_items)}")
    xt, yt = to_arrays(train_items)
    xv, yv = to_arrays(val_items)

    embedder = build_embedder()
    trainer = build_trainer(embedder, len(classes))
    trainer.compile(
        optimizer=tf.keras.optimizers.Adam(1e-3),
        loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
        metrics=["accuracy"],
    )
    steps = max(8, len(xt) // 32 * 2)
    t0 = time.time()
    trainer.fit(make_ds(xt, yt, True), epochs=EPOCHS, steps_per_epoch=steps,
                validation_data=make_ds(xv, yv, False), verbose=2)
    train_s = time.time() - t0

    keras_fn = lambda x: embedder.predict(x, verbose=0)
    top1, conf, same, other = nn_accuracy(keras_fn, train_items, val_items, classes)
    print(f"\nKeras fp32 — held-out NN top-1 {top1:.3f} · mean same-SKU cos {same:.3f} "
          f"· mean best-other cos {other:.3f} · trained in {train_s:.0f}s")

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    fp16 = OUT_DIR / "embedder_fp16.tflite"
    export_fp16(embedder, fp16)
    top1_16, conf16, same16, other16 = nn_accuracy(
        tflite_embed_fn(fp16), train_items, val_items, classes)
    print(f"fp16 tflite ({fp16.stat().st_size/1e6:.2f} MB) — held-out NN top-1 {top1_16:.3f} "
          f"· same {same16:.3f} · other {other16:.3f}")

    results = {
        "classes": classes, "train": len(train_items), "held_out": len(val_items),
        "epochs": EPOCHS, "train_seconds": round(train_s),
        "keras": {"top1": top1, "same": same, "other": other},
        "fp16": {"top1": top1_16, "same": same16, "other": other16,
                 "bytes": fp16.stat().st_size, "confusions": conf16},
    }

    # INT8 candidate: exported to a scratch path and only promoted into
    # assets/ if it loads and scores within 2 points of fp16 — the app prefers
    # int8 when present, so a broken one would silently replace a good fp16.
    # (MobileNetV3's hard-swish does not survive full-int8 on this converter:
    # XNNPACK refuses to prepare the graph. Expect this branch to fail.)
    scratch = HERE / "_int8_candidate.tflite"
    int8 = OUT_DIR / "embedder_int8.tflite"
    try:
        export_int8(embedder, xt, scratch)
        top1_8, conf8, same8, other8 = nn_accuracy(
            tflite_embed_fn(scratch), train_items, val_items, classes)
        print(f"int8 tflite ({scratch.stat().st_size/1e6:.2f} MB) — held-out NN top-1 {top1_8:.3f} "
              f"· same {same8:.3f} · other {other8:.3f}")
        keep = top1_8 >= top1_16 - 0.02
        results["int8"] = {"top1": top1_8, "same": same8, "other": other8,
                           "bytes": scratch.stat().st_size, "confusions": conf8,
                           "kept": keep}
        if keep:
            int8.write_bytes(scratch.read_bytes())
        else:
            print("int8 not promoted: more than 2 points below fp16")
    except Exception as e:  # noqa: BLE001
        print("int8 export/verify failed (not promoted):", str(e).splitlines()[0])
        results["int8"] = {"error": str(e).splitlines()[0], "kept": False}

    (HERE / "results.json").write_text(json.dumps(results, indent=1))
    print("wrote", HERE / "results.json")


if __name__ == "__main__":
    sys.exit(main())
