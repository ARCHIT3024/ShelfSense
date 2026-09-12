/// OrderScreen — T-19
///
/// Shows the rep the suggested order draft, lets them edit each finalQty
/// with +/– steppers, then confirms the visit (persist + XLSX + CSV).
///
/// Owned by C (provider + export wiring). B owns the visual polish.
library;

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/di.dart';
import '../../app/theme.dart';
import '../../data/db/database.dart' show SkusData;
import '../../domain/models/models.dart';
import 'order_provider.dart';

class OrderScreen extends ConsumerWidget {
  const OrderScreen({super.key, required this.visitId});
  final String visitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(orderProvider(visitId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Order Draft', style: AppText.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recompute',
            onPressed: () => ref.invalidate(orderProvider(visitId)),
          ),
        ],
      ),
      body: async.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (state) {
          if (state.isConfirmed) return _ConfirmedView(state: state);
          if (!state.hasLines) return const _EmptyView();
          return _OrderBody(visitId: visitId, state: state);
        },
      ),
      bottomNavigationBar: async.whenOrNull(
        data: (state) {
          if (state.isConfirmed || !state.hasLines || state.isLoading) {
            return null;
          }
          return _ConfirmBar(
            visitId: visitId,
            totalPaise: state.totalValuePaise,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Order body
// ---------------------------------------------------------------------------

class _OrderBody extends ConsumerWidget {
  const _OrderBody({required this.visitId, required this.state});
  final String visitId;
  final OrderState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _SummaryStrip(state: state),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: Sp.sm),
            // Last item is the secondary "+ Add line" action (04_UIUX §/order).
            itemCount: state.lines.length + 1,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, indent: Sp.screen),
            itemBuilder: (_, i) => i == state.lines.length
                ? _AddLineButton(visitId: visitId, state: state)
                : _OrderLineRow(
                    line: state.lines[i],
                    visitId: visitId,
                  ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// + Add line — what the owner asks for that isn't on the shelf
// ---------------------------------------------------------------------------

class _AddLineButton extends ConsumerWidget {
  const _AddLineButton({required this.visitId, required this.state});
  final String visitId;
  final OrderState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.screen, Sp.md, Sp.screen, Sp.lg),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add line'),
        onPressed: () async {
          final sku = await showModalBottomSheet<SkusData>(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppColors.surface,
            shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
            ),
            builder: (_) => _AddLineSheet(
              alreadyDrafted: state.lines.map((l) => l.skuId).toSet(),
            ),
          );
          if (sku != null) {
            ref.read(orderProvider(visitId).notifier).addLine(sku);
          }
        },
      ),
    );
  }
}

/// Searchable catalogue list; SKUs already on the draft are shown disabled.
class _AddLineSheet extends ConsumerStatefulWidget {
  const _AddLineSheet({required this.alreadyDrafted});
  final Set<String> alreadyDrafted;

  @override
  ConsumerState<_AddLineSheet> createState() => _AddLineSheetState();
}

