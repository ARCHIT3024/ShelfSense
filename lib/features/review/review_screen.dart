import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/di.dart';
import '../../app/theme.dart';
import '../../core/logger.dart';
import '../../core/result.dart';
import '../../domain/models/models.dart' show RawBox;
import '../../data/db/database.dart';
import '../../ml/common/image_crop.dart';
import 'review_repository.dart';
import 'sku_picker_sheet.dart';

const _tag = 'ReviewScreen';

/// Below this on-screen width the SKU chip is hidden so a dense rack stays
/// readable; the outline alone still carries the state colour.
const _kChipMinWidthPx = 44.0;

/// Smallest box the rep can draw or resize to, as a fraction of the photo.
const _kMinBoxFrac = 0.02;

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.visitId, this.focusSkuId});
  final String visitId;

  /// From `/shelf`: zoom to this SKU's first box once loaded.
  final String? focusSkuId;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen>
    with TickerProviderStateMixin {
  late final ReviewRepository _repo;
  ReviewData? _data;
  Object? _loadError;

  int _photoIndex = 0;
  // Decoded (EXIF-corrected) pixel size per photo — the frame the normalised
  // boxes are drawn against. Resolved lazily from the image cache.
  final _imageSizes = <String, Size>{};

  final _transform = TransformationController();
  double _scale = 1;
  Size _viewport = Size.zero;
  Rect _photoRect = Rect.zero; // where the photo sits inside the viewport

  // Resize mode for one box.
  String? _editingId;
  Rect? _editRect; // normalised, live while dragging
  _Corner? _dragCorner;
  bool _dragMove = false;

  // Long-press-to-draw.
  Offset? _drawStart; // normalised
  Rect? _drawRect;

  bool _summaryExpanded = false;

  late final AnimationController _reveal = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 250));
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _repo = ReviewRepository(ref.read(dbProvider));
    _transform.addListener(_onTransform);
    _load();
  }

  @override
  void dispose() {
    _transform.removeListener(_onTransform);
    _transform.dispose();
    _reveal.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _onTransform() {
    final s = _transform.value.getMaxScaleOnAxis();
    if ((s - _scale).abs() > 0.01) setState(() => _scale = s);
  }

  Future<void> _load({bool animate = true}) async {
    try {
      final data = await _repo.load(widget.visitId);
      if (!mounted) return;
      setState(() {
        _data = data;
        _loadError = null;
        if (_photoIndex >= data.photos.length) _photoIndex = 0;
      });
      for (final p in data.photos) {
        _resolveImageSize(p);
      }
      if (animate) _reveal.forward(from: 0);
      _applyFocus(data);
    } catch (e) {
      AppLogger.e(_tag, 'Load failed', e);
      if (mounted) setState(() => _loadError = e);
    }
  }

  bool _focusDone = false;

  /// Zooms to the focused SKU after the viewer has laid out (needs
  /// `_photoRect`, which only exists after the first frame with an image).
  void _applyFocus(ReviewData data) {
    final sku = widget.focusSkuId;
    if (sku == null || _focusDone) return;
    final target = data.detections.where((d) => d.skuId == sku).firstOrNull;
    if (target == null) {
      _focusDone = true;
      return;
    }
    void attempt(int triesLeft) {
      if (!mounted) return;
      if (_photoRect != Rect.zero) {
        _focusDone = true;
        _jumpTo(target);
        return;
      }
      if (triesLeft > 0) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => attempt(triesLeft - 1));
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => attempt(30));
  }

  void _resolveImageSize(VisitPhoto p) {
    if (_imageSizes.containsKey(p.id)) return;
    final stream = FileImage(File(p.filePath)).resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener((info, _) {
      stream.removeListener(listener);
      if (!mounted) return;
      setState(() => _imageSizes[p.id] =
          Size(info.image.width.toDouble(), info.image.height.toDouble()));
    }, onError: (e, _) {
      stream.removeListener(listener);
      AppLogger.e(_tag, 'Image decode failed for ${p.filePath}', e);
      if (mounted) {
        // Fall back to the stored dims so the screen still works.
        setState(() =>
            _imageSizes[p.id] = Size(p.width.toDouble(), p.height.toDouble()));
      }
    });
    stream.addListener(listener);
  }

  // ---------------------------------------------------------------------
  // Derived
  // ---------------------------------------------------------------------

  VisitPhoto? get _photo =>
      (_data?.photos.isEmpty ?? true) ? null : _data!.photos[_photoIndex];

  List<Detection> get _boxesOnPhoto {
    final p = _photo;
    if (p == null) return const [];
    return _data!.detections.where((d) => d.photoId == p.id).toList();
  }

  ({int packs, int matched, int untagged}) get _counts {
    var packs = 0, matched = 0, untagged = 0;
    for (final d in _data?.detections ?? const <Detection>[]) {
      if (d.isGap) continue;
      packs++;
      if (d.skuId != null) {
        matched++;
      } else {
        untagged++;
      }
    }
    return (packs: packs, matched: matched, untagged: untagged);
  }

  // ---------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------

  Future<void> _onBoxTap(Detection d) async {
    if (_editingId != null) return;
    if (d.isGap) {
      await _repo.dismissGap(d);
      await _load(animate: false);
      return;
    }
    final data = _data!;
    final current = data.skuById(d.skuId);
    final candidates = <RankedSku>[
      if (current != null) RankedSku(current, d.matchConfidence ?? 1.0),
    ];
    // With the recogniser loaded, rank the enrolled SKUs for this box so
    // the picker opens pre-filled with the top-3 (06_APP_FLOW §/review).
    final embedder = ref.read(embedderProvider);
    final index = ref.read(skuIndexProvider);
    if (embedder != null && embedder.isLoaded && !index.isEmpty) {
      final r = await embedder.embedBoxes(_photo!.filePath,
          [RawBox(x1: d.x1, y1: d.y1, x2: d.x2, y2: d.y2, score: 1)]);
      if (r case Ok(:final value) when value.first != null) {
        for (final c in index.topMatches(value.first!, k: 3)) {
          if (c.skuId == current?.id) continue;
          final sku = data.skuById(c.skuId);
          if (sku != null) candidates.add(RankedSku(sku, c.confidence));
        }
      }
      if (!mounted) return;
    }
    final result = await showSkuPicker(
      context,
      detection: d,
      photo: _photo!,
      skus: data.skus,
      candidates: candidates,
    );
    if (!mounted || result == null) return;
    switch (result) {
      case PickSku(:final sku):
        await _repo.setSku(d, sku);
        HapticFeedback.selectionClick();
        await _load(animate: false);
      case PickDelete():
        await _deleteBox(d);
      case PickAdjust():
        _beginEdit(d);
      case PickEnrol():
        await _enrolFromBox(d);
    }
  }

  Future<void> _onBoxLongPress(Detection d) async {
    if (_editingId != null) return;
    HapticFeedback.mediumImpact();
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.crop_free),
              title: const Text('Resize box'),
              onTap: () => Navigator.pop(ctx, 'adjust'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.danger),
              title: const Text('Delete box',
                  style: TextStyle(color: AppColors.danger)),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'delete') await _deleteBox(d);
    if (action == 'adjust') _beginEdit(d);
  }

  Future<void> _deleteBox(Detection d) async {
    await _repo.deleteBox(d);
    HapticFeedback.mediumImpact();
    await _load(animate: false);
  }

  Future<void> _enrolFromBox(Detection d) async {
    final photo = _photo!;
    try {
      final path = await writeBoxCrop(
        srcPath: photo.filePath,
        x1: d.x1,
        y1: d.y1,
        x2: d.x2,
        y2: d.y2,
        outName: d.id,
      );
      if (!mounted) return;
      // /enrol tags the box with the new SKU before popping; reload to show it.
      await context.push('/enrol', extra: {'cropPath': path, 'detectionId': d.id});
      if (mounted) await _load(animate: false);
    } catch (e) {
      AppLogger.e(_tag, 'Crop for enrolment failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not crop this pack.')),
        );
      }
    }
  }

  void _beginEdit(Detection d) {
    setState(() {
      _editingId = d.id;
      _editRect = Rect.fromLTRB(d.x1, d.y1, d.x2, d.y2);
      _summaryExpanded = false;
    });
  }

  Future<void> _commitEdit() async {
    final id = _editingId;
    final r = _editRect;
    setState(() {
      _editingId = null;
      _editRect = null;
    });
    if (id == null || r == null) return;
    final d = _data!.detections.firstWhere((x) => x.id == id);
    if ((r.left - d.x1).abs() < 1e-4 &&
        (r.top - d.y1).abs() < 1e-4 &&
        (r.right - d.x2).abs() < 1e-4 &&
        (r.bottom - d.y2).abs() < 1e-4) {
      return; // untouched
    }
    await _repo.updateBox(d, r.left, r.top, r.right, r.bottom);
    await _load(animate: false);
  }

  void _cancelEdit() => setState(() {
        _editingId = null;
        _editRect = null;
      });

  Future<void> _finishDraw() async {
    final r = _drawRect;
    setState(() {
      _drawStart = null;
      _drawRect = null;
    });
    if (r == null || r.width < _kMinBoxFrac || r.height < _kMinBoxFrac) return;
    final photo = _photo!;
    final d = await _repo.insertManualBox(
      visitId: widget.visitId,
      photoId: photo.id,
      x1: r.left,
      y1: r.top,
      x2: r.right,
      y2: r.bottom,
    );
    HapticFeedback.mediumImpact();
    await _load(animate: false);
    if (mounted) await _onBoxTap(d);
  }

  /// Zooms the viewer so [d] fills roughly a third of the viewport.
  void _jumpTo(Detection d) {
    final idx = _data!.photos.indexWhere((p) => p.id == d.photoId);
    if (idx != -1 && idx != _photoIndex) {
      setState(() => _photoIndex = idx);
      _reveal.forward(from: 0);
    }
    if (_viewport == Size.zero || _photoRect == Rect.zero) return;
    final boxW = (d.x2 - d.x1) * _photoRect.width;
    final boxH = (d.y2 - d.y1) * _photoRect.height;
    final target = math.min(_viewport.width / (boxW * 3),
            _viewport.height / (boxH * 3))
        .clamp(1.0, 5.0);
    final cx = _photoRect.left + (d.x1 + d.x2) / 2 * _photoRect.width;
    final cy = _photoRect.top + (d.y1 + d.y2) / 2 * _photoRect.height;
    // Clamp so the zoomed child never pulls away from the viewport edges
    // (InteractiveViewer only clamps user gestures, not a set transform).
    final tx = (_viewport.width / 2 - cx * target)
        .clamp(_viewport.width * (1 - target), 0.0);
    final ty = (_viewport.height / 2 - cy * target)
        .clamp(_viewport.height * (1 - target), 0.0);
    _transform.value = Matrix4.translationValues(tx, ty, 0) *
        Matrix4.diagonal3Values(target, target, 1);
    setState(() => _summaryExpanded = false);
  }

  // ---------------------------------------------------------------------
  // Gesture maths (all in normalised photo space)
  // ---------------------------------------------------------------------

  Offset _toNorm(Offset localInPhoto) => Offset(
        (localInPhoto.dx / _photoRect.width).clamp(0.0, 1.0),
        (localInPhoto.dy / _photoRect.height).clamp(0.0, 1.0),
      );

  bool _insideAnyBox(Offset n) =>
      _boxesOnPhoto.any((d) =>
          n.dx >= d.x1 && n.dx <= d.x2 && n.dy >= d.y1 && n.dy <= d.y2);

  void _editPanStart(DragStartDetails det) {
    final r = _editRect!;
    final n = _toNorm(det.localPosition);
    // Corner grab radius: 28 px on screen, converted to normalised units.
    final rx = 28 / (_photoRect.width * _scale);
    final ry = 28 / (_photoRect.height * _scale);
    _Corner? hit;
    for (final c in _Corner.values) {
      final p = c.of(r);
      if ((p.dx - n.dx).abs() <= rx && (p.dy - n.dy).abs() <= ry) {
        hit = c;
        break;
      }
    }
    _dragCorner = hit;
    _dragMove = hit == null && r.contains(n);
  }

  void _editPanUpdate(DragUpdateDetails det) {
    final r = _editRect!;
    final n = _toNorm(det.localPosition);
    Rect next = r;
    if (_dragCorner != null) {
      next = _dragCorner!.apply(r, n);
      // Keep a sane minimum size and normalise flipped drags.
      final l = math.min(next.left, next.right);
      final rr = math.max(next.left, next.right);
      final t = math.min(next.top, next.bottom);
      final b = math.max(next.top, next.bottom);
      next = Rect.fromLTRB(l, t, math.max(rr, l + _kMinBoxFrac),
          math.max(b, t + _kMinBoxFrac));
    } else if (_dragMove) {
      final dx = det.delta.dx / (_photoRect.width * _scale);
      final dy = det.delta.dy / (_photoRect.height * _scale);
      next = r.shift(Offset(dx, dy));
      next = Rect.fromLTWH(
        next.left.clamp(0.0, 1 - r.width),
        next.top.clamp(0.0, 1 - r.height),
        r.width,
        r.height,
      );
    } else {
      return;
    }
    setState(() => _editRect = Rect.fromLTRB(
          next.left.clamp(0.0, 1.0),
          next.top.clamp(0.0, 1.0),
          next.right.clamp(0.0, 1.0),
          next.bottom.clamp(0.0, 1.0),
        ));
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final counts = _counts;
    final editing = _editingId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review'),
        leading: editing
            ? IconButton(
                tooltip: 'Cancel',
                icon: const Icon(Icons.close),
                onPressed: _cancelEdit,
              )
            : null,
        actions: [
          if (editing)
            TextButton(
              onPressed: _commitEdit,
              child: const Text('Done'),
            )
          else ...[
            if (data != null && data.photos.length > 1)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: Sp.sm),
                  child: Text(
                    '${_photoIndex + 1}/${data.photos.length}',
                    style: AppText.mono,
                  ),
                ),
              ),
            IconButton(
              tooltip: 'Add another photo',
              icon: const Icon(Icons.add_a_photo_outlined),
              onPressed: () => context.pushReplacement('/capture/${widget.visitId}'),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildViewer(data)),
          if (!editing) _buildSummary(counts),
        ],
      ),
      bottomNavigationBar: editing
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    Sp.screen, Sp.sm, Sp.screen, Sp.lg),
                child: SizedBox(
                  height: Tap.counter,
                  child: FilledButton(
                    onPressed: data == null
                        ? null
                        : () => context.push('/shelf/${widget.visitId}'),
                    child: Text(counts.untagged > 0
                        ? 'Continue (${counts.untagged} untagged)'
                        : 'Continue'),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildViewer(ReviewData? data) {
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Sp.xxl),
          child: Text('Could not load this visit.\n$_loadError',
              style: AppText.body, textAlign: TextAlign.center),
        ),
      );
    }
    if (data == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    final photo = _photo;
    if (photo == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Sp.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_camera_outlined,
                  size: 64, color: AppColors.textDisabled),
              const SizedBox(height: Sp.lg),
              const Text('No photo yet', style: AppText.heading),
              const SizedBox(height: Sp.xxl),
              FilledButton(
                onPressed: () => context.pushReplacement('/capture/${widget.visitId}'),
                child: const Text('Photograph the shelf'),
              ),
            ],
          ),
        ),
      );
    }
    final imgSize = _imageSizes[photo.id];
    if (imgSize == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    final boxes = _boxesOnPhoto;
    final editing = _editingId != null;

    return Column(
      children: [
        if (data.photos.length > 1) _buildPhotoStrip(data),
        Expanded(
          child: Container(
            color: Colors.black,
            child: LayoutBuilder(builder: (context, c) {
              final vw = c.maxWidth, vh = c.maxHeight;
              final fit = math.min(vw / imgSize.width, vh / imgSize.height);
              final dw = imgSize.width * fit, dh = imgSize.height * fit;
              final rect = Rect.fromLTWH((vw - dw) / 2, (vh - dh) / 2, dw, dh);
              _viewport = Size(vw, vh);
              _photoRect = rect;

              return Stack(
                children: [
                  InteractiveViewer(
                    transformationController: _transform,
                    minScale: 1,
                    maxScale: 6,
                    panEnabled: !editing && _drawStart == null,
                    scaleEnabled: !editing && _drawStart == null,
                    child: SizedBox(
                      width: vw,
                      height: vh,
                      child: Stack(
                        children: [
                          Positioned.fromRect(
                            rect: rect,
                            child: _buildPhotoLayer(photo, boxes, rect),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (editing)
                    Positioned(
                      top: Sp.md,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _Hint('Drag corners to resize · drag inside to move'),
                      ),
                    )
                  else if (boxes.isEmpty)
                    Positioned(
                      bottom: Sp.md,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _Hint('No packs found. Long-press and drag to draw a box.'),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoLayer(VisitPhoto photo, List<Detection> boxes, Rect rect) {
    final editing = _editingId != null;
    final dw = rect.width, dh = rect.height;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Image.file(File(photo.filePath),
              fit: BoxFit.fill, gaplessPlayback: true),
        ),
        // Long-press-to-draw layer (behind the boxes so box gestures win).
        if (!editing)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onLongPressStart: (d) {
                final n = _toNorm(d.localPosition);
                if (_insideAnyBox(n)) return;
                HapticFeedback.selectionClick();
                setState(() {
                  _drawStart = n;
                  _drawRect = Rect.fromPoints(n, n);
                });
              },
              onLongPressMoveUpdate: (d) {
                final s = _drawStart;
                if (s == null) return;
                setState(() =>
                    _drawRect = Rect.fromPoints(s, _toNorm(d.localPosition)));
              },
              onLongPressEnd: (_) => _finishDraw(),
              onLongPressCancel: () => setState(() {
                _drawStart = null;
                _drawRect = null;
              }),
            ),
          ),
        // Boxes with staggered reveal.
        for (var i = 0; i < boxes.length; i++)
          if (boxes[i].id != _editingId)
            _positionedBox(boxes[i], i, boxes.length, dw, dh),
        // Rubber band while drawing.
        if (_drawRect != null)
          Positioned.fromRect(
            rect: _scaleRect(_drawRect!, dw, dh),
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.info, width: 2 / _scale),
                  color: AppColors.info.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        // Resize/move layer for the box being edited.
        if (editing && _editRect != null) ...[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: _editPanStart,
              onPanUpdate: _editPanUpdate,
              onPanEnd: (_) {
                _dragCorner = null;
                _dragMove = false;
              },
            ),
          ),
          Positioned.fromRect(
            rect: _scaleRect(_editRect!, dw, dh),
            child: IgnorePointer(
              child: _EditBox(scale: _scale),
            ),
          ),
        ],
      ],
    );
  }

  Widget _positionedBox(
      Detection d, int i, int n, double dw, double dh) {
    final r = _scaleRect(Rect.fromLTRB(d.x1, d.y1, d.x2, d.y2), dw, dh);
    final state = boxStateOf(d,
        acceptThreshold: ref.read(thresholdsProvider).matchHigh);
    final sku = _data!.skuById(d.skuId);
    // Stagger: each box's window is shifted by its index, total ≈ 250 ms.
    final start = n <= 1 ? 0.0 : (i / n) * 0.6;
    final anim = CurvedAnimation(
      parent: _reveal,
      curve: Interval(start, math.min(1.0, start + 0.4), curve: Curves.easeOut),
    );
    final showChip = r.width * _scale >= _kChipMinWidthPx;

    return Positioned.fromRect(
      rect: r,
      child: FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 0.85, end: 1.0).animate(anim),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onBoxTap(d),
            onLongPress: state == BoxState.gap ? null : () => _onBoxLongPress(d),
            child: _BoxView(
              state: state,
              label: switch (state) {
                BoxState.matchedHigh => sku?.code ?? '',
                BoxState.matchedLow => '?',
                _ => '',
              },
              showChip: showChip,
              scale: _scale,
              pulse: _pulse,
            ),
          ),
        ),
      ),
    );
  }

  static Rect _scaleRect(Rect n, double w, double h) =>
      Rect.fromLTRB(n.left * w, n.top * h, n.right * w, n.bottom * h);

  Widget _buildPhotoStrip(ReviewData data) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Sp.screen, vertical: Sp.sm),
        itemCount: data.photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: Sp.sm),
        itemBuilder: (_, i) {
          final p = data.photos[i];
          final selected = i == _photoIndex;
          final untagged = data.detections
              .where((d) => d.photoId == p.id && !d.isGap && d.skuId == null)
              .length;
          return GestureDetector(
            onTap: () {
              if (_editingId != null) return;
              setState(() => _photoIndex = i);
              _transform.value = Matrix4.identity();
              _reveal.forward(from: 0);
            },
            child: Stack(
              children: [
                Container(
                  width: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Radii.card),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(File(p.filePath), fit: BoxFit.cover),
                ),
                if (untagged > 0)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.info,
                        borderRadius: BorderRadius.circular(Radii.pill),
                      ),
                      child: Text('$untagged',
                          style: AppText.mono.copyWith(fontSize: 10)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummary(({int packs, int matched, int untagged}) counts) {
    final data = _data;
    if (data == null) return const SizedBox.shrink();
    final untaggedBoxes = data.detections
        .where((d) => !d.isGap && d.skuId == null)
        .toList();
    final maxListHeight = MediaQuery.of(context).size.height * 0.3;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: untaggedBoxes.isEmpty
                ? null
                : () => setState(() => _summaryExpanded = !_summaryExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Sp.screen, vertical: Sp.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: '${counts.packs} pack${counts.packs == 1 ? '' : 's'}'),
                        const TextSpan(text: ' · '),
                        TextSpan(
                          text: '${counts.matched} matched',
                          style: const TextStyle(color: AppColors.success),
                        ),
                        if (counts.untagged > 0) ...[
                          const TextSpan(text: ' · '),
                          TextSpan(
                            text: '${counts.untagged} need tagging',
                            style: const TextStyle(color: AppColors.info),
                          ),
                        ],
                      ]),
                      style: AppText.body,
                    ),
                  ),
                  if (untaggedBoxes.isNotEmpty)
                    Icon(
                      _summaryExpanded
                          ? Icons.expand_more
                          : Icons.expand_less,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ),
          ),
          if (_summaryExpanded && untaggedBoxes.isNotEmpty)
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxListHeight),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: untaggedBoxes.length,
                itemBuilder: (_, i) {
                  final d = untaggedBoxes[i];
                  final photoIdx =
                      data.photos.indexWhere((p) => p.id == d.photoId);
                  return ListTile(
                    dense: true,
                    leading: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                          color: AppColors.info, shape: BoxShape.circle),
                    ),
                    title: Text('Pack ${i + 1}', style: AppText.body),
                    subtitle: Text(
                      data.photos.length > 1
                          ? 'Photo ${photoIdx + 1} · row ${d.shelfRow ?? '–'}'
                          : 'Row ${d.shelfRow ?? '–'}',
                      style: AppText.label,
                    ),
                    trailing: const Icon(Icons.zoom_in,
                        color: AppColors.textSecondary),
                    onTap: () => _jumpTo(d),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

