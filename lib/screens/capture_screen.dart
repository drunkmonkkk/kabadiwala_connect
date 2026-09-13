import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../design_system/design_system.dart';
import 'identifying_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  XFile? _selectedFile;
  Uint8List? _previewBytes;
  bool _loading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 90);
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _selectedFile = file;
      _previewBytes = bytes;
    });
  }

  void _confirm() {
    if (_selectedFile == null || _loading) return;
    setState(() => _loading = true);
    context.read<AppState>().setCapturedImage(_selectedFile!);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const IdentifyingScreen()))
        .then((_) {
          if (mounted) setState(() => _loading = false);
        });
  }

  void _clearSelection() => setState(() {
    _selectedFile = null;
    _previewBytes = null;
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = _previewBytes != null;

    return Scaffold(
      backgroundColor: _Palette.background,
      appBar: AppBar(
        backgroundColor: _Palette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 72,
        leading: _BackButton(),
        title: Text(
          'Take Scrap Photo',
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
                  child: hasImage
                      ? _ImagePreview(
                          bytes: _previewBytes!,
                          onRetake: _clearSelection,
                        )
                      : _CameraArea(
                          onTapSource: (source) => _pickImage(source),
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
                  if (!hasImage) ...[
                    _ActionButton(
                      label: 'Take Photo',
                      icon: Icons.camera_alt_rounded,
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      outlined: true,
                      label: 'Choose Photo',
                      icon: Icons.photo_library_rounded,
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ] else ...[
                    _ActionButton(
                      label: _loading ? 'Checking…' : 'Identify Scrap',
                      icon: Icons.search_rounded,
                      onPressed: _loading ? () {} : _confirm,
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      outlined: true,
                      label: 'Retake Photo',
                      icon: Icons.camera_alt_rounded,
                      onPressed: _clearSelection,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraArea extends StatelessWidget {
  const _CameraArea({required this.onTapSource});
  final void Function(ImageSource) onTapSource;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          onTap: () => onTapSource(ImageSource.gallery),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Eyebrow('KABADIWALA CONNECT  /  PHOTO CAPTURE'),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 224,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Positioned.fill(
                          child: IgnorePointer(
                            child: RepaintBoundary(
                              child: CustomPaint(painter: _CityIllustration()),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                radius: 0.8,
                                colors: [
                                  const Color(0xFAFFFDF9),
                                  const Color(0x24FFFDF9),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const ExcludeSemantics(child: _ViewfinderFrame()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Keep the scrap clearly visible',
                  textAlign: TextAlign.center,
                  style: AppTypography.sectionHeading.copyWith(
                    color: _Palette.ink,
                    fontSize: 24,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Place one scrap item clearly in frame',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(color: _Palette.muted),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.photo_library_outlined,
                      color: _Palette.green,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Tap to choose a photo',
                        textAlign: TextAlign.center,
                        style: AppTypography.label.copyWith(
                          color: _Palette.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.bytes, required this.onRetake});
  final Uint8List bytes;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) => _Surface(
    color: const Color(0xFCFFFDF9),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Eyebrow('KABADIWALA CONNECT  /  PHOTO REVIEW'),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) => ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: (constraints.maxWidth * 0.8).clamp(260.0, 400.0),
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(
                    bytes,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    left: 12,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: TextButton.icon(
                        onPressed: onRetake,
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Change'),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xF2FFFDF9),
                          foregroundColor: _Palette.dark,
                          minimumSize: const Size(48, 48),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: _Palette.green,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Photo ready',
                style: AppTypography.sectionHeading.copyWith(
                  color: _Palette.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Review your photo, then identify your scrap.',
          style: AppTypography.body.copyWith(color: _Palette.muted),
        ),
      ],
    ),
  );
}

// Screen-local styling keeps other screens and shared components unchanged.
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
    this.outlined = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: outlined ? Colors.white : _Palette.green,
        foregroundColor: outlined ? _Palette.dark : Colors.white,
        minimumSize: const Size(48, 56),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        side: outlined
            ? const BorderSide(color: _Palette.border)
            : BorderSide.none,
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

class _BackButton extends StatelessWidget {
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

class _ViewfinderFrame extends StatelessWidget {
  const _ViewfinderFrame();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: CustomPaint(
        painter: _CornerPainter(),
        child: Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: _Palette.mint,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _Palette.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x090F3021),
                  blurRadius: 24,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 44,
              color: _Palette.green,
            ),
          ),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _Palette.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 28.0;
    final w = size.width;
    final h = size.height;
    canvas.drawLine(const Offset(0, len), Offset.zero, paint);
    canvas.drawLine(Offset.zero, const Offset(len, 0), paint);
    canvas.drawLine(Offset(w - len, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, len), paint);
    canvas.drawLine(Offset(0, h - len), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(len, h), paint);
    canvas.drawLine(Offset(w - len, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h - len), Offset(w, h), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
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
