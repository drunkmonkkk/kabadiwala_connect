import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../design_system/design_system.dart';
import '../mock_data.dart';
import 'confirm_handover_screen.dart';

class RecyclerScreen extends StatelessWidget {
  const RecyclerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final material = context.watch<AppState>().scannedMaterial;
    final recyclers = MockRecyclers.rankedForMaterial(material);
    return Scaffold(
      backgroundColor: _Palette.background,
      appBar: AppBar(
        backgroundColor: _Palette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 72,
        leading: _BackBtn(),
        title: Text(
          'Best Recycler',
          style: AppTypography.sectionHeading.copyWith(
            color: _Palette.ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final gutter = constraints.maxWidth < 600 ? 16.0 : 40.0;
                final horizontal = constraints.maxWidth > 960 + gutter * 2
                    ? (constraints.maxWidth - 960) / 2
                    : gutter;
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 40),
                  itemCount: recyclers.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 20),
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Surface(
                            color: const Color(0xFAFFFCF6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _Eyebrow(
                                  'KABADIWALA CONNECT  /  RECYCLER MATCHING',
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'The next stop for\nyour scrap.',
                                  style: AppTypography.headline1.copyWith(
                                    fontSize: 32,
                                    height: 1.16,
                                    color: _Palette.ink,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.9,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Authorized recyclers for $material',
                                  style: AppTypography.body.copyWith(
                                    color: _Palette.muted,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const _DetailChip(
                                  icon: Icons.recycling_rounded,
                                  label: 'Compare rates, distance and pickup options',
                                ),
                              ],
                            ),
                          ),
                          if (recyclers.isEmpty) ...[
                            const SizedBox(height: 20),
                            _Surface(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.storefront_outlined,
                                    color: _Palette.green,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No recyclers available',
                                    style: AppTypography.sectionHeading
                                        .copyWith(color: _Palette.ink),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'There are no listed recyclers for $material. Use Back to review your material.',
                                    style: AppTypography.body.copyWith(
                                      color: _Palette.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    }
                    final index = i - 1;
                    return _RecyclerCard(
                      data: recyclers[index],
                      isBestMatch: index == 0,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecyclerCard extends StatelessWidget {
  const _RecyclerCard({required this.data, required this.isBestMatch});
  final RecyclerData data;
  final bool isBestMatch;

  @override
  Widget build(BuildContext context) {
    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _Palette.mint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.recycling_rounded,
                color: _Palette.green,
                size: 26,
              ),
            ),
            if (isBestMatch)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _Palette.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Best Match',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          data.name,
          style: AppTypography.sectionHeading.copyWith(
            color: _Palette.ink,
            fontSize: 24,
            height: 1.25,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.verified_rounded, size: 16, color: _Palette.green),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Authorized',
                style: AppTypography.label.copyWith(
                  color: _Palette.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Accepts ${data.acceptsMaterial}',
          style: AppTypography.body.copyWith(color: _Palette.muted),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _DetailChip(
              icon: Icons.location_on_outlined,
              label: '${data.distanceKm} km',
            ),
            _DetailChip(
              icon: data.pickupAvailable
                  ? Icons.local_shipping_outlined
                  : Icons.storefront_outlined,
              label: data.pickupAvailable
                  ? 'Pickup available'
                  : 'Drop-off only',
            ),
          ],
        ),
      ],
    );
    final offer = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Surface(
          color: _Palette.mint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Eyebrow('RECYCLER RATE'),
              const SizedBox(height: 10),
              Text(
                '₹${data.ratePerKg}/kg',
                style: AppTypography.headline1.copyWith(
                  color: _Palette.dark,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ActionButton(
          label: 'Select Recycler',
          icon: Icons.arrow_forward_rounded,
          onPressed: () {
            context.read<AppState>().setSelectedRecycler(data);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ConfirmHandoverScreen()),
            );
          },
        ),
      ],
    );
    return Semantics(
      container: true,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFCFFFDF9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isBestMatch ? _Palette.green : _Palette.border,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x090F3021),
              blurRadius: 24,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 680) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: identity),
                  const SizedBox(width: 28),
                  SizedBox(width: 280, child: offer),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [identity, const SizedBox(height: 20), offer],
            );
          },
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: _Palette.mint,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: _Palette.green),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: AppTypography.label.copyWith(
              color: _Palette.dark,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

// Screen-local copies keep styling identical without changing shared files.
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: _Palette.green,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 56),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    ),
  );
}

class _BackBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: _Palette.ink,
          size: 22,
        ),
      ),
    );
  }
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
