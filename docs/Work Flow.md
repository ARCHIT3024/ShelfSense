# ShelfSense — iQOO City Battle Chennai (12–13 Sep 2026)
## Implementation plan, mapped to the Red/Green light timeline

---

## 0. Read this part first — three things in your pitch that will lose you the battle

I'm not going to just schedule the plan you have. Three parts of it are wrong for a 22-hour
phone-first event, and fixing them now is worth more than any scheduling trick.

### 0.1 "A custom-trained detector on Indian FMCG packs" — not buildable in this window

Slide 8 of your deck says it plainly: *"No public dataset looks like this, so collecting one is
the first piece of work."* Slide 16 budgets **two weeks** for that. You have roughly **22 hours**,
and a chunk of it is phone-only. A closed-set detector over 40–60 Indian SKUs needs thousands of
labelled shelf photos. You will not collect, label, train and quantise that between 11:00 Saturday
and 09:00 Sunday. If you try, you will hit Sunday morning with a half-trained model and no app.

**Replace the single closed-set detector with a two-stage open-set pipeline:**

| Stage | What it does | How it's trained |
|---|---|---|
| **A. Pack finder** | Class-agnostic box detector — finds *every* pack on the rack, no labels | Fine-tune a small YOLO on a SKU-110K subset (dense retail shelves, single class). ~1–2 GPU-hours. |
| **B. SKU recogniser** | Crops from stage A → 128-d embedding → cosine nearest-neighbour against an enrolled catalogue | Metric head trained on crops **you shoot at the venue**. Minutes to train, seconds to re-enrol. |
| **C. Disambiguator** | Reads grammage / variant text off the crop to split near-identical packs (500 g vs 1 kg) | ML Kit on-device OCR — no training at all |

This is not a downgrade. It is a **better product** and a better pitch:

- A distributor adds a new SKU by **photographing it three times in the app** — no retraining, no
  APK release, no "signed weights bundle on next sync" (slide 9). Your own slide 9 promises a
  weights-bundle pipeline; enrolment removes the need for one entirely.
- It attacks the exact failure you call out on slide 5 — foreign pack vocabularies — because the
  vocabulary is built by the user, in the shop, in one afternoon.
- **It gives you an unbeatable demo moment.** Hand a judge a pack they picked up themselves,
  enrol it in 20 seconds, put it on the shelf, shoot the rack, watch it get recognised. No
  closed-set detector can do that. That single moment is worth more than 4 points of mAP.
- You still honestly say "custom-trained": you fine-tune the detector **and** train the embedding
  head during the event window. Keep the closed-set detector on the roadmap slide as the
  production endgame.

### 0.2 "Distributor sheets are generated on sync" — this throws away free points

Slides 12 and 13 put the sheet generator in a **DISTRIBUTOR** layer, i.e. off-device. The playbook
is explicit: *"Build apps that run locally and on-device, including the backend… These earn
brownie points. The highest on-device builds will be preferred for the Top 10."*

**Move XLSX, CSV and the route-summary PDF generation onto the phone.** "Sync" stops being
"upload and a server renders your files" and becomes **file handover** — share sheet, or a tiny
local HTTP server on the handset that a laptop on the same hotspot downloads from.

Your pitch line becomes: **"There is no backend. The phone is the backend."** That is a sentence
no other team in the room can say about a B2B workflow product, and it is directly what the
scoring rewards. It is also *more* true to your problem statement than the original design.

### 0.3 The live cloud-vs-on-device comparison is a demo landmine

You want to demo a cloud VLM side by side. Good idea for Novelty (20%) and Technical Depth (15%),
bad idea live. Venue wifi at 09:00 on pitch day, forty teams on it, is exactly when that call
times out — and you will be standing in front of judges having just promised "zero network."

**Build the comparison as a baked benchmark screen inside the app**: pre-computed cloud results
on your own 20-image eval set, rendered next to on-device results, with timing and accuracy.
Run the cloud side once during a Green Light block using the OpenRouter credits. The on-device
side runs live. Put the phone in **aeroplane mode for the entire demo** and let the judges see
the toggle. That's the moment that sells it.

