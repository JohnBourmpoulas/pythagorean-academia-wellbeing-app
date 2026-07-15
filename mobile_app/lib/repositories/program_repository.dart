import '../models/program.dart';
import '../services/api_service.dart';

class ProgramRepository {
  Future<List<Map<String, dynamic>>> getPrograms() async {
    final response = await ApiService.get(
      '/programs/admin_list.php',
      auth: true,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Could not load programs');
    }

    final list = response['programs'] ?? response['data'] ?? [];

    return List<Map<String, dynamic>>.from(list);
  }

  Future<List<Program>> getAllPrograms() async {
    final response = await ApiService.get(
      '/programs/list.php',
      auth: true,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Could not load programs');
    }

    final list = response['programs'] ?? response['data'] ?? [];

    return List<Map<String, dynamic>>.from(list)
        .map((item) => Program.fromJson(item))
        .toList();
  }

  Future<List<Program>> getAdminPrograms() async {
    final response = await ApiService.get(
      '/programs/admin_list.php',
      auth: true,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Could not load admin programs');
    }

    final list = response['programs'] ?? response['data'] ?? [];

    return List<Map<String, dynamic>>.from(list)
        .map((item) => Program.fromJson(item))
        .toList();
  }

  Future<bool> createProgram({
    required String title,
    required String shortTitle,
    required String description,
    required int durationWeeks,
    int? maxParticipants,
  }) async {
    final response = await ApiService.post(
      '/programs/create.php',
      {
        'title': title.trim(),
        'short_title': shortTitle.trim(),
        'description': description.trim(),
        'duration_weeks': durationWeeks,
        'max_participants': maxParticipants,
      },
      auth: true,
    );

    return response['success'] == true;
  }

  Future<bool> updateProgram({
    required int programId,
    required String title,
    required String shortTitle,
    required String description,
    required int durationWeeks,
    required String status,
    int? maxParticipants,
  }) async {
    final response = await ApiService.post(
      '/programs/update.php',
      {
        'program_id': programId,
        'title': title.trim(),
        'short_title': shortTitle.trim(),
        'description': description.trim(),
        'duration_weeks': durationWeeks,
        'max_participants': maxParticipants,
        'status': status.trim().toLowerCase(),
      },
      auth: true,
    );

    return response['success'] == true;
  }

  Future<bool> deleteProgram(int programId) async {
    final response = await ApiService.post(
      '/programs/delete.php',
      {
        'program_id': programId,
      },
      auth: true,
    );

    return response['success'] == true;
  }
}