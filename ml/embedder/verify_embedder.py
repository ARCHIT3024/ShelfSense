"""Verify an exported embedder the way the app will use it.

Loads assets/models/embedder_*.tflite with the LiteRT runtime, dumps the
tensor contract, embeds every crop with the app's normalisation, and reports:
  - held-out nearest-neighbour top-1 (same split as train_embedder.py)
  - the confusion pairs (true -> predicted, with the winning cosine)
  - mean cosine: same-SKU best match vs best other-SKU match
  - a 13x13 mean-cosine matrix between SKUs (all crops)

Usage (from ml/embedder, inside .venv):
  python verify_embedder.py [path/to/model.tflite]
"""
from __future__ import annotations

import sys
from pathlib import Path

import numpy as np
from ai_edge_litert.interpreter import Interpreter

from train_embedder import (CROPS, OUT_DIR, load_image, normalise,
                            split_dataset, to_arrays)

path = Path(sys.argv[1]) if len(sys.argv) > 1 else OUT_DIR / "embedder_fp16.tflite"
it = Interpreter(model_path=str(path), num_threads=4)
it.allocate_tensors()
inp, out = it.get_input_details()[0], it.get_output_details()[0]
print(f"{path.name}: {path.stat().st_size/1e6:.2f} MB")
print("IN ", inp["shape"], inp["dtype"].__name__, inp["quantization"])
print("OUT", out["shape"], out["dtype"].__name__, out["quantization"])


def embed(x_norm):
    e = np.zeros((len(x_norm), out["shape"][-1]), np.float32)
    for i in range(len(x_norm)):
        it.set_tensor(inp["index"], x_norm[i:i + 1].astype(np.float32))
        it.invoke()
        v = it.get_tensor(out["index"])[0]
        e[i] = v / (np.linalg.norm(v) + 1e-9)
    return e


classes, train_items, val_items = split_dataset()
xt, yt = to_arrays(train_items)
xv, yv = to_arrays(val_items)
et, ev = embed(normalise(xt)), embed(normalise(xv))
print(f"\nembedded {len(et)} train + {len(ev)} held-out crops, norm check "
      f"{np.linalg.norm(ev, axis=1).min():.3f}..{np.linalg.norm(ev, axis=1).max():.3f}")

# Held-out NN, best-per-SKU like the app
sims = ev @ et.T
per_class = np.full((len(ev), len(classes)), -1.0, np.float32)
for j, c in enumerate(yt):
    per_class[:, c] = np.maximum(per_class[:, c], sims[:, j])
pred = per_class.argmax(1)
print(f"held-out NN top-1: {(pred == yv).mean():.3f}  ({(pred == yv).sum()}/{len(yv)})")
same = np.array([per_class[i, yv[i]] for i in range(len(yv))])
other = np.array([np.delete(per_class[i], yv[i]).max() for i in range(len(yv))])
print(f"mean cosine  same-SKU {same.mean():.3f}  ·  best other-SKU {other.mean():.3f}  "
      f"·  worst margin {(same - other).min():+.3f}")
print(f"app routing @0.72/0.55: {int((same >= 0.72).sum())} accept, "
      f"{int(((same >= 0.55) & (same < 0.72)).sum())} low-conf, {int((same < 0.55).sum())} unmatched "
      f"of {len(same)} held-out")
conf = [(classes[a], classes[b], per_class[i, b]) for i, (a, b) in enumerate(zip(yv, pred)) if a != b]
print("confusions:", conf if conf else "none")

# Closest other-SKU pairs (mean cosine between all crops of the two SKUs)
E = np.concatenate([et, ev]); Y = np.concatenate([yt, yv])
M = np.zeros((len(classes), len(classes)))
for a in range(len(classes)):
    for b in range(len(classes)):
        M[a, b] = (E[Y == a] @ E[Y == b].T).mean()
pairs = sorted(((M[a, b], classes[a], classes[b]) for a in range(len(classes))
                for b in range(a + 1, len(classes))), reverse=True)[:6]
print("\nclosest SKU pairs (mean cross-cosine — the ones most likely to swap):")
for s, a, b in pairs:
    print(f"  {a:14} ~ {b:14} {s:.3f}")
print("\nmean cosine matrix (rows/cols in this order):", classes)
np.set_printoptions(precision=2, suppress=True, linewidth=160)
print(M)