### 0.4 One more correction: NNAPI

Slide 9 says *"TFLite, NNAPI delegate."* NNAPI was deprecated in Android 15; the iQOO 15 runs
Android 16. Don't build the plan around it. Primary path: **LiteRT/TFLite + GPU delegate on the
Adreno 840**, CPU/XNNPACK as fallback. Ask at the Saturday 10:00 teach-in whether a Qualcomm QNN /
Hexagon delegate is provided in the vendor kit — if it is, that's your stretch goal and a genuine
technical-depth talking point. Do not put NNAPI on a slide.

---

## 1. What the rules actually constrain (from your three photos + the public playbook)

**Scoring — memorise this, it dictates every trade-off:**

| Criterion | Weight | Judged by |
|---|---|---|
| End product | 30% | Jury |
| Novelty & impact | 20% | Jury |
| **Creative phone use** (camera, voice, on-device AI) | **15%** | **HackTracker telemetry — cannot be faked** |
| Technical depth | 15% | Jury |
| **Office Kit usage** | **10%** | **HackTracker telemetry — cannot be faked** |
| Demo & presentation | 10% | Jury |

25% is measured automatically off the device. It does not care what your slides claim.
HackTracker records **counts and durations only** — no keystrokes, screenshots or browsing.

**Hard rules:**
- Original work only; code written **inside the event window**. No pre-built product shipped in.
- Open-source libraries and frameworks are fine **with attribution**.
- Repo + demo assets submitted on the Reskilll platform before the hard cutoff. Repos lock before
  the Top 10 pitch. Late = penalty or DQ.
- One loaner phone per person. It stays in the venue. It goes back at the end.
- Never tamper with HackTracker. Genuine lockout → go find an organiser, don't work around it.
- Top 6 teams per bucket (student / professional) go to the Grand Finale, Bengaluru, Oct 9–11.
  Standouts beyond the Top 6 can earn Finale slots too.

**Licensing note worth 30 seconds on stage:** Ultralytics YOLO is AGPL-3.0. Use it — it's the
fastest path in 22 hours — but **attribute it in your README** and be ready to say: *"For a
commercial distributor deployment we'd swap the backbone to NanoDet-Plus or RT-DETR under Apache-2.0;
the pipeline is backbone-agnostic."* Judges notice teams who know their own licence exposure.

---

## 2. The Red/Green timeline as I read your photo

| Block | Window | Light | Hours | Laptop? |
|---|---|---|---|---|
| G1 | Sat 11:00 – 14:00 | 🟢 Green | 3.0 | Direct |
| R1 | Sat 14:00 – 15:30 | 🔴 Red | 1.5 | Office Kit only |
| G2 | Sat 15:30 – 16:30 | 🟢 Green | 1.0 | Direct |
| R2 | Sat 16:30 – 19:00 | 🔴 Red | 2.5 | Office Kit only |
| G3 | Sat 19:00 – 22:00 | 🟢 Green | 3.0 | Direct |
| R3 | Sat 22:00 – Sun 01:00 | 🔴 Red | 3.0 | Office Kit only |
| G4 | Sun 01:00 – 06:30 | 🟢 Green | 5.5 | Direct |
| R4 | Sun 06:30 – 09:00 | 🔴 Red | 2.5 | Office Kit only |

**Two things I could not verify — confirm both at check-in:**

1. That colour reading (green first, alternating) is my read of a photographed bar. Confirm it.
2. **The numbers don't reconcile.** This is 12.5 h green / 9.5 h red = 57/43, but iQOO's public
   material says **55% Red / 45% Green**, and the rules card says the event runs to **~17:00
   Sunday**. Your bar stops at 09:00. So there is almost certainly more schedule after 09:00 that
   isn't in this photo — and it is probably heavily red. **Plan as if everything after 09:00 is
   Red Light**: evaluation, Top 10 pitch, and demo all on the phone. That assumption costs you
   nothing if it's wrong and saves you if it's right.
