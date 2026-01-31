import 'package:frontend/core/api/api_client.dart';
import 'package:frontend/features/skills/data/skill_model.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class AssessmentService {
  final ApiClient _client = ApiClient();

  Future<List<Skill>> getSkills() async {
    try {
      final response = await _client.dio.get('/skills/');
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => Skill.fromJson(e)).toList();
      }
    } catch (e) {
      throw Exception('Failed to load skills: $e');
    }
    return [];
  }

  Future<List<Assessment>> getAssessments(int skillId) async {
    try {
      final response = await _client.dio.get('/skills/$skillId/assessments');
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => Assessment.fromJson(e)).toList();
      }
    } catch (e) {
      throw Exception('Failed to load assessments: $e');
    }
    return [];
  }

  Future<int?> startAssessment(int assessmentId) async {
    try {
      final response = await _client.dio.post('/skills/assessments/$assessmentId/start');
      if (response.statusCode == 201) {
        return response.data['id']; // Return UserAssessmentID
      }
    } catch (e) {
      throw Exception('Failed to start assessment: $e');
    }
    return null;
  }
  
  Future<void> submitAssessment(int userAssessmentId, Map<String, dynamic> responses, {List<String>? filePaths}) async {
    try {
      final formData = FormData();
      
      // Add JSON data field
      final jsonMap = {
        'user_assessment_id': userAssessmentId,
        'responses': responses,
      };
      
      formData.fields.add(MapEntry('data', jsonEncode(jsonMap)));

      // Add Files
      if (filePaths != null) {
        for (int i = 0; i < filePaths.length; i++) {
          final path = filePaths[i];
          final fileName = path.split('/').last;
          formData.files.add(MapEntry(
            'evidence_$i', // Key for the file
            await MultipartFile.fromFile(path, filename: fileName)
          ));
        }
      }

      await _client.dio.post('/skills/assessments/submit', data: formData);
    } catch (e) {
      throw Exception('Failed to submit: $e');
    }
  }
}
