// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_litert/flutter_litert.dart';
import 'package:image_picker/image_picker.dart';

// ── Public result types ──────────────────────────────────────────────────────

/// A single classification prediction from the model.
class ScrapPrediction {
  final String label;        // user-facing name, e.g. "Copper Wire"
  final String rawLabel;     // model label, e.g. "copper_wire"
  final double confidence;   // 0.0 – 1.0

  const ScrapPrediction({
    required this.label,
    required this.rawLabel,
    required this.confidence,
  });

  @override
  String toString() =>
      'ScrapPrediction($label, ${(confidence * 100).toStringAsFixed(1)}%)';
}

// ── Label map ────────────────────────────────────────────────────────────────

const Map<String, String> _labelToDisplay = {
  'copper_wire': 'Copper Wire',
  'aluminium': 'Aluminium',
  'brass': 'Brass',
  'iron': 'Iron',
  'pcb': 'PCB / E-Waste',
  'battery': 'Battery',
};

// ── Service ──────────────────────────────────────────────────────────────────

/// On-device TFLite image classifier for scrap material identification.
///
/// Model expectations:
///   Input  : [1, 224, 224, 3]  float32  (pixels normalised 0.0 - 1.0)
///   Output : [1, N]            float32  (softmax probabilities, N = label count)
///
/// Drop assets/ml/scrap_classifier.tflite and assets/ml/labels.txt into
/// the project, uncomment the asset line in pubspec.yaml, and call [initialize]
/// before the first inference.
class ScrapClassifierService {
  static const String _modelAsset = 'assets/ml/scrap_classifier.tflite';
  static const String _labelsAsset = 'assets/ml/labels.txt';

  /// Input image size the model expects (square).
  /// Change here if your model uses a different resolution.
  static const int inputSize = 224;

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _modelAvailable = false;
  String? _initError;

  bool get isAvailable => _modelAvailable;
  String? get initError => _initError;

  /// Load model and labels from assets. Safe to call multiple times.
  /// Returns false if the model file is absent or fails to load.
  Future<bool> initialize() async {
    if (_modelAvailable) return true;

    // Load labels
    try {
      final labelsStr = await rootBundle.loadString(_labelsAsset);
      _labels = labelsStr
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
    } catch (e) {
      _initError = 'Failed to load labels: $e';
      print('[ScrapClassifier] $_initError');
      return false;
    }

    // Load model
    try {
      _interpreter = await Interpreter.fromAsset(
        _modelAsset,
        options: InterpreterOptions()..threads = 2,
      );
      _interpreter!.allocateTensors();
      _modelAvailable = true;
      print('[ScrapClassifier] Model loaded. '
          'Input: ${_interpreter!.getInputTensor(0).shape}  '
          'Output: ${_interpreter!.getOutputTensor(0).shape}');
      return true;
    } catch (e) {
      _initError = 'Model unavailable: $e';
      print('[ScrapClassifier] $_initError');
      _interpreter?.close();
      _interpreter = null;
      return false;
    }
  }

  /// Run inference on the given [image].
  /// Throws [ScrapClassifierException] on any inference error.
  Future<ClassificationResult> classify(XFile image) async {
    if (!_modelAvailable || _interpreter == null) {
      throw ScrapClassifierException(
          'Model not available. Call initialize() first.');
    }

    // 1. Read bytes from the picked file
    final bytes = await image.readAsBytes();

    // 2. Decode and resize using dart:ui (works on native and web)
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: inputSize,
      targetHeight: inputSize,
    );
    final frame = await codec.getNextFrame();
    final uiImage = frame.image;

    // 3. Extract raw RGBA pixel bytes
    final byteData =
        await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    uiImage.dispose();
    if (byteData == null) {
      throw ScrapClassifierException(
          'Failed to extract pixel data from image.');
    }

    // 4. Convert RGBA -> RGB float32, normalised [0.0, 1.0]
    final pixelCount = inputSize * inputSize;
    final inputFlat = Float32List(pixelCount * 3);
    final rawPixels = byteData.buffer.asUint8List();
    for (var i = 0; i < pixelCount; i++) {
      final srcOffset = i * 4; // RGBA
      final dstOffset = i * 3; // RGB
      inputFlat[dstOffset]     = rawPixels[srcOffset]     / 255.0;
      inputFlat[dstOffset + 1] = rawPixels[srcOffset + 1] / 255.0;
      inputFlat[dstOffset + 2] = rawPixels[srcOffset + 2] / 255.0;
    }

    // 5. Reshape flat buffer to [1, H, W, 3] nested list
    final inputTensor = _reshape4D(inputFlat, 1, inputSize, inputSize, 3);

    // 6. Prepare output buffer [1, numClasses]
    final numClasses = _labels.length;
    final outputBuffer =
        List.generate(1, (_) => List<double>.filled(numClasses, 0.0));

    // 7. Run inference
    try {
      _interpreter!.run(inputTensor, outputBuffer);
    } catch (e) {
      throw ScrapClassifierException('Inference failed: $e');
    }

    // 8. Parse and rank results
    final scores = outputBuffer[0];
    final indexed = List.generate(numClasses, (i) => MapEntry(i, scores[i]))
      ..sort((a, b) => b.value.compareTo(a.value));

    final top3 = indexed.take(3).map((e) {
      final raw = e.key < _labels.length ? _labels[e.key] : 'unknown';
      return ScrapPrediction(
        rawLabel: raw,
        label: _labelToDisplay[raw] ?? raw,
        confidence: e.value.clamp(0.0, 1.0),
      );
    }).toList();

    return ClassificationResult(top: top3.first, top3: top3);
  }

  /// Reshape a flat Float32List to [batch, h, w, c] nested list.
  List<List<List<List<double>>>> _reshape4D(
    Float32List flat,
    int b,
    int h,
    int w,
    int c,
  ) {
    var idx = 0;
    return List.generate(b, (_) {
      return List.generate(h, (_) {
        return List.generate(w, (_) {
          return List.generate(c, (_) => flat[idx++].toDouble());
        });
      });
    });
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
    _modelAvailable = false;
  }
}

// ── Result container ─────────────────────────────────────────────────────────

class ClassificationResult {
  final ScrapPrediction top;
  final List<ScrapPrediction> top3;

  const ClassificationResult({required this.top, required this.top3});
}

// ── Exception ────────────────────────────────────────────────────────────────

class ScrapClassifierException implements Exception {
  final String message;
  const ScrapClassifierException(this.message);

  @override
  String toString() => 'ScrapClassifierException: $message';
}
