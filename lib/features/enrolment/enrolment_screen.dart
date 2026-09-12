import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/di.dart';
import '../../app/theme.dart';
import '../../core/logger.dart';
import '../../data/db/database.dart';
import '../../core/result.dart';
import '../../ml/common/thresholds.dart';
import '../../ml/embedder/sku_index.dart' show MatchRoute, routeScore;
import 'enrol_camera.dart';
import 'enrolment_repository.dart';

const _tag = 'EnrolScreen';

/// Coverage grid: two slots per context, in the order the rep should shoot.
final _kSlots = [
  for (final c in kEnrolContexts) ...[c, c],
];

const _kHints = {
  'bright': 'Bright — face the light, pack filling the square',
  'dim': 'Dim — turn away from the light',
  'angled': 'Angled — tilt the pack about 30°',
  'occluded': 'Occluded — cover a corner with a finger',
};

enum _Step { details, capture, test }

/// `/enrol` — 3-step flow (04_UIUX_DESIGN §`/enrol`). Target: under 45 s.
class EnrolmentScreen extends ConsumerStatefulWidget {
  const EnrolmentScreen({
    super.key,
    this.skuId,
    this.preloadedCropPath,
    this.detectionId,
  });

  /// Enrol more shots for an existing SKU (skips step 1).
  final String? skuId;

  /// A crop handed over from `/review` — becomes shot #1.
  final String? preloadedCropPath;

  /// The `/review` box the crop came from; tagged with the new SKU on finish.
  final String? detectionId;

  @override
  ConsumerState<EnrolmentScreen> createState() => _EnrolmentScreenState();
}

class _EnrolmentScreenState extends ConsumerState<EnrolmentScreen> {
  late final EnrolmentRepository _repo;
  _Step _step = _Step.details;
  SkusData? _sku;
  List<EnrolShot> _shots = const [];
  String? _pendingCrop;
  int? _selectedSlot; // rep override of which slot to shoot next
  bool _busy = false;

  // "Test it now" — re-run the last shelf photo against the updated index.
  bool _testing = false;
  String? _testResult;

  bool get _recogniserReady {
    final d = ref.read(detectorProvider);
    final e = ref.read(embedderProvider);
    return d != null && d.isLoaded && e != null && e.isLoaded;
  }

