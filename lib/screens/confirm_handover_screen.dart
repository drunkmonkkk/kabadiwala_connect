import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../design_system/design_system.dart';
import 'handover_proof_screen.dart';

class ConfirmHandoverScreen extends StatelessWidget {
  const ConfirmHandoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final recycler = state.selectedRecycler!;
    final weight = state.weightKg;
    final rate = recycler.ratePerKg.toDouble();
    final amount = weight * rate;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: _BackBtn(),
        title: Text('Confirm Handover', style: AppTypography.sectionHeading),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    // Summary card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.mintSurface,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                        border:
                            Border.all(color: AppColors.mintCard, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          _Row(label: 'Material', value: state.scannedMaterial),
                          const Divider(color: AppColors.mintCard, height: 28),
                          _Row(
                            label: 'Weight',
                            value:
                                '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} kg',
                          ),
                          const Divider(color: AppColors.mintCard, height: 28),
                          _Row(
                            label: 'Rate',
                            value: '₹${rate.toStringAsFixed(0)}/kg',
                          ),
                          const Divider(color: AppColors.mintCard, height: 28),
                          _Row(
                            label: 'Amount',
                            value: '₹${_fmt(amount)}',
                            valueStyle: AppTypography.headline2.copyWith(
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Recycler card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        border:
                            Border.all(color: AppColors.mintCard, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          CircleIconContainer(
                            icon: Icons.recycling_rounded,
                            size: 48,
                            iconSize: 24,
                            backgroundColor: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recycler.name,
                                  style: AppTypography.label.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.nearBlack,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.verified_rounded,
                                        size: 13,
                                        color: AppColors.primaryGreen),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Authorized',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Icon(
                                      recycler.pickupAvailable
                                          ? Icons.local_shipping_rounded
                                          : Icons.storefront_rounded,
                                      size: 13,
                                      color: AppColors.mutedGrey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      recycler.pickupAvailable
                                          ? 'Pickup available'
                                          : 'Drop-off only',
                                      style: AppTypography.caption,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // CTA
              PrimaryButton(
                label: 'Start Handover',
                icon: Icons.handshake_rounded,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const HandoverProofScreen()),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedPillButton(
                label: 'Change Recycler',
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: AppSpacing.lg),
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

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.valueStyle});
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.body.copyWith(color: AppColors.mutedGrey)),
        Text(
          value,
          style: valueStyle ??
              AppTypography.label.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.nearBlack,
                fontSize: 16,
              ),
        ),
      ],
    );
  }
}

class _BackBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.sm),
        decoration: const BoxDecoration(color: AppColors.mintCard, shape: BoxShape.circle),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.darkGreen, size: 18),
      ),
    );
  }
}
