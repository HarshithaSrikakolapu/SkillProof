import 'package:dio/dio.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:frontend/features/certificates/data/certificate_model.dart';

class CertificateService {
  final ApiClient _client = ApiClient();

  Future<List<Certificate>> getCertificates() async {
    try {
      final response = await _client.dio.get('/certificates/');
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => Certificate.fromJson(e)).toList();
      }
    } catch (e) {
      throw Exception('Failed to load certificates: $e');
    }
    return [];
  }

  Future<void> uploadCertificate({
    required String name,
    required String issuer,
    required String issueDate, // YYYY-MM-DD
    required String filePath,
  }) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        'name': name,
        'issuer': issuer,
        'issue_date': issueDate,
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      await _client.dio.post('/certificates/upload', data: formData);
    } catch (e) {
       if (e is DioException) {
         throw Exception(e.response?.data['message'] ?? 'Upload failed');
       }
       throw Exception('Upload failed: $e');
    }
  }

  Future<void> deleteCertificate(int id) async {
    await _client.dio.delete('/certificates/$id');
  }
}
