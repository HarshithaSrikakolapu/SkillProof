import 'package:frontend/core/api/api_client.dart';

class AnalyticsService {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> getUserProgress() async {
    try {
      final response = await _client.dio.get('/analytics/user/me');
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      // ignore
    }
    return {'progress': [], 'credentials_count': 0};
  }

  Future<List<dynamic>> getSkillStats() async {
    try {
      final response = await _client.dio.get('/analytics/skills');
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      // ignore
    }
    return [];
  }
}
