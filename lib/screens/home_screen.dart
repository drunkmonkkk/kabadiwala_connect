import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../design_system/design_system.dart';
import 'capture_screen.dart';
import 'prices_screen.dart';
import 'recycler_screen.dart';
import 'earnings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: _Palette.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(painter: _CityIllustration()),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const _DashboardOfflineBanner(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      MediaQuery.sizeOf(context).width < 600 ? 16 : 40,
                      20,
                      MediaQuery.sizeOf(context).width < 600 ? 16 : 40,
                      40,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _TopBar(isOffline: state.isOffline),
                            const SizedBox(height: 20),
                            _PrimaryActionCard(),
                            const SizedBox(height: 20),
                            _QuickActions(),
                            const SizedBox(height: 20),
                            _RecentHandover(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Same offline state and message as OfflineBanner, with wrapping text and the
// dashboard palette. Styling stays local; the shared banner is unchanged.
class _DashboardOfflineBanner extends StatelessWidget {
  const _DashboardOfflineBanner();

  @override
  Widget build(BuildContext context) {
    final offline = context.watch<AppState>().isOffline;
    if (!offline) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF7E7),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 16,
            color: Color(0xFF856404),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline — using saved prices',
              style: AppTypography.caption.copyWith(
                color: const Color(0xFF856404),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isOffline});
  final bool isOffline;

  @override
  Widget build(BuildContext context) => _Surface(
    color: const Color(0xFAFFFCF6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kabadiwala Connect',
                style: AppTypography.sectionHeading.copyWith(
                  color: _Palette.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isOffline
                          ? const Color(0xFFD97706)
                          : _Palette.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isOffline
                          ? 'Offline — saved prices'
                          : 'Prices updated today',
                      style: AppTypography.caption.copyWith(
                        color: _Palette.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: isOffline
              ? 'Switch to online mode'
              : 'Switch to offline mode',
          onPressed: () => context.read<AppState>().setOffline(!isOffline),
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            backgroundColor: _Palette.mint,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(
            isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
            size: 22,
            color: isOffline ? const Color(0xFFD97706) : _Palette.dark,
          ),
        ),
      ],
    ),
  );
}

class _PrimaryActionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _TapSurface(
      onTap: () =>
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const CaptureScreen())),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Eyebrow('SCAN. IDENTIFY. RECYCLE.'),
              const SizedBox(height: 16),
              Text(
                'Check Scrap Value',
                style: AppTypography.headline1.copyWith(
                  color: _Palette.ink,
                  fontSize: 36,
                  height: 1.16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.9,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Take a photo to know the price',
                style: AppTypography.body.copyWith(color: _Palette.muted),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: _Palette.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Take Photo',
                        textAlign: TextAlign.center,
                        style: AppTypography.label.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          if (constraints.maxWidth >= 720) {
            return Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 40),
                const SizedBox(width: 260, child: _ScanIllustration()),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _Palette.mint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 28,
                  color: _Palette.green,
                ),
              ),
              const SizedBox(height: 20),
              content,
            ],
          );
        },
      ),
    );
  }
}

class _ScanIllustration extends StatelessWidget {
  const _ScanIllustration();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      height: 240,
      decoration: BoxDecoration(
        color: _Palette.mint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 154,
            height: 154,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF4),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _Palette.border),
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 60,
              color: _Palette.green,
            ),
          ),
          const Positioned(
            top: 24,
            left: 24,
            child: Icon(Icons.eco_outlined, size: 32, color: _Palette.green),
          ),
          Positioned(
            bottom: 22,
            right: 22,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: _Palette.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.recycling_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prices = _QuickCard(
      icon: Icons.currency_rupee_rounded,
      title: "Today's Prices",
      subtitle: 'View rates',
      onTap: () =>
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const PricesScreen())),
    );
    final recyclers = _QuickCard(
      icon: Icons.recycling_rounded,
      title: 'Find Recycler',
      subtitle: 'Authorized recyclers',
      onTap: () =>
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const RecyclerScreen())),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 340 &&
            MediaQuery.textScalerOf(context).scale(16) <= 22) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: prices),
              const SizedBox(width: 20),
              Expanded(child: recyclers),
            ],
          );
        }
        return Column(
          children: [prices, const SizedBox(height: 16), recyclers],
        );
      },
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _TapSurface(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _Palette.mint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 23, color: _Palette.green),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: _Palette.muted,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: AppTypography.sectionHeading.copyWith(
            color: _Palette.ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTypography.caption.copyWith(color: _Palette.muted),
        ),
      ],
    ),
  );
}

