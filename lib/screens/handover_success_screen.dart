import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../design_system/design_system.dart';
import 'receipt_screen.dart';

class HandoverSuccessScreen extends StatelessWidget {
  const HandoverSuccessScreen({super.key, required this.receiptId});
  final String receiptId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isOffline = state.isOffline;
    final weight = state.weightKg;
    final rate = state.ratePerKg;
    final amount = weight * rate;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),

              // ── Success icon ─────────────────────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 52, color: AppColors.white),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Handover Complete',
                style: AppTypography.headline2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Big amount ───────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Column(
                  children: [
                    Text(
                      '₹${_fmt(amount)}',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                        height: 1.0,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      isOffline
                          ? 'Saved on device. Will sync when online.'
                          : 'Payment recorded',
                      style: AppTypography.body.copyWith(
                          color: AppColors.white.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Transaction summary ──────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.mintSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.mintCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.scannedMaterial,
                      style: AppTypography.sectionHeading,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} kg · ${state.selectedRecycler?.name ?? ""}',
                      style: AppTypography.body
                          .copyWith(color: AppColors.mutedGrey),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(color: AppColors.mintCard),
                    const SizedBox(height: AppSpacing.sm),
                    _ProofRow(icon: Icons.camera_alt_rounded, label: 'Photo'),
                    const SizedBox(height: AppSpacing.sm),
                    _ProofRow(icon: Icons.location_on_rounded, label: 'GPS'),
                    const SizedBox(height: AppSpacing.sm),
                    _ProofRow(icon: Icons.schedule_rounded, label: 'Time'),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(color: AppColors.mintCard),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Receipt ID',
                            style: AppTypography.caption),
                        Text(
                          receiptId,
                          style: AppTypography.label.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.nearBlack,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              PrimaryButton(
                label: 'View Receipt',
                icon: Icons.receipt_long_rounded,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReceiptScreen(receiptId: receiptId),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedPillButton(
                label: 'Done',
                onPressed: () => Navigator.of(context)
                    .popUntil((r) => r.isFirst),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(double v) {
    final s = v.toInt().toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }
}

class _ProofRow extends StatelessWidget {
  const _ProofRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryGreen),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '✓ $label',
          style: AppTypography.label.copyWith(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
