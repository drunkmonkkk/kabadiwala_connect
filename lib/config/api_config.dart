import 'package:flutter/foundation.dart';

/// Central API configuration.
///
/// Automatically uses 10.0.2.2 on Android emulator to connect to host PC,
/// and 127.0.0.1 on Windows / Web / iOS.
class ApiConfig {
  ApiConfig._();

  /// Detect platform default host.
  static String get defaultHost {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  /// Optional override for physical devices or custom backend URL.
  static String customBaseUrl = '';

  /// Base URL of the FastAPI backend (no trailing slash).
  static String get baseUrl =>
      customBaseUrl.isNotEmpty ? customBaseUrl : defaultHost;

  /// Full URL for the /predict endpoint.
  static String get predictEndpoint => '$baseUrl/predict';

  /// Full URL for the specialized /predict-pcb endpoint.
  static String get pcbAnalysisEndpoint => '$baseUrl/predict-pcb';

  /// Request timeout duration.
  static const Duration requestTimeout = Duration(seconds: 30);
}
