import '../models/program_application.dart';
import '../services/api_service.dart';

class ApplicationRepository {
  String? lastError;

  Future<bool> applyToProgram({
    required int programId,
  }) async {
    final response = await ApiService.post(
      '/applications/apply.php',
      {'program_id': programId},
      auth: true,
    );

    lastError = response['message']?.toString();
    return response['success'] == true;
  }

  Future<List<ProgramApplication>> getUserApplications() async {
    final response = await ApiService.get(
      '/applications/user_list.php',
      auth: true,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Could not load applications');
    }

    final list = response['applications'] ?? response['data'] ?? [];

    return List<Map<String, dynamic>>.from(list)
        .map((item) => ProgramApplication.fromJson(item))
        .toList();
  }

  Future<List<ProgramApplication>> getAdminApplications({
    String status = 'pending',
  }) async {
    final response = await ApiService.get(
      '/applications/admin_list.php?status=$status',
      auth: true,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Could not load applications');
    }

    final list = response['applications'] ?? response['data'] ?? [];

    return List<Map<String, dynamic>>.from(list)
        .map((item) => ProgramApplication.fromJson(item))
        .toList();
  }

  Future<bool> approveApplication({
    required int applicationId,
  }) async {
    final response = await ApiService.post(
      '/applications/approve.php',
      {'application_id': applicationId},
      auth: true,
    );

    lastError = response['message']?.toString();

    if (response['success'] != true) {
      throw Exception(lastError ?? 'Could not approve application');
    }

    return true;
  }

  Future<bool> rejectApplication({
    required int applicationId,
    String notes = '',
  }) async {
    final response = await ApiService.post(
      '/applications/reject.php',
      {
        'application_id': applicationId,
        'admin_notes': notes,
      },
      auth: true,
    );

    lastError = response['message']?.toString();

    if (response['success'] != true) {
      throw Exception(lastError ?? 'Could not reject application');
    }

    return true;
  }
}