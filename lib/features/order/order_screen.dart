/// OrderScreen — T-19
///
/// Shows the rep the suggested order draft, lets them edit each finalQty
/// with +/– steppers, then confirms the visit (persist + XLSX + CSV).
///
/// Owned by C (provider + export wiring). B owns the visual polish.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme.dart';
import '../../domain/models/models.dart';
import 'order_provider.dart';

class OrderScreen extends ConsumerWidget {
  const OrderScreen({
    super.key,
    required this.visitId,
    this.storeCode = 'STORE',
    this.storeName = 'Store',
    this.beatName = 'Beat',
  });
  final String visitId;
  final String storeCode;
  final String storeName;
  final String beatName;

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
            storeCode: storeCode,
            storeName: storeName,
            beatName: beatName,
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
            itemCount: state.lines.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, indent: Sp.screen),
            itemBuilder: (_, i) => _OrderLineRow(
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
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Sp.screen, vertical: Sp.md),
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
        SizedBox(
          width: 44,
          child: Text(
            value.toString(),
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(fontWeight: FontWeight.w700),
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
  const _ConfirmBar({
    required this.visitId,
    required this.storeCode,
    required this.storeName,
    required this.beatName,
    required this.totalPaise,
  });
  final String visitId;
  final String storeCode;
  final String storeName;
  final String beatName;
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
              ref.read(orderProvider(visitId).notifier).confirmOrder(
                    storeCode: storeCode,
                    storeName: storeName,
                    beatName: beatName,
                  ),
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
