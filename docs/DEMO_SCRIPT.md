# ShelfSense — 3-minute judge demo

Setup before the judge arrives: aeroplane mode ON (Wi-Fi off too), phone at 100 %, the demo rack
lit, `/diagnostics → Reset demo data` run once after the last rehearsal, then a cold start so the
models are warm. Keep the laptop closed until step 8.

Say the numbers only when the screen is showing them.

| # | Tap | Say (≈ 20 s each) |
|---|---|---|
| 0 | Show the status bar (aeroplane icon) and the **OFFLINE** badge on `/beat`. | "This phone has no network. It won't need one at any point — the phone is the backend." |
| 1 | `/beat` — point at the header `N / 12 done · ₹ · stockouts`, one **Done** and one **Pending** pill. | "A distributor rep visits 10–15 kirana shops a day. This is today's beat." |
| 2 | Tap a **Pending** store → `/store`. Point at *Last visit / Last order / Stockouts* and the planogram list. | "Before walking in, the rep sees what this shop ordered last time and what should be on the shelf." |
| 3 | **Start visit** → `/capture`. Frame the rack. **Shutter.** | "One photo. Not a video, not a stream — one shutter press." Wait for `Finding packs… Recognising…`. |
| 4 | `/review` appears with boxes. Pinch to zoom. Point at a **green** box chip, an **amber ?**, a **blue** one. | "Every pack found on device in about 700 milliseconds. Green: it knows the SKU. Amber: it has a shortlist. Blue: never seen before." |
| 5 | Tap the **amber** box → ranked candidates → pick one. | "The rep never types a name — three candidates, one tap. Every correction is logged; the model learns from the field." |
| 6 | Tap a **blue** box → **Enrol this pack** → type name + grammage → **Next** → take **2 shots** → **Test it now** → **Done**. The box turns green. | "A new product: two more photos, forty-five seconds, no retraining, no app update. It's recognised from the next photo onward." |
| 7 | **Continue** → `/shelf` (stockouts first) → **Continue to order** → `/order`. Tap **+** once, tap **+ Add line** and pick one. **Confirm**. | "Plan versus found, per SKU. The order is drafted from the gap and this shop's history, rounded to cases. The rep adjusts, adds what the owner asks for, confirms." |
| 8 | **Share XLSX** (show the file in the sheet, cancel). Back to beat → **Export beat** → **Generate all** → PDF in the sheet. Cancel → **Handover** → **Serve on Wi-Fi** → show the QR. | "Excel, CSV and a beat PDF, generated on the handset. The distributor's laptop pulls them straight from the phone over the hotspot — no cloud, no account." |
| 9 | Diagnostics (tune icon on `/beat`): model cards and the connectivity card. | "Both models, their delegates and latencies. And the honest line: this app never uses the network on the path you just saw." |

Total ≈ 3 minutes with the shutter at the 35-second mark.

## Numbers to have in your head

- Pack Finder: mAP50 0.889 on 2,935 held-out SKU-110K test images, trained in the window.
- On the iQOO 15: 32 ms detect, ~2 ms per pack to recognise, ~760 ms shutter-to-labelled boxes.
- Models: 3.0 MB + 2.0 MB. 113 unit tests. Zero network calls.
- Enrolment: ≤ 45 s, 3 photos minimum, 8 recommended.

## If X goes wrong, do Y

| Symptom | Do | Say |
|---|---|---|
| Shutter → **no boxes** | Long-press and drag on the photo to draw one; tap it and pick the SKU. | "Manual fallback — the loop never blocks on the model." |
| Box is **amber** | Tap → pick from the ranked three. | "Low confidence is shown, never silently guessed." |
| Box is **green but wrong** | Tap → pick the right SKU. | "Logged as an override — training data for the next model." |
| Box on the **wrong thing** (price tag, hand) | Long-press → Delete. | Nothing; move on. |
| **Recognises nothing** after enrolment | `/diagnostics` → Recogniser card → **Reload**; check the index count > 0. | "Index reloads in a second." |
| Camera **black** or stuck | Back, then **Start visit** again (camera re-initialises). | — |
| `Finding packs…` for > 3 s | Back → `/beat` → the store shows **Resume** → reopen; the photo is saved. | — |
| Store shows **Resume** instead of Pending | Tap it — it reopens the draft's review. Or `/diagnostics → Reset demo data` before the next judge. | — |
| Share sheet shows **no apps** | Cancel; say the file is on disk; show `/handover` instead. | "Same file, over the hotspot." |
| Handover URL **won't open** on the laptop | Confirm both are on the phone's hotspot; the URL is on screen; fall back to the share sheet. | — |
| App **crashes** | Reopen — the visit is a draft with its photo; **Resume** on the beat. | "Every step is persisted before the next one runs." |

Never say "AI". Say what it did: found, recognised, drafted, wrote.