3. The rules card mentions **two evaluation rounds** feeding the Top 10 pitch. I read it as "Sat
   morning, Sun morning," which can't be right since the build starts Sat 11:00 — it's likely
   Sat evening and Sun morning. **Ask an organiser for the exact times in the first hour.**
   The plan below sets hard demoable checkpoints at **19:00 Sat** and **06:30 Sun** so you're
   covered either way.

**The operating principle for the whole event:**

> Green Light is for things that *physically require* a laptop — GPU training, model export,
> Gradle builds, adb. Everything else is Red Light work. Green Light is your scarcest resource
> even though there's more of it, because only laptops can do what Green Light unlocks.

Corollary: **never debug app logic during Green Light.** Debugging is phone-side. Green Light is
for compiling and training.

---

## 3. Architecture

```
┌─ PHONE (iQOO 15 · SD 8 Elite Gen 5 · Android 16) ──────────────────┐
│                                                                     │
│  camera ──► Stage A: pack finder (YOLO11n INT8, GPU delegate)       │
│                    │ boxes, class-agnostic                          │
│                    ▼                                                │
│              Stage B: crop ──► MobileNetV3 embedder ──► cosine kNN  │
│                    │                    over enrolled SKU index      │
│                    ▼                                                │
│              Stage C: ML Kit OCR on low-confidence crops            │
│                    │ grammage / variant tie-break                    │
│                    ▼                                                │
│              Planogram diff ──► facings, stockouts, below-plan      │
│                    │                                                │
│         ┌──────────┴──────────┐                                     │
│         ▼                     ▼                                     │
│   Order draft (editable)   Voice note ──► Whisper-tiny (ASR)        │
│         │                     │                                     │
│         └──────────┬──────────┘                                     │
│                    ▼                                                │
│        On-device LLM (Gemma 3 1B int4, MediaPipe LLM Inference)     │
│        → structured visit record JSON + beat summary prose          │
│                    ▼                                                │
│              drift / SQLite visit queue                             │
│                    ▼                                                │
│        ON-DEVICE GENERATORS: XLSX · CSV · PDF route summary         │
│                    ▼                                                │
│        Handover: share sheet │ local HTTP server on hotspot         │
└─────────────────────────────────────────────────────────────────────┘
                       NO SERVER.  NO NETWORK CALL.  ANYWHERE.
```

**Stack decisions and why — Flutter build (you know Flutter; use it):**

I originally specced native Kotlin. With three Flutter-capable students and 22 hours, that's wrong —
the framework you already know wins. Flutter is also genuinely *better* for the half of this product
that generates files, because the Dart XLSX and PDF libraries are pure-Dart and run on-device with no
fight at all. That removes the single ugliest task in the original plan.

| Layer | Choice | Notes / risk |
|---|---|---|
| App | **Flutter + Dart** | Rules explicitly welcome Flutter. Keep one escape hatch open: a Kotlin **platform channel** for the vision hot path if Dart preprocessing is too slow (see below). |
| Camera | `camera` package, **still capture only** | Do **not** run inference on the preview stream. Detect on shutter press. This dodges the Dart YUV→RGB cost, saves battery, and prevents thermal throttle during the demo. |
| Detector | **YOLO11n → TFLite INT8** via `tflite_flutter` with `GpuDelegateV2` | Attribute the AGPL-3.0. XNNPACK multi-thread as fallback. |
| Preprocessing | `image` package, run in a Dart **isolate** | This is the known Flutter trap. If a 640×640 resize+normalise costs >300 ms, move preprocessing + inference behind a Kotlin platform channel. **Time-box the decision to 30 minutes in R2.** |
| Embedder | **MobileNetV3-Small**, 128-d, ArcFace or triplet head, TFLite INT8 | CLIP is too heavy and its zero-shot is bad on Indian packaging — literally your slide-5 argument. |
| Index | Plain `Float32List` in SQLite, brute-force cosine | 40 SKUs × 8 embeddings = 320 vectors. FAISS is pure overhead here. |
| OCR | `google_mlkit_text_recognition` | Fully offline, bundled. Latin script first; add Devanagari/Tamil script models only if L3 time exists. |
| ASR | `whisper_ggml` / whisper.cpp binding, tiny model — **45-minute timebox**. Fallback: `speech_to_text` with the Android offline language pack | The playbook names Whisper Tiny, so it's worth the attempt. Be honest on stage: tiny handles English/Hinglish; Tamil is roadmap. |
| LLM | **`flutter_gemma` → Gemma 3 1B IT int4** (wraps MediaPipe LLM Inference, GPU backend) | Lowest-risk on-device LLM path in Flutter. **90-minute timebox**, then fall back to a llama.cpp binding with Qwen2.5-1.5B-Instruct Q4_K_M. Timer, not judgement. |
| DB | `drift` (or `sqflite` if faster for you) | — |
| **XLSX** | **`syncfusion_flutter_xlsio`** — pure Dart, generates real .xlsx on-device | This replaces the hand-rolled OOXML writer from the original plan. Hours saved. |
| **PDF** | **`pdf` + `printing`** packages — pure Dart | Route summary rendered entirely on the handset. |
| Handover | `share_plus` + **`shelf`** (Dart HTTP server running on the phone) | The local-server moment is a *pitch asset*, not just plumbing: laptop joins the phone's hotspot and downloads the beat's XLSX from the handset. |

