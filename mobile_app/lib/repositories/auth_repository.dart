import '../models/app_user.dart';
import '../services/api_service.dart';

class AuthRepository {
  String? lastError;

  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      '/auth/login.php',
      {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    if (response['success'] != true) {
      lastError = response['message']?.toString() ?? 'Login failed';
      return null;
    }

    final token = response['token']?.toString();

    if (token == null || token.isEmpty) {
      lastError = 'Server did not return token';
      return null;
    }

    await ApiService.saveToken(token);

    return AppUser.fromJson(
      Map<String, dynamic>.from(response['user']),
    );
  }

  Future<bool> registerInterestedUser({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await ApiService.post(
      '/auth/register.php',
      {
        'full_name': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'phone': phone ?? '',
      },
    );

    if (response['success'] != true) {
      lastError = response['message']?.toString() ?? 'Registration failed';
      return false;
    }

    return true;
  }

  Future<AppUser?> me() async {
    final response = await ApiService.get(
      '/auth/me.php',
      auth: true,
    );

    if (response['success'] != true) {
      await ApiService.clearToken();
      return null;
    }

    return AppUser.fromJson(
      Map<String, dynamic>.from(response['user']),
    );
  }

  Future<void> logout() async {
    await ApiService.post(
      '/auth/logout.php',
      {},
      auth: true,
    );

    await ApiService.clearToken();
  }
}