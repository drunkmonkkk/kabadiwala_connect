import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../mock_data.dart';
import '../design_system/design_system.dart';
import 'handover_success_screen.dart';

import '../services/location_service.dart';

class HandoverProofScreen extends StatefulWidget {
  const HandoverProofScreen({super.key});

  @override
  State<HandoverProofScreen> createState() => _HandoverProofScreenState();
}

class _HandoverProofScreenState extends State<HandoverProofScreen> {
  bool _hasPhoto = false;
  bool _hasLocation = false;
  String _locationText = 'Capturing location…';
  String _locationArea = '';
  bool _isLocationLoading = false;
  bool _hasTime = false;
  String _mockTime = '';

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _hasTime = true;
    _mockTime =
        '${_pad(now.hour)}:${_pad(now.minute)}  ${now.day}/${now.month}/${now.year}';

    _captureLocation();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  bool get _allComplete => _hasPhoto && _hasLocation && _hasTime;

  Future<void> _capturePhoto() async {
    final picker = ImagePicker();

    final file = await picker.pickImage(source: ImageSource.camera);

    if (file != null && mounted) {
      context.read<AppState>().setHandoverPhoto(file);

      setState(() {
        _hasPhoto = true;
      });
    }
  }

  void _complete() {
    final state = context.read<AppState>();
    final receiptId = state.generateReceiptId();
    final tx = HandoverTransaction.seed(
      receiptId: receiptId,
      material: state.scannedMaterial,
      weightKg: state.weightKg,
      ratePerKg: state.selectedRecycler!.ratePerKg.toDouble(),
      recyclerName: state.selectedRecycler!.name,
      timestamp: DateTime.now(),
      syncedOnline: !state.isOffline,
    );
    state.addTransaction(tx);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HandoverSuccessScreen(receiptId: receiptId),
      ),
    );
  }

  Future<void> _captureLocation() async {
    setState(() {
      _isLocationLoading = true;
      _locationText = 'Capturing GPS location…';
    });

    try {
      final res = await LocationService.instance.fetchLocation(
        allowFallback: true,
      );

      if (!mounted) return;

      setState(() {
        _hasLocation = true;
        _isLocationLoading = false;
        _locationText = res.coordinatesString;
        _locationArea = res.description;
      });

      context.read<AppState>().setHandoverLocation(res.coordinatesString);
    } catch (e) {
      if (!mounted) return;

      const fallbackCoords =
          '${LocationService.defaultLatitude}, ${LocationService.defaultLongitude}';

      setState(() {
        _hasLocation = true;
        _isLocationLoading = false;
        _locationText = fallbackCoords;
        _locationArea = 'Central Scrap Hub (Fallback Location)';
      });

      context.read<AppState>().setHandoverLocation(fallbackCoords);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: _Palette.background,
      appBar: AppBar(
        backgroundColor: _Palette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 72,
        leading: _BackBtn(),
        title: Text(
          'Record Handover',
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
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                MediaQuery.sizeOf(context).width < 600 ? 16 : 40,
                12,
                MediaQuery.sizeOf(context).width < 600 ? 16 : 40,
                20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Surface(
                        color: const Color(0xFAFFFCF6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Eyebrow(
                              'KABADIWALA CONNECT  /  PROOF OF TRANSFER',
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Capture proof of handover',
                              style: AppTypography.headline1.copyWith(
                                color: _Palette.ink,
                                fontSize: 30,
                                height: 1.16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.9,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'A photo, location and time document this transfer.',
                              style: AppTypography.body.copyWith(
                                color: _Palette.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _ProofItem(
                        step: '01',
                        icon: Icons.camera_alt_outlined,
                        title: 'Photo',
                        subtitle: _hasPhoto
                            ? 'Photo captured'
                            : 'Tap to add handover photo',
                        isDone: _hasPhoto,
                        onTap: _capturePhoto,
                      ),
                      const _ProofConnector(),
                      _ProofItem(
                        step: '02',
                        icon: Icons.location_on_outlined,
                        title: 'Location',
                        subtitle: _locationText,
                        isDone: _hasLocation,
                        actionLabel: _isLocationLoading
                            ? 'Fetching…'
                            : (_hasLocation
                                  ? 'Tap to refresh GPS'
                                  : 'Tap to fetch location'),
                        onTap: _isLocationLoading ? null : _captureLocation,
                        detail: _hasLocation
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ProofReadings(
                                    labels: const ['LATITUDE', 'LONGITUDE'],
                                    values: _locationText.split(', '),
                                  ),
                                  if (_locationArea.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      _locationArea,
                                      style: AppTypography.caption.copyWith(
                                        color: _Palette.dark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              )
                            : null,
                      ),
                      const _ProofConnector(),
                      _ProofItem(
                        step: '03',
                        icon: Icons.schedule_rounded,
                        title: 'Time',
                        subtitle: _hasTime ? _mockTime : 'Capturing time…',
                        isDone: _hasTime,
                        detail: _hasTime
                            ? _ProofReadings(
                                labels: const ['TIME', 'DATE'],
                                values: _mockTime.split('  '),
                              )
                            : null,
                      ),
                      if (state.isOffline) ...[
                        const SizedBox(height: 20),
                        _Surface(
                          color: const Color(0xFFFFF7E7),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.wifi_off_rounded,
                                size: 18,
                                color: Color(0xFF856404),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Offline — record will sync when online.',
                                  style: AppTypography.caption.copyWith(
                                    color: const Color(0xFF856404),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            MediaQuery.sizeOf(context).width < 600 ? 16 : 40,
            12,
            MediaQuery.sizeOf(context).width < 600 ? 16 : 40,
            20,
          ),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _allComplete
                        ? 'All required proof is recorded.'
                        : 'Photo, location and time are required.',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: _Palette.muted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _allComplete ? _complete : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: _Palette.green,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE0E5DA),
                        disabledForegroundColor: const Color(0xFF657168),
                        minimumSize: const Size(48, 56),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _allComplete
                                ? Icons.check_circle_outline_rounded
                                : Icons.lock_outline_rounded,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'Complete Handover',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProofItem extends StatelessWidget {
  const _ProofItem({
    required this.step,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDone,
    this.onTap,
    this.detail,
    this.actionLabel,
  });
  final String step;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDone;
  final VoidCallback? onTap;
  final Widget? detail;
  final String? actionLabel;

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
        side: BorderSide(
          color: isDone ? const Color(0xFFCBDCCD) : _Palette.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _Palette.mint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: _Palette.green, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Eyebrow('PROOF $step'),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: AppTypography.sectionHeading.copyWith(
                            color: _Palette.ink,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDone ? _Palette.mint : const Color(0xFFF4EFE4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDone
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isDone ? _Palette.green : _Palette.muted,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isDone ? 'Recorded' : 'Required',
                            style: AppTypography.caption.copyWith(
                              color: isDone ? _Palette.dark : _Palette.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Text(
                      actionLabel ??
                          (isDone ? 'Tap to replace photo' : 'Add photo'),
                      style: AppTypography.label.copyWith(
                        color: _Palette.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (detail != null)
                detail!
              else
                Text(
                  subtitle,
                  style: AppTypography.body.copyWith(color: _Palette.muted),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ProofReadings extends StatelessWidget {
  const _ProofReadings({required this.labels, required this.values});
  final List<String> labels;
  final List<String> values;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final readings = List.generate(
        values.length,
        (i) => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _Palette.mint,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Eyebrow(labels[i]),
              const SizedBox(height: 6),
              Text(
                values[i],
                style: AppTypography.sectionHeading.copyWith(
                  color: _Palette.dark,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      );
      if (constraints.maxWidth >= 480 &&
          MediaQuery.textScalerOf(context).scale(20) <= 30) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < readings.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: readings[i]),
            ],
          ],
        );
      }
      return Column(
        children: [
          for (var i = 0; i < readings.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            readings[i],
          ],
        ],
      );
    },
  );
}

class _ProofConnector extends StatelessWidget {
  const _ProofConnector();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: 20,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(left: 43),
          width: 2,
          color: const Color(0xFFCBDCCD),
        ),
      ),
    ),
  );
}

// Screen-local copies preserve the established visual system without shared edits.
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