**The hard rule for the LLM:** it is never in the blocking path. Detection → diff → order draft
must work perfectly with the LLM turned off. The LLM adds the narrative visit record and the
reorder rationale. If it OOMs at 08:50 Sunday, you still have a product.

---

## 4. Fallback ladder — the single most important table here

Build in this order. Each level is independently demoable. **Do not start a level until the one
below it works on the phone.**

| Level | Deadline | What works | If you stop here |
|---|---|---|---|
| **L0** | **Sat 22:00** | Shoot rack → boxes drawn → tap each box to tag SKU manually → order draft → XLSX + CSV on device | A real, working, offline field tool. Unexciting but **complete**. This is your floor. |
| **L1** | **Sun 02:30** | Enrolment flow + embedding recogniser auto-labels boxes; planogram diff computes facings / stockouts / below-plan | This is the product in your deck. Ship-worthy. |
| **L2** | **Sun 05:00** | Voice note → Whisper → on-device LLM → structured visit record + reorder rationale + PDF beat summary | Now it hits "on-device LLM at the core." Brownie points. |
| **L3** | **Sun 06:15** | OCR grammage tie-break · cloud-vs-on-device benchmark screen · local HTTP handover server | Top 10 material. |

**06:30 Sunday is a hard feature freeze.** Whatever compiles at 06:30 is what you pitch. After
that: install, rehearse, submit. No exceptions — the number of hackathon teams who lost on a
07:40 "one last commit" is very large.

---

## 5. Team roles — 3 students, 3 Windows laptops, ~6 GB VRAM each

- **A — Model lead.** Detector fine-tune, embedder training, INT8 export, latency benchmarking,
  the cloud baseline run.
- **B — App lead.** Flutter UI, camera, drift schema, inference wiring, the demo build.
- **C — Output & AI lead.** XLSX/CSV/PDF generators, Whisper + LLM pipeline, deck, demo script,
  Reskilll submission. **C owns the clock and calls the freeze.**

**A is the bottleneck in Green Light and idle-ish in Red Light. B is the reverse.** That asymmetry
is what the schedule below exploits.

### Two things your hardware unlocks

**Three GPUs means three parallel training runs.** Don't queue them. A's laptop trains the
detector; C's laptop trains the embedder as soon as the enrolment crops land; B's laptop never
trains anything and stays free for Flutter builds. At 6 GB VRAM, YOLO11n at 640 px needs
`batch=8, workers=2, amp=True` — it fits, but do not try 16.

**CUDA setup rule:** if `torch.cuda.is_available()` isn't `True` within **15 minutes** on a given
laptop, stop fixing it and move that run to Colab. Chasing a Windows CUDA/driver mismatch has eaten
entire hackathons. Set a timer.

