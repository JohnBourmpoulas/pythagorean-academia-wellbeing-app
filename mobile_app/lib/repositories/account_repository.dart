import '../services/api_service.dart';

class AccountRepository {
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await ApiService.post(
      '/auth/change_password.php',
      {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
      auth: true,
    );

    return response['success'] == true;
  }

  Future<bool> deleteAccount() async {
    final response = await ApiService.post(
      '/auth/delete_account.php',
      {},
      auth: true,
    );

    if (response['success'] == true) {
      await ApiService.clearToken();
      return true;
    }

    return false;
  }
}