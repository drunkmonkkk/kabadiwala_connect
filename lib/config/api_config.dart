/// Central API configuration.
///
/// To point at a production server, change [baseUrl] here — nowhere else needs
/// to be edited.
class ApiConfig {
  ApiConfig._();

  /// Base URL of the FastAPI backend (no trailing slash).
  ///
  /// Local development:  http://127.0.0.1:8000
  /// Production:         https://your-backend.example.com
  static const String baseUrl = 'http://127.0.0.1:8000';

  /// Full URL for the /predict endpoint.
  static const String predictEndpoint = '$baseUrl/predict';

static const String pcbAnalysisEndpoint = '$baseUrl/predict-pcb';

  /// Request timeout duration.
  static const Duration requestTimeout = Duration(seconds: 30);
}