### The scheduling trick that matters most

**A GPU doesn't need a human. Start every long training run in the last 20 minutes of a Green Light
block, so it trains *through* the Red Light block that follows.** Your laptops are off-limits to
your hands during red light, not off. Monitor from the phone browser (TensorBoard on localhost, or
just tail the log via Office Kit) — which is itself real phone work HackTracker will see.

Applied to your schedule: kick the detector run off by **13:40**, not 12:15, if you can — it then
trains through R1 (14:00–15:30) and is ready exactly when G2 opens. Same pattern before R2 and R3.

---

## 6. Block-by-block schedule

### 🟢 G1 · Sat 11:00–14:00 (3h) — parallel cold start

The most expensive block of the event. Nobody writes UI polish here.

| Who | Task |
|---|---|
| **All, 11:00–11:15** | Empty repo, push, both laptops cloned. **Confirm Office Kit pairing works on both laptops before you need it.** Ask organisers: exact evaluation-round times, post-09:00 schedule, QNN delegate availability. |
| **A** | Start the SKU-110K subset download (~2k images) **immediately** — longest-latency item. In parallel, verify CUDA on your laptop (15-min rule, §5). Config YOLO11n `imgsz=640, batch=8, amp=True`. **Kick training off by 13:40 so it runs through R1.** |
| **B** | Flutter project skeleton: `flutter create`, camera still-capture screen, drift entities (`Store`, `Sku`, `Planogram`, `Visit`, `Detection`, `OrderLine`), routing. Add `tflite_flutter`, `syncfusion_flutter_xlsio`, `pdf`, `google_mlkit_text_recognition` to `pubspec.yaml` and **confirm the release build compiles now**, not at 04:00. **Install a running APK on the iQOO phone before 14:00 — that's the block's success criterion.** |
| **C** | **Leave the venue and buy 30–40 real FMCG packs** from the nearest kirana (see §7). Back by 12:30. Build a 3-shelf rack from cartons on your desk. Then: XLSX writer scaffolding on the laptop. |

**Exit criteria for G1:** APK on the phone showing camera preview · YOLO training running ·
physical demo shelf standing on your desk.

---

### 🔴 R1 · Sat 14:00–15:30 (1.5h) — first phone block

| Who | Task |
|---|---|
| **A** | **Monitor the training run from the phone browser** (Colab / SSH via a phone terminal app). This is real work done on the phone and HackTracker sees it. |
| **B** | On-phone testing of the G1 APK. Capture flow UX: one-handed, thumb-reachable shutter, works in dim light. Fix via Office Kit remote control — **you are now also earning the 10% Office Kit score.** |
| **C** | **Shoot the enrolment set on the iQOO phone.** 30–40 SKUs × 8 shots each (angle, distance, tube light, shadow, partial occlusion). ~250–320 images. This is the highest-value 90 minutes of the whole event and it is *only* doable on the phone. Transfer to laptop via Office Kit file transfer. |

---

### 🟢 G2 · Sat 15:30–16:30 (1h) — short, surgical

| Who | Task |
|---|---|
| **A** | Detector training should be converging. Export best checkpoint → TFLite INT8. Hand the `.tflite` to B. |
| **B** | Wire the detector into the app: image → isolate resize/normalise → `tflite_flutter` GPU delegate → NMS in Dart → boxes on a `CustomPainter` overlay. |
| **C** | Train the embedder on the enrolment crops. Small model, small data — minutes, not hours. Export INT8. |

**Nothing else. One hour, three artefacts, hand them off.**

---

### 🔴 R2 · Sat 16:30–19:00 (2.5h) — make L0 real

| Who | Task |
|---|---|
| **B** | Boxes must render live on the phone. Tap-a-box → SKU picker sheet. This is L0's core. |
| **A** | Measure real latency and memory on the iQOO 15 — **these numbers replace the `000 ms` / `0.0 MB` placeholders on slide 9.** Judges will ask. Have the real figures. Break the timing into *preprocess / inference / NMS* — you need to know which one is slow. |
| **B** | **30-minute decision point: is Dart preprocessing >300 ms?** If yes, move resize+normalise+inference behind a Kotlin platform channel. Decide once, here, and never revisit it. |
| **C** | Planogram diff logic + order-draft screen. XLSX/CSV generation moved onto the phone. |

