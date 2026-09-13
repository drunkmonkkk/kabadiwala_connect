import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../mock_data.dart';
import '../design_system/design_system.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final txns = state.transactions;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: _BackBtn(),
        title: Text('Earnings', style: AppTypography.sectionHeading),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Summary row ──────────────────────────────────────────
            Container(
              margin: const EdgeInsets.all(AppSpacing.screenPadding),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem(
                    label: 'Today',
                    amount: state.todayEarnings,
                  ),
                  _Divider(),
                  _SummaryItem(
                    label: 'This Week',
                    amount: state.weekEarnings,
                  ),
                  _Divider(),
                  _SummaryItem(
                    label: 'This Month',
                    amount: state.monthEarnings,
                  ),
                ],
              ),
            ),

            // ── Transaction list ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: Row(
                children: [
                  Text(
                    'Handover History',
                    style: AppTypography.label.copyWith(
                      color: AppColors.mutedGrey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Expanded(
              child: txns.isEmpty
                  ? Center(
                      child: Text(
                        'No handovers yet',
                        style: AppTypography.body
                            .copyWith(color: AppColors.mutedGrey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPadding),
                      itemCount: txns.length,
                      separatorBuilder: (_, _) =>
                          const Divider(color: AppColors.mintCard, height: 1),
                      itemBuilder: (_, i) => _TxRow(tx: txns[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.amount});
  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '₹${_fmt(amount)}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.white,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption
              .copyWith(color: AppColors.white.withValues(alpha: 0.8)),
        ),
      ],
    );
  }

  String _fmt(double v) {
    if (v == 0) return '0';
    final s = v.toInt().toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.white.withValues(alpha: 0.25),
    );
  }
}

class _TxRow extends StatelessWidget {
  const _TxRow({required this.tx});
  final HandoverTransaction tx;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(tx.timestamp);
    final timeLabel = diff.inHours < 24
        ? 'Today'
        : diff.inHours < 48
            ? 'Yesterday'
            : '${diff.inDays} days ago';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          CircleIconContainer(
            icon: Icons.check_circle_rounded,
            size: 44,
            iconSize: 22,
            backgroundColor: AppColors.mintCard,
            iconColor: AppColors.darkGreen,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.material,
                  style: AppTypography.label.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.nearBlack,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tx.weightKg.toStringAsFixed(0)} kg · ${tx.recyclerName} · $timeLabel',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${_fmt(tx.amount)}',
                style: AppTypography.sectionHeading.copyWith(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 3),
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tx.syncedOnline
                      ? AppColors.mintCard
                      : const Color(0xFFFFF3CD),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  tx.syncedOnline ? 'Paid' : 'Offline',
                  style: AppTypography.caption.copyWith(
                    color: tx.syncedOnline
                        ? AppColors.darkGreen
                        : const Color(0xFF856404),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    final s = v.toInt().toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }
}

class _BackBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.sm),
        decoration: const BoxDecoration(
            color: AppColors.mintCard, shape: BoxShape.circle),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.darkGreen, size: 18),
      ),
    );
  }
}
