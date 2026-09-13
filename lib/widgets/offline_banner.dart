import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../design_system/design_system.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final offline = context.watch<AppState>().isOffline;
    if (!offline) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF3CD),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 14, color: Color(0xFF856404)),
          const SizedBox(width: 6),
          Text(
            'Offline — using saved prices',
            style: AppTypography.caption.copyWith(
              color: const Color(0xFF856404),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
