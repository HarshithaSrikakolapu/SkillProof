import 'package:frontend/core/api/api_client.dart';
import 'package:frontend/features/credentials/data/credential_model.dart';

class CredentialService {
  final ApiClient _client = ApiClient();

  Future<List<Credential>> getMyCredentials() async {
    try {
      final response = await _client.dio.get('/credentials/me');
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => Credential.fromJson(e)).toList();
      }
    } catch (e) {
      throw Exception('Failed to load credentials: $e');
    }
    return [];
  }
}