class _BoxView extends StatelessWidget {
  const _BoxView({
    required this.state,
    required this.label,
    required this.showChip,
    required this.scale,
    required this.pulse,
  });
  final BoxState state;
  final String label;
  final bool showChip;
  final double scale;
  final Animation<double> pulse;

  Color get _color => switch (state) {
        BoxState.matchedHigh => AppColors.success,
        BoxState.matchedLow => AppColors.warning,
        BoxState.unmatched => AppColors.info,
        BoxState.gap => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    // Stroke and chip are divided by the zoom so they stay constant on screen.
    final stroke = 2 / scale;
    final color = _color;

    Widget box = CustomPaint(
      painter: _BoxPainter(
        color: color,
        stroke: stroke,
        dashed: state == BoxState.gap,
        fillOpacity: state == BoxState.gap ? 0.08 : 0.2,
      ),
      child: showChip && label.isNotEmpty
          ? Align(
              alignment: Alignment.topLeft,
              child: Transform.scale(
                scale: 1 / scale,
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    label,
                    style: AppText.mono.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bg,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );

    if (state == BoxState.unmatched) {
      box = AnimatedBuilder(
        animation: pulse,
        builder: (_, child) => Opacity(
          opacity: 0.45 + 0.55 * pulse.value,
          child: child,
        ),
        child: box,
      );
    }
    return box;
  }
}

class _BoxPainter extends CustomPainter {
  const _BoxPainter({
    required this.color,
    required this.stroke,
    required this.dashed,
    required this.fillOpacity,
  });
  final Color color;
  final double stroke;
  final bool dashed;
  final double fillOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = color.withValues(alpha: fillOpacity));
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    if (!dashed) {
      canvas.drawRect(rect.deflate(stroke / 2), p);
      return;
    }
    final dash = 6 * stroke, gap = 4 * stroke;
    final path = Path()..addRect(rect.deflate(stroke / 2));
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final end = math.min(dist + dash, metric.length);
        canvas.drawPath(metric.extractPath(dist, end), p);
        dist = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_BoxPainter old) =>
      old.color != color ||
      old.stroke != stroke ||
      old.dashed != dashed ||
      old.fillOpacity != fillOpacity;
}

