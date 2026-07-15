class ApiConfig {
  // Android Emulator -> API endpoint
  static const String baseUrl = 'http://10.64.44.99:8000/api';

  // Android Emulator -> server root για εικόνες/uploads
  static const String serverUrl = 'http://10.64.44.99:8000';

// iOS Simulator / macOS app:
// static const String baseUrl = 'http://localhost:8000/api';
// static const String serverUrl = 'http://localhost:8000';

// Πραγματικό κινητό στο ίδιο Wi-Fi:
// static const String baseUrl = 'http://YOUR_MAC_IP:8000/api';
// static const String serverUrl = 'http://YOUR_MAC_IP:8000';

// Production:
// static const String baseUrl = 'https://your-domain.com/api';
// static const String serverUrl = 'https://your-domain.com';
}