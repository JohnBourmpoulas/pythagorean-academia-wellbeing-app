import '../services/api_service.dart';

class AdminRepository {
  Future<Map<String, int>> getAdminDashboardStats() async {
    final response = await ApiService.get(
      '/admin/dashboard.php',
      auth: true,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Could not load dashboard stats');
    }

    final rawStats = response['stats'] ?? response['data'] ?? response;
    final stats = Map<String, dynamic>.from(rawStats);

    return {
      'total_users': int.tryParse(stats['total_users'].toString()) ?? 0,
      'pending_applications':
      int.tryParse(stats['pending_applications'].toString()) ?? 0,
      'active_programs': int.tryParse(stats['active_programs'].toString()) ?? 0,
    };
  }

  Future<Map<String, dynamic>> getProgramStatistics(int programId) async {
    final response = await ApiService.get(
      '/admin/program_statistics.php?program_id=$programId',
      auth: true,
    );

    if (response['success'] != true) {
      return {
        'total_enrolled': 0,
        'active_participants': 0,
        'completed': 0,
        'avg_satisfaction': '0.0/5.0',
        'completion_rate': 0,
        'avg_progress': 0,
      };
    }

    return Map<String, dynamic>.from(
      response['statistics'] ?? response['data'] ?? {},
    );
  }
}