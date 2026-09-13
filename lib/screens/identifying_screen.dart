import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../design_system/design_system.dart';
import '../mock_data.dart';
import '../services/ai_api_service.dart';
import 'scrap_result_screen.dart';

class IdentifyingScreen extends StatefulWidget {
  const IdentifyingScreen({super.key});

  @override
  State<IdentifyingScreen> createState() => _IdentifyingScreenState();
}

class _IdentifyingScreenState extends State<IdentifyingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  _ScreenState _screenState = const _Identifying();

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    _runInference();
  }

  Future<void> _runInference() async {
    final state = context.read<AppState>();

    // Minimum display time so the screen never flashes
    final minDelay = Future.delayed(const Duration(milliseconds: 1200));

    final result = await state.runApiInference();
    await minDelay;

    if (!mounted) return;

    switch (result) {
      case PredictSuccess(:final response):
        if (response.detected && response.prediction != null) {
          // Material identified — navigate forward
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ScrapResultScreen()),
          );
        } else {
          // Backend said detected=false
          setState(() => _screenState = const _NotDetected());
        }

      case PredictFailure(:final error):
        final msg = switch (error) {
          NetworkError(:final message) => message,
          ServerError(:final statusCode) =>
            'Server error ($statusCode). Try again.',
          ParseError(:final message) => message,
        };
        setState(() => _screenState = _ApiError(msg));
    }
  }

  void _retryInference() {
    setState(() => _screenState = const _Identifying());
    _runInference();
  }

  void _goManual() {
    // Set a sensible default material so the result screen has valid state
    context.read<AppState>().setMaterialManually(MockScrap.material);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ScrapResultScreen()),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: switch (_screenState) {
              _Identifying() => _IdentifyingView(
                  scale: _scale,
                  pulse: _pulse,
                ),
              _NotDetected() => _NotDetectedView(
                  onManual: _goManual,
                  onRetry: _retryInference,
                ),
              _ApiError(:final message) => _ErrorView(
                  message: message,
                  onRetry: _retryInference,
                  onManual: _goManual,
                ),
            },
          ),
        ),
      ),
    );
  }
}

// ── State variants ────────────────────────────────────────────────────────────

sealed class _ScreenState {
  const _ScreenState();
}

final class _Identifying extends _ScreenState {
  const _Identifying();
}

final class _NotDetected extends _ScreenState {
  const _NotDetected();
}

final class _ApiError extends _ScreenState {
  final String message;
  const _ApiError(this.message);
}

// ── View components ───────────────────────────────────────────────────────────

class _IdentifyingView extends StatelessWidget {
  const _IdentifyingView({required this.scale, required this.pulse});
  final Animation<double> scale;
  final AnimationController pulse;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: scale,
          child: Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.document_scanner_rounded,
              size: 64,
              color: AppColors.white,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Identifying scrap…', style: AppTypography.headline2),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Sending photo to AI — please wait',
          style: AppTypography.body.copyWith(color: AppColors.mutedGrey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
        _ProgressDots(),
      ],
    );
  }
}

class _NotDetectedView extends StatelessWidget {
  const _NotDetectedView(
      {required this.onManual, required this.onRetry});
  final VoidCallback onManual;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.mintCard,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.help_outline_rounded,
            size: 52,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          "We couldn't identify\nthis scrap",
          style: AppTypography.headline2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Try a clearer photo, or choose\nthe material yourself.',
          style: AppTypography.body.copyWith(color: AppColors.mutedGrey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(
          label: 'Choose Material Manually',
          icon: Icons.list_rounded,
          onPressed: onManual,
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedPillButton(
          label: 'Retry with Same Photo',
          icon: Icons.refresh_rounded,
          onPressed: onRetry,
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView(
      {required this.message, required this.onRetry, required this.onManual});
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.wifi_off_rounded,
            size: 52,
            color: Color(0xFFDC2626),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'AI recognition is\nunavailable right now',
          style: AppTypography.headline2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.mintSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Text(
            message,
            style: AppTypography.caption.copyWith(color: AppColors.mutedGrey),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(
          label: 'Retry',
          icon: Icons.refresh_rounded,
          onPressed: onRetry,
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedPillButton(
          label: 'Choose Material Manually',
          icon: Icons.list_rounded,
          onPressed: onManual,
        ),
      ],
    );
  }
}

// ── Progress dots ─────────────────────────────────────────────────────────────

class _ProgressDots extends StatefulWidget {
  @override
  State<_ProgressDots> createState() => _ProgressDotsState();
}

class _ProgressDotsState extends State<_ProgressDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final active = (_ctrl.value * 3).floor() % 3;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == active
                    ? AppColors.primaryGreen
                    : AppColors.mintCard,
              ),
            );
          }),
        );
      },
    );
  }
}
