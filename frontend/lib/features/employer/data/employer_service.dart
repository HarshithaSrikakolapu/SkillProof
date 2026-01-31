import 'package:frontend/core/api/api_client.dart';
import 'package:frontend/features/auth/data/user_model.dart';
import 'package:frontend/features/credentials/data/credential_model.dart';

class EmployerService {
  final ApiClient _client = ApiClient();

  Future<List<User>> searchCandidates(String query) async {
    try {
      final response = await _client.dio.get('/employer/candidates', queryParameters: {'q': query});
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => User.fromJson(e)).toList();
      }
    } catch (e) {
      throw Exception('Failed to load candidates: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> getCandidateProfile(int userId) async {
    try {
      final response = await _client.dio.get('/employer/candidates/$userId');
      if (response.statusCode == 200) {
        return response.data; // {user, credentials, assessments}
      }
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
    return {};
  }
}