  /// Detect on the most recent shelf photo, embed every box, count how many
  /// the index now attributes to this SKU. Nothing is written to the DB.
  Future<void> _runTest() async {
    final sku = _sku;
    if (sku == null || _testing) return;
    setState(() {
      _testing = true;
      _testResult = null;
    });
    try {
      final db = ref.read(dbProvider);
      final photo = await (db.select(db.visitPhotos)
            ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)])
            ..limit(1))
          .getSingleOrNull();
      if (photo == null || !await File(photo.filePath).exists()) {
        _testResult = 'No shelf photo yet — photograph a rack first.';
        return;
      }
      final index = ref.read(skuIndexProvider);
      await index.refresh();
      final det = await ref.read(detectorProvider)!.detect(photo.filePath);
      final boxes = switch (det) {
        Ok(:final value) => value,
        Err(:final failure) => throw StateError(failure.message),
      };
      if (boxes.isEmpty) {
        _testResult = 'No packs found on the last shelf photo.';
        return;
      }
      final emb =
          await ref.read(embedderProvider)!.embedBoxes(photo.filePath, boxes);
      final vectors = switch (emb) {
        Ok(:final value) => value,
        Err(:final failure) => throw StateError(failure.message),
      };
      var hits = 0, low = 0;
      for (final v in vectors) {
        if (v == null) continue;
        final top = index.topMatches(v, k: 1);
        if (top.isEmpty || top.first.skuId != sku.id) continue;
        switch (routeScore(top.first.confidence)) {
          case MatchRoute.accept:
            hits++;
          case MatchRoute.lowConfidence:
            low++;
          case MatchRoute.unmatched:
            break;
        }
      }
      _testResult = hits > 0
          ? '$hits of ${boxes.length} packs recognised as ${sku.name}'
              '${low > 0 ? ' (+$low low-confidence)' : ''}'
          : low > 0
              ? '$low of ${boxes.length} packs look like ${sku.name}, '
                  'but below the accept threshold — add shots'
              : 'Not recognised on the last shelf photo — '
                  'add shots in different light';
    } catch (e) {
      AppLogger.e(_tag, 'Test failed', e);
      _testResult = 'Test failed: $e';
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _repo = EnrolmentRepository(
        ref.read(dbProvider), ref.read(embedderProvider),
        index: ref.read(skuIndexProvider));
    _pendingCrop = widget.preloadedCropPath;
    if (widget.skuId != null) _openExisting(widget.skuId!);
  }

  Future<void> _openExisting(String id) async {
    final sku = await _repo.skuById(id);
    if (sku == null || !mounted) return;
    await _startCapture(sku);
  }

  // ---- Step transitions --------------------------------------------------

  Future<void> _startCapture(SkusData sku) async {
    setState(() {
      _sku = sku;
      _busy = true;
    });
    var shots = await _repo.shots(sku.id);
    // The crop from /review counts as the first shot.
    final crop = _pendingCrop;
    if (crop != null && await File(crop).exists()) {
      _pendingCrop = null;
      await _repo.addShot(
          skuId: sku.id, cropPath: crop, context: _nextContext(shots));
      shots = await _repo.shots(sku.id);
    }
    if (!mounted) return;
    setState(() {
      _shots = shots;
      _step = _Step.capture;
      _busy = false;
    });
  }

  String _nextContext(List<EnrolShot> shots) {
    final slot = _selectedSlot ?? _firstEmptySlot(shots);
    return slot == null ? kEnrolContexts.first : _kSlots[slot];
  }

  /// Maps shots onto the 8 slots by context, in order; overflow is ignored
  /// for display (still stored on disk).
  List<EnrolShot?> _slotAssignment(List<EnrolShot> shots) {
    final out = List<EnrolShot?>.filled(_kSlots.length, null);
    for (final s in shots) {
      for (var i = 0; i < _kSlots.length; i++) {
        if (_kSlots[i] == s.context && out[i] == null) {
          out[i] = s;
          break;
        }
      }
    }
    return out;
  }

  int? _firstEmptySlot(List<EnrolShot> shots) {
    final a = _slotAssignment(shots);
    final i = a.indexWhere((s) => s == null);
    return i == -1 ? null : i;
  }

  Future<void> _onShot(String cropPath) async {
    final sku = _sku!;
    final ctx = _nextContext(_shots);
    await _repo.addShot(skuId: sku.id, cropPath: cropPath, context: ctx);
    final shots = await _repo.shots(sku.id);
    if (!mounted) return;
    setState(() {
      _shots = shots;
      _selectedSlot = null; // fall back to auto-advance
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _removeShot(EnrolShot shot) async {
    await _repo.removeShot(_sku!.id, shot);
    final shots = await _repo.shots(_sku!.id);
    if (mounted) setState(() => _shots = shots);
  }

  Future<void> _finish() async {
    final sku = _sku;
    if (sku != null && widget.detectionId != null) {
      await _repo.tagDetection(widget.detectionId!, sku.id);
    }
    if (!mounted) return;
    if (context.canPop()) {
      context.pop(sku?.id);
    } else {
      context.go('/beat');
    }
  }

  // ---- Build -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_sku == null ? 'Enrol a pack' : _sku!.name),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: _StepHeader(step: _step),
        ),
      ),
      body: _busy
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : switch (_step) {
              _Step.details => _DetailsStep(
                  repo: _repo,
                  preloadedCropPath: _pendingCrop,
                  onPicked: _startCapture,
                ),
              _Step.capture => _buildCapture(),
              _Step.test => _buildTest(),
            },
    );
  }

  Widget _buildCapture() {
    final slots = _slotAssignment(_shots);
    final nextSlot = _selectedSlot ?? _firstEmptySlot(_shots);
    final nextCtx = nextSlot == null ? null : _kSlots[nextSlot];
    final count = _shots.length;
    final canTest = count >= kMinEnrolShots;

    return Column(
      children: [
        // Coverage grid — 8 slots, fills with thumbnails.
        Padding(
          padding: const EdgeInsets.fromLTRB(Sp.screen, Sp.md, Sp.screen, Sp.sm),
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: Sp.sm,
            crossAxisSpacing: Sp.sm,
            childAspectRatio: 1,
            children: [
              for (var i = 0; i < _kSlots.length; i++)
                _SlotTile(
                  label: _kSlots[i],
                  shot: slots[i],
                  isNext: i == nextSlot,
                  onTap: () => setState(() => _selectedSlot = i),
                  onLongPress:
                      slots[i] == null ? null : () => _removeShot(slots[i]!),
                ),
            ],
          ),
        ),
        Expanded(
          child: EnrolCamera(
            onShot: _onShot,
            hint: nextCtx == null
                ? 'All 8 slots filled — extra shots still help'
                : _kHints[nextCtx]!,
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                Sp.screen, Sp.sm, Sp.screen, Sp.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: '$count / ${_kSlots.length} shots',
                        style: AppText.heading),
                    TextSpan(
                      text: canTest
                          ? '  ·  ready to test'
                          : '  ·  ${kMinEnrolShots - count} more to test',
                      style: AppText.label,
                    ),
                  ]),
                ),
                const SizedBox(height: Sp.sm),
                // Theme buttons are full-width (Size.fromHeight) — never put
                // one in a Row with an Expanded sibling.
                FilledButton(
                  onPressed: canTest
                      ? () => setState(() => _step = _Step.test)
                      : null,
                  child: const Text('Test it now'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTest() {
    final sku = _sku!;
    final embedded = _shots.where((s) => s.embedded).length;
    final hasModel = ref.read(embedderProvider)?.isLoaded ?? false;
    final enrolled = embedded >= kMinEnrolShots;
    final canTest = _recogniserReady;

    return Padding(
      padding: const EdgeInsets.all(Sp.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(Sp.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(Radii.card),
            ),
            child: Row(
              children: [
                if (_shots.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Radii.card),
                    child: Image.file(File(_shots.first.path),
                        width: 72, height: 72, fit: BoxFit.cover),
                  ),
                const SizedBox(width: Sp.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sku.name, style: AppText.heading),
                      const SizedBox(height: Sp.xs),
                      Text(
                        [sku.code, if (sku.brand != null) sku.brand!]
                            .join(' · '),
                        style: AppText.label,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Sp.lg),
          _StatRow(label: 'Shots captured', value: '${_shots.length}'),
          _StatRow(
            label: 'Embeddings',
            value: hasModel ? '$embedded' : 'pending model',
          ),
          _StatRow(
            label: 'Status',
            value: enrolled ? 'Enrolled' : 'Not yet recognisable',
            valueColor: enrolled ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(height: Sp.xl),
          if (!hasModel)
            Container(
              padding: const EdgeInsets.all(Sp.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(Radii.card),
              ),
              child: const Text(
                'Shots are saved. They will be embedded automatically once '
                'the recogniser model is loaded, and this pack will then be '
                'recognised on the next shelf photo.',
                style: AppText.body,
              ),
            ),
          if (canTest) ...[
            const SizedBox(height: Sp.sm),
            SizedBox(
              height: Tap.counter,
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryDim,
                  foregroundColor: AppColors.textPrimary,
                ),
                onPressed: _testing ? null : _runTest,
                icon: const Icon(Icons.bolt),
                label: Text(_testing
                    ? 'Re-running last shelf photo…'
                    : 'Test it now'),
              ),
            ),
            if (_testResult != null) ...[
              const SizedBox(height: Sp.md),
              Text(_testResult!,
                  style: AppText.body.copyWith(
                    color: _testResult!.contains('recognised as')
                        ? AppColors.success
                        : AppColors.textSecondary,
                  )),
            ],
          ],
          const Spacer(),
          SizedBox(
            height: Tap.counter,
            child: OutlinedButton(
              onPressed: () => setState(() => _step = _Step.capture),
              child: const Text('Add more shots'),
            ),
          ),
          const SizedBox(height: Sp.sm),
          SizedBox(
            height: Tap.counter,
            child: FilledButton(
              onPressed: _finish,
              child: Text(widget.detectionId != null
                  ? 'Done — tag the box'
                  : 'Done'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1 — Details
// ---------------------------------------------------------------------------

class _DetailsStep extends StatefulWidget {
  const _DetailsStep({
    required this.repo,
    required this.preloadedCropPath,
    required this.onPicked,
  });
  final EnrolmentRepository repo;
  final String? preloadedCropPath;
  final Future<void> Function(SkusData) onPicked;

  @override
  State<_DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends State<_DetailsStep> {
  bool _createNew = true;
  List<SkusData> _skus = const [];
  String _query = '';

  // New-SKU form
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _grammage = TextEditingController();
  final _variant = TextEditingController();
  final _mrp = TextEditingController();
  final _caseSize = TextEditingController(text: '1');
  String _unit = 'g';
  bool _more = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    widget.repo.activeSkus().then((s) {
      if (mounted) setState(() => _skus = s);
    });
  }

  @override
  void dispose() {
    for (final c in [_name, _brand, _grammage, _variant, _mrp, _caseSize]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submitNew() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final sku = await widget.repo.createSku(
        name: _name.text,
        brand: _brand.text,
        grammageValue: double.tryParse(_grammage.text.trim()),
        grammageUnit: _grammage.text.trim().isEmpty ? null : _unit,
        variant: _variant.text,
        mrpPaise: ((double.tryParse(_mrp.text.trim()) ?? 0) * 100).round(),
        caseSize: int.tryParse(_caseSize.text.trim()) ?? 1,
      );
      await widget.onPicked(sku);
    } catch (e) {
      AppLogger.e(_tag, 'Create SKU failed', e);
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.preloadedCropPath != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(Sp.screen, Sp.md, Sp.screen, 0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Radii.card),
                  child: Image.file(File(widget.preloadedCropPath!),
                      width: 64, height: 64, fit: BoxFit.cover),
                ),
                const SizedBox(width: Sp.md),
                const Expanded(
                  child: Text('This pack from the shelf photo becomes shot 1.',
                      style: AppText.body),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(Sp.screen),
          child: SegmentedButton<bool>(
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary,
              selectedForegroundColor: AppColors.textPrimary,
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
            ),
            segments: const [
              ButtonSegment(value: true, label: Text('New SKU')),
              ButtonSegment(value: false, label: Text('Existing SKU')),
            ],
            selected: {_createNew},
            onSelectionChanged: (s) => setState(() => _createNew = s.first),
          ),
        ),
        Expanded(child: _createNew ? _buildForm() : _buildExisting()),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Sp.screen, Sp.sm, Sp.screen, Sp.xl),
        children: [
          TextFormField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Pack name *'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: Sp.md),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _grammage,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Grammage'),
                ),
              ),
              const SizedBox(width: Sp.sm),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _unit,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  items: [
                    for (final u in const ['g', 'kg', 'ml', 'l', 'n'])
                      DropdownMenuItem(value: u, child: Text(u)),
                  ],
                  onChanged: (v) => setState(() => _unit = v ?? 'g'),
                ),
              ),
            ],
          ),
          const SizedBox(height: Sp.md),
          TextButton.icon(
            onPressed: () => setState(() => _more = !_more),
            icon: Icon(_more ? Icons.expand_less : Icons.expand_more),
            label: const Text('More details'),
          ),
          if (_more) ...[
            TextFormField(
              controller: _brand,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Brand'),
            ),
            const SizedBox(height: Sp.md),
            TextFormField(
              controller: _variant,
              decoration:
                  const InputDecoration(labelText: 'Variant (e.g. masala)'),
            ),
            const SizedBox(height: Sp.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _mrp,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'MRP (₹)'),
                  ),
                ),
                const SizedBox(width: Sp.sm),
                Expanded(
                  child: TextFormField(
                    controller: _caseSize,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Case size'),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: Sp.xl),
          SizedBox(
            height: Tap.counter,
            child: FilledButton(
              onPressed: _saving ? null : _submitNew,
              child: const Text('Next — capture'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExisting() {
    final q = _query.toLowerCase();
    final list = q.isEmpty
        ? _skus
        : _skus
            .where((s) =>
                s.name.toLowerCase().contains(q) ||
                s.code.toLowerCase().contains(q) ||
                (s.brand?.toLowerCase().contains(q) ?? false))
            .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.screen),
          child: TextField(
            onChanged: (v) => setState(() => _query = v.trim()),
            decoration: const InputDecoration(
              hintText: 'Search name, code or brand',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(height: Sp.sm),
        Expanded(
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final s = list[i];
              return ListTile(
                minTileHeight: Tap.counter,
                onTap: () => widget.onPicked(s),
                title: Text(s.name, style: AppText.body),
                subtitle: Text(
                  [s.code, if (s.brand != null) s.brand!].join(' · '),
                  style: AppText.label,
                ),
                trailing: Icon(
                  s.isEnrolled ? Icons.check_circle : Icons.circle_outlined,
                  color: s.isEnrolled ? AppColors.success : AppColors.textDisabled,
                  semanticLabel: s.isEnrolled ? 'Enrolled' : 'Not enrolled',
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step});
  final _Step step;

  @override
  Widget build(BuildContext context) {
    const labels = ['Details', 'Capture', 'Test'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.screen, 0, Sp.screen, Sp.sm),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: Sp.sm),
                child: Icon(Icons.arrow_forward,
                    size: 14, color: AppColors.textDisabled),
              ),
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= step.index
                    ? AppColors.primary
                    : AppColors.surfaceAlt,
              ),
              child: Text('${i + 1}',
                  style: AppText.mono.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: i <= step.index ? AppColors.bg : AppColors.textSecondary,
                  )),
            ),
            const SizedBox(width: Sp.xs),
            Text(
              labels[i],
              style: AppText.label.copyWith(
                color: i == step.index
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: i == step.index ? FontWeight.w600 : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.label,
    required this.shot,
    required this.isNext,
    required this.onTap,
    required this.onLongPress,
  });
  final String label;
  final EnrolShot? shot;
  final bool isNext;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(
            color: isNext ? AppColors.primary : AppColors.border,
            width: isNext ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (shot != null)
              Image.file(File(shot!.path), fit: BoxFit.cover)
            else
              Icon(Icons.add_a_photo_outlined,
                  size: 20,
                  color: isNext ? AppColors.primary : AppColors.textDisabled),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: AppColors.bg.withValues(alpha: 0.75),
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppText.label.copyWith(fontSize: 10),
                ),
              ),
            ),
            if (shot != null && shot!.embedded)
              const Positioned(
                top: 2,
                right: 2,
                child: Icon(Icons.check_circle,
                    size: 14, color: AppColors.success),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, this.valueColor});
  final String label, value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sp.sm),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.body)),
          Text(value,
              style: AppText.mono.copyWith(color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}
