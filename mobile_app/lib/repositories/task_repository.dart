import '../services/api_service.dart';

class TaskRepository {
  Future<List<Map<String, dynamic>>> getProgramTasks({
    required int programId,
    int? day,
  }) async {
    final endpoint = day == null
        ? '/admin/tasks/list.php?program_id=$programId'
        : '/admin/tasks/list.php?program_id=$programId&day=$day';

    final response = await ApiService.get(endpoint, auth: true);

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Could not load tasks');
    }

    return List<Map<String, dynamic>>.from(
      response['tasks'] ?? response['data'] ?? [],
    );
  }

  Future<Map<String, dynamic>?> getTaskDetails(int id) async {
    final response = await ApiService.get(
      '/admin/tasks/details.php?id=$id',
      auth: true,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Could not load task');
    }

    return Map<String, dynamic>.from(response['task'] ?? {});
  }

  Future<bool> createTask(Map<String, dynamic> data) async {
    final response = await ApiService.post(
      '/admin/tasks/create.php',
      data,
      auth: true,
    );

    return response['success'] == true;
  }

  Future<bool> updateTask(Map<String, dynamic> data) async {
    final response = await ApiService.post(
      '/admin/tasks/update.php',
      data,
      auth: true,
    );

    return response['success'] == true;
  }

  Future<bool> deleteTask(int id) async {
    final response = await ApiService.post(
      '/admin/tasks/delete.php',
      {'id': id},
      auth: true,
    );

    return response['success'] == true;
  }
}