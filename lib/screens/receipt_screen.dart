import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../design_system/design_system.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.receiptId});
  final String receiptId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final weight = state.weightKg;
    final rate = state.selectedRecycler?.ratePerKg.toDouble() ?? state.ratePerKg;
    final amount = weight * rate;
    final recycler = state.selectedRecycler;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.mintSurface,
      appBar: AppBar(
        backgroundColor: AppColors.mintSurface,
        elevation: 0,
        leading: _BackBtn(),
        title: Text('Receipt', style: AppTypography.sectionHeading),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),

              // ── Receipt card ─────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.mintCard, width: 1.5),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: const BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.only(
                          topLeft:
                              Radius.circular(AppSpacing.radiusLg - 1),
                          topRight:
                              Radius.circular(AppSpacing.radiusLg - 1),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.recycling_rounded,
                              size: 36, color: AppColors.white),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Kabadiwala Connect',
                            style: AppTypography.sectionHeading.copyWith(
                                color: AppColors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Digital Handover Receipt',
                            style: AppTypography.caption.copyWith(
                                color: AppColors.white.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),

                    // Receipt ID banner
                    Container(
                      width: double.infinity,
                      color: AppColors.mintSurface,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm),
                      child: Center(
                        child: Text(
                          receiptId,
                          style: AppTypography.label.copyWith(
                            color: AppColors.darkGreen,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    // Body rows
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          _ReceiptRow(label: 'Material', value: state.scannedMaterial),
                          _ReceiptRow(
                            label: 'Weight',
                            value:
                                '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} kg',
                          ),
                          _ReceiptRow(
                            label: 'Rate',
                            value: '₹${rate.toStringAsFixed(0)}/kg',
                          ),
                          _ReceiptRow(
                            label: 'Amount',
                            value: '₹${_fmt(amount)}',
                            valueStyle: AppTypography.sectionHeading.copyWith(
                              color: AppColors.darkGreen,
                              fontSize: 20,
                            ),
                          ),
                          const Divider(color: AppColors.mintCard, height: 28),
                          _ReceiptRow(
                            label: 'Recycler',
                            value: recycler?.name ?? '—',
                          ),
                          _ReceiptRow(
                            label: 'Authorization',
                            value: 'Verified',
                            valueColor: AppColors.primaryGreen,
                          ),
                          _ReceiptRow(label: 'Payment', value: 'Recorded'),
                          const Divider(color: AppColors.mintCard, height: 28),
                          _ReceiptRow(
                           label: 'Location',
                           value: state.handoverLocation ?? 'Not available',
),
                          _ReceiptRow(
                            label: 'Timestamp',
                            value:
                                '${_pad(now.hour)}:${_pad(now.minute)}  ${now.day}/${now.month}/${now.year}',
                          ),
                        ],
                      ),
                    ),

                    // Photo area
                    _HandoverPhoto(
                     imageFile: state.handoverPhoto,
),

                    // Footer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md),
                      decoration: const BoxDecoration(
                        color: AppColors.mintSurface,
                        borderRadius: BorderRadius.only(
                          bottomLeft:
                              Radius.circular(AppSpacing.radiusLg - 1),
                          bottomRight:
                              Radius.circular(AppSpacing.radiusLg - 1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'This is a verified digital handover record.',
                          style: AppTypography.caption.copyWith(
                              color: AppColors.mutedGrey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              OutlinedPillButton(
                label: 'Done',
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
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

  String _pad(int n) => n.toString().padLeft(2, '0');
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.valueStyle,
    this.valueColor,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  AppTypography.body.copyWith(color: AppColors.mutedGrey)),
          Text(
            value,
            style: valueStyle ??
                AppTypography.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.nearBlack,
                  fontSize: 15,
                ),
          ),
        ],
      ),
    );
  }
}
class _HandoverPhoto extends StatelessWidget {
  const _HandoverPhoto({
    required this.imageFile,
  });

  final XFile? imageFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.mintSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.mintCard,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: FutureBuilder<Uint8List?>(
          future: imageFile?.readAsBytes(),
          builder: (context, snapshot) {
            final bytes = snapshot.data;

            if (bytes != null) {
              return Image.memory(
                bytes,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              );
            }

            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.image_rounded,
                    size: 36,
                    color: AppColors.primaryGreen,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'No handover photo',
                    style: TextStyle(
                      color: AppColors.mutedGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
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
        decoration: const BoxDecoration(
            color: AppColors.mintCard, shape: BoxShape.circle),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.darkGreen, size: 18),
      ),
    );
  }
}