**19:00 checkpoint — first possible evaluation round. Be demoable:** shoot the rack, see boxes,
tag manually, produce a real XLSX file on the phone. Say the phrase *"zero network calls"* and
show aeroplane mode.

---

### 🟢 G3 · Sat 19:00–22:00 (3h) — heavy integration

| Who | Task |
|---|---|
| **A** | Embedding recogniser into the app: crop → embed → cosine kNN → label + confidence. Plus: **run the cloud VLM baseline via OpenRouter credits on your 20-image eval set now**, while the network is a tool and not a risk. Save results as a JSON asset. |
| **B** | Enrolment flow in-app: photograph a pack 3× → embed → write to index → available immediately. **This is the judge-facing magic trick — it has to be flawless.** |
| **C** | MediaPipe LLM Inference integration + Gemma 3 1B int4 asset bundled. Get *any* generation running on device before 22:00. |

**Exit criteria for G3: L0 complete and frozen. Tag it in git.** If L0 isn't done by 22:00, cancel
L2 and L3 outright and spend the rest of the night hardening L0. A polished L0 beats a broken L2 —
the playbook says this in as many words.

---

### 🔴 R3 · Sat 22:00–Sun 01:00 (3h) — phone block + sleep rotation

| Who | Task |
|---|---|
| **B** | **Sleep 22:00–00:30.** B has the 5.5-hour Green Light block next and must be sharp for it. |
| **A** | On-phone accuracy testing against the physical shelf. Build a confusion list — which SKUs get swapped? Feed that back into the tie-break design. Re-shoot enrolment images for weak SKUs. |
| **C** | LLM prompt engineering **on the device**, not on the laptop — 1B models behave differently quantised. Force JSON output, write a *forgiving* parser, and a deterministic non-LLM fallback path for every field. Also: start the deck rewrite (see §8). |

Sleep is not optional. A 5.5-hour Green Light block worked by three exhausted people produces
fewer working features than 4 hours worked by two rested ones. Rotate: B sleeps in R3, A sleeps
02:00–04:00, C sleeps 04:00–06:00.

---

### 🟢 G4 · Sun 01:00–06:30 (5.5h) — the biggest block

| Time | Focus |
|---|---|
| 01:00–02:30 | **L1 close-out.** Recogniser + planogram diff end to end. Tag `L1`. |
| 02:30–04:00 | **L2.** Whisper-tiny wiring, voice → LLM → structured visit record, PDF route summary generated on device. Tag `L2`. |
| 04:00–05:00 | **L3, strictly time-boxed.** OCR tie-break · benchmark screen · local HTTP handover. Anything not working at 05:00 gets reverted, not fixed. |
| 05:00–06:00 | **Bug bash only. No new code.** Run the full demo flow ten times in aeroplane mode. Every crash gets fixed or the feature gets hidden behind a flag. |
| 06:00–06:30 | Build release APK. Install clean on the demo phone. **Push everything. Submit the repo + demo assets to Reskilll now, not later** — beat the cutoff by hours, you can update if allowed. |

**06:30 = FEATURE FREEZE.** Git tag `demo`. Nobody touches the laptop again except to re-install
the same APK.

---

### 🔴 R4 · Sun 06:30–09:00 (2.5h) — pitch prep, phone only

| Who | Task |
|---|---|
| **All** | Finish the deck **on the phone** (Google Slides / Canva mobile). Real numbers everywhere. |
| **All** | **Rehearse the demo six times, out loud, on the phone, in aeroplane mode.** Time it. Find the one step that breaks under nerves and script around it. |
| **C** | Verify the Reskilll submission went through. Screenshot the confirmation. |
| **All** | Charge the phone to 100%. Clean the camera lens. Set the demo shelf up exactly as rehearsed. |

