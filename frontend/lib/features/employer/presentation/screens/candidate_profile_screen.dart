import 'package:flutter/material.dart';
import 'package:frontend/features/employer/data/employer_service.dart';
import 'package:frontend/features/credentials/data/credential_model.dart';
// Note: Using dynamic maps for Assessments for simplicity MVP

class CandidateProfileScreen extends StatefulWidget {
  final int userId;
  const CandidateProfileScreen({super.key, required this.userId});

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  final EmployerService _service = EmployerService();
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _service.getCandidateProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Candidate Profile')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
             return const Center(child: Text('No data.'));
          }

          final data = snapshot.data!;
          final user = data['user'];
          final creds = (data['credentials'] as List).map((x) => Credential.fromJson(x)).toList();
          final assessments = data['assessments'] as List; // UserAssessment JSONs

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
                  title: Text(user['email'], style: Theme.of(context).textTheme.headlineSmall),
                  subtitle: Text("ID: ${user['id']} • Joined: ${user['created_at'].toString().split('T')[0]}"),
                ),
                const Divider(),
                
                Text('Credentials', style: Theme.of(context).textTheme.titleLarge),
                if (creds.isEmpty) const Text("No credentials earned yet."),
                ...creds.map((c) => Card(
                  color: Colors.green.shade50,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.verified, color: Colors.green),
                    title: Text(c.skillName),
                    subtitle: Text("${c.level} • Score: ${c.score}%"),
                    trailing: const Icon(Icons.check_circle_outline),
                  ),
                )),
                
                const SizedBox(height: 16),
                const Divider(),
                Text('Assessment Activity', style: Theme.of(context).textTheme.titleLarge),
                if (assessments.isEmpty) const Text("No activity."),
                ...assessments.map((a) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      title: Text("Assessment ID: ${a['assessment_id']}"),
                      subtitle: Text("Status: ${a['status']} • Score: ${a['score'] ?? 'N/A'}"),
                      children: [
                         Padding(
                           padding: const EdgeInsets.all(16.0),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               const Text("Submitted Evidence/Data:", style: TextStyle(fontWeight: FontWeight.bold)),
                               const SizedBox(height: 8),
                               // Don't have full Question info here in MVP response unless we join tables deeper
                               // But we can show status timeframe
                               Text("Started: ${a['started_at']}"),
                               Text("Submitted: ${a['submitted_at']}"),
                             ],
                           ),
                         )
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
