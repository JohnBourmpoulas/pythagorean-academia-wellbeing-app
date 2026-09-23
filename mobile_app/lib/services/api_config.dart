class ApiConfig {
  // Android Emulator -> PHP server running on the Mac with:
  // cd ~/Desktop/pythagorean_api && php -S 0.0.0.0:8000
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String serverUrl = 'http://10.0.2.2:8000';

  // Production (restore these when deploying):
  // static const String baseUrl =
  //     'http://195.251.182.53/pythagorean_api/api';
  // static const String serverUrl =
  //     'http://195.251.182.53/pythagorean_api';
}
