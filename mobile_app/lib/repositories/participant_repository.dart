import '../models/participant_dashboard.dart';
import '../services/api_service.dart';

class ParticipantRepository {
  Future<ParticipantDashboard?> getDashboard() async {
    final response = await ApiService.get(
      '/participant/dashboard.php',
      auth: true,
    );

    if (response['success'] != true) {
      return null;
    }

    return ParticipantDashboard.fromJson(
      Map<String, dynamic>.from(response['dashboard'] ?? {}),
    );
  }
}