Assume everything from here is Red Light. Have nothing that needs a laptop.

---

## 7. The demo shelf — do not skip this

Buy from a kirana near the venue, ~₹2,000–3,000, all of it demo-usable:

- **Near-identical pairs that prove the grammage point:** same brand two sizes (e.g. a 500 g and a
  1 kg salt pack), same brand two variants (e.g. masala vs plain noodles).
- **Regional-language pack faces** — the exact case you say cloud models fail on.
- **Hanging strips / sachet rails** — slide 8's "half the pack behind a hanging strip."
- **A couple of competitor packs** for the competitor-share story on slide 4.
- Mix of rigid cartons, pouches, bottles. Vary the shine — foil pouches are your hard case.

Three cartons stacked makes the rack. **Deliberately leave two gaps** so the stockout detection
fires live.

**Why this decides the battle:** every other team will demo on a screenshot or a stock photo. You
will hand a judge a packet, enrol it in front of them, and watch it get recognised on a phone in
aeroplane mode. That is the Demo 10% and a large slice of the End Product 30%, purchased for
₹3,000 and one hour of C's time.

---

## 8. The deck needs a rewrite

The attached deck is a **concept pitch** — 17 slides, `000 ms`, `0.00 mAP`, `0,000 images`, and a
12-week roadmap. That deck is correct for an idea-screening round and **wrong for a build
competition**, where the jury weights End Product at 30%.

Restructure to ~8 slides:

1. **Problem** — keep slides 3 and 4 nearly verbatim. They are the strongest pages you have.
2. **Why nothing existing reaches kirana** — compress slide 5 to three lines.
3. **What we built** — a screenshot sequence, not architecture. Past tense.
4. **The open-set pipeline** — finder → embedder → OCR tie-break. Why open-set beats closed-set
   *for the user*, not just for your schedule.
5. **Measured, on this handset** — real ms, real MB, real recognition accuracy on your own eval
   set, real APK size. The honesty of "these are our numbers from last night" lands hard.
6. **On-device vs cloud** — your baked benchmark. One chart.
7. **Zero backend** — the phone generates the XLSX. This is the differentiator; give it a slide.
8. **What's next** — the 12-week plan from slide 16, now credible because you shipped in 22 hours.

**Delete the placeholder zeros.** A `0.00` on a judged slide reads as "we didn't measure."

**Demo script, 3 minutes flat:**
> *"Thirty stores a day, four minutes each, and the shelf is never recorded."* (10s)
> → Aeroplane mode ON, held up to the judges. (5s)
> → Shoot the rack. Boxes appear. Stockouts flagged red. (25s)
> → **Judge picks a packet not in the catalogue. Enrol it live, three photos, re-shoot, it's recognised.** (45s)
> → Voice note: *"owner wants extra noodles before Diwali"* → structured visit record + reorder draft. (30s)
> → Tap export → XLSX opens **on the phone**. *"No server touched this. None exists."* (25s)
> → One line on the 12-week pilot. (20s)

---

## 8b. Framing for the Productivity track

You're registered under **Productivity**, and the rules card is explicit that *"tracks are broad
domains, not fixed briefs."* So ShelfSense fits — but only if you frame it as **workflow
automation**, not as a computer-vision project. Judges scoring a Productivity entry are asking
"what manual work did this delete?", not "what's your mAP?"

Lead every framing with the work eliminated:

- **Before:** 4 minutes per store × 35 stores, then 60–90 minutes of evening data entry at the
  office. Shelf state recorded: none.
- **After:** one shutter press per store, order confirmed at the counter, and the distributor's
  spreadsheet already exists before the rep leaves the beat. Data entry deleted entirely.

Say the phrase **"we removed the evening data-entry shift"** on stage. That is the Productivity
sentence. The on-device model is *how*, not *what*.

One consequence: your **KPI slide should be time, not accuracy.** Minutes saved per beat, entries
eliminated per day, hours from visit to distributor sheet (was: next morning; is: instant). Keep
the accuracy numbers on the technical-depth slide where they belong.

