import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/db/database.dart';

/// What the rep chose in the picker. `null` from the sheet means dismissed.
sealed class PickerResult {
  const PickerResult();
}

class PickSku extends PickerResult {
  const PickSku(this.sku);
  final SkusData sku;
}

class PickEnrol extends PickerResult {
  const PickEnrol();
}

class PickAdjust extends PickerResult {
  const PickAdjust();
}

class PickDelete extends PickerResult {
  const PickDelete();
}

/// A ranked candidate for a box. Filled by the embedder once T-20 lands;
/// until then the current match (if any) is the only candidate.
class RankedSku {
  const RankedSku(this.sku, this.confidence);
  final SkusData sku;
  final double confidence;
}

Future<PickerResult?> showSkuPicker(
  BuildContext context, {
  required Detection detection,
  required VisitPhoto photo,
  required List<SkusData> skus,
  required List<RankedSku> candidates,
}) {
  return showModalBottomSheet<PickerResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
    ),
    builder: (_) => _SkuPickerSheet(
      detection: detection,
      photo: photo,
      skus: skus,
      candidates: candidates,
    ),
  );
}

class _SkuPickerSheet extends StatefulWidget {
  const _SkuPickerSheet({
    required this.detection,
    required this.photo,
    required this.skus,
    required this.candidates,
  });
  final Detection detection;
  final VisitPhoto photo;
  final List<SkusData> skus;
  final List<RankedSku> candidates;

  @override
  State<_SkuPickerSheet> createState() => _SkuPickerSheetState();
}

class _SkuPickerSheetState extends State<_SkuPickerSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<SkusData> get _filtered {
    if (_query.isEmpty) return widget.skus;
    final q = _query.toLowerCase();
    return widget.skus.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.code.toLowerCase().contains(q) ||
          (s.brand?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.detection;
    final height = MediaQuery.of(context).size.height * 0.85;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final filtered = _filtered;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            const SizedBox(height: Sp.sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(Radii.pill),
              ),
            ),
            // Crop + current state — anchors the rep in what they're tagging.
            Padding(
              padding: const EdgeInsets.fromLTRB(Sp.screen, Sp.lg, Sp.screen, Sp.md),
              child: Row(
                children: [
                  _CropThumb(photo: widget.photo, detection: d),
                  const SizedBox(width: Sp.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.skuId == null ? 'Tag this pack' : 'Correct this pack',
                          style: AppText.heading,
                        ),
                        const SizedBox(height: Sp.xs),
                        Text(
                          'Detected at ${(d.detConfidence * 100).round()}%',
                          style: AppText.label,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Adjust box',
                    onPressed: () =>
                        Navigator.pop(context, const PickAdjust()),
                    icon: Icon(Icons.crop_free,
                        color: AppColors.textSecondary),
                  ),
                  IconButton(
                    tooltip: 'Delete box',
                    onPressed: () =>
                        Navigator.pop(context, const PickDelete()),
                    icon: Icon(Icons.delete_outline,
                        color: AppColors.danger),
                  ),
                ],
              ),
            ),
            if (widget.candidates.isNotEmpty) ...[
              const _SectionLabel('Best matches'),
              for (final c in widget.candidates)
                _CandidateRow(
                  candidate: c,
                  selected: c.sku.id == d.skuId,
                  onTap: () => Navigator.pop(context, PickSku(c.sku)),
                ),
              const SizedBox(height: Sp.sm),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.screen),
              child: TextField(
                controller: _search,
                autofocus: false,
                textInputAction: TextInputAction.search,
                onChanged: (v) => setState(() => _query = v.trim()),
                decoration: InputDecoration(
                  hintText: 'Search name, code or brand',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: Sp.sm),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No SKU matches "$_query"',
                        style: AppText.body
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final s = filtered[i];
                        return _SkuRow(
                          sku: s,
                          selected: s.id == d.skuId,
                          onTap: () => Navigator.pop(context, PickSku(s)),
                        );
                      },
                    ),
            ),
            // The demo hinges on this being one tap away.
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    Sp.screen, Sp.sm, Sp.screen, Sp.md),
                child: SizedBox(
                  width: double.infinity,
                  height: Tap.counter,
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryDim,
                      foregroundColor: AppColors.textPrimary,
                    ),
                    onPressed: () =>
                        Navigator.pop(context, const PickEnrol()),
                    icon: const Icon(Icons.add),
                    label: const Text('Enrol this pack'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows just the box's region of the photo without decoding a second copy —
/// `Align` with width/height factors clips the already-cached image.
class _CropThumb extends StatelessWidget {
  const _CropThumb({required this.photo, required this.detection});
  final VisitPhoto photo;
  final Detection detection;

  @override
  Widget build(BuildContext context) {
    final d = detection;
    final w = (d.x2 - d.x1).clamp(0.01, 1.0);
    final h = (d.y2 - d.y1).clamp(0.01, 1.0);
    // FractionalOffset maps 0..1 across the *remaining* slack, hence the divide.
    final ax = w >= 1 ? 0.0 : d.x1 / (1 - w);
    final ay = h >= 1 ? 0.0 : d.y1 / (1 - h);
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.card),
      child: Container(
        width: 96,
        height: 96,
        color: AppColors.surfaceAlt,
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: ClipRect(
            child: Align(
              alignment: FractionalOffset(ax, ay),
              widthFactor: w,
              heightFactor: h,
              child: Image.file(File(photo.filePath)),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.screen, Sp.xs, Sp.screen, Sp.xs),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text.toUpperCase(),
            style: AppText.label.copyWith(letterSpacing: 0.8)),
      ),
    );
  }
}

class _CandidateRow extends StatelessWidget {
  const _CandidateRow(
      {required this.candidate, required this.selected, required this.onTap});
  final RankedSku candidate;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = candidate.sku;
    final pct = (candidate.confidence * 100).round();
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Sp.screen, vertical: Sp.xs),
        padding: const EdgeInsets.all(Sp.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(s.name, style: AppText.heading)),
                Text(_grammage(s), style: AppText.mono),
              ],
            ),
            const SizedBox(height: Sp.sm),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Radii.pill),
                    child: LinearProgressIndicator(
                      value: candidate.confidence,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      color: pct >= 72 ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
                const SizedBox(width: Sp.sm),
                Text('$pct%', style: AppText.mono),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkuRow extends StatelessWidget {
  const _SkuRow({required this.sku, required this.selected, required this.onTap});
  final SkusData sku;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minTileHeight: Tap.counter,
      selected: selected,
      selectedTileColor: AppColors.surfaceAlt,
      title: Text(sku.name, style: AppText.body),
      subtitle: Text(
        [sku.code, if (sku.brand != null) sku.brand!].join(' · '),
        style: AppText.label,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_grammage(sku), style: AppText.mono),
          if (!sku.isEnrolled) ...[
            const SizedBox(width: Sp.sm),
            Tooltip(
              message: 'Not enrolled yet',
              child: Icon(Icons.visibility_off_outlined,
                  size: 16, color: AppColors.textDisabled),
            ),
          ],
        ],
      ),
    );
  }
}

String _grammage(SkusData s) {
  final v = s.grammageValue;
  if (v == null) return '';
  final disp = v == v.floorToDouble() ? v.toInt().toString() : v.toString();
  return '$disp ${s.grammageUnit ?? ''}'.trim();
}