class _RecentHandover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tx = context.watch<AppState>().transactions;
    if (tx.isEmpty) return const SizedBox.shrink();
    final latest = tx.first;

    return _TapSurface(
      onTap: () =>
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const EarningsScreen())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 24,
              runSpacing: 10,
              children: [
                Text(
                  'Recent Handover',
                  style: AppTypography.sectionHeading.copyWith(
                    color: _Palette.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'View all',
                  style: AppTypography.label.copyWith(
                    color: _Palette.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: _Palette.border),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final details = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _Palette.mint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 24,
                      color: _Palette.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          latest.material,
                          style: AppTypography.label.copyWith(
                            color: _Palette.ink,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${latest.weightKg.toStringAsFixed(0)} kg · ${latest.recyclerName}',
                          style: AppTypography.caption.copyWith(
                            color: _Palette.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final amount = Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _Palette.mint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '₹${_fmt(latest.amount)}',
                  style: AppTypography.headline2.copyWith(
                    color: _Palette.dark,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
              if (constraints.maxWidth >= 600) {
                return Row(
                  children: [
                    Expanded(child: details),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: amount,
                      ),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [details, const SizedBox(height: 16), amount],
              );
            },
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

// Entire cards remain tappable, with keyboard focus and ink feedback.
class _TapSurface extends StatelessWidget {
  const _TapSurface({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x090F3021),
          blurRadius: 24,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Material(
      color: const Color(0xFCFFFDF9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: _Palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    ),
  );
}

// Screen-local styling mirrors the reviewed result and recycler screens.
abstract final class _Palette {
  static const background = Color(0xFFF4EFE4);
  static const ink = Color(0xFF29332E);
  static const muted = Color(0xFF64736B);
  static const green = Color(0xFF176443);
  static const dark = Color(0xFF104B39);
  static const mint = Color(0xFFEDF3E9);
  static const border = Color(0xFFE0E5DA);
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: _Palette.muted,
      fontSize: 11,
      height: 1.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    ),
  );
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child, this.color = const Color(0xFCFFFDF9)});
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _Palette.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x090F3021),
          blurRadius: 24,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}

// Decorative editorial scene: local canvas artwork, no assets or network reads.
// It stays behind nearly opaque cards and never receives pointer events.
class _CityIllustration extends CustomPainter {
  const _CityIllustration();

  @override
  void paint(Canvas canvas, Size size) {
    final paper = Paint()..color = _Palette.background;
    canvas.drawRect(Offset.zero & size, paper);
    // Sparse paper grain, deterministic so rebuilds do not shimmer.
    final grain = Paint()..color = const Color(0x087B6B4B);
    for (var i = 0; i < 1800; i++) {
      final x = ((i * 73.37) % 997) / 997 * size.width;
      final y = ((i * 41.71) % 991) / 991 * size.height;
      canvas.drawCircle(Offset(x, y), i.isEven ? 0.6 : 0.9, grain);
    }
    final scale = (size.width / 1000).clamp(0.65, 1.35);
    canvas.save();
    canvas.translate(0, size.height * 0.30);
    canvas.scale(scale);
    _neighborhood(canvas);
    canvas.restore();
    canvas.save();
    canvas.translate(size.width, size.height * 0.12);
    canvas.scale(-scale, scale);
    _neighborhood(canvas);
    canvas.restore();
    // A soft central wash keeps the content column visually quiet.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0x00F4EFE4),
            Color(0xB8F4EFE4),
            Color(0xB8F4EFE4),
            Color(0x00F4EFE4),
          ],
          stops: [0, 0.27, 0.73, 1],
        ).createShader(Offset.zero & size),
    );
  }

  void _neighborhood(Canvas canvas) {
    final sand = Paint()..color = const Color(0x35B8A181);
    final teal = Paint()..color = const Color(0x35739386);
    final green = Paint()..color = const Color(0x356F8B65);
    final ink = Paint()
      ..color = const Color(0x42717A68)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    // Flat-roof buildings, parapets and rooftop water tanks.
    for (var i = 0; i < 4; i++) {
      final x = i * 58.0 - 28;
      final top = 105.0 + (i % 3) * 43;
      canvas.drawRect(
        Rect.fromLTRB(x, top, x + 52, 420),
        i.isEven ? sand : teal,
      );
      canvas.drawRect(Rect.fromLTWH(x - 3, top, 58, 6), sand);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 12, top - 17, 20, 15),
          const Radius.circular(3),
        ),
        teal,
      );
      for (var row = 0; row < 4; row++) {
        for (var col = 0; col < 2; col++) {
          canvas.drawRect(
            Rect.fromLTWH(x + 10 + col * 23, top + 22 + row * 39, 9, 14),
            Paint()..color = const Color(0x2472705B),
          );
        }
      }
    }
    final wire = Path()
      ..moveTo(0, 198)
      ..quadraticBezierTo(110, 226, 242, 197);
    canvas.drawPath(wire, ink..color = const Color(0x28717A68));
    canvas.drawLine(const Offset(20, 160), const Offset(20, 432), ink);
    // Ground wash and a low compound wall.
    canvas.drawOval(const Rect.fromLTWH(-95, 412, 390, 210), sand);
    final wall = Path()
      ..moveTo(-20, 355)
      ..lineTo(216, 397)
      ..lineTo(216, 451)
      ..lineTo(-20, 438)
      ..close();
    canvas.drawPath(wall, Paint()..color = const Color(0x50D8CBB1));
    canvas.drawLine(const Offset(0, 358), const Offset(217, 398), ink);
    // A hand-pulled collection cart, with sorted scrap and bicycle-style wheels.
    canvas.save();
    canvas.translate(13, 449);
    ink.color = const Color(0x60707A68);
    for (final x in [28.0, 119.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 58), width: 36, height: 54),
        ink..strokeWidth = 3,
      );
      canvas.drawLine(
        Offset(x - 15, 42),
        Offset(x + 15, 74),
        ink..strokeWidth = 1,
      );
      canvas.drawLine(Offset(x + 15, 42), Offset(x - 15, 74), ink);
      canvas.drawLine(Offset(x, 33), Offset(x, 83), ink);
    }
    canvas.drawRect(const Rect.fromLTWH(0, 0, 142, 48), teal);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 142, 5), green);
    for (var i = 0; i < 5; i++) {
      canvas.drawLine(Offset(8 + i * 29.0, 5), Offset(8 + i * 29.0, 46), ink);
    }
    canvas.drawLine(
      const Offset(137, 11),
      const Offset(185, -3),
      ink..strokeWidth = 3,
    );
    canvas.drawLine(const Offset(-3, 49), const Offset(149, 49), ink);
    canvas.drawRect(const Rect.fromLTWH(9, -23, 37, 23), sand);
    canvas.drawRect(const Rect.fromLTWH(51, -17, 28, 17), green);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(89, -27, 14, 27),
        const Radius.circular(4),
      ),
      teal,
    );
    canvas.drawRect(const Rect.fromLTWH(92, -32, 8, 7), teal);
    canvas.drawLine(
      const Offset(12, -14),
      const Offset(38, -14),
      ink..strokeWidth = 1,
    );
    canvas.restore();
    // Municipal collection bins with a circular-resource mark.
    canvas.save();
    canvas.translate(180, 435);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 43, 64),
        const Radius.circular(5),
      ),
      green,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-4, -4, 51, 8),
        const Radius.circular(3),
      ),
      teal,
    );
    canvas.drawCircle(const Offset(8, 65), 4, teal);
    canvas.drawCircle(const Offset(35, 65), 4, teal);
    canvas.drawArc(
      const Rect.fromLTWH(11, 20, 22, 22),
      0.4,
      4.8,
      false,
      ink..strokeWidth = 2,
    );
    canvas.drawPath(
      Path()
        ..moveTo(25, 18)
        ..lineTo(31, 20)
        ..lineTo(28, 26),
      ink,
    );
    canvas.restore();
    // Loose layered foliage softens the built environment.
    for (final tree in [const Offset(-7, 292), const Offset(215, 330)]) {
      canvas.drawPath(
        Path()
          ..moveTo(tree.dx, tree.dy + 154)
          ..quadraticBezierTo(tree.dx + 12, tree.dy + 62, tree.dx - 7, tree.dy),
        ink
          ..strokeWidth = 5
          ..color = const Color(0x387F8066),
      );
      for (var i = 0; i < 34; i++) {
        final dx = ((i * 37) % 97) - 48.0;
        final dy = ((i * 29) % 83) - 46.0;
        canvas.drawOval(
          Rect.fromCenter(
            center: tree + Offset(dx, dy),
            width: 33 + i % 14,
            height: 24 + i % 19,
          ),
          Paint()
            ..color = i % 3 == 0
                ? const Color(0x24779879)
                : const Color(0x267F965F),
        );
      }
    }
    // Small roadside plants.
    for (var i = 0; i < 8; i++) {
      final x = 150 + i * 13.0;
      final y = 562 + (i % 3) * 8.0;
      canvas.drawLine(
        Offset(x, y),
        Offset(x - 5, y - 36),
        ink..strokeWidth = 1.5,
      );
      canvas.drawOval(Rect.fromLTWH(x - 18, y - 35, 18, 10), green);
      canvas.drawOval(Rect.fromLTWH(x - 3, y - 25, 20, 11), teal);
    }
  }

  @override
  bool shouldRepaint(covariant _CityIllustration oldDelegate) => false;
}