Students bucket: you're competing against the other student teams only, three prizes, three Finale
slots — plus the standout route beyond the Top 6. A finished, boring-but-working workflow tool
places better in this bucket than an ambitious broken one.

---

## 9. Risk register

| Risk | Trigger | Action |
|---|---|---|
| SKU-110K download too slow on venue wifi | Not down by 12:00 | Drop to 800 images, or train the finder on your own enrolment shots with box labels — 300 images of your own shelf is enough for a single-class finder on *your* shelf. |
| CUDA won't initialise on a Windows laptop | 15 min in | Move that run to Colab T4. Do not debug drivers. |
| 6 GB VRAM OOM during YOLO training | First epoch | `batch=4`, or `imgsz=512`. 512 is fine — you're detecting large rigid packs, not small objects. |
| `flutter_gemma` won't load the model | 90 min spent in G3 | Hard switch to a llama.cpp binding + Qwen2.5-1.5B-Instruct Q4_K_M. **Timer, not judgement.** |
| Dart preprocessing too slow | R2 decision point | Kotlin platform channel for the vision path. Budget 60 min; if it isn't working, drop to `imgsz=512` and accept ~700 ms — still well inside "under a second in a dim aisle." |
| Syncfusion licence banner in generated XLSX | First export | Syncfusion's community licence is free but needs registering. Check at G1, not at 06:00. If it's noisy, `excel` package or plain CSV + a `pdf` summary is an acceptable L0. |
| Recogniser confuses two SKUs | Any time | OCR tie-break; if that fails, show both with confidences and let the rep pick. Slide 11 already says the human confirms every line — lean on it, it's a *feature*. |
| Detection too slow on GPU delegate | R2 benchmarking | Drop input to 480×480, or fall back to XNNPACK 4-thread. Sub-second on an 8 Elite Gen 5 is very achievable at 480. |
| Phone thermal throttle during demo | Repeated inference | Don't loop inference in preview. Detect on shutter press only. Also saves battery. |
| HackTracker lockout | Any time | **Go to an organiser immediately.** Never work around it. |
| Someone "just adds one thing" after 06:30 | Sunday morning | C has authority to veto. Written down here so it isn't a debate at 07:15. |

---

## 10. Phone / laptop work split — the reference card

**Only ever on the laptop (Green Light):**
GPU training · TFLite export & quantisation · Gradle builds and APK installs · adb ·
bulk dataset handling · the one cloud baseline run.

**Always on the phone (Red Light, and good for it):**
Enrolment and eval photography · all accuracy testing against the real shelf · LLM prompt
iteration on the quantised model · latency and thermal measurement · UX testing one-handed ·
deck building · demo rehearsal · submission · monitoring a Colab run from the browser.

**Through Office Kit (Red Light, earns the 10%):**
Remote-controlling a laptop to kick off or restart a training run · pulling the enrolment images
off the phone · pushing a rebuilt APK back to the phone · clipboard between the two while you
debug from the phone screen.

Don't spend 100% of Red Light puppeting the laptop through Office Kit — that maximises the 10%
and starves the 15%. Roughly **two-thirds native phone work, one-third Office Kit** across each
red block.

---

## 11. Attribution checklist for the README (rules require it)

- Ultralytics YOLO11 — **AGPL-3.0**, note the commercial swap plan
- SKU-110K dataset — cite the paper and licence
- MobileNetV3 (torchvision / timm) weights
- Google MediaPipe LLM Inference API, via `flutter_gemma`
- Gemma 3 1B — Gemma Terms of Use
- whisper.cpp — MIT; Whisper model — MIT
- ML Kit Text Recognition, via `google_mlkit_text_recognition`
- `tflite_flutter`, `drift`, `image`, `share_plus`, `shelf` — check each licence
- **`syncfusion_flutter_xlsio` — community licence, register it and say so**
- `pdf` / `printing` packages
- **State plainly: repo initialised empty at 11:00 Saturday, all application code written in-window.**

---

*Plan authored before the build window. Everything above is design and scheduling — write the
code in-window, from an empty repo, as the rules require.*