class _AddLineSheetState extends ConsumerState<_AddLineSheet> {
  List<SkusData> _skus = const [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    final db = ref.read(dbProvider);
    (db.select(db.skus)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.name)]))
        .get()
        .then((rows) {
      if (mounted) setState(() => _skus = rows);
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final list = q.isEmpty
        ? _skus
        : _skus
            .where((s) =>
                s.name.toLowerCase().contains(q) ||
                s.code.toLowerCase().contains(q) ||
                (s.brand?.toLowerCase().contains(q) ?? false))
            .toList();
    final height = MediaQuery.of(context).size.height * 0.75;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Sp.screen, Sp.lg, Sp.screen, Sp.sm),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Add a line', style: AppText.heading),
                  ),
                  Text('${list.length} SKUs', style: AppText.label),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.screen),
              child: TextField(
                onChanged: (v) => setState(() => _query = v.trim()),
                textInputAction: TextInputAction.search,
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
                  final drafted = widget.alreadyDrafted.contains(s.id);
                  return ListTile(
                    minTileHeight: Tap.counter,
                    enabled: !drafted,
                    onTap: drafted ? null : () => Navigator.pop(context, s),
                    title: Text(s.name, style: AppText.body),
                    subtitle: Text(
                      [
                        s.code,
                        if (s.brand != null) s.brand!,
                        if (drafted) 'already on the order',
                      ].join(' · '),
                      style: AppText.label,
                    ),
                    trailing: Text(
                      '${s.caseSize}/case · ₹${(s.mrpPaise / 100).toStringAsFixed(0)}',
                      style: AppText.mono,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary strip
// ---------------------------------------------------------------------------

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.state});
  final OrderState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Sp.screen, vertical: Sp.sm),
      child: Wrap(
        spacing: Sp.sm,
        children: [
          _Chip(
            label: '${state.lines.length} SKUs',
            icon: Icons.inventory_2_outlined,
          ),
          _Chip(
            label: '₹${(state.totalValuePaise / 100).toStringAsFixed(0)}',
            icon: Icons.currency_rupee,
            highlight: true,
          ),
          if (state.overrideCount > 0)
            _Chip(
              label: '${state.overrideCount} edited',
              icon: Icons.edit_outlined,
              color: AppColors.warning,
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    this.highlight = false,
    this.color,
  });
  final String label;
  final IconData icon;
  final bool highlight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final clr =
        color ?? (highlight ? AppColors.primary : AppColors.textSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: clr.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: clr.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: clr),
          const SizedBox(width: 4),
          Text(label,
              style: AppText.label.copyWith(
                  color: clr, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual order line row
// ---------------------------------------------------------------------------

class _OrderLineRow extends ConsumerWidget {
  const _OrderLineRow({required this.line, required this.visitId});
  final OrderLine line;
  final String visitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      // 4 dp primary bar on the left edge marks a rep-edited line
      // (04_UIUX §/order) — a colour AND the "edited" word, never colour alone.
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: line.wasOverridden ? AppColors.primary : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
          Sp.screen - 4, Sp.md, Sp.screen, Sp.md),
      child: Row(
        children: [
          // SKU info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        line.skuName ?? line.skuCode ?? line.skuId,
                        style: AppText.body
                            .copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (line.wasOverridden)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('edited',
                            style: AppText.label.copyWith(
                                color: AppColors.warning, fontSize: 10)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${line.grammageLabel ?? ''}  ·  ${line.caseSize} units/case'
                  '  ·  ₹${(line.mrpPaise / 100).toStringAsFixed(2)}/unit',
                  style: AppText.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Value: ₹${(line.finalQty * line.mrpPaise / 100).toStringAsFixed(0)}'
                  '  ·  Suggested: ${line.suggestedQty}',
                  style: AppText.label
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: Sp.md),
          // Stepper
          _Stepper(
            value: line.finalQty,
            step: line.caseSize,
            onChanged: (val) => ref
                .read(orderProvider(visitId).notifier)
                .overrideQty(line.id, val),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stepper widget
// ---------------------------------------------------------------------------

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.step,
    required this.onChanged,
  });
  final int value;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(
          icon: Icons.remove,
          enabled: value > 0,
          onTap: () => onChanged((value - step).clamp(0, 9999)),
        ),
        // Long-press the value → numeric keypad, for a jump like 4 → 48.
        GestureDetector(
          onLongPress: () async {
            final typed = await _askQuantity(context, value);
            if (typed != null) onChanged(typed);
          },
          child: SizedBox(
            width: 44,
            height: Tap.min,
            child: Center(
              child: Text(
                value.toString(),
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        _StepBtn(
          icon: Icons.add,
          enabled: true,
          onTap: () => onChanged(value + step),
        ),
      ],
    );
  }
}

/// Numeric keypad dialog for the stepper value. Returns null on cancel.
Future<int?> _askQuantity(BuildContext context, int current) {
  final controller = TextEditingController(text: current.toString());
  return showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Quantity', style: AppText.heading),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: AppText.display,
        onSubmitted: (v) => Navigator.pop(ctx, int.tryParse(v.trim())),
        decoration: const InputDecoration(hintText: 'units'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(ctx, int.tryParse(controller.text.trim())),
          child: const Text('Set'),
        ),
      ],
    ),
  ).then((v) => v?.clamp(0, 9999));
}

class _StepBtn extends StatelessWidget {
  const _StepBtn(
      {required this.icon, required this.enabled, required this.onTap});
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withAlpha(20)
              : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withAlpha(60)
                : Colors.transparent,
          ),
        ),
        child: Icon(icon,
            size: 18,
            color: enabled ? AppColors.primary : AppColors.textSecondary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Confirm bar
// ---------------------------------------------------------------------------

class _ConfirmBar extends ConsumerWidget {
  const _ConfirmBar({required this.visitId, required this.totalPaise});
  final String visitId;
  final int totalPaise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Sp.screen, Sp.sm, Sp.screen, Sp.lg),
        child: FilledButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          label: Text(
              'Confirm  ·  ₹${(totalPaise / 100).toStringAsFixed(0)}'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: AppColors.primary,
          ),
          onPressed: () =>
              ref.read(orderProvider(visitId).notifier).confirmOrder(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Post-confirm view
// ---------------------------------------------------------------------------

class _ConfirmedView extends StatelessWidget {
  const _ConfirmedView({required this.state});
  final OrderState state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sp.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 72, color: Colors.green),
            const SizedBox(height: Sp.md),
            Text('Visit confirmed!', style: AppText.title),
            const SizedBox(height: Sp.sm),
            Text(
              '${state.lines.length} lines  ·  '
              '₹${(state.totalValuePaise / 100).toStringAsFixed(0)}',
              style: AppText.body,
            ),
            const SizedBox(height: Sp.lg),
            if (state.exportXlsxPath != null)
              _ExportButton(
                label: 'Share XLSX',
                icon: Icons.table_chart_outlined,
                path: state.exportXlsxPath!,
                mimeType:
                    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
              ),
            const SizedBox(height: Sp.sm),
            if (state.exportCsvPath != null)
              _ExportButton(
                label: 'Share CSV',
                icon: Icons.description_outlined,
                path: state.exportCsvPath!,
                mimeType: 'text/csv',
              ),
            const SizedBox(height: Sp.lg),
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Beat'),
              onPressed: () => context.go('/beat'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.label,
    required this.icon,
    required this.path,
    required this.mimeType,
  });
  final String label;
  final IconData icon;
  final String path;
  final String mimeType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: () => SharePlus.instance.share(
          ShareParams(
            files: [XFile(path, mimeType: mimeType)],
            subject: label,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty / error views
// ---------------------------------------------------------------------------

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Sp.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inventory_2_outlined,
                  size: 64, color: Colors.green),
              const SizedBox(height: Sp.md),
              Text('All stocked up!', style: AppText.title),
              const SizedBox(height: Sp.sm),
              Text('No reorder needed for this visit.',
                  style: AppText.body,
                  textAlign: TextAlign.center),
              const SizedBox(height: Sp.lg),
              FilledButton(
                onPressed: () => context.go('/beat'),
                child: const Text('Confirm & Close'),
              ),
            ],
          ),
        ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Sp.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: Sp.md),
              Text('Something went wrong', style: AppText.title),
              const SizedBox(height: Sp.sm),
              Text(message,
                  style: AppText.label,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