/// The box under edit: primary outline plus four corner handles.
class _EditBox extends StatelessWidget {
  const _EditBox({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final handle = 18 / scale;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 2 / scale),
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
          ),
        ),
        for (final c in _Corner.values)
          Positioned(
            left: c.isLeft ? -handle / 2 : null,
            right: c.isLeft ? null : -handle / 2,
            top: c.isTop ? -handle / 2 : null,
            bottom: c.isTop ? null : -handle / 2,
            child: Container(
              width: handle,
              height: handle,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.bg, width: 2 / scale),
              ),
            ),
          ),
      ],
    );
  }
}

enum _Corner {
  topLeft(true, true),
  topRight(false, true),
  bottomLeft(true, false),
  bottomRight(false, false);

  const _Corner(this.isLeft, this.isTop);
  final bool isLeft, isTop;

  Offset of(Rect r) => Offset(isLeft ? r.left : r.right, isTop ? r.top : r.bottom);

  Rect apply(Rect r, Offset p) => Rect.fromLTRB(
        isLeft ? p.dx : r.left,
        isTop ? p.dy : r.top,
        isLeft ? r.right : p.dx,
        isTop ? r.bottom : p.dy,
      );
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: Sp.sm),
      decoration: BoxDecoration(
        color: AppColors.bg.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(text, style: AppText.label, textAlign: TextAlign.center),
    );
  }
}
