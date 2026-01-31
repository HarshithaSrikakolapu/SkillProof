import 'package:dio/dio.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:frontend/features/auth/data/user_model.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<User?> login(String email, String password) async {
    try {
      final response = await _client.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        final user = User.fromJson(response.data['user']);
        await _client.storage.write(key: 'accessToken', value: token);
        return user;
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
    return null;
  }

  Future<User?> register(String email, String password, String role, String fullName) async {
    try {
      final response = await _client.dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'role': role,
        'full_name': fullName,
      });

      if (response.statusCode == 201) {
        return User.fromJson(response.data['user']);
      }
    } catch (e) {
       throw Exception('Registration failed: ${e.toString()}');
    }
    return null;
  }

  Future<void> logout() async {
    await _client.storage.delete(key: 'accessToken');
  }
}
