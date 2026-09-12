import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/di.dart';
import '../../app/theme.dart';
import '../../domain/models/models.dart';
import '../order/order_provider.dart';
import 'shelf_facts_pipeline.dart';

/// Recomputed every time the screen is entered so edits on `/review` show
/// up immediately. autoDispose keeps it from going stale between visits.
final shelfReportProvider = FutureProvider.autoDispose
    .family<ShelfReport, String>((ref, visitId) {
      return computeShelfFacts(ref.watch(dbProvider), visitId);
    });

/// `/shelf` — planogram diff table (04_UIUX_DESIGN §`/shelf`).
class ShelfReportScreen extends ConsumerWidget {
  const ShelfReportScreen({super.key, required this.visitId});
  final String visitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(shelfReportProvider(visitId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shelf status'),
        actions: [
          IconButton(
            tooltip: 'Back to review',
            icon: const Icon(Icons.grid_view_outlined),
            onPressed: () => context.canPop() ? context.pop() : context.go('/review/$visitId'),
          ),
        ],
      ),
      body: report.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(Sp.xxl),
            child: Text(
              'Could not compute shelf status.\n$e',
              style: AppText.body,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (r) => r.facts.isEmpty
            ? const _Empty()
            : Column(
                children: [
                  const _HeaderRow(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: r.facts.length,
                      itemBuilder: (_, i) => _FactRow(
                        fact: r.facts[i],
                        onTap: () => context.push(
                          '/review/$visitId?sku=${r.facts[i].skuId}',
                        ),
                      ),
                    ),
                  ),
                  _Footer(report: r),
                ],
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Sp.screen,
            Sp.sm,
            Sp.screen,
            Sp.lg,
          ),
          child: FilledButton(
            onPressed: report.hasValue
                ? () {
                    // The draft is cached per visit; force it to rebuild
                    // from the facts we just computed.
                    ref.invalidate(orderProvider(visitId));
                    context.push('/order/$visitId');
                  }
                : null,
            child: const Text('Continue to order'),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

Color _statusColor(ShelfStatus s) => switch (s) {
  ShelfStatus.stockout => AppColors.danger,
  ShelfStatus.belowPlan => AppColors.warning,
  ShelfStatus.unlisted => AppColors.info,
  ShelfStatus.inStock => AppColors.success,
};

String _statusWord(ShelfStatus s) => switch (s) {
  ShelfStatus.stockout => 'Stockout',
  ShelfStatus.belowPlan => 'Below plan',
  ShelfStatus.unlisted => 'Unlisted',
  ShelfStatus.inStock => 'In stock',
};

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final style = AppText.label.copyWith(letterSpacing: 0.8);
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(Sp.screen, Sp.sm, Sp.screen, Sp.sm),
      child: Row(
        children: [
          Expanded(child: Text('SKU', style: style)),
          SizedBox(
            width: 44,
            child: Text('PLAN', style: style, textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 52,
            child: Text('FOUND', style: style, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 96),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.fact, required this.onTap});
  final ShelfFact fact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(fact.status);
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: Tap.counter),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 4 dp status bar — colour AND a word, never colour alone.
              Container(width: 4, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sp.md,
                    vertical: Sp.sm,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fact.skuName ?? fact.skuId,
                        style: AppText.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((fact.grammageLabel ?? '').isNotEmpty)
                        Text(fact.grammageLabel!, style: AppText.label),
                    ],
                  ),
                ),
              ),
              _Num(
                fact.status == ShelfStatus.unlisted
                    ? '–'
                    : '${fact.targetFacings}',
                width: 44,
              ),
              _Num('${fact.detectedFacings}', width: 52, color: color),
              SizedBox(
                width: 96,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                    child: Text(
                      _statusWord(fact.status),
                      style: AppText.label.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Sp.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _Num extends StatelessWidget {
  const _Num(this.text, {required this.width, this.color});
  final String text;
  final double width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(
          text,
          style: AppText.mono.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.report});
  final ShelfReport report;

  @override
  Widget build(BuildContext context) {
    final parts = <InlineSpan>[];
    void add(ShelfStatus s, String singular, String plural) {
      final n = report.countOf(s);
      if (n == 0) return;
      if (parts.isNotEmpty) parts.add(const TextSpan(text: '  ·  '));
      parts.add(
        TextSpan(
          text: '$n ${n == 1 ? singular : plural}',
          style: TextStyle(color: _statusColor(s), fontWeight: FontWeight.w600),
        ),
      );
    }

    add(ShelfStatus.stockout, 'stockout', 'stockouts');
    add(ShelfStatus.belowPlan, 'below plan', 'below plan');
    add(ShelfStatus.unlisted, 'unlisted', 'unlisted');
    add(ShelfStatus.inStock, 'in stock', 'in stock');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Sp.screen,
        vertical: Sp.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Text.rich(TextSpan(children: parts), style: AppText.body),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Sp.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shelves, size: 64, color: AppColors.textDisabled),
            SizedBox(height: Sp.lg),
            Text(
              'No planogram for this store',
              style: AppText.heading,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Sp.sm),
            Text(
              'Tag packs on the review screen to count facings.',
              style: AppText.label,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
